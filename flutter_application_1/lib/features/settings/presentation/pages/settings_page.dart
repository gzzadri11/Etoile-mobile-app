import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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
    final isSeeker = authState is AuthAuthenticated && authState.isSeeker;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.settings),
      ),
      body: ListView(
        children: [
          const SizedBox(height: AppTheme.spaceSm),

          // === COMPTE ===
          _buildSectionHeader(context, 'Compte'),
          _buildTile(
            context,
            icon: Icons.person_outline,
            title: AppStrings.editProfile,
            onTap: () => context.push(
              isSeeker
                  ? AppRoutes.editProfile
                  : AppRoutes.editRecruiterProfile,
            ),
          ),
          _buildTile(
            context,
            icon: Icons.star_outline,
            title: AppStrings.goPremium,
            onTap: () => context.push(
              isSeeker
                  ? AppRoutes.premiumSeeker
                  : AppRoutes.premiumRecruiter,
            ),
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

          // === DECONNEXION ===
          _buildTile(
            context,
            icon: Icons.logout,
            title: AppStrings.logout,
            iconColor: AppColors.error,
            textColor: AppColors.error,
            onTap: () => _showLogoutDialog(context),
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
