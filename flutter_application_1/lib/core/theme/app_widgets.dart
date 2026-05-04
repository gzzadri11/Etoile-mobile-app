library;

/// Widgets reutilisables de l'application Etoile.

import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import 'app_theme.dart';

class AppButtonPrimary extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const AppButtonPrimary({
    required this.label,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: ElevatedButton(
        onPressed: onTap,
        child: Text(
          label,
          style: AppTextStyles.button().copyWith(color: Colors.white),
        ),
      ),
    );
  }
}

class AppButtonSecondary extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const AppButtonSecondary({
    required this.label,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentBg,
          foregroundColor: AppColors.accentDark,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.button().copyWith(color: AppColors.accentDark),
        ),
      ),
    );
  }
}

class AppChip extends StatelessWidget {
  final String label;
  final Color bg;
  final Color textColor;

  const AppChip({
    required this.label,
    required this.bg,
    required this.textColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption().copyWith(
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class AppScoreBadge extends StatelessWidget {
  final int score;

  const AppScoreBadge({
    required this.score,
    super.key,
  });

  Color get _color => score >= 80 ? AppColors.success : AppColors.warning;
  Color get _bg => score >= 80 ? AppColors.successBg : AppColors.warningBg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        '$score%',
        style: AppTextStyles.label().copyWith(
          color: _color,
          fontSize: 11,
        ),
      ),
    );
  }
}

class AppProgressBar extends StatelessWidget {
  final double value;

  const AppProgressBar({
    required this.value,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: value,
        minHeight: 8,
        backgroundColor: AppColors.bgMuted,
        valueColor: const AlwaysStoppedAnimation(AppColors.accent),
      ),
    );
  }
}

class AppAvatar extends StatelessWidget {
  final String initials;
  final Color color;
  final double size;

  const AppAvatar({
    required this.initials,
    required this.color,
    this.size = 40,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: AppTextStyles.button().copyWith(
          color: Colors.white,
          fontSize: size * 0.35,
        ),
      ),
    );
  }
}

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const AppCard({
    required this.child,
    this.padding,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgPrimary,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: child,
    );
  }
}
