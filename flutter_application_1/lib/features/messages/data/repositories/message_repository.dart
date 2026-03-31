library;

/// Repository des operations sur les messages et conversations via Supabase.

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/message_model.dart';

/// Acces aux messages : chargement, envoi, temps reel et enrichissement des conversations.
class MessageRepository {
  final SupabaseClient _supabaseClient;

  MessageRepository({required SupabaseClient supabaseClient})
      : _supabaseClient = supabaseClient;

  /// Get current user's ID
  String? get currentUserId => _supabaseClient.auth.currentUser?.id;

  /// Get messages for a conversation
  Future<List<Message>> getMessages(String conversationId) async {
    try {
      final response = await _supabaseClient
          .from('messages')
          .select()
          .eq('conversation_id', conversationId)
          .order('created_at', ascending: true);

      final messages = (response as List)
          .map((json) => Message.fromJson(json as Map<String, dynamic>))
          .toList();

      return messages;
    } catch (e) {
      debugPrint('[Messages] Error loading messages: $e');
      return [];
    }
  }

  /// Send a message
  Future<Message> sendMessage({
    required String conversationId,
    required String content,
  }) async {
    final senderId = currentUserId;
    if (senderId == null) {
      throw Exception('Utilisateur non connecte');
    }

    final response = await _supabaseClient
        .from('messages')
        .insert({
          'conversation_id': conversationId,
          'sender_id': senderId,
          'content': content,
          'content_type': 'text',
        })
        .select()
        .single();

    // Update conversation last message (non-critical, don't block message display)
    try {
      final preview = content.length > 100 ? '${content.substring(0, 100)}...' : content;
      await _supabaseClient.from('conversations').update({
        'last_message_at': DateTime.now().toIso8601String(),
        'last_message_preview': preview,
      }).eq('id', conversationId);
    } catch (e) {
      debugPrint('[Messages] Error updating conversation preview: $e');
    }

    return Message.fromJson(response);
  }

  /// Mark messages as read
  Future<void> markMessagesAsRead(String conversationId) async {
    final userId = currentUserId;
    if (userId == null) return;

    try {
      // Get conversation to determine which read field to update
      final conversation = await _supabaseClient
          .from('conversations')
          .select()
          .eq('id', conversationId)
          .maybeSingle();

      if (conversation == null) return;

      final isParticipant1 = conversation['participant_1'] == userId;
      final field = isParticipant1 ? 'participant_1_read_at' : 'participant_2_read_at';

      await _supabaseClient.from('conversations').update({
        field: DateTime.now().toIso8601String(),
      }).eq('id', conversationId);
    } catch (e) {
      debugPrint('[Messages] Error marking as read: $e');
    }
  }

