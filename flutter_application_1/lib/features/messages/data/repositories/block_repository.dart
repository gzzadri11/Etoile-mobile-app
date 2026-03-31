library;

/// Repository pour le blocage d'utilisateurs via Supabase.

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Acces aux operations de blocage/deblocage d'utilisateurs.
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

  /// Get blocked users with display details (name, date).
  Future<List<Map<String, dynamic>>> getBlockedUsersWithDetails() async {
    final userId = _currentUserId;
    if (userId == null) return [];

    final response = await _supabaseClient
        .from('blocks')
        .select('blocked_id, created_at')
        .eq('blocker_id', userId)
        .order('created_at', ascending: false);

    final blocks = response as List;
    if (blocks.isEmpty) return [];

    final blockedIds = blocks.map((b) => b['blocked_id'] as String).toList();

    // Try to get names from seeker_profiles
    final seekers = await _supabaseClient
        .from('seeker_profiles')
        .select('user_id, first_name, last_name')
        .inFilter('user_id', blockedIds);

    // Try to get names from recruiter_profiles
    final recruiters = await _supabaseClient
        .from('recruiter_profiles')
        .select('user_id, company_name')
        .inFilter('user_id', blockedIds);

    final nameMap = <String, String>{};
    for (final s in seekers as List) {
      nameMap[s['user_id']] =
          '${s['first_name'] ?? ''} ${s['last_name'] ?? ''}'.trim();
    }
    for (final r in recruiters as List) {
      nameMap[r['user_id']] = r['company_name'] ?? 'Recruteur';
    }

    return blocks.map((b) {
      final id = b['blocked_id'] as String;
      return {
        'userId': id,
        'name': nameMap[id] ?? 'Utilisateur',
        'blockedAt': b['created_at'] as String,
      };
    }).toList();
  }
}
