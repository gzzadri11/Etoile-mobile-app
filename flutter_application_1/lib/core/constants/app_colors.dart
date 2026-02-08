import 'package:flutter/material.dart';

/// Etoile application color palette
///
/// Based on the UX Design specifications:
/// - Primary: Jaune Etoile (#FFB800) and Orange Etoile (#FF8C00)
/// - The color scheme represents optimism and warmth
abstract class AppColors {
  // ============================================
  // PRIMARY COLORS
  // ============================================

  /// Jaune Etoile - Primary accent color
  /// Used for: CTA principal, accents, highlights
  static const Color primaryYellow = Color(0xFFFFB800);

  /// Orange Etoile - Secondary accent color
  /// Used for: CTA secondaire, gradients, hover states
  static const Color primaryOrange = Color(0xFFFF8C00);

  /// Primary gradient for buttons and headers
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryYellow, primaryOrange],
  );

  // ============================================
  // NEUTRAL COLORS
  // ============================================

  /// Pure white - Backgrounds, text on dark
  static const Color white = Color(0xFFFFFFFF);

  /// Deep black - Primary text, video backgrounds
  static const Color black = Color(0xFF1A1A1A);

  /// Warm grey - Secondary text, placeholders
  static const Color greyWarm = Color(0xFF6B6B6B);

  /// Light grey - Separators, secondary backgrounds
  static const Color greyLight = Color(0xFFF5F5F5);

  /// Medium grey - Borders, disabled states
  static const Color greyMedium = Color(0xFFE5E5E5);

  // ============================================
  // SEMANTIC COLORS
  // ============================================

  /// Success green - Validations, confirmations
  static const Color success = Color(0xFF22C55E);

  /// Error red - Errors, critical alerts
  static const Color error = Color(0xFFEF4444);

  /// Warning amber - Warnings
  static const Color warning = Color(0xFFF59E0B);

  /// Info blue - Information, links
  static const Color info = Color(0xFF3B82F6);

  // ============================================
  // SPECIAL COLORS
  // ============================================

  /// Tag background - Semi-transparent yellow
  static const Color tagBackground = Color(0x26FFB800); // 15% opacity

  /// Tag text color
  static const Color tagText = Color(0xFFFF8C00);

  /// Overlay gradient for video cards
  static const LinearGradient videoOverlayGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.transparent,
      Color(0xB3000000), // 70% black opacity
    ],
  );

  /// Semi-transparent white for icons on dark background
  static const Color iconOnDark = Color(0x1AFFFFFF); // 10% opacity

  // ============================================
  // MATERIAL COLOR SWATCH
  // ============================================

  /// Material color swatch for primary yellow
  static const MaterialColor primarySwatch = MaterialColor(
    0xFFFFB800,
    <int, Color>{
      50: Color(0xFFFFF8E1),
      100: Color(0xFFFFECB3),
      200: Color(0xFFFFE082),
      300: Color(0xFFFFD54F),
      400: Color(0xFFFFCA28),
      500: Color(0xFFFFB800),
      600: Color(0xFFFFB300),
      700: Color(0xFFFFAB00),
      800: Color(0xFFFFA000),
      900: Color(0xFFFF8C00),
    },
  );

  // ============================================
  // HELPER METHODS
  // ============================================

  /// Returns appropriate text color for given background
  static Color textColorOn(Color background) {
    return background.computeLuminance() > 0.5 ? black : white;
  }

  /// Returns a color with modified opacity
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
}
