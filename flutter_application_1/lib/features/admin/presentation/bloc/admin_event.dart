import 'package:equatable/equatable.dart';

abstract class AdminEvent extends Equatable {
  const AdminEvent();

  @override
  List<Object?> get props => [];
}

/// Load dashboard counts (pending recruiters, pending reports)
class AdminDashboardLoadRequested extends AdminEvent {
  const AdminDashboardLoadRequested();
}

/// Load list of recruiters pending verification
class AdminVerificationListLoadRequested extends AdminEvent {
  const AdminVerificationListLoadRequested();
}

/// Load full detail for a specific recruiter
class AdminRecruiterDetailLoadRequested extends AdminEvent {
  final String userId;
  const AdminRecruiterDetailLoadRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Approve a recruiter
class AdminRecruiterApproveRequested extends AdminEvent {
  final String userId;
  const AdminRecruiterApproveRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Reject a recruiter with a reason
class AdminRecruiterRejectRequested extends AdminEvent {
  final String userId;
  final String reason;
  const AdminRecruiterRejectRequested({
    required this.userId,
    required this.reason,
  });

  @override
  List<Object?> get props => [userId, reason];
}

/// Load list of pending reports
class AdminReportsListLoadRequested extends AdminEvent {
  const AdminReportsListLoadRequested();
}

/// Dismiss a report (mark as non-issue)
class AdminReportDismissRequested extends AdminEvent {
  final String reportId;
  const AdminReportDismissRequested({required this.reportId});

  @override
  List<Object?> get props => [reportId];
}

/// Load full platform statistics
class AdminStatsLoadRequested extends AdminEvent {
  const AdminStatsLoadRequested();
}

/// Take action on a report (suspend content/user)
class AdminReportActionRequested extends AdminEvent {
  final String reportId;
  final String action;
  final String? notes;
  final String? targetUserId;
  final String? targetVideoId;
  const AdminReportActionRequested({
    required this.reportId,
    required this.action,
    this.notes,
    this.targetUserId,
    this.targetVideoId,
  });

  @override
  List<Object?> get props => [reportId, action, notes, targetUserId, targetVideoId];
}
