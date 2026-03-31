library;

/// BLoC d'administration de la plateforme Etoile.
///
/// Gere les evenements du tableau de bord admin : chargement des compteurs,
/// verification des recruteurs (approuver/rejeter), moderation des
/// signalements et consultation des statistiques globales.

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/admin_repository.dart';
import '../../../profile/data/models/recruiter_profile_model.dart';
import 'admin_event.dart';
import 'admin_state.dart';

/// BLoC gerant les operations d'administration de la plateforme.
class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final AdminRepository _adminRepository;

  AdminBloc({required AdminRepository adminRepository})
      : _adminRepository = adminRepository,
        super(const AdminInitial()) {
    on<AdminDashboardLoadRequested>(_onDashboardLoad);
    on<AdminVerificationListLoadRequested>(_onVerificationListLoad);
    on<AdminRecruiterDetailLoadRequested>(_onRecruiterDetailLoad);
    on<AdminRecruiterApproveRequested>(_onRecruiterApprove);
    on<AdminRecruiterRejectRequested>(_onRecruiterReject);
    on<AdminReportsListLoadRequested>(_onReportsListLoad);
    on<AdminReportDismissRequested>(_onReportDismiss);
    on<AdminReportActionRequested>(_onReportAction);
    on<AdminStatsLoadRequested>(_onStatsLoad);
  }

  Future<void> _onDashboardLoad(
    AdminDashboardLoadRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminDashboardLoading());

    try {
      final counts = await _adminRepository.getDashboardCounts();

      emit(AdminDashboardLoaded(
        pendingRecruiters: counts['pendingRecruiters'] ?? 0,
        pendingReports: counts['pendingReports'] ?? 0,
      ));
    } catch (e) {
      debugPrint('[AdminBloc] Error loading dashboard: $e');
      emit(const AdminError(
        message: 'Impossible de charger le tableau de bord',
      ));
    }
  }

  Future<void> _onVerificationListLoad(
    AdminVerificationListLoadRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminVerificationListLoading());

    try {
      final recruiters = await _adminRepository.getPendingRecruiters();

      emit(AdminVerificationListLoaded(recruiters: recruiters));
    } catch (e) {
      debugPrint('[AdminBloc] Error loading verification list: $e');
      emit(const AdminError(
        message: 'Impossible de charger les vérifications',
      ));
    }
  }

  Future<void> _onRecruiterDetailLoad(
    AdminRecruiterDetailLoadRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminRecruiterDetailLoading());

    try {
      final detail = await _adminRepository.getRecruiterDetail(event.userId);
      final profile = detail['profile'] as RecruiterProfile;

      // Generate signed URL for document if available
      String? documentSignedUrl;
      if (profile.documentUrl != null && profile.documentUrl!.isNotEmpty) {
        try {
          documentSignedUrl = await _adminRepository
              .getDocumentSignedUrl(profile.documentUrl!);
        } catch (e) {
          debugPrint('[AdminBloc] Error getting document signed URL: $e');
        }
      }

      emit(AdminRecruiterDetailLoaded(
        profile: profile,
        registeredAt: detail['registeredAt'],
        documentSignedUrl: documentSignedUrl,
      ));
    } catch (e) {
      debugPrint('[AdminBloc] Error loading recruiter detail: $e');
      emit(const AdminError(
        message: 'Impossible de charger le détail du recruteur',
      ));
    }
  }

  Future<void> _onRecruiterApprove(
    AdminRecruiterApproveRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminRecruiterActionLoading());

    try {
      await _adminRepository.approveRecruiter(event.userId);

      emit(const AdminRecruiterActionSuccess(
        message: 'Recruteur approuvé avec succès',
      ));
    } catch (e) {
      debugPrint('[AdminBloc] Error approving recruiter: $e');
      emit(const AdminError(
        message: 'Impossible d\'approuver le recruteur',
      ));
    }
  }

  Future<void> _onRecruiterReject(
    AdminRecruiterRejectRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminRecruiterActionLoading());

    try {
      await _adminRepository.rejectRecruiter(event.userId, event.reason);

      emit(const AdminRecruiterActionSuccess(
        message: 'Recruteur rejeté',
      ));
    } catch (e) {
      debugPrint('[AdminBloc] Error rejecting recruiter: $e');
      emit(const AdminError(
        message: 'Impossible de rejeter le recruteur',
      ));
    }
  }

  // ===========================================================================
  // REPORTS
  // ===========================================================================

  Future<void> _onReportsListLoad(
    AdminReportsListLoadRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminReportsListLoading());

    try {
      final reports = await _adminRepository.getPendingReports();

      emit(AdminReportsListLoaded(reports: reports));
    } catch (e) {
      debugPrint('[AdminBloc] Error loading reports: $e');
      emit(const AdminError(
        message: 'Impossible de charger les signalements',
      ));
    }
  }

  Future<void> _onReportDismiss(
    AdminReportDismissRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminReportActionLoading());

    try {
      await _adminRepository.dismissReport(event.reportId);

      emit(const AdminReportActionSuccess(
        message: 'Signalement ignoré',
      ));
    } catch (e) {
      debugPrint('[AdminBloc] Error dismissing report: $e');
      emit(const AdminError(
        message: 'Impossible d\'ignorer le signalement',
      ));
    }
  }

  Future<void> _onReportAction(
    AdminReportActionRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminReportActionLoading());

    try {
      // Action the report
      await _adminRepository.actionReport(
        event.reportId,
        action: event.action,
        notes: event.notes,
      );

      // Suspend target if requested
      if (event.action == 'suspend_user' && event.targetUserId != null) {
        await _adminRepository.suspendUser(event.targetUserId!);
      }
      if (event.action == 'suspend_video' && event.targetVideoId != null) {
        await _adminRepository.suspendVideo(event.targetVideoId!);
      }

      emit(AdminReportActionSuccess(
        message: _actionLabel(event.action),
      ));
    } catch (e) {
      debugPrint('[AdminBloc] Error actioning report: $e');
      emit(const AdminError(
        message: 'Impossible de traiter le signalement',
      ));
    }
  }

  String _actionLabel(String action) {
    switch (action) {
      case 'suspend_user':
        return 'Utilisateur suspendu';
      case 'suspend_video':
        return 'Vidéo supprimée du feed';
      default:
        return 'Action effectuée';
    }
  }

  // ===========================================================================
  // STATS
  // ===========================================================================

  Future<void> _onStatsLoad(
    AdminStatsLoadRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminStatsLoading());

    try {
      final stats = await _adminRepository.getDashboardStats();

      emit(AdminStatsLoaded(stats: stats));
    } catch (e) {
      debugPrint('[AdminBloc] Error loading stats: $e');
      emit(const AdminError(
        message: 'Impossible de charger les statistiques',
      ));
    }
  }
}
