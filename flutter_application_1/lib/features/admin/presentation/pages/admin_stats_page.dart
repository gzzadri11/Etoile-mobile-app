library;

/// Page des statistiques de la plateforme (vue admin).
///
/// Affiche les metriques globales : utilisateurs, videos,
/// abonnements, verifications recruteurs et messages.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';

/// Page des statistiques admin affichant les metriques de la plateforme.
///
/// Displays counters for users, recruiters, videos, messages,
/// and subscriptions. No charts for MVP — just clear numbers.
class AdminStatsPage extends StatelessWidget {
  const AdminStatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Statistiques')),
      body: BlocBuilder<AdminBloc, AdminState>(
        builder: (context, state) {
          if (state is AdminStatsLoading || state is AdminInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AdminStatsLoaded) {
            return _buildStats(context, state);
          }

          if (state is AdminError) {
            return _buildError(context, state.message);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildStats(BuildContext context, AdminStatsLoaded state) {
    final stats = state.stats;

    return RefreshIndicator(
      onRefresh: () async {
        context.read<AdminBloc>().add(const AdminStatsLoadRequested());
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppTheme.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Last update
            Text(
              'Mise a jour : ${_formatDateTime(state.loadedAt)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: AppTheme.spaceLg),

            // Users section
            _buildSectionTitle(context, 'Utilisateurs'),
            const SizedBox(height: AppTheme.spaceSm),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.people,
                    label: 'Total',
                    value: '${stats['totalUsers'] ?? 0}',
                    color: AppColors.warning,
                  ),
                ),
                const SizedBox(width: AppTheme.spaceSm),
                Expanded(
                  child: _StatCard(
                    icon: Icons.person_search,
                    label: 'Chercheurs',
                    value: '${stats['seekerCount'] ?? 0}',
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(width: AppTheme.spaceSm),
                Expanded(
                  child: _StatCard(
                    icon: Icons.business,
                    label: 'Recruteurs',
                    value: '${stats['recruiterCount'] ?? 0}',
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppTheme.spaceLg),

            // Recruiter verification section
            _buildSectionTitle(context, 'Vérification recruteurs'),
            const SizedBox(height: AppTheme.spaceSm),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.verified,
                    label: 'Vérifiés',
                    value: '${stats['verifiedRecruiters'] ?? 0}',
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: AppTheme.spaceSm),
                Expanded(
                  child: _StatCard(
                    icon: Icons.hourglass_top,
                    label: 'En attente',
                    value: '${stats['pendingRecruiters'] ?? 0}',
                    color: AppColors.warning,
                  ),
                ),
                const SizedBox(width: AppTheme.spaceSm),
                Expanded(
                  child: _StatCard(
                    icon: Icons.cancel,
                    label: 'Rejetes',
                    value: '${stats['rejectedRecruiters'] ?? 0}',
                    color: AppColors.danger,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppTheme.spaceLg),

            // Videos section
            _buildSectionTitle(context, 'Videos actives'),
            const SizedBox(height: AppTheme.spaceSm),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.videocam,
                    label: 'Total',
                    value: '${stats['totalVideos'] ?? 0}',
                    color: AppColors.warning,
                  ),
                ),
                const SizedBox(width: AppTheme.spaceSm),
                Expanded(
                  child: _StatCard(
                    icon: Icons.person_pin,
                    label: 'Presentations',
                    value: '${stats['presentationCount'] ?? 0}',
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spaceSm),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.work,
                    label: 'Offres',
                    value: '${stats['offerCount'] ?? 0}',
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: AppTheme.spaceSm),
                Expanded(
                  child: _StatCard(
                    icon: Icons.image,
                    label: 'Affiches',
                    value: '${stats['posterCount'] ?? 0}',
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppTheme.spaceLg),

            // Messages + Premium section
            _buildSectionTitle(context, 'Activite'),
            const SizedBox(height: AppTheme.spaceSm),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.chat,
                    label: 'Messages',
                    value: '${stats['messagesCount'] ?? 0}',
                    color: AppColors.warning,
                  ),
                ),
                const SizedBox(width: AppTheme.spaceSm),
                Expanded(
                  child: _StatCard(
                    icon: Icons.star,
                    label: 'Premium',
                    value: '${stats['premiumCount'] ?? 0}',
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppTheme.spaceLg),

            // Subscriptions section (B2B: recruiters only)
            _buildSectionTitle(context, 'Abonnements actifs'),
            const SizedBox(height: AppTheme.spaceSm),
            _StatCard(
              icon: Icons.business_center,
              label: 'Recruteurs Premium',
              value: '${stats['recruiterSubscriptions'] ?? 0}',
              subtitle: '499 EUR/mois',
              color: AppColors.success,
            ),

            const SizedBox(height: AppTheme.space2Xl),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.danger),
            const SizedBox(height: AppTheme.spaceMd),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spaceLg),
            OutlinedButton.icon(
              onPressed: () => context
                  .read<AdminBloc>()
                  .add(const AdminStatsLoadRequested()),
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} a ${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}

/// A compact stat card with icon, value, and label.
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? subtitle;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withAlpha(60)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spaceSm,
          vertical: AppTheme.spaceMd,
        ),
        child: Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: AppTheme.spaceSm),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
