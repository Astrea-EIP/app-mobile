import 'package:flutter/material.dart';
import 'package:astrea/core/theme/app_theme.dart';

/// Reusable selectable card component with icon, badges and check indicator.
class AstreaSelectableCard extends StatelessWidget {
  const AstreaSelectableCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.accentColor = AppColors.primaryStrong,
    this.badgeBg = AppColors.badge,
    this.selectedBadgeText = 'Sélectionné',
    super.key,
  });

  final String title;
  final String description;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Color accentColor;
  final Color badgeBg;
  final String? selectedBadgeText;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      checked: isSelected,
      label: '$title. $description',
      onTap: onTap,
      excludeSemantics: true,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isSelected ? accentColor : AppColors.border,
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
              ? <BoxShadow>[
                  BoxShadow(
                    color: accentColor.withAlpha(35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : const <BoxShadow>[
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: isSelected ? accentColor : AppColors.border,
                        width: 1.5,
                      ),
                    ),
                    child: Icon(icon, color: accentColor, size: 28),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                title,
                                style: AppTypography.corpsLgGras.copyWith(
                                  color: isSelected
                                      ? accentColor
                                      : AppColors.ink,
                                ),
                              ),
                            ),
                            if (isSelected && selectedBadgeText != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: badgeBg,
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.full,
                                  ),
                                ),
                                child: Text(
                                  selectedBadgeText!,
                                  style: AppTypography.petitGras.copyWith(
                                    color: accentColor,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          description,
                          style: AppTypography.corpsMd.copyWith(
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? accentColor : Colors.transparent,
                      border: Border.all(
                        color: isSelected
                            ? accentColor
                            : AppColors.borderStrong,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            size: 16,
                            color: AppColors.surface,
                          )
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
