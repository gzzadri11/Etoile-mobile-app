import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// Primary button widget for Etoile app
///
/// Supports:
/// - Primary (filled with gradient)
/// - Secondary (outlined)
/// - Ghost (text only)
/// - Loading state
/// - Disabled state
class EtoileButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final bool isGhost;
  final IconData? icon;
  final double? width;

  const EtoileButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.isGhost = false,
    this.icon,
    this.width,
  });

  /// Outlined button variant
  const EtoileButton.outlined({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
  })  : isOutlined = true,
        isGhost = false;

  /// Ghost (text only) button variant
  const EtoileButton.ghost({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
  })  : isOutlined = false,
        isGhost = true;

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || isLoading;

    if (isGhost) {
      return _buildGhostButton(context, isDisabled);
    }

    if (isOutlined) {
      return _buildOutlinedButton(context, isDisabled);
    }

    return _buildPrimaryButton(context, isDisabled);
  }

  Widget _buildPrimaryButton(BuildContext context, bool isDisabled) {
    return SizedBox(
      width: width ?? double.infinity,
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: isDisabled
              ? null
              : AppColors.primaryGradient,
          color: isDisabled ? AppColors.greyMedium : null,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          boxShadow: isDisabled
              ? null
              : [
                  BoxShadow(
                    color: AppColors.primaryYellow.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isDisabled ? null : onPressed,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            child: Center(
              child: _buildButtonContent(
                context,
                textColor: isDisabled ? AppColors.greyWarm : AppColors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOutlinedButton(BuildContext context, bool isDisabled) {
    return SizedBox(
      width: width ?? double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: isDisabled ? null : onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: isDisabled ? AppColors.greyMedium : AppColors.primaryYellow,
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
        ),
        child: _buildButtonContent(
          context,
          textColor: isDisabled ? AppColors.greyWarm : AppColors.primaryYellow,
        ),
      ),
    );
  }

  Widget _buildGhostButton(BuildContext context, bool isDisabled) {
    return SizedBox(
      width: width,
      child: TextButton(
        onPressed: isDisabled ? null : onPressed,
        child: _buildButtonContent(
          context,
          textColor: isDisabled ? AppColors.greyWarm : AppColors.greyWarm,
        ),
      ),
    );
  }

  Widget _buildButtonContent(BuildContext context, {required Color textColor}) {
    if (isLoading) {
      return SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(textColor),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: textColor, size: 20),
          const SizedBox(width: AppTheme.spaceSm),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      );
    }

    return Text(
      label,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: textColor,
            fontWeight: FontWeight.w700,
          ),
    );
  }
}

/// Icon button with Etoile styling
class EtoileIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final Color? backgroundColor;
  final Color? iconColor;

  const EtoileIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 48,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: backgroundColor ?? AppColors.iconOnDark,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Center(
            child: Icon(
              icon,
              color: iconColor ?? AppColors.white,
              size: size * 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
