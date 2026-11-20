import 'package:flutter/material.dart';
import 'package:astrea/core/theme/app_theme.dart';

/// White card with the brand gradient stripe on its left edge (Figma).
class GradientAccentCard extends StatelessWidget {
  const GradientAccentCard({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md + 1,
              14,
              AppSpacing.md,
              14,
            ),
            child: child,
          ),
          const Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 5,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    AppColors.brandGradientStart,
                    AppColors.brandGradientEnd,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Top of the map screen: greeting and search field, then the brand bar.
class MapHeader extends StatelessWidget {
  const MapHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.page,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s20,
                AppSpacing.md,
                AppSpacing.s20,
                AppSpacing.s12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Semantics(
                    header: true,
                    child: const Text('Bonjour', style: AppTypography.titreLg),
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  Semantics(
                    label: 'Où souhaitez-vous aller ?',
                    child: ExcludeSemantics(
                      child: Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          border: Border.all(color: AppColors.borderStrong),
                        ),
                        child: Row(
                          children: <Widget>[
                            const Icon(
                              Icons.search_rounded,
                              size: 18,
                              color: AppColors.muted,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              'Où souhaitez-vous aller ?',
                              style: AppTypography.corpsMd.copyWith(
                                color: AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 4,
            width: double.infinity,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: <Color>[
                    AppColors.brandGradientStart,
                    AppColors.brandGradientEnd,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Emergency button (Figma "SosButton"): activated by a long press only, to
/// avoid accidental taps.
class SosButton extends StatelessWidget {
  const SosButton({required this.onActivated, super.key});

  final VoidCallback onActivated;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'SOS, appel d\'urgence',
      hint: 'Appui long pour activer',
      excludeSemantics: true,
      onLongPress: onActivated,
      child: GestureDetector(
        onLongPress: onActivated,
        child: Container(
          width: 56,
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.error,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.surface, width: 3),
          ),
          child: Text(
            'SOS',
            style: AppTypography.corpsLgGras.copyWith(color: AppColors.onError),
          ),
        ),
      ),
    );
  }
}
