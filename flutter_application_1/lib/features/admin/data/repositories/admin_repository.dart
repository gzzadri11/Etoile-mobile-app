import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../profile/data/models/recruiter_profile_model.dart';
import '../models/report_model.dart';

/// Repository for admin operations.
///
/// Provides access to admin-only data: dashboard counts,
/// recruiter verifications, reports moderation, and platform stats.
class AdminRepository {
  final SupabaseClient _supabaseClient;

  AdminRepository({required SupabaseClient supabaseClient})
      : _supabaseClient = supabaseClient;

  // ===========================================================================
  // DASHBOARD
  // ===========================================================================

  /// Get dashboard summary counts for the admin hub.
  Future<Map<String, int>> getDashboardCounts() async {
    try {
      final recruitersResponse = await _supabaseClient
          .from('recruiter_profiles')
          .select('user_id')
          .eq('verification_status', 'pending');
      final pendingRecruiters = (recruitersResponse as List).length;

      final reportsResponse = await _supabaseClient
          .from('reports')
          .select('id')
          .eq('status', 'pending');
      final pendingReports = (reportsResponse as List).length;

      debugPrint(
        '[AdminRepository] Dashboard counts: '
        'pendingRecruiters=$pendingRecruiters, '
        'pendingReports=$pendingReports',
      );

      return {
        'pendingRecruiters': pendingRecruiters,
        'pendingReports': pendingReports,
      };
    } catch (e) {
      debugPrint('[AdminRepository] Error loading dashboard counts: $e');
      rethrow;
    }
  }

  /// Get full platform statistics for the admin stats page.
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      // Users by role
      final usersResponse =
          await _supabaseClient.from('user_roles').select('role, is_premium');
      final users = usersResponse as List;
      final seekerCount = users.where((u) => u['role'] == 'seeker').length;
      final recruiterCount =
          users.where((u) => u['role'] == 'recruiter').length;
      final premiumCount = users.where((u) => u['is_premium'] == true).length;

      // Recruiter verification status
      final recruitersResponse = await _supabaseClient
          .from('recruiter_profiles')
          .select('verification_status');
      final recruiters = recruitersResponse as List;
      final verifiedCount = recruiters
          .where((r) => r['verification_status'] == 'verified')
          .length;
      final pendingCount = recruiters
          .where((r) => r['verification_status'] == 'pending')
          .length;
      final rejectedCount = recruiters
          .where((r) => r['verification_status'] == 'rejected')
          .length;

      // Videos by type
      final videosResponse = await _supabaseClient
          .from('videos')
          .select('type')
          .eq('status', 'active');
      final videos = videosResponse as List;
      final presentationCount =
          videos.where((v) => v['type'] == 'presentation').length;
      final offerCount = videos.where((v) => v['type'] == 'offer').length;
      final posterCount = videos.where((v) => v['type'] == 'poster').length;

      // Messages count
      final messagesResponse =
          await _supabaseClient.from('messages').select('id');
      final messagesCount = (messagesResponse as List).length;

      // Active subscriptions (B2B: recruiters only)
      final subsResponse = await _supabaseClient
          .from('subscriptions')
          .select('plan_type')
          .eq('status', 'active');
      final subs = subsResponse as List;
      final recruiterSubsCount =
          subs.where((s) => s['plan_type'] == 'recruiter_premium').length;

      debugPrint('[AdminRepository] Stats loaded successfully');

