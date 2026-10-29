import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:astrea/features/onboarding/data/models/accessibility_profile.dart';
import 'package:astrea/features/onboarding/presentation/widgets/mobility_type_card.dart';

void main() {
  group('MobilityTypeCard', () {
    testWidgets('renders title, description and triggers onTap', (
      WidgetTester tester,
    ) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MobilityTypeCard(
              type: MobilityType.manualWheelchair,
              isSelected: false,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Fauteuil roulant manuel'), findsOneWidget);
      expect(
        find.text(
          'Itinéraires adaptés avec contraintes de pente douce et de largeur minimale.',
        ),
        findsOneWidget,
      );
      expect(find.text('Sélectionné'), findsNothing);
      expect(find.byIcon(Icons.check), findsNothing);

      await tester.tap(find.byType(MobilityTypeCard));
      expect(tapped, isTrue);
    });

    testWidgets('renders selected state with badge and check icon', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MobilityTypeCard(
              type: MobilityType.pedestrian,
              isSelected: true,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Piéton'), findsOneWidget);
      expect(find.text('Sélectionné'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
    });
  });
}
