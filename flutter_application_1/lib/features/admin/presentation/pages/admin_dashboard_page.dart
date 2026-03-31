library;

/// Page du tableau de bord administrateur.
///
/// Affiche les compteurs principaux (recruteurs en attente, signalements)
/// et fournit la navigation vers les sous-pages admin.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';

/// Admin dashboard hub page.
///
/// Displays 3 navigation cards with badge counts:
/// - Verifications recruteurs (pending count)
/// - Signalements (pending count)
/// - Statistiques
class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administration'),
      ),
      body: BlocBuilder<AdminBloc, AdminState>(
        builder: (context, state) {
          if (state is AdminDashboardLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AdminError) {
            return _buildError(context, state.message);
          }

          final pendingRecruiters =
              state is AdminDashboardLoaded ? state.pendingRecruiters : 0;
          final pendingReports =
              state is AdminDashboardLoaded ? state.pendingReports : 0;

          return RefreshIndicator(
            onRefresh: () async {
              context
                  .read<AdminBloc>()
                  .add(const AdminDashboardLoadRequested());
              // Wait a bit for the state to update
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: ListView(
              padding: const EdgeInsets.all(AppTheme.spaceMd),
              children: [
                Text(
                  'Tableau de bord',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: AppTheme.spaceXs),
                Text(
                  'Gerez la plateforme Etoile',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.greyWarm,
                      ),
                ),
                const SizedBox(height: AppTheme.spaceLg),

                // Verifications card
                _DashboardCard(
                  icon: Icons.verified_user_outlined,
                  iconColor: AppColors.primaryOrange,
                  title: 'Verifications',
                  subtitle: 'Recruteurs en attente de validation',
                  badgeCount: pendingRecruiters,
                  onTap: () => context.push(AppRoutes.adminVerifications),
                ),
                const SizedBox(height: AppTheme.spaceMd),

                // Reports card
                _DashboardCard(
                  icon: Icons.flag_outlined,
                  iconColor: AppColors.error,
                  title: 'Signalements',
                  subtitle: 'Contenus signales a moderer',
                  badgeCount: pendingReports,
                  onTap: () => context.push(AppRoutes.adminReports),
                ),
                const SizedBox(height: AppTheme.spaceMd),

                // Stats card
                _DashboardCard(
                  icon: Icons.bar_chart_outlined,
                  iconColor: AppColors.success,
                  title: 'Statistiques',
                  subtitle: 'Metriques cles de la plateforme',
                  onTap: () => context.push(AppRoutes.adminStats),
                ),
              ],
            ),
          );
        },
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
            const Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.error,
            ),
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
                  .add(const AdminDashboardLoadRequested()),
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}

/// A card in the admin dashboard with icon, title, subtitle, and optional badge.
class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final int? badgeCount;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.badgeCount,
    required this.onTap,
  });

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
              // Icon container
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: AppTheme.spaceMd),

              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style:
                          Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style:
                          Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.greyWarm,
                              ),
                    ),
                  ],
                ),
              ),

              // Badge + chevron
              if (badgeCount != null && badgeCount! > 0) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: iconColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$badgeCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spaceSm),
              ],

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
}
