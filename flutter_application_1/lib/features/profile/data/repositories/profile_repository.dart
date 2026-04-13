library;

/// Repository d'acces aux profils chercheur et recruteur via Supabase.
///
/// Gere le chargement, la mise a jour et la completude des profils.

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/seeker_profile_model.dart';
import '../models/recruiter_profile_model.dart';

/// Operations CRUD sur les profils via Supabase.
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

  /// Verifie si un username est disponible (non pris par un autre seeker).
  Future<bool> isUsernameAvailable(String username) async {
    final userId = currentUserId;
    if (userId == null) return false;

    final response = await _supabaseClient
        .from('seeker_profiles')
        .select('user_id')
        .eq('username', username)
        .neq('user_id', userId)
        .maybeSingle();

    return response == null;
  }

  // ===========================================================================
  // RECRUITER PROFILE (read-only — seekers view company profiles)
  // ===========================================================================

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

  // ===========================================================================
  // SEEKER PHOTO
  // ===========================================================================

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
    final profile = await getSeekerProfile();
    return profile?.completionPercentage ?? 0;
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
