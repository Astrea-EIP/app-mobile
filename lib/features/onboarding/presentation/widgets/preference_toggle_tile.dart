import 'package:flutter/material.dart';
import 'package:astrea/core/theme/app_theme.dart';
import 'package:astrea/core/widgets/astrea_toggle_tile.dart';

class PreferenceToggleTile extends StatelessWidget {
  const PreferenceToggleTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.onChanged,
    this.iconColor = AppColors.primaryStrong,
    this.badgeBg = AppColors.badge,
    super.key,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color iconColor;
  final Color badgeBg;

  @override
  Widget build(BuildContext context) {
    return AstreaToggleTile(
      title: title,
      subtitle: subtitle,
      icon: icon,
      value: value,
      onChanged: onChanged,
      iconColor: iconColor,
      badgeBg: badgeBg,
    );
  }
}
