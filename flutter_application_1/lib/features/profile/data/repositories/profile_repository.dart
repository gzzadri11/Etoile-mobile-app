import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/seeker_profile_model.dart';
import '../models/recruiter_profile_model.dart';

/// Repository for profile operations with Supabase
class ProfileRepository {
  final SupabaseClient _supabaseClient;

  ProfileRepository({required SupabaseClient supabaseClient})
      : _supabaseClient = supabaseClient;

  /// Get current user's ID
  String? get currentUserId => _supabaseClient.auth.currentUser?.id;

  /// Get current user's role from metadata
  String? get currentUserRole {
    final metadata = _supabaseClient.auth.currentUser?.userMetadata;
    return metadata?['role'] as String?;
  }

  // ===========================================================================
  // SEEKER PROFILE
  // ===========================================================================

  /// Fetch seeker profile for current user
  Future<SeekerProfile?> getSeekerProfile() async {
    final userId = currentUserId;
    if (userId == null) return null;

    final response = await _supabaseClient
        .from('seeker_profiles')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (response == null) return null;
    return SeekerProfile.fromJson(response);
  }

  /// Fetch seeker profile by user ID (for viewing other profiles)
  Future<SeekerProfile?> getSeekerProfileById(String userId) async {
    final response = await _supabaseClient
        .from('seeker_profiles')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (response == null) return null;
    return SeekerProfile.fromJson(response);
  }

  /// Update seeker profile
  Future<SeekerProfile> updateSeekerProfile(SeekerProfile profile) async {
    final response = await _supabaseClient
        .from('seeker_profiles')
        .update(profile.toJson())
        .eq('user_id', profile.userId)
        .select()
        .single();

    return SeekerProfile.fromJson(response);
  }

  /// Check if seeker profile is complete
  Future<bool> isSeekerProfileComplete() async {
    final profile = await getSeekerProfile();
    if (profile == null) return false;

    // Profile is complete when all 5 categories are filled (5x20%=100%)
    return profile.completionPercentage >= 100;
  }

  // ===========================================================================
  // RECRUITER PROFILE
  // ===========================================================================

  /// Fetch recruiter profile for current user
  Future<RecruiterProfile?> getRecruiterProfile() async {
    final userId = currentUserId;
    if (userId == null) return null;

    final response = await _supabaseClient
        .from('recruiter_profiles')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (response == null) return null;
    return RecruiterProfile.fromJson(response);
  }

  /// Fetch recruiter profile by user ID (for viewing company profiles)
  Future<RecruiterProfile?> getRecruiterProfileById(String userId) async {
    final response = await _supabaseClient
        .from('recruiter_profiles')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (response == null) return null;
    return RecruiterProfile.fromJson(response);
  }

  /// Update recruiter profile
  Future<RecruiterProfile> updateRecruiterProfile(
      RecruiterProfile profile) async {
    final response = await _supabaseClient
        .from('recruiter_profiles')
        .update(profile.toJson())
        .eq('user_id', profile.userId)
        .select()
        .single();

    return RecruiterProfile.fromJson(response);
  }

  /// Check if recruiter profile is complete
  Future<bool> isRecruiterProfileComplete() async {
    final profile = await getRecruiterProfile();
    if (profile == null) return false;

    // Profile is complete if these fields are filled
    return profile.companyName.isNotEmpty &&
        profile.companyName != 'A completer' &&
        profile.sector != null &&
        profile.sector!.isNotEmpty &&
        profile.description != null &&
        profile.description!.isNotEmpty;
  }

  /// Upload company logo to Supabase Storage and return public URL
  Future<String> uploadLogo(Uint8List bytes, String extension) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('Utilisateur non connecte');

    final path = '$userId/logo.$extension';

