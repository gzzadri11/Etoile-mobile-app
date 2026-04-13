library;

/// Repository du feed video avec pagination et filtres.

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/feed_item_model.dart';
import '../../../video/data/models/video_model.dart';

/// Acces au feed video via Supabase (pagination, filtres secteur/ville).
class FeedRepository {
  final SupabaseClient _supabaseClient;

  FeedRepository({required SupabaseClient supabaseClient})
      : _supabaseClient = supabaseClient;

  /// Get current user's ID
  String? get currentUserId => _supabaseClient.auth.currentUser?.id;

  /// Get current user's role by checking which profile table has an entry
  Future<String?> getUserRole() async {
    final userId = currentUserId;
    if (userId == null) return null;

    final seekerProfile = await _supabaseClient
        .from('seeker_profiles')
        .select('user_id')
        .eq('user_id', userId)
        .maybeSingle();

    if (seekerProfile != null) return 'seeker';

    final recruiterProfile = await _supabaseClient
        .from('recruiter_profiles')
        .select('user_id')
        .eq('user_id', userId)
        .maybeSingle();

    if (recruiterProfile != null) return 'recruiter';

    return null;
  }

  /// Get feed for seekers: only recruiter offer videos and posters (verified recruiters)
  Future<List<FeedItem>> getSeekerOffersFeed({
    int limit = 20,
    int offset = 0,
    FeedFilters? filters,
  }) async {
    // 1. Get active offer videos and posters
    final videosResponse = await _supabaseClient
        .from('videos')
        .select()
        .eq('status', 'active')
        .inFilter('type', ['offer', 'poster'])
        .order('published_at', ascending: false)
        .range(offset, offset + limit - 1);

    final videos = (videosResponse as List)
        .map((json) => Video.fromJson(json as Map<String, dynamic>))
        .toList();

    if (videos.isEmpty) return [];

    // 2. Get recruiter profiles for video authors
    final userIds = videos.map((v) => v.userId).toSet().toList();
    final recruiterProfilesResponse = await _supabaseClient
        .from('recruiter_profiles')
        .select()
        .inFilter('user_id', userIds)
        .eq('verification_status', 'verified');

    final recruiterProfiles = <String, Map<String, dynamic>>{};
    for (final profile in (recruiterProfilesResponse as List)) {
      final p = profile as Map<String, dynamic>;
      recruiterProfiles[p['user_id'] as String] = p;
    }

    // 3. Build FeedItems (only for verified recruiters)
    final feedItems = <FeedItem>[];
    for (final video in videos) {
      final recruiterProfile = recruiterProfiles[video.userId];
      if (recruiterProfile == null) continue;

      feedItems.add(FeedItem(
        video: video,
        userName: (recruiterProfile['company_name'] as String?) ?? 'Entreprise',
        userTitle: video.title ?? recruiterProfile['sector'] as String?,
        userLocation: _buildRecruiterLocation(
          recruiterProfile['locations'] as List<dynamic>?,
        ),
        userAvatarUrl: recruiterProfile['logo_url'] as String?,
        isRecruiter: true,
        isVerified: true,
        region: _getFirstLocation(recruiterProfile['locations'] as List<dynamic>?),
        sector: recruiterProfile['sector'] as String?,
      ));
    }

    // 4. Apply seeker-specific filters
    if (filters != null && filters.hasFilters) {
      return _applySeekerFilters(feedItems, filters);
    }

    return feedItems;
  }

