import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BlockRepository {
  final SupabaseClient _supabaseClient;

  BlockRepository({required SupabaseClient supabaseClient})
      : _supabaseClient = supabaseClient;

  String? get _currentUserId => _supabaseClient.auth.currentUser?.id;

  /// Block a user. Inserts into `blocks` table.
  Future<void> blockUser(String blockedUserId, {String? reason}) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('Non connecte');
    if (blockedUserId == userId) {
      throw Exception('Vous ne pouvez pas vous bloquer vous-meme');
    }

    debugPrint('[BlockRepository] Blocking user $blockedUserId');

    await _supabaseClient.from('blocks').upsert(
      {
        'blocker_id': userId,
        'blocked_id': blockedUserId,
        'reason': reason,
      },
      onConflict: 'blocker_id,blocked_id',
    );

    debugPrint('[BlockRepository] User $blockedUserId blocked');
  }

  /// Unblock a user.
  Future<void> unblockUser(String blockedUserId) async {
    final userId = _currentUserId;
    if (userId == null) return;

    debugPrint('[BlockRepository] Unblocking user $blockedUserId');

    await _supabaseClient
        .from('blocks')
        .delete()
        .eq('blocker_id', userId)
        .eq('blocked_id', blockedUserId);
  }

  /// Check if a user is blocked by the current user.
  Future<bool> isBlocked(String otherUserId) async {
    final userId = _currentUserId;
    if (userId == null) return false;

    final response = await _supabaseClient
        .from('blocks')
        .select('id')
        .eq('blocker_id', userId)
        .eq('blocked_id', otherUserId)
        .maybeSingle();

    return response != null;
  }

  /// Get the list of user IDs blocked by the current user.
  Future<List<String>> getBlockedUserIds() async {
    final userId = _currentUserId;
    if (userId == null) return [];

    final response = await _supabaseClient
        .from('blocks')
        .select('blocked_id')
        .eq('blocker_id', userId);

    return (response as List)
        .map((row) => row['blocked_id'] as String)
        .toList();
  }
}
