library;

/// Repository pour les signalements d'utilisateurs et de videos via Supabase.

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Acces aux operations de signalement (insertion dans la table reports).
class ReportRepository {
  final SupabaseClient _supabaseClient;

  ReportRepository({required SupabaseClient supabaseClient})
      : _supabaseClient = supabaseClient;

  String get _currentUserId => _supabaseClient.auth.currentUser!.id;

  /// Create a new report
  Future<void> createReport({
    required String reason,
    String? description,
    required String reportedUserId,
    String? reportedVideoId,
    String? reportedMessageId,
  }) async {
    // Guard: cannot report yourself
    if (reportedUserId == _currentUserId) {
      throw Exception('Vous ne pouvez pas vous signaler vous-meme');
    }

    debugPrint('[ReportRepository] Creating report: reason=$reason, '
        'reportedUser=$reportedUserId, video=$reportedVideoId');

    await _supabaseClient.from('reports').insert({
      'reporter_id': _currentUserId,
      'reported_user_id': reportedUserId,
      'reported_video_id': reportedVideoId,
      'reported_message_id': reportedMessageId,
      'reason': reason,
      'description': description,
      'status': 'pending',
    });

    debugPrint('[ReportRepository] Report created successfully');
  }
}
