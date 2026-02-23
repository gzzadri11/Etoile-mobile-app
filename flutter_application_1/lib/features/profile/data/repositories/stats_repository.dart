import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/video_stats.dart';

/// Repository for loading video statistics from video_views table
///
/// RLS policy on video_views ensures only video owners can read views,
/// so all queries automatically filter to the current user's videos.
class StatsRepository {
  final SupabaseClient _supabaseClient;

  StatsRepository({required SupabaseClient supabaseClient})
      : _supabaseClient = supabaseClient;

  String? get _currentUserId => _supabaseClient.auth.currentUser?.id;

  /// Check if the current user has premium status
  Future<bool> isPremium() async {
    final userId = _currentUserId;
    if (userId == null) return false;

    try {
      final response = await _supabaseClient
          .from('users')
          .select('is_premium')
          .eq('id', userId)
          .maybeSingle();

      return response?['is_premium'] == true;
    } catch (e) {
      debugPrint('[StatsRepository] Error checking premium: $e');
      return false;
    }
  }

  /// Get video statistics for the current user
  ///
  /// Uses RLS on video_views: only returns views for owned videos.
  Future<VideoStats> getStats() async {
    try {
      // RLS filters to current user's videos automatically
      final views = await _supabaseClient
          .from('video_views')
          .select('viewer_id, created_at');

      if (views.isEmpty) return VideoStats.empty();

      final totalViews = views.length;

      // Unique viewers (distinct viewer_id, excluding nulls)
      final uniqueViewers = views
          .map((r) => r['viewer_id'] as String?)
          .where((id) => id != null)
          .toSet()
          .length;

      // Weekly trend
      final now = DateTime.now().toUtc();
      final thisWeekStart = now.subtract(const Duration(days: 7));
      final lastWeekStart = now.subtract(const Duration(days: 14));

      int thisWeekViews = 0;
      int lastWeekViews = 0;

      for (final view in views) {
        final createdAt = DateTime.parse(view['created_at'] as String);
        if (createdAt.isAfter(thisWeekStart)) {
          thisWeekViews++;
        } else if (createdAt.isAfter(lastWeekStart)) {
          lastWeekViews++;
        }
      }

      double trendPercent = 0;
      if (lastWeekViews > 0) {
        trendPercent =
            ((thisWeekViews - lastWeekViews) / lastWeekViews) * 100;
      } else if (thisWeekViews > 0) {
        trendPercent = 100;
      }

      return VideoStats(
        totalViews: totalViews,
        uniqueViewers: uniqueViewers,
        thisWeekViews: thisWeekViews,
        lastWeekViews: lastWeekViews,
        trendPercent: trendPercent,
      );
    } catch (e) {
      debugPrint('[StatsRepository] Error loading stats: $e');
      return VideoStats.empty();
    }
  }
}
