library;

/// Modele de donnees representant un signalement utilisateur.
///
/// Mappe la table `reports` dans Supabase.

import 'package:equatable/equatable.dart';

/// Modele de signalement (report) avec les champs de la table `reports`.
class ReportModel extends Equatable {
  final String id;
  final String reporterId;
  final String? reportedUserId;
  final String? reportedVideoId;
  final String? reportedMessageId;
  final String reason;
  final String? description;
  final String status; // 'pending', 'reviewing', 'actioned', 'dismissed'
  final String? actionTaken;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final String? adminNotes;
  final DateTime createdAt;

  // Joined data (optional, loaded separately)
  final String? reporterEmail;
  final String? reportedUserEmail;

  const ReportModel({
    required this.id,
    required this.reporterId,
    this.reportedUserId,
    this.reportedVideoId,
    this.reportedMessageId,
    required this.reason,
    this.description,
    this.status = 'pending',
    this.actionTaken,
    this.reviewedBy,
    this.reviewedAt,
    this.adminNotes,
    required this.createdAt,
    this.reporterEmail,
    this.reportedUserEmail,
  });

  bool get isPending => status == 'pending';
  bool get isActioned => status == 'actioned';
  bool get isDismissed => status == 'dismissed';

  /// What type of content was reported
  String get reportType {
    if (reportedVideoId != null) return 'video';
    if (reportedMessageId != null) return 'message';
    if (reportedUserId != null) return 'utilisateur';
    return 'inconnu';
  }

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'] as String,
      reporterId: json['reporter_id'] as String,
      reportedUserId: json['reported_user_id'] as String?,
      reportedVideoId: json['reported_video_id'] as String?,
      reportedMessageId: json['reported_message_id'] as String?,
      reason: json['reason'] as String,
      description: json['description'] as String?,
      status: json['status'] as String? ?? 'pending',
      actionTaken: json['action_taken'] as String?,
      reviewedBy: json['reviewed_by'] as String?,
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.parse(json['reviewed_at'] as String)
          : null,
      adminNotes: json['admin_notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      // Joined data from nested select
      reporterEmail: json['reporter'] != null
          ? (json['reporter'] as Map<String, dynamic>)['email'] as String?
          : null,
      reportedUserEmail: json['reported_user'] != null
          ? (json['reported_user'] as Map<String, dynamic>)['email'] as String?
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reporter_id': reporterId,
      'reported_user_id': reportedUserId,
      'reported_video_id': reportedVideoId,
      'reported_message_id': reportedMessageId,
      'reason': reason,
      'description': description,
      'status': status,
      'action_taken': actionTaken,
      'reviewed_by': reviewedBy,
      'admin_notes': adminNotes,
    };
  }

  @override
  List<Object?> get props => [
        id,
        reporterId,
        reportedUserId,
        reportedVideoId,
        reportedMessageId,
        reason,
        status,
        createdAt,
      ];
}
