import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:astrea/features/onboarding/presentation/widgets/onboarding_progress_bar.dart';

void main() {
  testWidgets('OnboardingProgressBar renders correct number of step segments', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: OnboardingProgressBar(currentStep: 1, totalSteps: 4),
        ),
      ),
    );

    expect(find.byType(OnboardingProgressBar), findsOneWidget);
    expect(find.byType(ShaderMask), findsOneWidget);
  });
}
