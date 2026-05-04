library;

/// Page de verification detaillee d'un recruteur.
///
/// Affiche les informations du profil recruteur (SIRET, document,
/// entreprise) et permet a l'admin d'approuver ou rejeter la demande.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../profile/data/models/recruiter_profile_model.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';

/// Detail page for a recruiter pending verification.
///
/// Shows all recruiter info (SIRET, company, document) and
/// provides Approve / Reject actions for the admin.
class RecruiterVerificationPage extends StatelessWidget {
  final String userId;

  const RecruiterVerificationPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Détail recruteur')),
      body: BlocConsumer<AdminBloc, AdminState>(
        listener: (context, state) {
          if (state is AdminRecruiterActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
            Navigator.pop(context);
          }
          if (state is AdminError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.danger,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AdminRecruiterDetailLoading ||
              state is AdminRecruiterActionLoading ||
              state is AdminInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AdminRecruiterDetailLoaded) {
            return _buildDetail(context, state);
          }

          if (state is AdminError) {
            return _buildError(context, state.message);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildDetail(BuildContext context, AdminRecruiterDetailLoaded state) {
    final profile = state.profile;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spaceMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with logo
                _buildHeader(context, profile),
                const SizedBox(height: AppTheme.spaceLg),

                // Info sections
                _buildInfoSection(context, 'Informations entreprise', [
                  _InfoRow(
                    label: 'Nom',
                    value: profile.companyName.isNotEmpty
                        ? profile.companyName
                        : 'Non renseigné',
                  ),
                  _InfoRow(
                    label: 'SIRET',
                    value: profile.siret ?? 'Non renseigné',
                    mono: true,
                  ),
                  if (profile.siren != null)
                    _InfoRow(label: 'SIREN', value: profile.siren!, mono: true),
                  if (profile.legalForm != null)
                    _InfoRow(
                        label: 'Forme juridique', value: profile.legalForm!),
                  _InfoRow(
                    label: 'Secteur',
                    value: profile.sector ?? 'Non renseigné',
                  ),
                ]),

                const SizedBox(height: AppTheme.spaceMd),

                _buildInfoSection(context, 'Compte', [
                  _InfoRow(
                    label: 'Inscription',
                    value: _formatDateTime(state.registeredAt),
                  ),
                  _InfoRow(
                    label: 'Statut',
                    value: _statusLabel(profile.verificationStatus),
                  ),
                ]),

                const SizedBox(height: AppTheme.spaceMd),

                // Document section
                _buildDocumentSection(context, profile, state.documentSignedUrl),

                const SizedBox(height: AppTheme.spaceMd),

                // Description
                if (profile.description != null &&
                    profile.description!.isNotEmpty) ...[
                  _buildInfoSection(context, 'Description', []),
                  Text(
                    profile.description!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                  ),
                  const SizedBox(height: AppTheme.spaceMd),
                ],

                // Locations
                if (profile.locations.isNotEmpty) ...[
                  _buildInfoSection(context, 'Localisations', []),
                  Wrap(
                    spacing: AppTheme.spaceSm,
                    runSpacing: AppTheme.spaceXs,
                    children: profile.locations
                        .map((loc) => Chip(
                              label: Text(loc),
                              visualDensity: VisualDensity.compact,
                            ))
                        .toList(),
                  ),
                ],

                const SizedBox(height: AppTheme.space2Xl),
              ],
            ),
          ),
        ),

