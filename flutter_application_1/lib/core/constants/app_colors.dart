library;

/// Palette de couleurs de l'application Etoile.

import 'package:flutter/material.dart';

abstract class AppColors {
  // ============================================
  // ACCENT
  // ============================================

  static const accent      = Color(0xFF635BFF);
  static const accentLight = Color(0xFFC4C1FF);
  static const accentDark  = Color(0xFF4F46E5);
  static const accentBg    = Color(0xFFF0EFFF);
  static const accentDeep  = Color(0xFF312E81);

  // ============================================
  // SUCCESS
  // ============================================

  static const success       = Color(0xFF10B981);
  static const successLight  = Color(0xFF6EE7B7);
  static const successBg     = Color(0xFFECFDF5);
  static const successDark   = Color(0xFF059669);

  // ============================================
  // WARNING
  // ============================================

  static const warning       = Color(0xFFF59E0B);
  static const warningLight  = Color(0xFFFDE68A);
  static const warningBg     = Color(0xFFFFFBEB);
  static const warningDark   = Color(0xFFD97706);

  // ============================================
  // DANGER
  // ============================================

  static const danger        = Color(0xFFEF4444);
  static const dangerLight   = Color(0xFFFECACA);
  static const dangerBg      = Color(0xFFFEF2F2);
  static const dangerDark    = Color(0xFFB91C1C);

  // ============================================
  // NEUTRALS
  // ============================================

  static const textPrimary   = Color(0xFF0A0A0B);
  static const textSecondary = Color(0xFF6B7280);
  static const textTertiary  = Color(0xFF9CA3AF);
  static const bgPrimary     = Color(0xFFFFFFFF);
  static const bgSubtle      = Color(0xFFF9FAFB);
  static const bgMuted       = Color(0xFFF3F4F6);
  static const border        = Color(0xFFE5E7EB);
  static const borderLight   = Color(0xFFF3F4F6);

  // ============================================
  // MATERIAL COLOR SWATCH
  // ============================================

  static const MaterialColor primarySwatch = MaterialColor(
    0xFF635BFF,
    <int, Color>{
      50: Color(0xFFF0EFFF),
      100: Color(0xFFE0DEFF),
      200: Color(0xFFC4C1FF),
      300: Color(0xFFA8A4FF),
      400: Color(0xFF8C87FF),
      500: Color(0xFF635BFF),
      600: Color(0xFF4F46E5),
      700: Color(0xFF4338CA),
      800: Color(0xFF3730A3),
      900: Color(0xFF312E81),
    },
  );

  // ============================================
  // HELPER METHODS
  // ============================================

  static Color textColorOn(Color background) {
    return background.computeLuminance() > 0.5 ? textPrimary : bgPrimary;
  }

  static Color withOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }
}
