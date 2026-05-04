library;

/// Configuration du theme de l'application Etoile.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';

abstract class AppSpacing {
  static const double xs  = 4;
  static const double sm  = 8;
  static const double md  = 12;
  static const double lg  = 16;
  static const double xl  = 24;
  static const double xl2 = 32;
  static const double xl3 = 48;
}

abstract class AppRadius {
  static const double tag   = 4;
  static const double btn   = 8;
  static const double card  = 12;
  static const double modal = 16;
  static const double pill  = 100;
}

abstract class AppTextStyles {
  static TextStyle display() => GoogleFonts.sora(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.28,
        color: AppColors.textPrimary,
        height: 1.0,
      );

  static TextStyle h1() => GoogleFonts.sora(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.72,
        color: AppColors.textPrimary,
      );

  static TextStyle h2() => GoogleFonts.sora(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.36,
        color: AppColors.textPrimary,
      );

  static TextStyle body() => GoogleFonts.sora(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: AppColors.textSecondary,
        height: 1.6,
      );

  static TextStyle caption() => GoogleFonts.sora(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.12,
        color: AppColors.textTertiary,
      );

  static TextStyle label() => GoogleFonts.sora(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
        color: AppColors.textTertiary,
      );

  static TextStyle button() => GoogleFonts.sora(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.13,
      );

  static TextStyle buttonSm() => GoogleFonts.sora(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.12,
      );
}

abstract class AppTheme {
  // ============================================
  // SPACING TOKENS (Compatibility aliases)
  // ============================================
  static const double spaceXs  = AppSpacing.xs;
  static const double spaceSm  = AppSpacing.sm;
  static const double spaceMd  = AppSpacing.md;
  static const double spaceLg  = AppSpacing.lg;
  static const double spaceXl  = AppSpacing.xl;
  static const double space2Xl = AppSpacing.xl2;
  static const double space3Xl = AppSpacing.xl3;

  // ============================================
  // BORDER RADIUS TOKENS (Compatibility aliases)
  // ============================================
  static const double radiusSm   = AppRadius.tag;
  static const double radiusMd   = AppRadius.btn;
  static const double radiusLg   = AppRadius.card;
  static const double radiusXl   = AppRadius.modal;
  static const double radiusFull = AppRadius.pill;

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        fontFamily: GoogleFonts.sora().fontFamily,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.accent,
          primary: AppColors.accent,
          onPrimary: Colors.white,
          surface: AppColors.bgPrimary,
          onSurface: AppColors.textPrimary,
          error: AppColors.danger,
        ),
        scaffoldBackgroundColor: AppColors.bgSubtle,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.bgPrimary,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
          titleTextStyle: AppTextStyles.h2(),
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.bgPrimary,
          selectedItemColor: AppColors.accent,
          unselectedItemColor: AppColors.textTertiary,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedLabelStyle:
              TextStyle(fontSize: 9, fontWeight: FontWeight.w600),
          unselectedLabelStyle:
              TextStyle(fontSize: 9, fontWeight: FontWeight.w500),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.bgPrimary,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.card),
            borderSide: const BorderSide(color: AppColors.border, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.card),
            borderSide: const BorderSide(color: AppColors.border, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.card),
            borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
          ),
          labelStyle: AppTextStyles.caption(),
          hintStyle: AppTextStyles.caption(),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.card),
            ),
            textStyle: AppTextStyles.button(),
            minimumSize: const Size(double.infinity, 44),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textPrimary,
            side: const BorderSide(color: AppColors.border, width: 1.5),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.card),
            ),
            textStyle: AppTextStyles.button(),
            minimumSize: const Size(double.infinity, 44),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.accent,
            textStyle: AppTextStyles.button(),
          ),
        ),
        cardTheme: CardThemeData(
          color: AppColors.bgPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.card),
            side: const BorderSide(color: AppColors.border, width: 0.5),
          ),
          margin: EdgeInsets.zero,
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.borderLight,
          thickness: 0.5,
          space: 0,
        ),
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.bgMuted,
          labelStyle: AppTextStyles.caption(),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          shape: const StadiumBorder(),
          side: BorderSide.none,
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: AppColors.accent,
          linearTrackColor: AppColors.bgMuted,
        ),
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        bottomSheetTheme: BottomSheetThemeData(
          backgroundColor: AppColors.bgPrimary,
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppRadius.modal),
            ),
          ),
          showDragHandle: true,
          dragHandleColor: AppColors.border,
          dragHandleSize: const Size(40, 4),
        ),
        dialogTheme: DialogThemeData(
          elevation: 0,
          backgroundColor: AppColors.bgPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.modal),
          ),
          titleTextStyle: AppTextStyles.h1(),
          contentTextStyle: AppTextStyles.body(),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.textPrimary,
          contentTextStyle: AppTextStyles.body().copyWith(
            color: AppColors.bgPrimary,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.btn),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: CircleBorder(),
        ),
        listTileTheme: ListTileThemeData(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          titleTextStyle: AppTextStyles.body().copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
          subtitleTextStyle: AppTextStyles.caption(),
        ),
        tabBarTheme: TabBarThemeData(
          labelColor: AppColors.accent,
          unselectedLabelColor: AppColors.textTertiary,
          labelStyle: AppTextStyles.button(),
          unselectedLabelStyle: AppTextStyles.button().copyWith(
            fontWeight: FontWeight.w500,
          ),
          indicatorColor: AppColors.accent,
          indicatorSize: TabBarIndicatorSize.label,
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        fontFamily: GoogleFonts.sora().fontFamily,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.accent,
          brightness: Brightness.dark,
          primary: AppColors.accent,
          onPrimary: Colors.white,
          surface: const Color(0xFF1A1A1A),
          onSurface: Colors.white,
          error: AppColors.danger,
        ),
        scaffoldBackgroundColor: const Color(0xFF0A0A0B),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF1A1A1A),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          titleTextStyle: AppTextStyles.h2().copyWith(color: Colors.white),
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF1A1A1A),
          selectedItemColor: AppColors.accent,
          unselectedItemColor: Color(0xFF6B7280),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedLabelStyle:
              TextStyle(fontSize: 9, fontWeight: FontWeight.w600),
          unselectedLabelStyle:
              TextStyle(fontSize: 9, fontWeight: FontWeight.w500),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.card),
            ),
            textStyle: AppTextStyles.button(),
            minimumSize: const Size(double.infinity, 44),
          ),
        ),
      );
}
