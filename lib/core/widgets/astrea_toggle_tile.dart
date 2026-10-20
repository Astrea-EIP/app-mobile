import 'package:flutter/material.dart';
import 'package:astrea/core/theme/app_theme.dart';

/// Reusable interactive toggle tile adhering to Astrea Design Tokens & RGAA.
class AstreaToggleTile extends StatelessWidget {
  const AstreaToggleTile({
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
    return Semantics(
      toggled: value,
      label: '$title. $subtitle',
      onTap: () => onChanged(!value),
      excludeSemantics: true,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.s12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            onTap: () => onChanged(!value),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.s12,
              ),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: value ? badgeBg : AppColors.page,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Icon(
                      icon,
                      color: value ? iconColor : AppColors.muted,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(title, style: AppTypography.corpsMdGras),
                        const SizedBox(height: 2),
                        Text(subtitle, style: AppTypography.petit),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Switch.adaptive(
                    value: value,
                    onChanged: onChanged,
                    activeTrackColor: AppColors.primaryStrong,
                    activeThumbColor: AppColors.surface,
                    inactiveTrackColor: AppColors.border,
                    trackOutlineColor: WidgetStateProperty.resolveWith<Color?>((
                      Set<WidgetState> states,
                    ) {
                      if (states.contains(WidgetState.selected)) {
                        return Colors.transparent;
                      }
                      return AppColors.borderStrong;
                    }),
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