  /// Get discover feed for seekers: recruiter presentation videos (verified recruiters)
  Future<List<FeedItem>> getSeekerDiscoverFeed({
    int limit = 20,
    int offset = 0,
    FeedFilters? filters,
  }) async {
    // 1. Get active presentation videos from recruiters
    final videosResponse = await _supabaseClient
        .from('videos')
        .select()
        .eq('status', 'active')
        .eq('type', 'presentation')
        .order('published_at', ascending: false)
        .range(offset, offset + limit - 1);

    final videos = (videosResponse as List)
        .map((json) => Video.fromJson(json as Map<String, dynamic>))
        .toList();

    if (videos.isEmpty) return [];

    // 2. Get recruiter profiles for video authors (verified only)
    final userIds = videos.map((v) => v.userId).toSet().toList();
    final recruiterProfilesResponse = await _supabaseClient
        .from('recruiter_profiles')
        .select()
        .inFilter('user_id', userIds)
        .eq('verification_status', 'verified');

    final recruiterProfiles = <String, Map<String, dynamic>>{};
    for (final profile in (recruiterProfilesResponse as List)) {
      final p = profile as Map<String, dynamic>;
      recruiterProfiles[p['user_id'] as String] = p;
    }

    // 3. Build FeedItems (only for verified recruiters)
    final feedItems = <FeedItem>[];
    for (final video in videos) {
      final recruiterProfile = recruiterProfiles[video.userId];
      if (recruiterProfile == null) continue;

      feedItems.add(FeedItem(
        video: video,
        userName: (recruiterProfile['company_name'] as String?) ?? 'Entreprise',
        userTitle: video.title ?? recruiterProfile['sector'] as String?,
        userLocation: _buildRecruiterLocation(
          recruiterProfile['locations'] as List<dynamic>?,
        ),
        userAvatarUrl: recruiterProfile['logo_url'] as String?,
        isRecruiter: true,
        isVerified: true,
        region: _getFirstLocation(recruiterProfile['locations'] as List<dynamic>?),
        sector: recruiterProfile['sector'] as String?,
      ));
    }

    // 4. Apply seeker-specific filters
    if (filters != null && filters.hasFilters) {
      return _applySeekerFilters(feedItems, filters);
    }

    return feedItems;
  }

  /// Get mixed feed (both seekers and offers) - fallback
  Future<List<FeedItem>> getMixedFeed({
    int limit = 20,
    int offset = 0,
    FeedFilters? filters,
  }) async {
    // 1. Get active videos
    final videosResponse = await _supabaseClient
        .from('videos')
        .select()
        .eq('status', 'active')
        .order('published_at', ascending: false)
        .range(offset, offset + limit - 1);

    final videos = (videosResponse as List)
        .map((json) => Video.fromJson(json as Map<String, dynamic>))
        .toList();

    if (videos.isEmpty) return [];

    // 2. Get unique user IDs from videos
    final userIds = videos.map((v) => v.userId).toSet().toList();

    // 3. Fetch seeker profiles for these users
    final seekerProfilesResponse = await _supabaseClient
        .from('seeker_profiles')
        .select()
        .inFilter('user_id', userIds);

    final seekerProfiles = <String, Map<String, dynamic>>{};
    for (final profile in (seekerProfilesResponse as List)) {
      final p = profile as Map<String, dynamic>;
      seekerProfiles[p['user_id'] as String] = p;
    }

    // 4. Fetch recruiter profiles for these users
    final recruiterProfilesResponse = await _supabaseClient
        .from('recruiter_profiles')
        .select()
        .inFilter('user_id', userIds);

    final recruiterProfiles = <String, Map<String, dynamic>>{};
    for (final profile in (recruiterProfilesResponse as List)) {
      final p = profile as Map<String, dynamic>;
      recruiterProfiles[p['user_id'] as String] = p;
    }

    // 5. Build FeedItems
    final feedItems = <FeedItem>[];
    for (final video in videos) {
      final seekerProfile = seekerProfiles[video.userId];
      final recruiterProfile = recruiterProfiles[video.userId];

      if (seekerProfile != null) {
        final firstName = (seekerProfile['first_name'] as String?) ?? '';
        final lastName = seekerProfile['last_name'] as String?;
        final fullName = (lastName != null && lastName.isNotEmpty)
            ? '$firstName $lastName'.trim()
            : firstName;

        feedItems.add(FeedItem(
          video: video,
          userName: fullName.isNotEmpty ? fullName : 'Utilisateur',
          userLocation: _buildLocation(
            seekerProfile['city'] as String?,
            seekerProfile['region'] as String?,
          ),
          userAvatarUrl: seekerProfile['photo_url'] as String?,
          isRecruiter: false,
          isVerified: false,
          region: seekerProfile['region'] as String?,
          city: seekerProfile['city'] as String?,
        ));
      } else if (recruiterProfile != null) {
        feedItems.add(FeedItem(
          video: video,
          userName: (recruiterProfile['company_name'] as String?) ?? 'Entreprise',
          userTitle: video.title ?? recruiterProfile['sector'] as String?,
          userLocation: _buildRecruiterLocation(
            recruiterProfile['locations'] as List<dynamic>?,
          ),
          userAvatarUrl: recruiterProfile['logo_url'] as String?,
          isRecruiter: true,
          isVerified: recruiterProfile['verification_status'] == 'verified',
          region: _getFirstLocation(recruiterProfile['locations'] as List<dynamic>?),
          sector: recruiterProfile['sector'] as String?,
        ));
      } else {
        // No profile found, still show the video
        feedItems.add(FeedItem(
          video: video,
          userName: 'Utilisateur',
          isRecruiter: false,
          isVerified: false,
        ));
      }
    }

    // 6. Apply filters if any
    if (filters != null && filters.hasFilters) {
      return _applyFilters(feedItems, filters);
    }

    return feedItems;
  }

