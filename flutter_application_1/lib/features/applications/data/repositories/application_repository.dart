import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// An offer with its application (candidate) count
class OfferWithApplications extends Equatable {
  final String videoId;
  final String title;
  final String type; // 'offer' or 'poster'
  final String? thumbnailUrl;
  final String? contractType;
  final String status;
  final DateTime? publishedAt;
  final int applicationCount;

  const OfferWithApplications({
    required this.videoId,
    required this.title,
    required this.type,
    this.thumbnailUrl,
    this.contractType,
    required this.status,
    this.publishedAt,
    required this.applicationCount,
  });

  @override
  List<Object?> get props => [videoId, applicationCount];
}

/// A candidate who applied to an offer
class OfferCandidate extends Equatable {
  final String seekerUserId;
  final String applicationId;
  final String applicationStatus;
  final DateTime appliedAt;

  // Seeker profile info
  final String name;
  final String? photoUrl;
  final String? age;
  final String? school;
  final String? studyLevel;
  final String? city;
  final String? domain;
  final String? specialty;

  // Seeker presentation video
  final String? presentationVideoUrl;
  final String? presentationThumbnailUrl;
  final String? presentationVideoId;

  const OfferCandidate({
    required this.seekerUserId,
    required this.applicationId,
    required this.applicationStatus,
    required this.appliedAt,
    required this.name,
    this.photoUrl,
    this.age,
    this.school,
    this.studyLevel,
    this.city,
    this.domain,
    this.specialty,
    this.presentationVideoUrl,
    this.presentationThumbnailUrl,
    this.presentationVideoId,
  });

  @override
  List<Object?> get props => [seekerUserId, applicationId];
}

/// A seeker's application to an offer
class SeekerApplication extends Equatable {
  final String id;
  final String videoId;
  final String status;
  final DateTime appliedAt;
  final String offerTitle;
  final String companyName;
  final String? contractType;

  const SeekerApplication({
    required this.id,
    required this.videoId,
    required this.status,
    required this.appliedAt,
    required this.offerTitle,
    required this.companyName,
    this.contractType,
  });

  @override
  List<Object?> get props => [id, videoId, status];
}

/// Repository for application (candidature) operations — reads/writes `applications` table
class ApplicationRepository {
  final SupabaseClient _supabaseClient;

  ApplicationRepository({required SupabaseClient supabaseClient})
      : _supabaseClient = supabaseClient;

  String? get currentUserId => _supabaseClient.auth.currentUser?.id;

  /// Apply to an offer (seeker inserts into applications)
  Future<void> applyToOffer({
    required String videoId,
    required String recruiterId,
  }) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('Utilisateur non connecte');

    debugPrint('[Applications] Applying to offer: videoId=$videoId, recruiter=$recruiterId');

    await _supabaseClient.from('applications').insert({
      'video_id': videoId,
      'seeker_id': userId,
      'recruiter_id': recruiterId,
    });

