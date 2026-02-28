import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../data/models/report_model.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';

/// Page listing pending reports for admin moderation.
///
/// Admin can tap a report to open a bottom sheet with details
/// and action buttons (dismiss, suspend video, suspend user).
class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<AdminBloc>().add(const AdminReportsListLoadRequested());

    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<AdminBloc, AdminState>(
          builder: (context, state) {
            final count =
                state is AdminReportsListLoaded ? state.reports.length : 0;
            return Text(
              count > 0 ? 'Signalements ($count)' : 'Signalements',
            );
          },
        ),
      ),
      body: BlocConsumer<AdminBloc, AdminState>(
        listener: (context, state) {
          if (state is AdminReportActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
            // Reload the list after action
            context
                .read<AdminBloc>()
                .add(const AdminReportsListLoadRequested());
          }
          if (state is AdminError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AdminReportsListLoading ||
              state is AdminReportActionLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AdminReportsListLoaded) {
            if (state.reports.isEmpty) {
              return _buildEmpty(context);
            }
            return _buildList(context, state.reports);
          }

          if (state is AdminError) {
            return _buildError(context, state.message);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildList(BuildContext context, List<ReportModel> reports) {
    return RefreshIndicator(
      onRefresh: () async {
        context
            .read<AdminBloc>()
            .add(const AdminReportsListLoadRequested());
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(AppTheme.spaceMd),
        itemCount: reports.length,
        separatorBuilder: (context, index) =>
            const SizedBox(height: AppTheme.spaceSm),
        itemBuilder: (context, index) {
          return _ReportTile(
            report: reports[index],
            onTap: () => _showReportDetail(context, reports[index]),
          );
        },
      ),
    );
  }

  void _showReportDetail(BuildContext context, ReportModel report) {
    final notesController = TextEditingController();
    final bloc = context.read<AdminBloc>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.85,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(AppTheme.spaceLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.greyMedium,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spaceLg),

                  // Title
                  Text(
                    'Detail du signalement',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: AppTheme.spaceLg),

                  // Report info
                  _DetailRow(
                    icon: Icons.flag,
                    label: 'Motif',
                    value: report.reason,
                    color: AppColors.error,
                  ),
                  if (report.description != null &&
                      report.description!.isNotEmpty) ...[
                    const SizedBox(height: AppTheme.spaceSm),
                    _DetailRow(
                      icon: Icons.description,
                      label: 'Description',
                      value: report.description!,
                    ),
                  ],
                  const SizedBox(height: AppTheme.spaceSm),
                  _DetailRow(
                    icon: Icons.category,
                    label: 'Type',
                    value: _reportTypeLabel(report.reportType),
                  ),
                  const SizedBox(height: AppTheme.spaceSm),
                  _DetailRow(
                    icon: Icons.schedule,
                    label: 'Date',
                    value: _formatDateTime(report.createdAt),
                  ),
                  const SizedBox(height: AppTheme.spaceSm),
                  _DetailRow(
                    icon: Icons.person_outline,
                    label: 'Signale par',
                    value: report.reporterEmail ?? report.reporterId,
                  ),
                  if (report.reportedUserEmail != null) ...[
                    const SizedBox(height: AppTheme.spaceSm),
                    _DetailRow(
                      icon: Icons.person,
                      label: 'Utilisateur signale',
                      value: report.reportedUserEmail!,
                    ),
                  ],

                  const SizedBox(height: AppTheme.spaceLg),

                  // Notes field
                  Text(
                    'Notes admin (optionnel)',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: AppTheme.spaceSm),
                  TextField(
                    controller: notesController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      hintText: 'Ajouter une note...',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: AppTheme.spaceLg),

                  // Actions
                  Text(
                    'Actions',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: AppTheme.spaceMd),

                  // Dismiss button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        _showConfirmDialog(
                          context: context,
                          title: 'Ignorer ce signalement ?',
                          content:
                              'Le signalement sera marque comme non pertinent.',
                          confirmLabel: 'Ignorer',
                          confirmColor: AppColors.greyWarm,
                          onConfirm: () {
                            bloc.add(AdminReportDismissRequested(
                              reportId: report.id,
                            ));
                          },
                        );
                      },
                      icon: const Icon(Icons.close),
                      label: const Text('Ignorer'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.greyWarm,
                        side: const BorderSide(color: AppColors.greyMedium),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppTheme.spaceSm),

                  // Suspend video (only if video reported)
                  if (report.reportedVideoId != null)
                    Padding(
                      padding:
                          const EdgeInsets.only(bottom: AppTheme.spaceSm),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(sheetContext);
                            _showConfirmDialog(
                              context: context,
                              title: 'Supprimer la video du feed ?',
                              content:
                                  'La video ne sera plus visible publiquement.',
                              confirmLabel: 'Supprimer du feed',
                              confirmColor: AppColors.warning,
                              onConfirm: () {
                                bloc.add(AdminReportActionRequested(
                                  reportId: report.id,
                                  action: 'suspend_video',
                                  notes: notesController.text.isNotEmpty
                                      ? notesController.text.trim()
                                      : null,
                                  targetVideoId: report.reportedVideoId,
                                ));
                              },
                            );
                          },
                          icon: const Icon(Icons.videocam_off),
                          label: const Text('Supprimer la video'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.warning,
                            foregroundColor: Colors.white,
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ),

                  // Suspend user (if user reported)
                  if (report.reportedUserId != null)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(sheetContext);
                          _showConfirmDialog(
                            context: context,
                            title: 'Suspendre cet utilisateur ?',
                            content:
                                'L\'utilisateur ne pourra plus acceder a la plateforme.',
                            confirmLabel: 'Suspendre',
                            confirmColor: AppColors.error,
                            onConfirm: () {
                              bloc.add(AdminReportActionRequested(
                                reportId: report.id,
                                action: 'suspend_user',
                                notes: notesController.text.isNotEmpty
                                    ? notesController.text.trim()
                                    : null,
                                targetUserId: report.reportedUserId,
                              ));
                            },
                          );
                        },
                        icon: const Icon(Icons.person_off),
                        label: const Text('Suspendre l\'utilisateur'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: Colors.white,
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),

                  const SizedBox(height: AppTheme.spaceLg),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showConfirmDialog({
    required BuildContext context,
    required String title,
    required String content,
    required String confirmLabel,
    required Color confirmColor,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor,
              foregroundColor: Colors.white,
            ),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.check_circle_outline,
      iconColor: AppColors.success.withAlpha(150),
      title: 'Aucun signalement en attente',
      subtitle: 'Tous les signalements ont ete traites.',
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: AppTheme.spaceMd),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.greyWarm,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spaceLg),
            OutlinedButton.icon(
              onPressed: () => context
                  .read<AdminBloc>()
                  .add(const AdminReportsListLoadRequested()),
              icon: const Icon(Icons.refresh),
              label: const Text('Reessayer'),
            ),
          ],
        ),
      ),
    );
  }

  String _reportTypeLabel(String type) {
    switch (type) {
      case 'video':
        return 'Video';
      case 'message':
        return 'Message';
      case 'utilisateur':
        return 'Utilisateur';
      default:
        return 'Inconnu';
    }
  }

  String _formatDateTime(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} a ${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}

