library;

/// Widget bulle de message avec mascotte Etoile.

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// Variante de couleur pour la bulle mascotte.
enum MascotteVariant { info, success, encouragement }

/// A mascotte speech-bubble widget used for profile completion milestones.
///
/// Displays a small mascotte image next to a colored bubble with
/// a title and message. Can be dismissed by the user.
class MascotteMessage extends StatelessWidget {
  final String title;
  final String message;
  final MascotteVariant variant;
  final VoidCallback? onDismiss;

  const MascotteMessage({
    super.key,
    required this.title,
    required this.message,
    this.variant = MascotteVariant.info,
    this.onDismiss,
  });

  Color get _backgroundColor {
    switch (variant) {
      case MascotteVariant.info:
        return AppColors.info.withAlpha(25);
      case MascotteVariant.success:
        return AppColors.success.withAlpha(25);
      case MascotteVariant.encouragement:
        return AppColors.primaryYellow.withAlpha(40);
    }
  }

  Color get _borderColor {
    switch (variant) {
      case MascotteVariant.info:
        return AppColors.info.withAlpha(80);
      case MascotteVariant.success:
        return AppColors.success.withAlpha(80);
      case MascotteVariant.encouragement:
        return AppColors.primaryYellow.withAlpha(100);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spaceMd),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mascotte image
          Image.asset(
            'assets/images/mascotte.png',
            height: 48,
            width: 48,
            errorBuilder: (_, _, _) => Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: AppColors.primaryYellow.withAlpha(40),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.star_rounded,
                color: AppColors.primaryYellow,
                size: 28,
              ),
            ),
          ),
          const SizedBox(width: AppTheme.spaceSm),
          // Speech bubble
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(AppTheme.spaceMd),
              decoration: BoxDecoration(
                color: _backgroundColor,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(color: _borderColor),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          message,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.greyWarm,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  if (onDismiss != null)
                    GestureDetector(
                      onTap: onDismiss,
                      child: const Padding(
                        padding: EdgeInsets.only(left: AppTheme.spaceSm),
                        child: Icon(
                          Icons.close,
                          size: 16,
                          color: AppColors.greyWarm,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Returns a MascotteMessage for a given profile completion percentage,
  /// or null if no message applies at that percentage.
  static MascotteMessage? forCompletion(int percentage,
      {VoidCallback? onDismiss}) {
    if (percentage >= 40 && percentage < 60) {
      return MascotteMessage(
        title: 'Bon debut !',
        message: 'Continue a completer ton profil',
        variant: MascotteVariant.info,
        onDismiss: onDismiss,
      );
    } else if (percentage >= 60 && percentage < 80) {
      return MascotteMessage(
        title: 'Tu progresses bien !',
        message: 'Plus que quelques infos',
        variant: MascotteVariant.encouragement,
        onDismiss: onDismiss,
      );
    } else if (percentage >= 80 && percentage < 100) {
      return MascotteMessage(
        title: 'Presque fini !',
        message: 'Encore un petit effort',
        variant: MascotteVariant.success,
        onDismiss: onDismiss,
      );
    }
    return null;
  }
}
