library;

/// Page de la file d'attente de verification des recruteurs.
///
/// Liste les recruteurs en attente de validation SIRET/document
/// avec navigation vers la fiche de detail pour approuver ou rejeter.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../profile/data/models/recruiter_profile_model.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';

/// Page listing recruiters pending verification.
///
/// Admin can tap on a recruiter to view details and approve/reject.
class VerificationQueuePage extends StatelessWidget {
  const VerificationQueuePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<AdminBloc, AdminState>(
          builder: (context, state) {
            final count = state is AdminVerificationListLoaded
                ? state.recruiters.length
                : 0;
            return Text(
              count > 0
                  ? 'Verifications ($count)'
                  : 'Verifications',
            );
          },
        ),
      ),
      body: BlocBuilder<AdminBloc, AdminState>(
        builder: (context, state) {
          if (state is AdminVerificationListLoading || state is AdminInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AdminError) {
            return _buildError(context, state.message);
          }

          if (state is AdminVerificationListLoaded) {
            if (state.recruiters.isEmpty) {
              return _buildEmpty(context);
            }
            return _buildList(context, state.recruiters);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildList(BuildContext context, List<RecruiterProfile> recruiters) {
    return RefreshIndicator(
      onRefresh: () async {
        context
            .read<AdminBloc>()
            .add(const AdminVerificationListLoadRequested());
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(AppTheme.spaceMd),
        itemCount: recruiters.length,
        separatorBuilder: (context, index) => const SizedBox(height: AppTheme.spaceSm),
        itemBuilder: (context, index) {
          return _RecruiterTile(
            recruiter: recruiters[index],
            onTap: () {
              // Navigate to detail page (Story 14.4)
              context.push(
                '/admin/verifications/${recruiters[index].userId}',
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.verified_outlined,
      iconColor: AppColors.success.withAlpha(150),
      title: 'Aucun recruteur en attente',
      subtitle: 'Tous les recruteurs ont ete verifies.',
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
                  .add(const AdminVerificationListLoadRequested()),
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}

/// A card showing a pending recruiter's summary info.
class _RecruiterTile extends StatelessWidget {
  final RecruiterProfile recruiter;
  final VoidCallback onTap;

  const _RecruiterTile({required this.recruiter, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.border.withAlpha(60)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spaceMd),
          child: Row(
            children: [
              // Logo or placeholder
              _buildAvatar(),
              const SizedBox(width: AppTheme.spaceMd),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Company name
                    Text(
                      recruiter.companyName.isNotEmpty
                          ? recruiter.companyName
                          : 'Entreprise sans nom',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),

                    // SIRET
                    if (recruiter.siret != null &&
                        recruiter.siret!.isNotEmpty) ...[
                      Text(
                        'SIRET : ${recruiter.siret}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                              fontFamily: 'monospace',
                            ),
                      ),
                      const SizedBox(height: 2),
                    ],

                    // Sector + date
                    Row(
                      children: [
                        if (recruiter.sector != null) ...[
                          Icon(Icons.business_outlined,
                              size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              recruiter.sector!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: AppColors.textSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: AppTheme.spaceSm),
                        ],
                        Icon(Icons.schedule,
                            size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(recruiter.createdAt),
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: AppTheme.spaceSm),

              // Badge + chevron
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'En attente',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.border,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    if (recruiter.logoUrl != null && recruiter.logoUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          recruiter.logoUrl!,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholderAvatar(),
        ),
      );
    }
    return _buildPlaceholderAvatar();
  }

  Widget _buildPlaceholderAvatar() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.accent.withAlpha(25),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.business,
        color: AppColors.accent,
        size: 24,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
