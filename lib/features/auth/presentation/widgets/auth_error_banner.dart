import 'package:flutter/material.dart';
import 'package:astrea/core/theme/app_theme.dart';

/// Form-level error (e.g. wrong credentials). Announced to screen readers
/// as soon as it appears.
class AuthErrorBanner extends StatelessWidget {
  const AuthErrorBanner({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      container: true,
      label: 'Erreur : $message',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.s12),
        decoration: BoxDecoration(
          color: AppColors.errorBg,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.errorBorder),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppSpacing.sm,
          children: <Widget>[
            const Icon(
              Icons.error_outline_rounded,
              size: 20,
              color: AppColors.error,
            ),
            Expanded(
              child: Text(
                message,
                style: AppTypography.corpsMd.copyWith(color: AppColors.error),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
