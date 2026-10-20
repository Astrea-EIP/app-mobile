import 'package:flutter/material.dart';

/// Semantic colors adhering strictly to Astrea Figma Foundations & WCAG 2.2 AA.
class AppColors {
  // Primary
  static const Color primary = Color(
    0xFF4CAF50,
  ); // Fond vert boutons, pas de texte direct
  static const Color primaryHover = Color(0xFF43A047);
  static const Color primaryStrong = Color(
    0xFF2E7D32,
  ); // Texte & icônes verts sur fond clair (≥ 4.5:1)
  static const Color onPrimary = Color(
    0xFF212529,
  ); // Texte sombre sur fond primary

  // Accent
  static const Color accent = Color(0xFFFF9800); // Fond orange
  static const Color accentStrong = Color(
    0xFFB34700,
  ); // Texte/icônes orange sur fond clair
  static const Color onAccent = Color(0xFF212529); // Texte sur fond accent

  // Tertiary
  static const Color tertiary = Color(
    0xFF2B6CB0,
  ); // Bleu : liens, tracé secondaire

  // Surfaces & Backgrounds
  static const Color surface = Color(0xFFFFFFFF); // Cartes, champs, feuilles
  static const Color page = Color(0xFFFAF7F2); // Fond de page
  static const Color map = Color(0xFFEFEAE0); // Fond de la carte
  static const Color badge = Color(0xFFE8F5E9); // Fond des pastilles vertes
  static const Color accentBg = Color(
    0xFFFFF3E0,
  ); // Fond orange pâle (pastilles/icônes accent)
  static const Color tertiaryBg = Color(
    0xFFEBF4FF,
  ); // Fond bleu pâle (pastilles/icônes tertiary)

  // Text
  static const Color ink = Color(0xFF212529); // Texte principal
  static const Color muted = Color(0xFF5B6560); // Texte secondaire

  // Borders
  static const Color border = Color(0xFFDDD8CE); // Séparateurs décoratifs
  static const Color borderStrong = Color(
    0xFF7C847F,
  ); // Contours champs, pistes switch (≥ 3:1)

  // Error & Feedback
  static const Color error = Color(0xFFB3261E); // Messages & contours erreur
  static const Color errorBg = Color(0xFFFDEDEB); // Fond des messages d'erreur
  static const Color errorBorder = Color(0xFFB3261E);
  static const Color onError = Color(0xFFFFFFFF); // SOS / texte sur fond error

  // Brand Gradient
  static const Color brandGradientStart = Color(0xFF43A047);
  static const Color brandGradientEnd = Color(0xFFFFA726);
}

/// Spacing tokens matching Figma Foundations.
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double s12 = 12.0;
  static const double md = 16.0;
  static const double s20 = 20.0;
  static const double lg = 24.0;
  static const double s32 = 32.0;
  static const double s40 = 40.0;
  static const double s56 = 56.0;
}

/// Border radius tokens matching Figma Foundations.
class AppRadius {
  static const double sm = 8.0;
  static const double md = 10.0;
  static const double lg = 12.0;
  static const double full = 999.0;
}

/// Typography styles matching Astrea Foundations (Montserrat pour les titres, Inter pour le corps).
class AppTypography {
  // Titres
  static const TextStyle titreXl = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
    letterSpacing: -0.5,
  );

  static const TextStyle titreLg = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
    letterSpacing: -0.3,
  );

  static const TextStyle titreMd = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.ink,
  );

  // Corps
  static const TextStyle corpsLg = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.ink,
    height: 1.5,
  );

  static const TextStyle corpsLgGras = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.ink,
  );

  static const TextStyle corpsMd = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.ink,
    height: 1.4,
  );

  static const TextStyle corpsMdGras = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.ink,
  );

  static const TextStyle petit = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.muted,
  );

  static const TextStyle petitGras = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.ink,
  );
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.page,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        secondary: AppColors.accent,
        onSecondary: AppColors.onAccent,
        error: AppColors.error,
        onError: AppColors.onError,
        surface: AppColors.surface,
        onSurface: AppColors.ink,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.ink),
        titleTextStyle: AppTypography.titreMd,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          elevation: 0,
          textStyle: AppTypography.corpsLgGras,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ink,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          side: const BorderSide(color: AppColors.borderStrong),
          textStyle: AppTypography.corpsLgGras,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.s12,
        ),
        hintStyle: AppTypography.corpsMd.copyWith(color: AppColors.muted),
        labelStyle: AppTypography.corpsMd.copyWith(color: AppColors.ink),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(color: AppColors.borderStrong),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(color: AppColors.borderStrong),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(
            color: AppColors.primaryStrong,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(color: AppColors.errorBorder),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(color: AppColors.errorBorder, width: 2),
        ),
      ),
    );
  }
}
