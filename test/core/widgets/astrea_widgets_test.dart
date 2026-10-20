import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:astrea/core/theme/app_theme.dart';
import 'package:astrea/core/widgets/widgets.dart';

void main() {
  group('AstreaButton', () {
    testWidgets('primary variant renders label, icon and handles tap', (
      WidgetTester tester,
    ) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: AstreaButton.primary(
              label: 'Continuer',
              icon: Icons.arrow_forward_rounded,
              onPressed: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Continuer'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward_rounded), findsOneWidget);

      await tester.tap(find.byType(AstreaButton));
      expect(tapped, isTrue);
    });

    testWidgets('outlined variant renders and triggers callback', (
      WidgetTester tester,
    ) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: AstreaButton.outlined(
              label: 'Retour',
              onPressed: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Retour'), findsOneWidget);

      await tester.tap(find.byType(AstreaButton));
      expect(tapped, isTrue);
    });

    testWidgets(
      'shows loading spinner when isLoading is true and ignores tap',
      (WidgetTester tester) async {
        bool tapped = false;

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: AstreaButton.primary(
                label: 'Valider',
                isLoading: true,
                onPressed: () {
                  tapped = true;
                },
              ),
            ),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Valider'), findsNothing);

        await tester.tap(find.byType(AstreaButton));
        expect(tapped, isFalse);
      },
    );

    testWidgets('disabled button does not trigger callback', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AstreaButton.primary(label: 'Désactivé', onPressed: null),
          ),
        ),
      );

      final ElevatedButton button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('loading state announces combined label to screen reader', (
      WidgetTester tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: AstreaButton.primary(
              label: 'Valider',
              isLoading: true,
              onPressed: () {},
            ),
          ),
        ),
      );
      expect(
        find.bySemanticsLabel('Valider, chargement en cours'),
        findsOneWidget,
      );
      handle.dispose();
    });
  });

  group('AstreaToggleTile', () {
    testWidgets('renders title, subtitle and toggles on tap', (
      WidgetTester tester,
    ) async {
      bool toggledValue = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: AstreaToggleTile(
              title: 'Éviter les escaliers',
              subtitle: 'Priorise rampes et ascenseurs',
              icon: Icons.stairs_rounded,
              value: toggledValue,
              onChanged: (bool val) {
                toggledValue = val;
              },
            ),
          ),
        ),
      );

      expect(find.text('Éviter les escaliers'), findsOneWidget);
      expect(find.text('Priorise rampes et ascenseurs'), findsOneWidget);
      expect(find.byIcon(Icons.stairs_rounded), findsOneWidget);

      await tester.tap(find.byType(AstreaToggleTile));
      expect(toggledValue, isTrue);
    });

    testWidgets('exposes toggled state and label to screen reader', (
      WidgetTester tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: AstreaToggleTile(
              title: 'Éviter les escaliers',
              subtitle: 'Priorise rampes et ascenseurs',
              icon: Icons.stairs_rounded,
              value: true,
              onChanged: (_) {},
            ),
          ),
        ),
      );
      expect(
        tester.getSemantics(
          find.bySemanticsLabel(
            'Éviter les escaliers. Priorise rampes et ascenseurs',
          ),
        ),
        matchesSemantics(
          label: 'Éviter les escaliers. Priorise rampes et ascenseurs',
          isToggled: true,
          hasTapAction: true,
        ),
      );
      handle.dispose();
    });
  });

  group('AstreaSelectableCard', () {
    testWidgets(
      'renders selectable card and displays checkmark when selected',
      (WidgetTester tester) async {
        bool tapped = false;

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: AstreaSelectableCard(
                title: 'Option A',
                description: 'Description de test',
                icon: Icons.directions_walk_rounded,
                isSelected: true,
                onTap: () {
                  tapped = true;
                },
              ),
            ),
          ),
        );

        expect(find.text('Option A'), findsOneWidget);
        expect(find.text('Description de test'), findsOneWidget);
        expect(find.text('Sélectionné'), findsOneWidget);
        expect(find.byIcon(Icons.check), findsOneWidget);

        await tester.tap(find.byType(AstreaSelectableCard));
        expect(tapped, isTrue);
      },
    );

    testWidgets('exposes checked state and label to screen reader', (
      WidgetTester tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: AstreaSelectableCard(
              title: 'Option A',
              description: 'Description de test',
              icon: Icons.directions_walk_rounded,
              isSelected: true,
              onTap: () {},
            ),
          ),
        ),
      );
      expect(
        tester.getSemantics(
          find.bySemanticsLabel('Option A. Description de test'),
        ),
        matchesSemantics(
          label: 'Option A. Description de test',
          isChecked: true,
          hasTapAction: true,
        ),
      );
      handle.dispose();
    });
  });

  group('AstreaAppBar', () {
    testWidgets('renders Astrea brand title and subtitle', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(appBar: AstreaAppBar(subtitle: 'Test Subtitle')),
        ),
      );

      expect(find.text('Astrea'), findsOneWidget);
      expect(find.text('Test Subtitle'), findsOneWidget);
    });
  });

  group('AstreaSegmentedProgressBar', () {
    testWidgets('renders segments', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AstreaSegmentedProgressBar(currentStep: 2, totalSteps: 4),
          ),
        ),
      );

      expect(find.byType(AstreaSegmentedProgressBar), findsOneWidget);
      expect(find.byType(ShaderMask), findsOneWidget);
    });

    testWidgets('announces current step and total to screen reader', (
      WidgetTester tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AstreaSegmentedProgressBar(currentStep: 2, totalSteps: 4),
          ),
        ),
      );
      expect(find.bySemanticsLabel('Étape 3 sur 4'), findsOneWidget);
      handle.dispose();
    });
  });
}
