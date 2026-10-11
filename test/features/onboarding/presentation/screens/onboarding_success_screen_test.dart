import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:astrea/features/onboarding/data/models/accessibility_profile.dart';
import 'package:astrea/features/onboarding/presentation/screens/onboarding_success_screen.dart';

void main() {
  group('OnboardingSuccessScreen', () {
    testWidgets('renders success message, summary and triggers onRestart', (
      WidgetTester tester,
    ) async {
      bool restarted = false;
      const AccessibilityProfile profile = AccessibilityProfile(
        mobilityType: MobilityType.manualWheelchair,
        dimensions: WheelchairDimensions(
          widthCm: 65,
          lengthCm: 105,
          maxStepHeightCm: 4,
        ),
        preferences: RoutePreferences(dogFriendly: true, avoidStairs: true),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: OnboardingSuccessScreen(
            profile: profile,
            onRestart: () {
              restarted = true;
            },
          ),
        ),
      );

      expect(find.text('Profil créé avec succès !'), findsOneWidget);
      expect(find.text('Fauteuil roulant manuel'), findsOneWidget);
      expect(find.text('65 × 105 cm'), findsOneWidget);
      expect(find.text('4 cm'), findsOneWidget);
      expect(find.text('Commencer l\'exploration'), findsOneWidget);
      expect(find.text('Recommencer l\'onboarding (Démo)'), findsOneWidget);

      await tester.ensureVisible(find.text('Recommencer l\'onboarding (Démo)'));
      await tester.tap(find.text('Recommencer l\'onboarding (Démo)'));
      expect(restarted, isTrue);
    });

    testWidgets('renders pedestrian profile without dimensions rows', (
      WidgetTester tester,
    ) async {
      const AccessibilityProfile profile = AccessibilityProfile(
        mobilityType: MobilityType.pedestrian,
        preferences: RoutePreferences(dogFriendly: false),
      );

      await tester.pumpWidget(
        const MaterialApp(home: OnboardingSuccessScreen(profile: profile)),
      );

      expect(find.text('Profil créé avec succès !'), findsOneWidget);
      expect(find.text('Piéton'), findsOneWidget);
      expect(find.text('Dimensions (L × L)'), findsNothing);
    });
  });
}
