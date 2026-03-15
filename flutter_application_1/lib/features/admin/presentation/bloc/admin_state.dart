import 'package:equatable/equatable.dart';

import '../../data/models/report_model.dart';
import '../../../profile/data/models/recruiter_profile_model.dart';

abstract class AdminState extends Equatable {
  const AdminState();

  @override
  List<Object?> get props => [];
}

class AdminInitial extends AdminState {
  const AdminInitial();
}

// ---------------------------------------------------------------------------
// DASHBOARD
// ---------------------------------------------------------------------------

class AdminDashboardLoading extends AdminState {
  const AdminDashboardLoading();
}

class AdminDashboardLoaded extends AdminState {
  final int pendingRecruiters;
  final int pendingReports;

  const AdminDashboardLoaded({
    required this.pendingRecruiters,
    required this.pendingReports,
  });

  @override
  List<Object?> get props => [pendingRecruiters, pendingReports];
}

// ---------------------------------------------------------------------------
// VERIFICATION QUEUE
// ---------------------------------------------------------------------------

class AdminVerificationListLoading extends AdminState {
  const AdminVerificationListLoading();
}

class AdminVerificationListLoaded extends AdminState {
  final List<RecruiterProfile> recruiters;

  const AdminVerificationListLoaded({required this.recruiters});

  @override
  List<Object?> get props => [recruiters];
}

// ---------------------------------------------------------------------------
// RECRUITER DETAIL
// ---------------------------------------------------------------------------

class AdminRecruiterDetailLoading extends AdminState {
  const AdminRecruiterDetailLoading();
}

class AdminRecruiterDetailLoaded extends AdminState {
  final RecruiterProfile profile;
  final DateTime registeredAt;
  final String? documentSignedUrl;

  const AdminRecruiterDetailLoaded({
    required this.profile,
    required this.registeredAt,
    this.documentSignedUrl,
  });

  @override
  List<Object?> get props => [profile, registeredAt, documentSignedUrl];
}

/// Emitted after a successful approve or reject action.
class AdminRecruiterActionSuccess extends AdminState {
  final String message;

  const AdminRecruiterActionSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class AdminRecruiterActionLoading extends AdminState {
  const AdminRecruiterActionLoading();
}

// ---------------------------------------------------------------------------
// REPORTS
// ---------------------------------------------------------------------------

class AdminReportsListLoading extends AdminState {
  const AdminReportsListLoading();
}

class AdminReportsListLoaded extends AdminState {
  final List<ReportModel> reports;

  const AdminReportsListLoaded({required this.reports});

  @override
  List<Object?> get props => [reports];
}

class AdminReportActionLoading extends AdminState {
  const AdminReportActionLoading();
}

class AdminReportActionSuccess extends AdminState {
  final String message;

  const AdminReportActionSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

// ---------------------------------------------------------------------------
// STATS
// ---------------------------------------------------------------------------

class AdminStatsLoading extends AdminState {
  const AdminStatsLoading();
}

class AdminStatsLoaded extends AdminState {
  final Map<String, dynamic> stats;
  final DateTime loadedAt;

  AdminStatsLoaded({required this.stats})
      : loadedAt = DateTime.now();

  @override
  List<Object?> get props => [stats, loadedAt];
}

// ---------------------------------------------------------------------------
// ERROR
// ---------------------------------------------------------------------------

class AdminError extends AdminState {
  final String message;

  const AdminError({required this.message});

  @override
  List<Object?> get props => [message];
}
