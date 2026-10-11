import 'package:flutter/material.dart';
import 'package:astrea/core/widgets/astrea_segmented_progress_bar.dart';

class OnboardingProgressBar extends StatelessWidget {
  const OnboardingProgressBar({
    required this.currentStep,
    required this.totalSteps,
    super.key,
  });

  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return AstreaSegmentedProgressBar(
      currentStep: currentStep,
      totalSteps: totalSteps,
    );
  }
}