    await _supabaseClient.storage.from('company-logos').uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            upsert: true,
            contentType: 'image/$extension',
          ),
        );

    final url = _supabaseClient.storage
        .from('company-logos')
        .getPublicUrl(path);

    return url;
  }

  /// Upload cover photo to Supabase Storage and return public URL
  Future<String> uploadCover(Uint8List bytes, String extension) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('Utilisateur non connecte');

    final path = '$userId/cover.$extension';

    await _supabaseClient.storage.from('company-logos').uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            upsert: true,
            contentType: 'image/$extension',
          ),
        );

    final url = _supabaseClient.storage
        .from('company-logos')
        .getPublicUrl(path);

    return url;
  }

  /// Upload seeker photo to Supabase Storage and return public URL
  Future<String> uploadSeekerPhoto(Uint8List bytes, String extension) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('Utilisateur non connecte');

    final path = '$userId/photo.$extension';

    await _supabaseClient.storage.from('seeker-photos').uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            upsert: true,
            contentType: 'image/$extension',
          ),
        );

    final url = _supabaseClient.storage
        .from('seeker-photos')
        .getPublicUrl(path);

    return url;
  }

  // ===========================================================================
  // DOCUMENT JUSTIFICATIF
  // ===========================================================================

  /// Upload a verification document to Supabase Storage (private bucket).
  ///
  /// Returns the storage path. Also updates the recruiter_profiles table
  /// with document_url, document_type, and document_uploaded_at.
  Future<String> uploadDocument(
    Uint8List bytes,
    String extension, {
    required String documentType,
  }) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('Utilisateur non connecte');

    final path = '$userId/document.$extension';

    await _supabaseClient.storage.from('verification-docs').uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            upsert: true,
            contentType: extension == 'pdf'
                ? 'application/pdf'
                : 'image/$extension',
          ),
        );

    // Store the storage path (not public URL — bucket is private)
    // Update recruiter profile with document info + re-submit for review
    await _supabaseClient.from('recruiter_profiles').update({
      'document_url': path,
      'document_type': documentType,
      'document_uploaded_at': DateTime.now().toIso8601String(),
      'verification_status': 'pending',
      'rejection_reason': null,
    }).eq('user_id', userId);

    return path;
  }

  /// Remove the current verification document from storage and profile.
  ///
  /// Clears document_url, document_type, document_uploaded_at and resets
  /// verification_status so the recruiter can upload a new document.
  Future<void> removeDocument() async {
    final userId = currentUserId;
    if (userId == null) throw Exception('Utilisateur non connecte');

    // Try to delete file from storage (best-effort, may already be gone)
    try {
      final profile = await _supabaseClient
          .from('recruiter_profiles')
          .select('document_url')
          .eq('user_id', userId)
          .single();
      final docUrl = profile['document_url'] as String?;
      if (docUrl != null && docUrl.isNotEmpty) {
        await _supabaseClient.storage
            .from('verification-docs')
            .remove([docUrl]);
      }
    } catch (e) {
      debugPrint('[ProfileRepository] Storage remove failed (non-blocking): $e');
    }

    // Clear document fields in profile
    await _supabaseClient.from('recruiter_profiles').update({
      'document_url': null,
      'document_type': null,
      'document_uploaded_at': null,
      'verification_status': 'pending',
      'rejection_reason': null,
    }).eq('user_id', userId);
  }

  // ===========================================================================
  // USER ROLE
  // ===========================================================================

  /// Get user role from database
  Future<String?> getUserRole() async {
    final userId = currentUserId;
    if (userId == null) return null;

    final response = await _supabaseClient
        .from('user_roles')
        .select('role')
        .eq('user_id', userId)
        .maybeSingle();

    return response?['role'] as String?;
  }

  // ===========================================================================
  // PROFILE COMPLETION
  // ===========================================================================

  /// Get current user's profile completion percentage (0-100).
  Future<int> getProfileCompletionPercentage() async {
    final role = currentUserRole;
    if (role == 'seeker') {
      final profile = await getSeekerProfile();
      return profile?.completionPercentage ?? 0;
    } else {
      final profile = await getRecruiterProfile();
      return profile?.completionPercentage ?? 0;
    }
  }

  // ===========================================================================
  // CATEGORIES
  // ===========================================================================

  /// Get all available categories
  Future<List<Map<String, dynamic>>> getCategories() async {
    final response = await _supabaseClient
        .from('categories')
        .select()
        .eq('is_active', true)
        .order('sort_order');

    return List<Map<String, dynamic>>.from(response);
  }
}