    debugPrint('[Applications] Application created');
  }

  /// Get set of video IDs the current seeker has applied to
  Future<Set<String>> getAppliedVideoIds() async {
    final userId = currentUserId;
    if (userId == null) return {};

    try {
      final result = await _supabaseClient
          .from('applications')
          .select('video_id')
          .eq('seeker_id', userId)
          .neq('status', 'withdrawn');

      return (result as List)
          .map((row) => row['video_id'] as String)
          .toSet();
    } catch (e) {
      debugPrint('[Applications] Error loading applied video IDs: $e');
      return {};
    }
  }

  /// Get seeker's applications with enriched offer info
  Future<List<SeekerApplication>> getSeekerApplications() async {
    final userId = currentUserId;
    if (userId == null) throw Exception('Utilisateur non connecte');

    debugPrint('[Applications] Loading seeker applications for: $userId');

    try {
      final applications = await _supabaseClient
          .from('applications')
          .select('id, video_id, status, applied_at')
          .eq('seeker_id', userId)
          .order('applied_at', ascending: false);

      final result = <SeekerApplication>[];

      for (final app in (applications as List)) {
        final videoId = app['video_id'] as String;

        // Fetch video info (title, contract_type, user_id)
        final video = await _supabaseClient
            .from('videos')
            .select('title, contract_type, user_id')
            .eq('id', videoId)
            .maybeSingle();

        if (video == null) continue;

        // Fetch recruiter company name
        final recruiterId = video['user_id'] as String;
        final recruiterProfile = await _supabaseClient
            .from('recruiter_profiles')
            .select('company_name')
            .eq('user_id', recruiterId)
            .maybeSingle();

        result.add(SeekerApplication(
          id: app['id'] as String,
          videoId: videoId,
          status: app['status'] as String? ?? 'pending',
          appliedAt: DateTime.parse(app['applied_at'] as String),
          offerTitle: video['title'] as String? ?? 'Offre sans titre',
          companyName: recruiterProfile?['company_name'] as String? ?? 'Entreprise',
          contractType: video['contract_type'] as String?,
        ));
      }

      debugPrint('[Applications] Found ${result.length} seeker applications');
      return result;
    } catch (e) {
      debugPrint('[Applications] Error loading seeker applications: $e');
      rethrow;
    }
  }

  /// Get recruiter's offers with application count (from applications table)
  Future<List<OfferWithApplications>> getOffersWithApplicationCount() async {
    final userId = currentUserId;
    if (userId == null) throw Exception('Utilisateur non connecte');

    debugPrint('[Applications] Loading offers for recruiter: $userId');

    try {
      // Get recruiter's active offers/posters
      final videos = await _supabaseClient
          .from('videos')
          .select()
          .eq('user_id', userId)
          .inFilter('type', ['offer', 'poster'])
          .inFilter('status', ['active', 'processing'])
          .order('created_at', ascending: false);

      final offers = <OfferWithApplications>[];

      for (final video in (videos as List)) {
        final videoId = video['id'] as String;

        // Count applications for this offer
        final countResult = await _supabaseClient
            .from('applications')
            .select('id')
            .eq('video_id', videoId)
            .neq('status', 'withdrawn');

        final count = (countResult as List).length;

        offers.add(OfferWithApplications(
          videoId: videoId,
          title: video['title'] as String? ?? 'Offre sans titre',
          type: video['type'] as String,
          thumbnailUrl: video['thumbnail_url'] as String?,
          contractType: video['contract_type'] as String?,
          status: video['status'] as String,
          publishedAt: video['published_at'] != null
              ? DateTime.parse(video['published_at'] as String)
              : null,
          applicationCount: count,
        ));
      }

      debugPrint('[Applications] Found ${offers.length} offers');
      return offers;
    } catch (e) {
      debugPrint('[Applications] Error loading offers: $e');
      rethrow;
    }
  }

  /// Get candidates who applied to a specific offer (from applications table)
  Future<List<OfferCandidate>> getCandidatesForOffer(String videoId) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('Utilisateur non connecte');

    debugPrint('[Applications] Loading candidates for offer: $videoId');

    try {
      // Get applications for this offer
      final applications = await _supabaseClient
          .from('applications')
          .select('id, seeker_id, status, applied_at')
          .eq('video_id', videoId)
          .neq('status', 'withdrawn')
          .order('applied_at', ascending: false);

      final candidates = <OfferCandidate>[];

      for (final app in (applications as List)) {
        final seekerUserId = app['seeker_id'] as String;

        // Fetch seeker profile
        final profile = await _supabaseClient
            .from('seeker_profiles')
            .select()
            .eq('user_id', seekerUserId)
            .maybeSingle();

        if (profile == null) continue;

        final firstName = profile['first_name'] as String? ?? '';
        final lastName = profile['last_name'] as String? ?? '';
        final name = '$firstName $lastName'.trim();

        // Fetch seeker's presentation video
        final presentationVideo = await _supabaseClient
            .from('videos')
            .select('id, video_url, thumbnail_url')
            .eq('user_id', seekerUserId)
            .eq('type', 'presentation')
            .eq('status', 'active')
            .maybeSingle();

        candidates.add(OfferCandidate(
          seekerUserId: seekerUserId,
          applicationId: app['id'] as String,
          applicationStatus: app['status'] as String? ?? 'pending',
          appliedAt: DateTime.parse(app['applied_at'] as String),
          name: name.isNotEmpty ? name : 'Chercheur',
          photoUrl: profile['photo_url'] as String?,
          age: profile['age'] as String?,
          school: profile['school'] as String?,
          studyLevel: profile['study_level'] as String?,
          city: profile['city'] as String?,
          domain: profile['domain'] as String?,
          specialty: profile['specialty'] as String?,
          presentationVideoUrl:
              presentationVideo?['video_url'] as String?,
          presentationThumbnailUrl:
              presentationVideo?['thumbnail_url'] as String?,
          presentationVideoId:
              presentationVideo?['id'] as String?,
        ));
      }

      debugPrint('[Applications] Found ${candidates.length} candidates');
      return candidates;
    } catch (e) {
      debugPrint('[Applications] Error loading candidates: $e');
      rethrow;
    }
  }

  /// Withdraw an application (seeker)
  Future<void> withdrawApplication(String applicationId) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('Utilisateur non connecte');

    await _supabaseClient
        .from('applications')
        .update({'status': 'withdrawn'})
        .eq('id', applicationId)
        .eq('seeker_id', userId);

    debugPrint('[Applications] Application $applicationId withdrawn');
  }

  /// Mark an application as contacted (recruiter)
  Future<void> markAsContacted(String applicationId) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('Utilisateur non connecte');

    await _supabaseClient
        .from('applications')
        .update({'status': 'contacted'})
        .eq('id', applicationId)
        .eq('recruiter_id', userId);

    debugPrint('[Applications] Application $applicationId marked as contacted');
  }
}
