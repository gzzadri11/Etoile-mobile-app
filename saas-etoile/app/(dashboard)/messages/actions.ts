'use server';

import { createClient } from '@/lib/supabase/server';
import type { ConversationWithUnread } from '@/lib/types/database';

/**
 * Récupère toutes les conversations du recruteur connecté
 * Triées par last_message_at DESC avec compteur non-lus
 */
export async function getConversations(): Promise<ConversationWithUnread[]> {
  try {
    const supabase = await createClient();

    const { data: { user } } = await supabase.auth.getUser();
    if (!user) {
      return [];
    }

    // Step 1: Fetch conversations where recruiter is participant_1
    // (In our code, recruiter is ALWAYS participant_1, seeker is ALWAYS participant_2)
    const { data: conversations, error: convError } = await supabase
      .from('conversations')
      .select('*')
      .eq('participant_1', user.id)
      .order('last_message_at', { ascending: false, nullsFirst: false });

    if (convError) {
      console.error('Error fetching conversations:', convError);
      return [];
    }

    if (!conversations || conversations.length === 0) {
      return [];
    }

    // Step 2: Fetch seeker profiles for all participant_2 (seekers)
    const seekerIds = conversations.map(c => c.participant_2);
    const { data: seekers, error: seekersError } = await supabase
      .from('seeker_profiles')
      .select('user_id, first_name, username, photo_url, specialty')
      .in('user_id', seekerIds);

    if (seekersError) {
      console.error('Error fetching seeker profiles:', seekersError);
      // Continue without seeker data rather than failing completely
    }

    // Step 3: Fetch unread message counts for each conversation
    const conversationIds = conversations.map(c => c.id);
    const { data: unreadCounts, error: unreadError } = await supabase
      .from('messages')
      .select('conversation_id')
      .in('conversation_id', conversationIds)
      .eq('is_read', false)
      .neq('sender_id', user.id);

    if (unreadError) {
      console.error('Error fetching unread counts:', unreadError);
    }

    // Count unread messages per conversation
    const unreadMap = (unreadCounts || []).reduce((acc, msg) => {
      acc[msg.conversation_id] = (acc[msg.conversation_id] || 0) + 1;
      return acc;
    }, {} as Record<string, number>);

    // Step 4: Merge data
    const seekerMap = (seekers || []).reduce((acc, seeker) => {
      acc[seeker.user_id] = seeker;
      return acc;
    }, {} as Record<string, any>);

    const result: ConversationWithUnread[] = conversations.map(conv => ({
      ...conv,
      unread_count: unreadMap[conv.id] || 0,
      participant: seekerMap[conv.participant_2] || {
        user_id: conv.participant_2,
        first_name: null,
        username: null,
        photo_url: null,
        specialty: null,
      },
    }));

    return result;
  } catch (error) {
    console.error('Unexpected error in getConversations:', error);
    return [];
  }
}

/**
 * Envoie un message dans une conversation
 */
export async function sendMessage(
  conversationId: string,
  content: string
): Promise<{ success: boolean; error?: string }> {
  try {
    const supabase = await createClient();

    const { data: { user } } = await supabase.auth.getUser();
    if (!user) {
      return { success: false, error: 'Not authenticated' };
    }

    // Valider que le contenu n'est pas vide
    if (!content.trim()) {
      return { success: false, error: 'Message cannot be empty' };
    }

    // Insert message
    const { error } = await supabase
      .from('messages')
      .insert({
        conversation_id: conversationId,
        sender_id: user.id,
        content: content.trim(),
        content_type: 'text',
      });

    if (error) {
      console.error('Error sending message:', error);
      return { success: false, error: error.message };
    }

    // Update conversation last_message_at + preview
    await supabase
      .from('conversations')
      .update({
        last_message_at: new Date().toISOString(),
        last_message_preview: content.trim().slice(0, 100),
      })
      .eq('id', conversationId);

    return { success: true };
  } catch (error) {
    console.error('Unexpected error in sendMessage:', error);
    return { success: false, error: 'Failed to send message' };
  }
}

/**
 * Marque tous les messages d'une conversation comme lus
 */
export async function markConversationAsRead(
  conversationId: string
): Promise<{ success: boolean }> {
  try {
    const supabase = await createClient();

    const { data: { user } } = await supabase.auth.getUser();
    if (!user) {
      return { success: false };
    }

    // Marquer tous les messages non-lus comme lus
    const { error: messagesError } = await supabase
      .from('messages')
      .update({
        is_read: true,
        read_at: new Date().toISOString(),
      })
      .eq('conversation_id', conversationId)
      .eq('is_read', false)
      .neq('sender_id', user.id);  // Pas ses propres messages

    if (messagesError) {
      console.error('Error marking messages as read:', messagesError);
      return { success: false };
    }

    // Update conversation read timestamp
    const { error: convError } = await supabase
      .from('conversations')
      .update({
        participant_1_read_at: new Date().toISOString(),
      })
      .eq('id', conversationId)
      .eq('participant_1', user.id);

    await supabase
      .from('conversations')
      .update({
        participant_2_read_at: new Date().toISOString(),
      })
      .eq('id', conversationId)
      .eq('participant_2', user.id);

    if (convError) {
      console.error('Error updating conversation read status:', convError);
    }

    return { success: true };
  } catch (error) {
    console.error('Unexpected error in markConversationAsRead:', error);
    return { success: false };
  }
}