      return {
        'totalUsers': users.length,
        'seekerCount': seekerCount,
        'recruiterCount': recruiterCount,
        'premiumCount': premiumCount,
        'verifiedRecruiters': verifiedCount,
        'pendingRecruiters': pendingCount,
        'rejectedRecruiters': rejectedCount,
        'totalVideos': videos.length,
        'presentationCount': presentationCount,
        'offerCount': offerCount,
        'posterCount': posterCount,
        'messagesCount': messagesCount,
        'recruiterSubscriptions': recruiterSubsCount,
      };
    } catch (e) {
      debugPrint('[AdminRepository] Error loading stats: $e');
      rethrow;
    }
  }

  // ===========================================================================
  // AUDIT LOGGING
  // ===========================================================================

  /// Log an admin action to the audit_logs table.
  Future<void> _logAction({
    required String action,
    String? entityType,
    String? entityId,
    Map<String, dynamic>? oldValues,
    Map<String, dynamic>? newValues,
  }) async {
    try {
      final adminId = _supabaseClient.auth.currentUser?.id;
      if (adminId == null) return;
      await _supabaseClient.from('audit_logs').insert({
        'user_id': adminId,
        'action': action,
        'entity_type': entityType,
        'entity_id': entityId,
        'old_values': oldValues,
        'new_values': newValues,
      });
    } catch (e) {
      debugPrint('[AdminRepository] Audit log failed: $e');
    }
  }

  // ===========================================================================
  // RECRUITER VERIFICATION
  // ===========================================================================

  /// Get list of recruiters with pending verification.
  Future<List<RecruiterProfile>> getPendingRecruiters() async {
    try {
      final response = await _supabaseClient
          .from('recruiter_profiles')
          .select()
          .eq('verification_status', 'pending')
          .order('created_at', ascending: true);

      final list = (response as List)
          .map((json) =>
              RecruiterProfile.fromJson(json as Map<String, dynamic>))
          .toList();

      debugPrint(
          '[AdminRepository] Loaded ${list.length} pending recruiters');
      return list;
    } catch (e) {
      debugPrint('[AdminRepository] Error loading pending recruiters: $e');
      rethrow;
    }
  }

  /// Get full recruiter detail including user email.
  Future<Map<String, dynamic>> getRecruiterDetail(String userId) async {
    try {
      final profileResponse = await _supabaseClient
          .from('recruiter_profiles')
          .select()
          .eq('user_id', userId)
          .single();

      final userResponse = await _supabaseClient
          .from('user_roles')
          .select('created_at')
          .eq('user_id', userId)
          .single();

      final profile = RecruiterProfile.fromJson(profileResponse);

      debugPrint('[AdminRepository] Loaded detail for recruiter $userId');
      return {
        'profile': profile,
        'registeredAt': DateTime.parse(userResponse['created_at'] as String),
      };
    } catch (e) {
      debugPrint('[AdminRepository] Error loading recruiter detail: $e');
      rethrow;
    }
  }

  /// Approve a recruiter (set verification_status to 'verified').
  Future<void> approveRecruiter(String userId) async {
    try {
      final adminId = _supabaseClient.auth.currentUser!.id;

      await _supabaseClient.from('recruiter_profiles').update({
        'verification_status': 'verified',
        'verified_at': DateTime.now().toIso8601String(),
        'verified_by': adminId,
      }).eq('user_id', userId);

      await _logAction(
        action: 'recruiter_approved',
        entityType: 'recruiter_profile',
        entityId: userId,
      );

      debugPrint('[AdminRepository] Recruiter $userId approved');
    } catch (e) {
      debugPrint('[AdminRepository] Error approving recruiter: $e');
      rethrow;
    }
  }

  /// Reject a recruiter with a reason.
  Future<void> rejectRecruiter(String userId, String reason) async {
    try {
      await _supabaseClient.from('recruiter_profiles').update({
        'verification_status': 'rejected',
        'rejection_reason': reason,
      }).eq('user_id', userId);

      await _logAction(
        action: 'recruiter_rejected',
        entityType: 'recruiter_profile',
        entityId: userId,
        newValues: {'rejection_reason': reason},
      );

      debugPrint('[AdminRepository] Recruiter $userId rejected: $reason');
    } catch (e) {
      debugPrint('[AdminRepository] Error rejecting recruiter: $e');
      rethrow;
    }
  }

  // ===========================================================================
  // REPORTS / MODERATION
  // ===========================================================================

  /// Get list of pending reports.
  Future<List<ReportModel>> getPendingReports() async {
    try {
      final response = await _supabaseClient
          .from('reports')
          .select('*')
          .eq('status', 'pending')
          .order('created_at', ascending: false);

      final list = (response as List)
          .map((json) => ReportModel.fromJson(json as Map<String, dynamic>))
          .toList();

      debugPrint('[AdminRepository] Loaded ${list.length} pending reports');
      return list;
    } catch (e) {
      debugPrint('[AdminRepository] Error loading pending reports: $e');
      rethrow;
    }
  }

  /// Dismiss a report (mark as non-issue).
  Future<void> dismissReport(String reportId) async {
    try {
      final adminId = _supabaseClient.auth.currentUser!.id;

      await _supabaseClient.from('reports').update({
        'status': 'dismissed',
        'reviewed_by': adminId,
        'reviewed_at': DateTime.now().toIso8601String(),
      }).eq('id', reportId);

      await _logAction(
        action: 'report_dismissed',
        entityType: 'report',
        entityId: reportId,
      );

      debugPrint('[AdminRepository] Report $reportId dismissed');
    } catch (e) {
      debugPrint('[AdminRepository] Error dismissing report: $e');
      rethrow;
    }
  }

  /// Take action on a report (delete content, suspend user, etc.).
  Future<void> actionReport(
    String reportId, {
    required String action,
    String? notes,
  }) async {
    try {
      final adminId = _supabaseClient.auth.currentUser!.id;

      await _supabaseClient.from('reports').update({
        'status': 'actioned',
        'action_taken': action,
        'admin_notes': notes,
        'reviewed_by': adminId,
        'reviewed_at': DateTime.now().toIso8601String(),
      }).eq('id', reportId);

      await _logAction(
        action: 'report_actioned',
        entityType: 'report',
        entityId: reportId,
        newValues: {'action_taken': action, 'admin_notes': notes},
      );

      debugPrint('[AdminRepository] Report $reportId actioned: $action');
    } catch (e) {
      debugPrint('[AdminRepository] Error actioning report: $e');
      rethrow;
    }
  }

  /// Suspend a user account.
  Future<void> suspendUser(String userId) async {
    try {
      await _supabaseClient
          .from('user_roles')
          .update({'status': 'suspended'}).eq('user_id', userId);

      await _logAction(
        action: 'user_suspended',
        entityType: 'user',
        entityId: userId,
      );

      debugPrint('[AdminRepository] User $userId suspended');
    } catch (e) {
      debugPrint('[AdminRepository] Error suspending user: $e');
      rethrow;
    }
  }

  /// Suspend a video (remove from feed).
  Future<void> suspendVideo(String videoId) async {
    try {
      await _supabaseClient
          .from('videos')
          .update({'status': 'suspended'}).eq('id', videoId);

      await _logAction(
        action: 'video_suspended',
        entityType: 'video',
        entityId: videoId,
      );

      debugPrint('[AdminRepository] Video $videoId suspended');
    } catch (e) {
      debugPrint('[AdminRepository] Error suspending video: $e');
      rethrow;
    }
  }
}
