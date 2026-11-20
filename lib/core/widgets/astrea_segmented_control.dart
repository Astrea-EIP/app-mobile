import 'package:flutter/material.dart';
import 'package:astrea/core/theme/app_theme.dart';

/// Two-or-more option segmented control matching the Figma
/// "SegmentedControl" component (52 px high, selected segment raised on a
/// white pill with a strong 1 px border).
class AstreaSegmentedControl extends StatelessWidget {
  const AstreaSegmentedControl({
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
    super.key,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.map,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        spacing: AppSpacing.xs,
        children: <Widget>[
          for (int i = 0; i < labels.length; i++)
            Expanded(
              child: _Segment(
                label: labels[i],
                isSelected: i == selectedIndex,
                onTap: () => onChanged(i),
              ),
            ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(AppRadius.md);

    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: Material(
        color: isSelected ? AppColors.surface : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: isSelected
              ? const BorderSide(color: AppColors.borderStrong)
              : BorderSide.none,
        ),
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Center(
            child: Text(
              label,
              style:
                  (isSelected
                          ? AppTypography.corpsMdGras
                          : AppTypography.corpsMd.copyWith(
                              color: AppColors.muted,
                            ))
                      .copyWith(height: 20 / 14),
            ),
          ),
        ),
      ),
    );
  }
}
