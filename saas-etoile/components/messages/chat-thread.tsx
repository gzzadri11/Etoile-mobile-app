'use client';

import { useEffect, useState, useRef } from 'react';
import { createClient } from '@/lib/supabase/client';
import { getMessages, sendMessage as sendMessageAction } from '@/app/(dashboard)/messages/actions';
import type { Message } from '@/lib/types/database';
import { MessageBubble } from './message-bubble';
import { MessageInput } from './message-input';
import { toast } from 'sonner';

interface ChatThreadProps {
  conversationId: string;
  participant: {
    user_id: string;
    first_name: string | null;
    username: string | null;
    photo_url: string | null;
    specialty: string | null;
  };
  currentUserId: string;
}

/**
 * Epic 15 US-15.2 : Thread de conversation pour modal candidat
 * Similaire à MessageThread mais avec info participant
 */
export function ChatThread({ conversationId, participant, currentUserId }: ChatThreadProps) {
  const [messages, setMessages] = useState<Message[]>([]);
  const [loading, setLoading] = useState(true);
  const bottomRef = useRef<HTMLDivElement>(null);
  const supabase = createClient();

  // Load initial messages
  useEffect(() => {
    if (!conversationId) return;

    setLoading(true);
    getMessages(conversationId).then((msgs) => {
      setMessages(msgs);
      setLoading(false);
    });
  }, [conversationId]);

  // Realtime subscription
  useEffect(() => {
    if (!conversationId) return;

    const channel = supabase
      .channel(`chat-${conversationId}`)
      .on(
        'postgres_changes',
        {
          event: 'INSERT',
          schema: 'public',
          table: 'messages',
          filter: `conversation_id=eq.${conversationId}`,
        },
        (payload) => {
          const newMessage = payload.new as Message;
          setMessages((prev) => [...prev, newMessage]);
        }
      )
      .subscribe();

    return () => {
      channel.unsubscribe();
    };
  }, [conversationId, supabase]);

  // Auto-scroll to bottom
  useEffect(() => {
    bottomRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages.length]);

  const handleSendMessage = async (content: string) => {
    const result = await sendMessageAction(conversationId, content);
    if (!result.success) {
      toast.error(result.error || 'Échec envoi message');
    }
  };

  if (loading) {
    return (
      <div className="flex-1 flex items-center justify-center">
        <p className="text-muted-foreground">Chargement...</p>
      </div>
    );
  }

  return (
    <div className="flex-1 flex flex-col overflow-hidden">
      {/* Header with participant info */}
      <div className="border-b p-3 flex items-center gap-3">
        {participant.photo_url ? (
          <img
            src={participant.photo_url}
            alt={participant.first_name || 'Candidat'}
            className="w-10 h-10 rounded-full object-cover"
          />
        ) : (
          <div className="w-10 h-10 rounded-full bg-accent/10 flex items-center justify-center text-accent font-medium">
            {participant.first_name?.charAt(0)?.toUpperCase() || '?'}
          </div>
        )}
        <div>
          <p className="font-medium text-sm">{participant.first_name || 'Inconnu'}</p>
          {participant.specialty && (
            <p className="text-xs text-muted-foreground">{participant.specialty}</p>
          )}
        </div>
      </div>

      {/* Messages container */}
      <div className="flex-1 overflow-y-auto p-4 space-y-4">
        {messages.length === 0 ? (
          <div className="flex items-center justify-center h-full text-muted-foreground">
            <p className="text-sm">Aucun message pour le moment</p>
          </div>
        ) : (
          messages.map((msg) => <MessageBubble key={msg.id} message={msg} />)
        )}
        <div ref={bottomRef} />
      </div>

      {/* Input container */}
      <MessageInput onSend={handleSendMessage} />
    </div>
  );
}
