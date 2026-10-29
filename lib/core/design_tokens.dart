import 'package:flutter/material.dart';

abstract final class AstreaColors {
  // Primary
  static const Color primary = Color(0xFF4CAF50);
  static const Color primaryHover = Color(0xFF43A047);
  static const Color primaryStrong = Color(0xFF2E7D32);
  static const Color onPrimary = Color(0xFF212529);

  // Accent
  static const Color accent = Color(0xFFFF9800);
  static const Color accentStrong = Color(0xFFB34700);
  static const Color onAccent = Color(0xFF212529);

  // Tertiary
  static const Color tertiary = Color(0xFF2B6CB0);

  // Surfaces & Backgrounds
  static const Color surface = Color(0xFFFFFFFF);
  static const Color page = Color(0xFFFAF7F2);
  static const Color map = Color(0xFFEFEAE0);
  static const Color badge = Color(0xFFE8F5E9);
  // accentBg / tertiaryBg : tokens internes, non référencés dans Figma Foundations pour l'instant
  static const Color accentBg = Color(0xFFFFF3E0);
  static const Color tertiaryBg = Color(0xFFEBF4FF);

  // Text
  static const Color ink = Color(0xFF212529);
  static const Color muted = Color(0xFF5B6560);

  // Borders
  static const Color border = Color(0xFFDDD8CE);
  static const Color borderStrong = Color(0xFF7C847F);

  // Error
  static const Color error = Color(0xFFB3261E);
  static const Color errorBg = Color(0xFFFDEDEB);
  static const Color errorBorder = Color(0xFFB3261E);
  static const Color onError = Color(0xFFFFFFFF);

  // Brand Gradient
  static const Color brandGradientStart = Color(0xFF43A047);
  static const Color brandGradientEnd = Color(0xFFFFA726);

  // Shadows (élévation légère, non porteurs de sens WCAG)
  static const Color shadowSm = Color(0x08000000);
  static const Color shadow = Color(0x0A000000);
  static const Color shadowMd = Color(0x0C000000);
}

abstract final class AstreaSpacing {
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

abstract final class AstreaRadius {
  static const double sm = 8.0;
  static const double md = 10.0;
  static const double lg = 12.0;
  static const double full = 999.0;
}

abstract final class AstreaTypography {
  static const String heading = 'Montserrat';
  static const String body = 'Inter';

  // Titres (Montserrat)
  static const TextStyle titreXl = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AstreaColors.ink,
    letterSpacing: -0.5,
  );
  static const TextStyle titreLg = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: AstreaColors.ink,
    letterSpacing: -0.3,
  );
  static const TextStyle titreMd = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AstreaColors.ink,
  );

  // Logotype Astrea (w800, non utilisé dans les écrans content)
  static const TextStyle brandTitle = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: AstreaColors.ink,
    letterSpacing: -0.5,
  );

  // Corps (Inter)
  static const TextStyle corpsLg = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AstreaColors.ink,
    height: 1.5,
  );
  static const TextStyle corpsLgGras = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AstreaColors.ink,
  );
  static const TextStyle corpsMd = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AstreaColors.ink,
    height: 1.4,
  );
  static const TextStyle corpsMdGras = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AstreaColors.ink,
  );
  static const TextStyle petit = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AstreaColors.muted,
  );
  static const TextStyle petitGras = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AstreaColors.ink,
  );
}
