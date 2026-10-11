import 'package:flutter/material.dart';
import 'package:astrea/core/theme/app_theme.dart';

/// Reusable segmented progress bar with unified continuous brand gradient.
class AstreaSegmentedProgressBar extends StatelessWidget {
  const AstreaSegmentedProgressBar({
    required this.currentStep,
    required this.totalSteps,
    super.key,
  });

  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s20,
        vertical: AppSpacing.s12,
      ),
      child: Stack(
        children: <Widget>[
          // Background track: all segments in neutral border
          Row(
            children: List<Widget>.generate(totalSteps, (int index) {
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(
                    right: index < totalSteps - 1 ? AppSpacing.sm : 0,
                  ),
                  height: 5,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    color: AppColors.border,
                  ),
                ),
              );
            }),
          ),
          // Active continuous gradient mask spanning the entire width
          ShaderMask(
            shaderCallback: (Rect bounds) {
              return const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: <Color>[
                  AppColors.brandGradientStart,
                  AppColors.brandGradientEnd,
                ],
              ).createShader(bounds);
            },
            blendMode: BlendMode.srcIn,
            child: Row(
              children: List<Widget>.generate(totalSteps, (int index) {
                final bool isActive = index <= currentStep;

                return Expanded(
                  child: Container(
                    margin: EdgeInsets.only(
                      right: index < totalSteps - 1 ? AppSpacing.sm : 0,
                    ),
                    height: 5,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      color: isActive ? Colors.white : Colors.transparent,
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
