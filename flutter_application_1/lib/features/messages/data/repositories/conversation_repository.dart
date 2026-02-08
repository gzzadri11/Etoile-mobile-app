import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repository for conversation operations with Supabase
class ConversationRepository {
  final SupabaseClient _supabaseClient;

  ConversationRepository({required SupabaseClient supabaseClient})
      : _supabaseClient = supabaseClient;

  /// Get current user's ID
  String? get currentUserId => _supabaseClient.auth.currentUser?.id;

  /// Find or create a conversation between current user and another user
  Future<String> findOrCreateConversation({
    required String otherUserId,
    String? videoId,
  }) async {
    final myUserId = currentUserId;
    if (myUserId == null) {
      throw Exception('Utilisateur non connecte');
    }

    if (myUserId == otherUserId) {
      throw Exception('Vous ne pouvez pas vous envoyer un message');
    }

    debugPrint('[Conversation] Finding conversation: $myUserId <-> $otherUserId');

    try {
      // Check if conversation already exists - try both directions
      final existing1 = await _supabaseClient
          .from('conversations')
          .select('id')
          .eq('participant_1', myUserId)
          .eq('participant_2', otherUserId)
          .maybeSingle();

      if (existing1 != null) {
        debugPrint('[Conversation] Found existing (direction 1): ${existing1['id']}');
        return existing1['id'] as String;
      }

      final existing2 = await _supabaseClient
          .from('conversations')
          .select('id')
          .eq('participant_1', otherUserId)
          .eq('participant_2', myUserId)
          .maybeSingle();

      if (existing2 != null) {
        debugPrint('[Conversation] Found existing (direction 2): ${existing2['id']}');
        return existing2['id'] as String;
      }

      // Create new conversation
      debugPrint('[Conversation] Creating new conversation...');
      final newConversation = await _supabaseClient
          .from('conversations')
          .insert({
            'participant_1': myUserId,
            'participant_2': otherUserId,
            'video_id': videoId,
          })
          .select('id')
          .single();

      debugPrint('[Conversation] Created: ${newConversation['id']}');
      return newConversation['id'] as String;
    } catch (e) {
      debugPrint('[Conversation] Error: $e');
      rethrow;
    }
  }

  /// Get conversation by ID
  Future<Map<String, dynamic>?> getConversation(String conversationId) async {
    try {
      final conversation = await _supabaseClient
          .from('conversations')
          .select()
          .eq('id', conversationId)
          .maybeSingle();
      return conversation;
    } catch (e) {
      debugPrint('[Conversation] Error getting conversation: $e');
      return null;
    }
  }

  /// Get all conversations for current user
  Future<List<Map<String, dynamic>>> getMyConversations() async {
    final myUserId = currentUserId;
    if (myUserId == null) return [];

    try {
      // Get conversations where user is participant_1
      final conv1 = await _supabaseClient
          .from('conversations')
          .select()
          .eq('participant_1', myUserId);

      // Get conversations where user is participant_2
      final conv2 = await _supabaseClient
          .from('conversations')
          .select()
          .eq('participant_2', myUserId);

      final allConversations = <Map<String, dynamic>>[
        ...List<Map<String, dynamic>>.from(conv1),
        ...List<Map<String, dynamic>>.from(conv2),
      ];

      // Sort by last_message_at descending
      allConversations.sort((a, b) {
        final aTime = a['last_message_at'] ?? a['created_at'];
        final bTime = b['last_message_at'] ?? b['created_at'];
        if (aTime == null && bTime == null) return 0;
        if (aTime == null) return 1;
        if (bTime == null) return -1;
        return bTime.compareTo(aTime);
      });

      return allConversations;
    } catch (e) {
      debugPrint('[Conversation] Error getting conversations: $e');
      return [];
    }
  }
}
