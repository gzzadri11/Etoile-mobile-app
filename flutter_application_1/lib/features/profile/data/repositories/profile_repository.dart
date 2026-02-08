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

    // Profile is complete if these fields are filled
    return profile.firstName.isNotEmpty &&
        profile.lastName != null &&
        profile.lastName!.isNotEmpty &&
        profile.city != null &&
        profile.city!.isNotEmpty &&
        profile.categories.isNotEmpty;
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
