import 'package:flutter/material.dart';
import 'package:astrea/core/theme/app_theme.dart';

/// Brand block shown at the top of the auth screens: Astrea logo,
/// "Astrea" wordmark and tagline.
class AuthLogoHeader extends StatelessWidget {
  const AuthLogoHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 6,
      children: <Widget>[
        // Purely decorative: the wordmark below carries the meaning.
        Image.asset(
          'assets/images/astrea_logo.png',
          width: 56,
          height: 56,
          filterQuality: FilterQuality.high,
          excludeFromSemantics: true,
        ),
        Semantics(
          header: true,
          child: Text(
            'Astrea',
            style: AppTypography.titreLg.copyWith(
              letterSpacing: 0,
              height: 32 / 26,
            ),
          ),
        ),
        Text(
          'Mobilité accessible, simplifiée',
          style: AppTypography.corpsMd.copyWith(
            color: AppColors.muted,
            height: 20 / 14,
          ),
        ),
      ],
    );
  }
}