  String? _getFirstLocation(List<dynamic>? locations) {
    if (locations == null || locations.isEmpty) return null;
    return locations.first as String?;
  }

  String? _buildLocation(String? city, String? region) {
    final parts = <String>[];
    if (city != null && city.isNotEmpty) parts.add(city);
    if (region != null && region.isNotEmpty) parts.add(region);
    return parts.isNotEmpty ? parts.join(', ') : null;
  }

  String? _buildRecruiterLocation(List<dynamic>? locations) {
    if (locations == null || locations.isEmpty) return null;
    return locations.first as String?;
  }

  /// Apply filters for seeker feed (filtering recruiter videos)
  List<FeedItem> _applySeekerFilters(List<FeedItem> items, FeedFilters filters) {
    return items.where((item) {
      // Filter by sector
      if (filters.sector != null && filters.sector!.isNotEmpty) {
        if (item.sector == null ||
            !item.sector!.toLowerCase().contains(filters.sector!.toLowerCase())) {
          return false;
        }
      }

      // Filter by region
      if (filters.region != null && filters.region!.isNotEmpty) {
        final filterRegion = filters.region!.toLowerCase();
        final itemRegion = item.region?.toLowerCase() ?? '';
        final itemLocation = item.userLocation?.toLowerCase() ?? '';
        if (!itemRegion.contains(filterRegion) &&
            !itemLocation.contains(filterRegion)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  /// Apply filters to feed items (for mixed feed fallback)
  List<FeedItem> _applyFilters(List<FeedItem> items, FeedFilters filters) {
    return items.where((item) {
      if (filters.region != null && filters.region!.isNotEmpty) {
        final filterRegion = filters.region!.toLowerCase();
        final itemRegion = item.region?.toLowerCase() ?? '';
        final itemCity = item.city?.toLowerCase() ?? '';
        final itemLocation = item.userLocation?.toLowerCase() ?? '';
        if (!itemRegion.contains(filterRegion) &&
            !itemCity.contains(filterRegion) &&
            !itemLocation.contains(filterRegion)) {
          return false;
        }
      }

      if (filters.sector != null && filters.sector!.isNotEmpty) {
        if (item.sector == null ||
            !item.sector!.toLowerCase().contains(filters.sector!.toLowerCase())) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  /// Get distinct regions from seeker profiles
  Future<List<String>> getRegions() async {
    final response = await _supabaseClient
        .from('seeker_profiles')
        .select('region')
        .not('region', 'is', null);

    final regions = (response as List)
        .map((r) => r['region'] as String?)
        .where((r) => r != null && r.isNotEmpty)
        .toSet()
        .cast<String>()
        .toList();

    regions.sort();
    return regions;
  }

  /// Get distinct sectors from recruiter profiles
  Future<List<String>> getSectors() async {
    final response = await _supabaseClient
        .from('recruiter_profiles')
        .select('sector')
        .not('sector', 'is', null)
        .eq('verification_status', 'verified');

    final sectors = (response as List)
        .map((r) => r['sector'] as String?)
        .where((s) => s != null && s.isNotEmpty)
        .toSet()
        .cast<String>()
        .toList();

    sectors.sort();
    return sectors;
  }

  /// Record a video view
  Future<void> recordView({
    required String videoId,
    int? watchDuration,
    bool completed = false,
  }) async {
    final viewerId = currentUserId;

    await _supabaseClient.from('video_views').insert({
      'video_id': videoId,
      'viewer_id': viewerId,
      'watch_duration': watchDuration,
      'completed': completed,
    });
  }
}
