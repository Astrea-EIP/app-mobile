import 'package:flutter/material.dart';
import 'package:astrea/core/theme/app_theme.dart';
import 'package:astrea/core/widgets/astrea_selectable_card.dart';
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
      case MobilityType.pedestrian:
        return AppColors.primaryStrong;
      case MobilityType.electricWheelchair:
      case MobilityType.stroller:
        return AppColors.accentStrong;
      case MobilityType.walkingWithAssistance:
        return AppColors.tertiary;
    }
  }

  Color _badgeBgForType(MobilityType type) {
    switch (type) {
      case MobilityType.manualWheelchair:
      case MobilityType.pedestrian:
        return AppColors.badge;
      case MobilityType.electricWheelchair:
      case MobilityType.stroller:
        return AppColors.accentBg;
      case MobilityType.walkingWithAssistance:
        return AppColors.tertiaryBg;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AstreaSelectableCard(
      title: type.displayName,
      description: type.description,
      icon: _iconForType(type),
      isSelected: isSelected,
      onTap: onTap,
      accentColor: _accentColorForType(type),
      badgeBg: _badgeBgForType(type),
    );
  }
}
