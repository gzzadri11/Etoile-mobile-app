library;

/// Repository des candidatures : postulation, suivi chercheur et dossiers recruteur.

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Candidature d'un chercheur a une offre.
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

/// Repository des candidatures — lecture/ecriture de la table `applications`.
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

    // Use upsert to handle case where user previously withdrew
    await _supabaseClient.from('applications').upsert({
      'video_id': videoId,
      'seeker_id': userId,
      'recruiter_id': recruiterId,
      'status': 'pending', // Reset to pending if was withdrawn
      'applied_at': DateTime.now().toIso8601String(),
    }, onConflict: 'video_id,seeker_id');
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

    try {
      final applications = await _supabaseClient
          .from('applications')
          .select('id, video_id, status, applied_at')
          .eq('seeker_id', userId)
          .neq('status', 'withdrawn')
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

      return result;
    } catch (e) {
      debugPrint('[Applications] Error loading seeker applications: $e');
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
  }
}
