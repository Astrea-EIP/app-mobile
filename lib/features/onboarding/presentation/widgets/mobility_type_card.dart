import 'package:flutter/material.dart';
import 'package:astrea/core/theme/app_theme.dart';
import 'package:astrea/features/onboarding/data/models/accessibility_profile.dart';

class MobilityTypeCard extends StatelessWidget {
  const MobilityTypeCard({
    required this.type,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final MobilityType type;
  final bool isSelected;
  final VoidCallback onTap;

  IconData _iconForType(MobilityType type) {
    switch (type) {
      case MobilityType.manualWheelchair:
        return Icons.accessible_forward;
      case MobilityType.electricWheelchair:
        return Icons.electric_rickshaw_rounded;
      case MobilityType.walkingWithAssistance:
        return Icons.nordic_walking_rounded;
      case MobilityType.pedestrian:
        return Icons.directions_walk_rounded;
      case MobilityType.stroller:
        return Icons.child_friendly_rounded;
    }
  }

  Color _accentColorForType(MobilityType type) {
    switch (type) {
      case MobilityType.manualWheelchair:
        return AppColors.primaryStrong;
      case MobilityType.electricWheelchair:
        return AppColors.accentStrong;
      case MobilityType.walkingWithAssistance:
        return AppColors.tertiary;
      case MobilityType.pedestrian:
        return AppColors.primaryStrong;
      case MobilityType.stroller:
        return AppColors.accentStrong;
    }
  }

  Color _badgeBgForType(MobilityType type) {
    switch (type) {
      case MobilityType.manualWheelchair:
      case MobilityType.pedestrian:
        return AppColors.badge;
      case MobilityType.electricWheelchair:
      case MobilityType.stroller:
        return const Color(0xFFFFF3E0); // Warm soft accent surface
      case MobilityType.walkingWithAssistance:
        return const Color(0xFFEBF4FF); // Soft blue surface
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color typeColor = _accentColorForType(type);
    final Color badgeBg = _badgeBgForType(type);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isSelected ? typeColor : AppColors.border,
          width: isSelected ? 2.0 : 1.0,
        ),
        boxShadow: isSelected
            ? <BoxShadow>[
                BoxShadow(
                  color: typeColor.withAlpha(35),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : const <BoxShadow>[
                BoxShadow(
                  color: Color(0x0A000000),
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
                      color: isSelected ? typeColor : AppColors.border,
                      width: 1.5,
                    ),
                  ),
                  child: Icon(_iconForType(type), color: typeColor, size: 28),
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
                              type.displayName,
                              style: AppTypography.corpsLgGras.copyWith(
                                color: isSelected ? typeColor : AppColors.ink,
                              ),
                            ),
                          ),
                          if (isSelected)
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
                                'Sélectionné',
                                style: AppTypography.petitGras.copyWith(
                                  color: typeColor,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        type.description,
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
                    color: isSelected ? typeColor : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? typeColor : AppColors.borderStrong,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