        // Action buttons (fixed at bottom)
        if (profile.isPending) _buildActions(context),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, RecruiterProfile profile) {
    return Row(
      children: [
        // Logo
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: profile.logoUrl != null && profile.logoUrl!.isNotEmpty
              ? Image.network(
                  profile.logoUrl!,
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildLogoPlaceholder(),
                )
              : _buildLogoPlaceholder(),
        ),
        const SizedBox(width: AppTheme.spaceMd),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile.companyName.isNotEmpty
                    ? profile.companyName
                    : 'Entreprise sans nom',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accent.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'En attente de vérification',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLogoPlaceholder() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.accent.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.business, color: AppColors.accent, size: 32),
    );
  }

  Widget _buildInfoSection(
      BuildContext context, String title, List<_InfoRow> rows) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: AppTheme.spaceSm),
        for (final row in rows)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 120,
                  child: Text(
                    row.label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ),
                Expanded(
                  child: Text(
                    row.value,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontFamily: row.mono ? 'monospace' : null,
                        ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildDocumentSection(
      BuildContext context, RecruiterProfile profile, String? signedUrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Document justificatif',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: AppTheme.spaceSm),
        if (profile.documentUrl != null &&
            profile.documentUrl!.isNotEmpty) ...[
          // Document info card (tappable)
          GestureDetector(
            onTap: signedUrl != null
                ? () => _openDocument(context, signedUrl, profile.documentType)
                : null,
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: AppColors.success.withAlpha(80)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spaceMd),
                child: Row(
                  children: [
                    const Icon(Icons.description, color: AppColors.success),
                    const SizedBox(width: AppTheme.spaceSm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile.documentType ?? 'Document',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w500),
                          ),
                          if (profile.documentUploadedAt != null)
                            Text(
                              'Uploadé le ${_formatDate(profile.documentUploadedAt!)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                          Text(
                            signedUrl != null
                                ? 'Appuyez pour visualiser'
                                : 'Document inaccessible (vérifier les permissions storage)',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: signedUrl != null
                                      ? AppColors.accent
                                      : AppColors.danger,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.open_in_new,
                        size: 20, color: AppColors.accent),
                  ],
                ),
              ),
            ),
          ),
          // Document image preview (for image documents)
          if (signedUrl != null &&
              profile.documentUrl != null &&
              !profile.documentUrl!.endsWith('.pdf')) ...[
            const SizedBox(height: AppTheme.spaceSm),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                signedUrl,
                width: double.infinity,
                height: 250,
                fit: BoxFit.contain,
                loadingBuilder: (_, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 250,
                    color: AppColors.bgSubtle,
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
                errorBuilder: (_, _, _) => Container(
                  height: 100,
                  color: AppColors.bgSubtle,
                  child: const Center(
                    child: Text('Impossible de charger l\'aperçu'),
                  ),
                ),
              ),
            ),
          ],
        ] else
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: AppColors.danger.withAlpha(80)),
            ),
            color: AppColors.danger.withAlpha(10),
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spaceMd),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber,
                      color: AppColors.danger),
                  const SizedBox(width: AppTheme.spaceSm),
                  Expanded(
                    child: Text(
                      'Aucun document justificatif uploadé',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.danger,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  /// Open document in browser or show full-screen image dialog.
  void _openDocument(BuildContext context, String url, String? docType) {
    if (docType != null && docType.toLowerCase().contains('pdf')) {
      // Open PDF in browser
      launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      // Show image in full-screen dialog
      showDialog(
        context: context,
        builder: (_) => Dialog(
          insetPadding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBar(
                title: Text(docType ?? 'Document'),
                leading: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
                automaticallyImplyLeading: false,
              ),
              Flexible(
                child: InteractiveViewer(
                  child: Image.network(
                    url,
                    fit: BoxFit.contain,
                    loadingBuilder: (_, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const SizedBox(
                        height: 300,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    },
                    errorBuilder: (_, _, _) => const SizedBox(
                      height: 200,
                      child: Center(
                        child: Text('Impossible de charger le document'),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Reject button
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showRejectDialog(context),
                icon: const Icon(Icons.close, color: AppColors.danger),
                label: const Text('Rejeter'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  side: const BorderSide(color: AppColors.danger),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(width: AppTheme.spaceMd),
            // Approve button
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _showApproveDialog(context),
                icon: const Icon(Icons.check),
                label: const Text('Approuver'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showApproveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Approuver ce recruteur ?'),
        content: const Text(
          'Le recruteur pourra publier des offres et contacter des chercheurs.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AdminBloc>().add(
                    AdminRecruiterApproveRequested(userId: userId),
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
            ),
            child: const Text('Approuver'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context) {
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Rejeter ce recruteur ?'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: reasonController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Motif du rejet (obligatoire)',
              alignLabelWithHint: true,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Veuillez indiquer un motif';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(dialogContext);
              context.read<AdminBloc>().add(
                    AdminRecruiterRejectRequested(
                      userId: userId,
                      reason: reasonController.text.trim(),
                    ),
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            child: const Text('Rejeter'),
          ),
        ],
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
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: AppTheme.spaceLg),
            OutlinedButton.icon(
              onPressed: () => context
                  .read<AdminBloc>()
                  .add(AdminRecruiterDetailLoadRequested(userId: userId)),
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _formatDateTime(DateTime date) {
    return '${_formatDate(date)} à ${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'En attente';
      case 'verified':
        return 'Vérifié';
      case 'rejected':
        return 'Rejeté';
      default:
        return status;
    }
  }
}

/// Simple data holder for info rows.
class _InfoRow {
  final String label;
  final String value;
  final bool mono;
  const _InfoRow({required this.label, required this.value, this.mono = false});
}
