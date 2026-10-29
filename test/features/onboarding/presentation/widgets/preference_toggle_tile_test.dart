import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:astrea/features/onboarding/presentation/widgets/preference_toggle_tile.dart';

void main() {
  group('PreferenceToggleTile', () {
    testWidgets('renders title, subtitle and toggles value on tap', (
      WidgetTester tester,
    ) async {
      bool value = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return PreferenceToggleTile(
                  title: 'Chiens guides autorisés',
                  subtitle: 'Privilégier les lieux et espaces adaptés.',
                  icon: Icons.pets_rounded,
                  value: value,
                  onChanged: (bool newVal) {
                    setState(() {
                      value = newVal;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Chiens guides autorisés'), findsOneWidget);
      expect(
        find.text('Privilégier les lieux et espaces adaptés.'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.pets_rounded), findsOneWidget);

      final Switch switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.value, isFalse);

      await tester.tap(find.byType(PreferenceToggleTile));
      await tester.pumpAndSettle();

      final Switch toggledSwitch = tester.widget<Switch>(find.byType(Switch));
      expect(toggledSwitch.value, isTrue);
    });
  });
}
