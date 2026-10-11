import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:astrea/features/onboarding/presentation/widgets/dimensions_step_form.dart';

void main() {
  group('DimensionsStepForm', () {
    testWidgets('renders all fields and triggers onChanged on text change', (
      WidgetTester tester,
    ) async {
      final TextEditingController widthCtrl = TextEditingController();
      final TextEditingController lengthCtrl = TextEditingController();
      final TextEditingController stepCtrl = TextEditingController();
      int changeCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: DimensionsStepForm(
                widthController: widthCtrl,
                lengthController: lengthCtrl,
                stepHeightController: stepCtrl,
                onChanged: () {
                  changeCount++;
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('Largeur totale de l\'équipement'), findsOneWidget);
      expect(find.text('Longueur totale de l\'équipement'), findsOneWidget);
      expect(
        find.text('Hauteur max de marche / bordure franchissable'),
        findsOneWidget,
      );

      await tester.enterText(find.byType(TextFormField).at(0), '65');
      expect(changeCount, equals(1));
      expect(widthCtrl.text, equals('65'));

      await tester.enterText(find.byType(TextFormField).at(1), '105');
      expect(changeCount, equals(2));
      expect(lengthCtrl.text, equals('105'));

      await tester.enterText(find.byType(TextFormField).at(2), '4');
      expect(changeCount, equals(3));
      expect(stepCtrl.text, equals('4'));
    });

    testWidgets('displays validation error for out-of-range values', (
      WidgetTester tester,
    ) async {
      final TextEditingController widthCtrl = TextEditingController();
      final TextEditingController lengthCtrl = TextEditingController();
      final TextEditingController stepCtrl = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: DimensionsStepForm(
                widthController: widthCtrl,
                lengthController: lengthCtrl,
                stepHeightController: stepCtrl,
                onChanged: () {},
              ),
            ),
          ),
        ),
      );

      // Enter out-of-bounds width (> 200)
      await tester.enterText(find.byType(TextFormField).at(0), '300');
      await tester.pumpAndSettle();

      expect(find.text('Doit être ≤ 200 cm'), findsOneWidget);
    });
  });
}
