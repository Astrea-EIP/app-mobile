import 'package:flutter/material.dart';
import 'package:astrea/core/theme/app_theme.dart';
import 'package:astrea/core/widgets/widgets.dart';
import 'package:astrea/features/map/presentation/widgets/map_widgets.dart';

/// Map area shown when the position cannot be obtained (Figma "Localisation
/// refusée"): empty beige map, an icon badge and a card with the actions.
class LocationFallback extends StatelessWidget {
  const LocationFallback({
    required this.icon,
    required this.title,
    required this.message,
    required this.primaryLabel,
    required this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
    super.key,
  });

  final IconData icon;
  final String title;
  final String message;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.map,
      child: SafeArea(
        top: false,
        child: Column(
          children: <Widget>[
            Expanded(
              child: Center(
                child: ExcludeSemantics(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      color: AppColors.map,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: AppColors.muted, size: 36),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: GradientAccentCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Semantics(
                      header: true,
                      child: Text(title, style: AppTypography.titreMd),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      message,
                      style: AppTypography.corpsMd.copyWith(
                        color: AppColors.muted,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AstreaButton.primary(
                      label: primaryLabel,
                      onPressed: onPrimary,
                    ),
                    if (secondaryLabel != null &&
                        onSecondary != null) ...<Widget>[
                      const SizedBox(height: AppSpacing.sm),
                      AstreaButton.outlined(
                        label: secondaryLabel!,
                        onPressed: onSecondary,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
