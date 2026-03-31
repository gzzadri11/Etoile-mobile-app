library;

/// Widget d'etat vide reutilisable dans toute l'application.

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// Etat vide : icone/mascotte, titre, sous-titre et bouton d'action.
/// and optional action button in a consistent layout.
class EmptyStateWidget extends StatelessWidget {
  final IconData? icon;
  final Color? iconColor;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool showMascotte;
  final bool compact;
  final bool darkMode;

  const EmptyStateWidget({
    super.key,
    this.icon,
    this.iconColor,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.showMascotte = false,
    this.compact = false,
    this.darkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return _buildCompact(context);
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceLg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (showMascotte)
              Semantics(
                label: 'Mascotte Etoile',
                child: Image.asset(
                  'assets/images/mascotte.png',
                  height: 120,
                ),
              )
            else if (icon != null)
              Icon(
                icon,
                size: 64,
                color: iconColor ?? AppColors.greyWarm,
              ),
            const SizedBox(height: AppTheme.spaceMd),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: darkMode ? AppColors.white : null,
                  ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppTheme.spaceSm),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: darkMode ? AppColors.greyMedium : AppColors.greyWarm,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppTheme.spaceLg),
              OutlinedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.arrow_forward),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCompact(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spaceMd),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            Icon(
              icon,
              size: 32,
              color: iconColor ?? AppColors.greyMedium,
            ),
          if (icon != null) const SizedBox(height: AppTheme.spaceSm),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.greyWarm,
                ),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: AppTheme.spaceXs),
            Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.greyMedium,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
