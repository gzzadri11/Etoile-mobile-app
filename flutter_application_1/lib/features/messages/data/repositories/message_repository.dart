import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/message_model.dart';

/// Repository for message operations with Supabase
class MessageRepository {
  final SupabaseClient _supabaseClient;

  MessageRepository({required SupabaseClient supabaseClient})
      : _supabaseClient = supabaseClient;

  /// Get current user's ID
  String? get currentUserId => _supabaseClient.auth.currentUser?.id;

  /// Get messages for a conversation
  Future<List<Message>> getMessages(String conversationId) async {
    try {
      debugPrint('[Messages] Loading messages for: $conversationId');
      final response = await _supabaseClient
          .from('messages')
          .select()
          .eq('conversation_id', conversationId)
          .order('created_at', ascending: true);

      final messages = (response as List)
          .map((json) => Message.fromJson(json as Map<String, dynamic>))
          .toList();

      debugPrint('[Messages] Loaded ${messages.length} messages');
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

    debugPrint('[Messages] Sending message to $conversationId');

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

    // Update conversation last message
    final preview = content.length > 100 ? '${content.substring(0, 100)}...' : content;
    await _supabaseClient.from('conversations').update({
      'last_message_at': DateTime.now().toIso8601String(),
      'last_message_preview': preview,
    }).eq('id', conversationId);

    debugPrint('[Messages] Message sent successfully');
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
    debugPrint('[Messages] Subscribing to realtime for: $conversationId');
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
            debugPrint('[Messages] Realtime message received');
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
      debugPrint('[Messages] No user ID, returning empty list');
      throw Exception('Utilisateur non connecté');
    }

    debugPrint('[Messages] Loading conversations for user: $userId');

    try {
      // Get conversations where user is participant_1
      debugPrint('[Messages] Fetching conversations as participant_1...');
      final conv1 = await _supabaseClient
          .from('conversations')
          .select()
          .eq('participant_1', userId);
      debugPrint('[Messages] Found ${(conv1 as List).length} as participant_1');

      // Get conversations where user is participant_2
      debugPrint('[Messages] Fetching conversations as participant_2...');
      final conv2 = await _supabaseClient
          .from('conversations')
          .select()
          .eq('participant_2', userId);
      debugPrint('[Messages] Found ${(conv2 as List).length} as participant_2');

      final allConvData = <Map<String, dynamic>>[
        ...List<Map<String, dynamic>>.from(conv1),
        ...List<Map<String, dynamic>>.from(conv2),
      ];

      debugPrint('[Messages] Total conversations: ${allConvData.length}');

      if (allConvData.isEmpty) {
        debugPrint('[Messages] No conversations found for user');
        return [];
      }

      // Convert to Conversation objects and enrich
      final conversations = <Conversation>[];
      for (final data in allConvData) {
        try {
          debugPrint('[Messages] Processing conversation: ${data['id']}');
          final conv = Conversation.fromJson(data);
          final otherUserId = conv.getOtherParticipantId(userId);
          debugPrint('[Messages] Other user: $otherUserId');
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

      debugPrint('[Messages] Returning ${conversations.length} enriched conversations');
      return conversations;
    } on PostgrestException catch (e) {
      debugPrint('[Messages] Supabase error: ${e.message}');
      debugPrint('[Messages] Error code: ${e.code}');
      debugPrint('[Messages] Error details: ${e.details}');
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
      debugPrint('[Messages] Loading conversation: $conversationId');
      final response = await _supabaseClient
          .from('conversations')
          .select()
          .eq('id', conversationId)
          .maybeSingle();

      if (response == null) {
        debugPrint('[Messages] Conversation not found');
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
        return conversation.copyWith(
          otherUserName: name.isNotEmpty ? name : 'Utilisateur',
          otherUserTitle: seekerProfile['bio'] as String?,
          isOtherUserVerified: false,
        );
      }

      // Try recruiter profile
      final recruiterProfile = await _supabaseClient
          .from('recruiter_profiles')
          .select()
          .eq('user_id', otherUserId)
          .maybeSingle();

      if (recruiterProfile != null) {
        return conversation.copyWith(
          otherUserName: recruiterProfile['company_name'] as String? ?? 'Entreprise',
          otherUserAvatar: recruiterProfile['logo_url'] as String?,
          otherUserTitle: recruiterProfile['sector'] as String?,
          isOtherUserVerified: recruiterProfile['verification_status'] == 'verified',
        );
      }

      return conversation.copyWith(otherUserName: 'Utilisateur');
    } catch (e) {
      debugPrint('[Messages] Error enriching conversation: $e');
      return conversation.copyWith(otherUserName: 'Utilisateur');
    }
  }
}
