import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:astrea/core/theme/app_theme.dart';

void main() {
  group('AppColors', () {
    test('brand color tokens match expected Figma foundations', () {
      expect(AppColors.primary, equals(const Color(0xFF4CAF50)));
      expect(AppColors.primaryHover, equals(const Color(0xFF43A047)));
      expect(AppColors.primaryStrong, equals(const Color(0xFF2E7D32)));
      expect(AppColors.onPrimary, equals(const Color(0xFF212529)));

      expect(AppColors.accent, equals(const Color(0xFFFF9800)));
      expect(AppColors.accentStrong, equals(const Color(0xFFB34700)));
      expect(AppColors.onAccent, equals(const Color(0xFF212529)));

      expect(AppColors.tertiary, equals(const Color(0xFF2B6CB0)));
      expect(AppColors.surface, equals(const Color(0xFFFFFFFF)));
      expect(AppColors.page, equals(const Color(0xFFFAF7F2)));
      expect(AppColors.map, equals(const Color(0xFFEFEAE0)));
      expect(AppColors.badge, equals(const Color(0xFFE8F5E9)));

      expect(AppColors.ink, equals(const Color(0xFF212529)));
      expect(AppColors.muted, equals(const Color(0xFF5B6560)));

      expect(AppColors.border, equals(const Color(0xFFDDD8CE)));
      expect(AppColors.borderStrong, equals(const Color(0xFF7C847F)));

      expect(AppColors.error, equals(const Color(0xFFB3261E)));
      expect(AppColors.errorBg, equals(const Color(0xFFFDEDEB)));
      expect(AppColors.errorBorder, equals(const Color(0xFFB3261E)));
      expect(AppColors.onError, equals(const Color(0xFFFFFFFF)));

      expect(AppColors.brandGradientStart, equals(const Color(0xFF43A047)));
      expect(AppColors.brandGradientEnd, equals(const Color(0xFFFFA726)));
    });
  });

  group('AppSpacing & AppRadius', () {
    test('spacing tokens match defined scales', () {
      expect(AppSpacing.xs, equals(4.0));
      expect(AppSpacing.sm, equals(8.0));
      expect(AppSpacing.s12, equals(12.0));
      expect(AppSpacing.md, equals(16.0));
      expect(AppSpacing.s20, equals(20.0));
      expect(AppSpacing.lg, equals(24.0));
      expect(AppSpacing.s32, equals(32.0));
      expect(AppSpacing.s40, equals(40.0));
      expect(AppSpacing.s56, equals(56.0));
    });

    test('radius tokens match defined scales', () {
      expect(AppRadius.sm, equals(8.0));
      expect(AppRadius.md, equals(10.0));
      expect(AppRadius.lg, equals(12.0));
      expect(AppRadius.full, equals(999.0));
    });
  });

  group('AppTypography', () {
    test('titles use Montserrat font family', () {
      expect(AppTypography.titreXl.fontFamily, equals('Montserrat'));
      expect(AppTypography.titreLg.fontFamily, equals('Montserrat'));
      expect(AppTypography.titreMd.fontFamily, equals('Montserrat'));
    });

    test('body styles use Inter font family', () {
      expect(AppTypography.corpsLg.fontFamily, equals('Inter'));
      expect(AppTypography.corpsLgGras.fontFamily, equals('Inter'));
      expect(AppTypography.corpsMd.fontFamily, equals('Inter'));
      expect(AppTypography.corpsMdGras.fontFamily, equals('Inter'));
      expect(AppTypography.petit.fontFamily, equals('Inter'));
      expect(AppTypography.petitGras.fontFamily, equals('Inter'));
    });
  });

  group('AppTheme.lightTheme', () {
    test('provides consistent theme configuration', () {
      final ThemeData theme = AppTheme.lightTheme;

      expect(theme.useMaterial3, isTrue);
      expect(theme.scaffoldBackgroundColor, equals(AppColors.page));
      expect(theme.colorScheme.primary, equals(AppColors.primary));
      expect(theme.colorScheme.onPrimary, equals(AppColors.onPrimary));
      expect(theme.colorScheme.secondary, equals(AppColors.accent));
      expect(theme.colorScheme.surface, equals(AppColors.surface));
      expect(theme.colorScheme.error, equals(AppColors.error));
      expect(theme.appBarTheme.centerTitle, isTrue);
      expect(theme.cardTheme.elevation, equals(0));
    });
  });
}