  /// Subscribe to new messages in a conversation (realtime)
  RealtimeChannel subscribeToMessages(
    String conversationId,
    void Function(Message) onMessage,
  ) {
    return _supabaseClient
        .channel('messages:$conversationId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'conversation_id',
            value: conversationId,
          ),
          callback: (payload) {
            final message = Message.fromJson(payload.newRecord);
            onMessage(message);
          },
        )
        .subscribe();
  }

  /// Unsubscribe from messages
  Future<void> unsubscribeFromMessages(RealtimeChannel channel) async {
    await _supabaseClient.removeChannel(channel);
  }

  /// Get all conversations for current user with participant info
  Future<List<Conversation>> getConversations() async {
    final userId = currentUserId;
    if (userId == null) {
      throw Exception('Utilisateur non connecté');
    }

    try {
      // Get conversations where user is participant_1
      final conv1 = await _supabaseClient
          .from('conversations')
          .select()
          .eq('participant_1', userId);

      // Get conversations where user is participant_2
      final conv2 = await _supabaseClient
          .from('conversations')
          .select()
          .eq('participant_2', userId);

      final allConvData = <Map<String, dynamic>>[
        ...List<Map<String, dynamic>>.from(conv1),
        ...List<Map<String, dynamic>>.from(conv2),
      ];

      if (allConvData.isEmpty) {
        return [];
      }

      // Convert to Conversation objects and enrich
      final conversations = <Conversation>[];
      for (final data in allConvData) {
        try {
          final conv = Conversation.fromJson(data);
          final otherUserId = conv.getOtherParticipantId(userId);
          final enriched = await _enrichConversation(conv, otherUserId);
          conversations.add(enriched);
        } catch (e) {
          debugPrint('[Messages] Error processing conversation ${data['id']}: $e');
          // Continue with other conversations
        }
      }

      // Sort by last_message_at descending
      conversations.sort((a, b) {
        final aTime = a.lastMessageAt ?? a.createdAt;
        final bTime = b.lastMessageAt ?? b.createdAt;
        return bTime.compareTo(aTime);
      });

      return conversations;
    } on PostgrestException catch (e) {
      debugPrint('[Messages] Supabase error: ${e.message} (code: ${e.code})');
      throw Exception('Erreur de base de données: ${e.message}');
    } catch (e) {
      debugPrint('[Messages] Error loading conversations: $e');
      rethrow;
    }
  }

  /// Get a single conversation with participant info
  Future<Conversation?> getConversation(String conversationId) async {
    final userId = currentUserId;
    if (userId == null) return null;

    try {
      final response = await _supabaseClient
          .from('conversations')
          .select()
          .eq('id', conversationId)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      final conversation = Conversation.fromJson(response);
      final otherUserId = conversation.getOtherParticipantId(userId);

      return _enrichConversation(conversation, otherUserId);
    } catch (e) {
      debugPrint('[Messages] Error loading conversation: $e');
      return null;
    }
  }

  /// Enrich conversation with other user's profile info
  Future<Conversation> _enrichConversation(
    Conversation conversation,
    String otherUserId,
  ) async {
    try {
      Conversation enriched;

      // Try seeker profile first
      final seekerProfile = await _supabaseClient
          .from('seeker_profiles')
          .select()
          .eq('user_id', otherUserId)
          .maybeSingle();

      if (seekerProfile != null) {
        final firstName = seekerProfile['first_name'] as String? ?? '';
        final lastName = seekerProfile['last_name'] as String? ?? '';
        final name = '$firstName $lastName'.trim();
        enriched = conversation.copyWith(
          otherUserName: name.isNotEmpty ? name : 'Utilisateur',
          otherUserAvatar: seekerProfile['photo_url'] as String?,
          otherUserTitle: seekerProfile['bio'] as String?,
          isOtherUserVerified: false,
          otherUserRole: 'seeker',
        );
      } else {
        // Try recruiter profile
        final recruiterProfile = await _supabaseClient
            .from('recruiter_profiles')
            .select()
            .eq('user_id', otherUserId)
            .maybeSingle();

        if (recruiterProfile != null) {
          enriched = conversation.copyWith(
            otherUserName: recruiterProfile['company_name'] as String? ?? 'Entreprise',
            otherUserAvatar: recruiterProfile['logo_url'] as String?,
            otherUserTitle: recruiterProfile['sector'] as String?,
            isOtherUserVerified: recruiterProfile['verification_status'] == 'verified',
            otherUserRole: 'recruiter',
          );
        } else {
          enriched = conversation.copyWith(otherUserName: 'Utilisateur');
        }
      }

      // Enrich with video info if conversation is linked to an offer
      return _enrichWithVideoInfo(enriched);
    } catch (e) {
      debugPrint('[Messages] Error enriching conversation: $e');
      return conversation.copyWith(otherUserName: 'Utilisateur');
    }
  }

  /// Enrich conversation with linked video/offer info
  Future<Conversation> _enrichWithVideoInfo(Conversation conversation) async {
    if (conversation.videoId == null) return conversation;
    try {
      final video = await _supabaseClient
          .from('videos')
          .select('title, type, thumbnail_url')
          .eq('id', conversation.videoId!)
          .maybeSingle();

      if (video != null) {
        return conversation.copyWith(
          videoTitle: video['title'] as String?,
          videoType: video['type'] as String?,
          videoThumbnailUrl: video['thumbnail_url'] as String?,
        );
      }
    } catch (e) {
      debugPrint('[Messages] Error enriching video info: $e');
    }
    return conversation;
  }
}
