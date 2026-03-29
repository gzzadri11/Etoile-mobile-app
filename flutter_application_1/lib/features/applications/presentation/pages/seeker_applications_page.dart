import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../data/repositories/application_repository.dart';

/// Page showing a seeker's own applications with status
class SeekerApplicationsPage extends StatefulWidget {
  const SeekerApplicationsPage({super.key});

  @override
  State<SeekerApplicationsPage> createState() => _SeekerApplicationsPageState();
}

class _SeekerApplicationsPageState extends State<SeekerApplicationsPage> {
  List<SeekerApplication> _applications = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadApplications();
  }

  Future<void> _loadApplications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final repo = GetIt.I<ApplicationRepository>();
      final applications = await repo.getSeekerApplications();
      if (mounted) {
        setState(() {
          _applications = applications;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('[SeekerApplications] Error: $e');
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _withdrawApplication(SeekerApplication application) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Retirer ma candidature'),
        content: Text(
          'Voulez-vous retirer votre candidature pour "${application.offerTitle}" ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Retirer'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      final repo = GetIt.I<ApplicationRepository>();
      await repo.withdrawApplication(application.id);
      if (mounted) {
        setState(() {
          _applications.removeWhere((a) => a.id == application.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Candidature retirée')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur : ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes candidatures'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryYellow),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spaceLg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: AppTheme.spaceMd),
              Text(_error!, textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.greyWarm)),
              const SizedBox(height: AppTheme.spaceLg),
              ElevatedButton.icon(
                onPressed: _loadApplications,
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    if (_applications.isEmpty) {
      return const EmptyStateWidget(
        showMascotte: true,
        title: 'Aucune candidature',
        subtitle: 'Postulez à des offres depuis le feed pour les voir ici',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadApplications,
      color: AppColors.primaryYellow,
      child: ListView.separated(
        padding: const EdgeInsets.all(AppTheme.spaceMd),
        itemCount: _applications.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppTheme.spaceSm),
        itemBuilder: (context, index) {
          final app = _applications[index];
          return _ApplicationCard(
            application: app,
            onWithdraw: () => _withdrawApplication(app),
          );
        },
      ),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  final SeekerApplication application;
  final VoidCallback onWithdraw;

  const _ApplicationCard({
    required this.application,
    required this.onWithdraw,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppColors.greyLight),
      ),
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + status badge
          Row(
            children: [
              Expanded(
                child: Text(
                  application.offerTitle,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppTheme.spaceSm),
              _StatusBadge(status: application.status),
            ],
          ),
          const SizedBox(height: AppTheme.spaceXs),

          // Company name
          Row(
            children: [
              const Icon(Icons.business, size: 14, color: AppColors.greyWarm),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  application.companyName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.greyWarm,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          // Contract type
          if (application.contractType != null) ...[
            const SizedBox(height: AppTheme.spaceXs),
            Row(
              children: [
                const Icon(Icons.work_outline, size: 14,
                    color: AppColors.primaryOrange),
                const SizedBox(width: 4),
                Text(
                  application.contractType!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.primaryOrange,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ],

          const SizedBox(height: AppTheme.spaceSm),

          // Date + withdraw action
          Row(
            children: [
              Icon(Icons.calendar_today, size: 12,
                  color: AppColors.greyWarm),
              const SizedBox(width: 4),
              Text(
                _formatDate(application.appliedAt),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.greyWarm,
                    ),
              ),
              const Spacer(),
              if (application.status == 'pending')
                TextButton.icon(
                  onPressed: onWithdraw,
                  icon: const Icon(Icons.close, size: 16),
                  label: const Text('Retirer'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.error,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return "Aujourd'hui";
    if (diff.inDays == 1) return 'Hier';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays}j';
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Status badge for application state
class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'contacted' => ('Contacté', AppColors.success),
      'withdrawn' => ('Retirée', AppColors.greyWarm),
      _ => ('En attente', AppColors.primaryOrange),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