/// A card showing a pending report summary.
class _ReportTile extends StatelessWidget {
  final ReportModel report;
  final VoidCallback onTap;

  const _ReportTile({required this.report, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.greyMedium.withAlpha(60)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spaceMd),
          child: Row(
            children: [
              // Type icon
              _buildTypeIcon(),
              const SizedBox(width: AppTheme.spaceMd),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Reason
                    Text(
                      report.reason,
                      style:
                          Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),

                    // Description preview
                    if (report.description != null &&
                        report.description!.isNotEmpty) ...[
                      Text(
                        report.description!,
                        style:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.greyWarm,
                                ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                    ],

                    // Type + date
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _typeColor().withAlpha(25),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _typeLabel(),
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: _typeColor(),
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                        const SizedBox(width: AppTheme.spaceSm),
                        Icon(Icons.schedule,
                            size: 14, color: AppColors.greyWarm),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(report.createdAt),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.greyWarm,
                                  ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: AppTheme.spaceSm),

              // Chevron
              const Icon(
                Icons.chevron_right,
                color: AppColors.greyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeIcon() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: _typeColor().withAlpha(25),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        _typeIcon(),
        color: _typeColor(),
        size: 22,
      ),
    );
  }

  IconData _typeIcon() {
    switch (report.reportType) {
      case 'video':
        return Icons.videocam_outlined;
      case 'message':
        return Icons.chat_bubble_outline;
      case 'utilisateur':
        return Icons.person_outline;
      default:
        return Icons.flag_outlined;
    }
  }

  Color _typeColor() {
    switch (report.reportType) {
      case 'video':
        return AppColors.warning;
      case 'message':
        return AppColors.info;
      case 'utilisateur':
        return AppColors.error;
      default:
        return AppColors.greyWarm;
    }
  }

  String _typeLabel() {
    switch (report.reportType) {
      case 'video':
        return 'Video';
      case 'message':
        return 'Message';
      case 'utilisateur':
        return 'Utilisateur';
      default:
        return 'Autre';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}

/// Simple row for report detail display.
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: color ?? AppColors.greyWarm),
        const SizedBox(width: AppTheme.spaceSm),
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.greyWarm,
                ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
