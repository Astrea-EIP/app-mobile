import 'package:flutter/material.dart';
import 'package:astrea/core/theme/app_theme.dart';

/// Underlined text link (14 px semi-bold) used on the auth screens.
///
/// The touch target is 44 px high while the text keeps its 20 px Figma
/// line height: the 12 px of padding above and below replace the gaps the
/// design puts around the link, so the layout is pixel-identical.
class AuthLinkButton extends StatelessWidget {
  const AuthLinkButton({
    required this.label,
    required this.onPressed,
    this.alignment = Alignment.center,
    super.key,
  });

  final String label;
  final VoidCallback onPressed;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      link: true,
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: onPressed,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: SizedBox(
          height: 44,
          width: double.infinity,
          child: Align(
            alignment: alignment,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: AppTypography.corpsMdGras.copyWith(
                decoration: TextDecoration.underline,
                height: 20 / 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Placeholder feedback for flows that are out of scope for now (Google
/// sign-in, password reset).
void showAuthComingSoon(BuildContext context, String feature) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text('$feature sera bientôt disponible.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
}
