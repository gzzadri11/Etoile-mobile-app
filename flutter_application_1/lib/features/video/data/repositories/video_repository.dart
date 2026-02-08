import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/video_model.dart';

/// Repository for video operations with Supabase
class VideoRepository {
  final SupabaseClient _supabaseClient;

  VideoRepository({required SupabaseClient supabaseClient})
      : _supabaseClient = supabaseClient;

  /// Get current user's ID
  String? get currentUserId => _supabaseClient.auth.currentUser?.id;

  // ===========================================================================
  // FETCH VIDEOS
  // ===========================================================================

  /// Get current user's presentation video
  Future<Video?> getMyPresentationVideo() async {
    final userId = currentUserId;
    if (userId == null) return null;

    final response = await _supabaseClient
        .from('videos')
        .select()
        .eq('user_id', userId)
        .eq('type', 'presentation')
        .neq('status', 'deleted')
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (response == null) return null;
    return Video.fromJson(response);
  }

  /// Get all videos for a user
  Future<List<Video>> getVideosForUser(String userId) async {
    final response = await _supabaseClient
        .from('videos')
        .select()
        .eq('user_id', userId)
        .eq('status', 'active')
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => Video.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Get video by ID
  Future<Video?> getVideoById(String videoId) async {
    final response = await _supabaseClient
        .from('videos')
        .select()
        .eq('id', videoId)
        .maybeSingle();

    if (response == null) return null;
    return Video.fromJson(response);
  }

  /// Get feed videos (active videos from all users)
  Future<List<Video>> getFeedVideos({
    int limit = 20,
    int offset = 0,
    String? categoryId,
  }) async {
    var query = _supabaseClient
        .from('videos')
        .select()
        .eq('status', 'active')
        .eq('type', 'presentation');

    if (categoryId != null) {
      query = query.eq('category_id', categoryId);
    }

    final response = await query
        .order('published_at', ascending: false)
        .range(offset, offset + limit - 1);

    return (response as List)
        .map((json) => Video.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // ===========================================================================
  // CREATE VIDEO
  // ===========================================================================

  /// Create a new video entry (before upload)
  Future<Video> createVideo({
    required String type,
    required String videoKey,
    String? categoryId,
    String? title,
    String? description,
    int durationSeconds = 40,
    int? fileSizeBytes,
    String? resolution,
  }) async {
    final userId = currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final data = {
      'user_id': userId,
      'type': type,
      'video_key': videoKey,
      'category_id': categoryId,
      'title': title,
      'description': description,
      'duration_seconds': durationSeconds,
      'file_size_bytes': fileSizeBytes,
      'resolution': resolution,
      'status': 'processing',
    };

    final response = await _supabaseClient
        .from('videos')
        .insert(data)
        .select()
        .single();

    return Video.fromJson(response);
  }

  /// Update video after successful upload
  Future<Video> updateVideoAfterUpload({
    required String videoId,
    required String videoUrl,
    String? thumbnailUrl,
  }) async {
    final response = await _supabaseClient
        .from('videos')
        .update({
          'video_url': videoUrl,
          'thumbnail_url': thumbnailUrl,
          'status': 'active',
          'published_at': DateTime.now().toIso8601String(),
        })
        .eq('id', videoId)
        .select()
        .single();

    return Video.fromJson(response);
  }

  /// Update video details
  Future<Video> updateVideo({
    required String videoId,
    String? title,
    String? description,
    String? categoryId,
  }) async {
    final data = <String, dynamic>{};
    if (title != null) data['title'] = title;
    if (description != null) data['description'] = description;
    if (categoryId != null) data['category_id'] = categoryId;

    final response = await _supabaseClient
        .from('videos')
        .update(data)
        .eq('id', videoId)
        .select()
        .single();

    return Video.fromJson(response);
  }

  /// Mark video as failed
  Future<void> markVideoFailed({
    required String videoId,
    required String error,
  }) async {
    await _supabaseClient.from('videos').update({
      'status': 'processing',
      'processing_error': error,
    }).eq('id', videoId);
  }

  /// Delete video (soft delete)
  Future<void> deleteVideo(String videoId) async {
    await _supabaseClient.from('videos').update({
      'status': 'deleted',
    }).eq('id', videoId);
  }

  // ===========================================================================
  // VIDEO VIEWS
  // ===========================================================================

  /// Record a view for a video
  Future<void> recordView({
    required String videoId,
    int? watchDuration,
    bool completed = false,
    String? deviceType,
  }) async {
    final viewerId = currentUserId;

    await _supabaseClient.from('video_views').insert({
      'video_id': videoId,
      'viewer_id': viewerId,
      'watch_duration': watchDuration,
      'completed': completed,
      'device_type': deviceType,
    });

    // Increment view count
    await _supabaseClient.rpc('increment_video_views', params: {
      'video_id': videoId,
    });
  }

  // ===========================================================================
  // UPLOAD HELPERS
  // ===========================================================================

  /// Generate a unique video key for R2
  String generateVideoKey() {
    final userId = currentUserId ?? 'unknown';
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'videos/$userId/$timestamp.mp4';
  }

  /// Generate a unique thumbnail key for R2
  String generateThumbnailKey(String videoKey) {
    return videoKey.replaceAll('.mp4', '_thumb.jpg');
  }
}