/**
 * Récupère ou crée une conversation avec un chercheur pour une offre
 * Utilisé depuis le modal candidat
 */
export async function getConversationBySeeker(
  seekerId: string,
  videoId: string
): Promise<{ conversationId: string | null; error?: string }> {
  try {
    const supabase = await createClient();

    const { data: { user } } = await supabase.auth.getUser();
    if (!user) {
      return { conversationId: null, error: 'Not authenticated' };
    }

    // Chercher conversation existante
    const { data: existing } = await supabase
      .from('conversations')
      .select('id')
      .or(`and(participant_1.eq.${user.id},participant_2.eq.${seekerId}),and(participant_1.eq.${seekerId},participant_2.eq.${user.id})`)
      .eq('video_id', videoId)
      .maybeSingle();

    if (existing) {
      return { conversationId: existing.id };
    }

    // Créer nouvelle conversation
    const { data: newConv, error } = await supabase
      .from('conversations')
      .insert({
        participant_1: user.id,
        participant_2: seekerId,
        video_id: videoId,
      })
      .select('id')
      .single();

    if (error) {
      console.error('Error creating conversation:', error);
      return { conversationId: null, error: error.message };
    }

    return { conversationId: newConv.id };
  } catch (error) {
    console.error('Unexpected error in getConversationBySeeker:', error);
    return { conversationId: null, error: 'Failed to get conversation' };
  }
}

/**
 * Récupère les messages d'une conversation
 */
export async function getMessages(conversationId: string) {
  try {
    const supabase = await createClient();

    const { data, error } = await supabase
      .from('messages')
      .select('*')
      .eq('conversation_id', conversationId)
      .order('created_at', { ascending: true });

    if (error) {
      console.error('Error fetching messages:', error);
      return [];
    }

    return data || [];
  } catch (error) {
    console.error('Unexpected error in getMessages:', error);
    return [];
  }
}

/**
 * Crée une nouvelle conversation avec un premier message
 * Utilisé depuis le modal candidat pour le premier contact
 */
export async function createConversation(
  seekerId: string,
  videoId: string,
  firstMessage: string
): Promise<{ success: boolean; conversationId?: string; error?: string }> {
  try {
    const supabase = await createClient();

    const { data: { user } } = await supabase.auth.getUser();
    if (!user) {
      return { success: false, error: 'Not authenticated' };
    }

    // Valider que le message n'est pas vide
    if (!firstMessage.trim()) {
      return { success: false, error: 'Message cannot be empty' };
    }

    // Créer ou récupérer conversation
    const { data: existingConv } = await supabase
      .from('conversations')
      .select('id')
      .or(`and(participant_1.eq.${user.id},participant_2.eq.${seekerId}),and(participant_1.eq.${seekerId},participant_2.eq.${user.id})`)
      .eq('video_id', videoId)
      .maybeSingle();

    let conversationId: string;

    if (existingConv) {
      conversationId = existingConv.id;
    } else {
      // Créer nouvelle conversation
      const { data: newConv, error: convError } = await supabase
        .from('conversations')
        .insert({
          participant_1: user.id,
          participant_2: seekerId,
          video_id: videoId,
        })
        .select('id')
        .single();

      if (convError || !newConv) {
        console.error('Error creating conversation:', convError);
        return { success: false, error: convError?.message || 'Failed to create conversation' };
      }

      conversationId = newConv.id;
    }

    // Envoyer le premier message
    const { error: msgError } = await supabase
      .from('messages')
      .insert({
        conversation_id: conversationId,
        sender_id: user.id,
        content: firstMessage.trim(),
        content_type: 'text',
      });

    if (msgError) {
      console.error('Error sending first message:', msgError);
      return { success: false, error: msgError.message };
    }

    // Update conversation metadata
    await supabase
      .from('conversations')
      .update({
        last_message_at: new Date().toISOString(),
        last_message_preview: firstMessage.trim().slice(0, 100),
      })
      .eq('id', conversationId);

    // Update application status to "contacted"
    await supabase
      .from('applications')
      .update({
        status: 'contacted',
      })
      .eq('seeker_id', seekerId)
      .eq('video_id', videoId);

    return { success: true, conversationId };
  } catch (error) {
    console.error('Unexpected error in createConversation:', error);
    return { success: false, error: 'Failed to create conversation' };
  }
}
