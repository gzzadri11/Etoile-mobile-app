library;

/// Page des parametres de l'application.
///
/// Regroupe les options utilisateur : compte, notifications,
/// donnees personnelles (RGPD), mentions legales, FAQ,
/// contact support et deconnexion.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final isAdmin = authState is AuthAuthenticated && authState.isAdmin;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.settings),
      ),
      body: ListView(
        children: [
          const SizedBox(height: AppTheme.spaceSm),

          // === ADMINISTRATION (admin only) ===
          if (isAdmin) ...[
            _buildSectionHeader(context, 'Administration'),
            _buildTile(
              context,
              icon: Icons.admin_panel_settings,
              title: 'Administration',
              iconColor: AppColors.info,
              onTap: () => context.push('/admin'),
            ),
            const Divider(height: AppTheme.spaceLg),
          ],

          // === COMPTE ===
          _buildSectionHeader(context, 'Compte'),
          _buildTile(
            context,
            icon: Icons.person_outline,
            title: AppStrings.editProfile,
            onTap: () => context.push(AppRoutes.editProfile),
          ),
          _buildTile(
            context,
            icon: Icons.download_outlined,
            title: 'Exporter mes donnees',
            onTap: () => _showExportDataDialog(context),
          ),
          _buildTile(
            context,
            icon: Icons.block,
            title: 'Utilisateurs bloques',
            onTap: () => context.push('/settings/blocked'),
          ),

          const Divider(height: AppTheme.spaceLg),

          // === SUPPORT ===
          _buildSectionHeader(context, 'Support'),
          _buildTile(
            context,
            icon: Icons.help_outline,
            title: AppStrings.faq,
            onTap: () => context.push(AppRoutes.faq),
          ),
          _buildTile(
            context,
            icon: Icons.mail_outline,
            title: AppStrings.contactSupport,
            onTap: () => context.push(AppRoutes.contactSupport),
          ),

          const Divider(height: AppTheme.spaceLg),

          // === INFORMATIONS ===
          _buildSectionHeader(context, 'Informations'),
          _buildTile(
            context,
            icon: Icons.description_outlined,
            title: AppStrings.termsOfService,
            onTap: () => context.push(AppRoutes.termsOfService),
          ),
          _buildTile(
            context,
            icon: Icons.shield_outlined,
            title: AppStrings.privacyPolicy,
            onTap: () => context.push(AppRoutes.privacyPolicy),
          ),
          _buildTile(
            context,
            icon: Icons.info_outline,
            title: AppStrings.about,
            subtitle: 'Version 1.0.0',
          ),

          const Divider(height: AppTheme.spaceLg),

          // === COMPTE (actions) ===
          _buildTile(
            context,
            icon: Icons.logout,
            title: AppStrings.logout,
            iconColor: AppColors.error,
            textColor: AppColors.error,
            onTap: () => _showLogoutDialog(context),
          ),
          _buildTile(
            context,
            icon: Icons.delete_forever,
            title: AppStrings.deleteAccount,
            iconColor: AppColors.error,
            textColor: AppColors.error,
            onTap: () => _showDeleteAccountDialog(context),
          ),

          const SizedBox(height: AppTheme.space2Xl),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spaceMd,
        vertical: AppTheme.spaceSm,
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.greyWarm,
            ),
      ),
    );
  }

  Widget _buildTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Color? iconColor,
    Color? textColor,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? AppColors.greyWarm),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: textColor,
            ),
      ),
      subtitle: subtitle != null
          ? Text(subtitle, style: Theme.of(context).textTheme.bodySmall)
          : null,
      trailing: onTap != null
          ? const Icon(Icons.chevron_right, color: AppColors.greyMedium)
          : null,
      onTap: onTap,
    );
  }

  void _showExportDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Exporter mes donnees'),
        content: const Text(
          'Vos donnees personnelles seront preparees au format JSON '
          '(RGPD Art. 20 — droit a la portabilite).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _performExport(context);
            },
            child: const Text('Exporter'),
          ),
        ],
      ),
    );
  }

  Future<void> _performExport(BuildContext context) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await Supabase.instance.client.functions.invoke(
        'export-user-data',
      );

      // Dismiss loading
      if (context.mounted) Navigator.pop(context);

      if (response.status != 200) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erreur lors de l\'export. Reessayez.')),
          );
        }
        return;
      }

      final jsonString = const JsonEncoder.withIndent('  ').convert(response.data);

      if (context.mounted) {
        showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Vos donnees'),
            content: SizedBox(
              width: double.maxFinite,
              height: 400,
              child: SingleChildScrollView(
                child: SelectableText(
                  jsonString,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: jsonString));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Donnees copiees dans le presse-papiers')),
                  );
                },
                child: const Text('Copier'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text(AppStrings.close),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      debugPrint('[Settings] Export error: $e');
      if (context.mounted) {
        Navigator.pop(context); // Dismiss loading if still showing
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    }
  }

  void _showDeleteAccountDialog(BuildContext context) {
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => BlocConsumer<AuthBloc, AuthState>(
        listener: (ctx, state) {
          if (state is AuthAccountDeleted) {
            Navigator.pop(dialogContext);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Votre compte sera supprime dans 30 jours. '
                  'Reconnectez-vous avant pour annuler.',
                ),
              ),
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (ctx, state) => AlertDialog(
          title: const Text('Supprimer votre compte ?'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cette action est irreversible apres 30 jours. '
                  'Toutes vos donnees (profil, videos, messages) seront supprimees. '
                  'Vous avez 30 jours pour vous reconnecter et annuler.',
                ),
                const SizedBox(height: AppTheme.spaceMd),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirmez votre mot de passe',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Mot de passe requis' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(AppStrings.cancel),
            ),
            TextButton(
              onPressed: state is AuthLoading
                  ? null
                  : () {
                      if (formKey.currentState!.validate()) {
                        context.read<AuthBloc>().add(
                              AuthDeleteAccountRequested(
                                password: passwordController.text,
                              ),
                            );
                      }
                    },
              child: state is AuthLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'Supprimer definitivement',
                      style: TextStyle(color: AppColors.error),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(AppStrings.logout),
        content: const Text('Etes-vous sur de vouloir vous deconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AuthBloc>().add(const AuthLogoutRequested());
            },
            child: Text(
              AppStrings.confirm,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
