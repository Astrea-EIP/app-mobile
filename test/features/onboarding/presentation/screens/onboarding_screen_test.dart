import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:astrea/core/theme/app_theme.dart';
import 'package:astrea/features/onboarding/data/repositories/profile_repository.dart';
import 'package:astrea/features/onboarding/presentation/bloc/profile_bloc.dart';
import 'package:astrea/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:astrea/features/onboarding/presentation/screens/onboarding_success_screen.dart';

void main() {
  group('OnboardingScreen Integration Flow', () {
    late MockProfileRepository repository;

    setUp(() {
      repository = MockProfileRepository(simulatedDelay: Duration.zero);
    });

    Widget createWidgetUnderTest() {
      return MaterialApp(
        theme: AppTheme.lightTheme,
        home: BlocProvider<ProfileBloc>(
          create: (_) => ProfileBloc(profileRepository: repository),
          child: const OnboardingScreen(),
        ),
      );
    }

    testWidgets(
      'complete pedestrian flow navigates, skips dimensions and submits successfully',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(800, 1400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Step 0: Mobility Selection
        expect(find.text('Comment vous déplacez-vous ?'), findsOneWidget);
        expect(find.text('Astrea'), findsOneWidget);

        // Select pedestrian
        await tester.ensureVisible(find.text('Piéton'));
        await tester.tap(find.text('Piéton'));
        await tester.pumpAndSettle();

        // Tap "Continuer"
        await tester.tap(find.text('Continuer'));
        await tester.pumpAndSettle();

        // Step 2: Preferences (Dimensions step was skipped)
        expect(find.text('Vos préférences d\'itinéraire'), findsOneWidget);

        // Tap "Continuer" to proceed to summary
        await tester.tap(find.text('Continuer'));
        await tester.pumpAndSettle();

        // Step 3: Summary
        expect(find.text('Récapitulatif de votre profil'), findsOneWidget);
        expect(find.text('Piéton'), findsWidgets);

        // Tap "Valider mon profil"
        await tester.tap(find.text('Valider mon profil'));
        await tester.pumpAndSettle();

        // Success screen displayed
        expect(find.byType(OnboardingSuccessScreen), findsOneWidget);
        expect(find.text('Profil créé avec succès !'), findsOneWidget);
      },
    );

    testWidgets(
      'wheelchair flow navigates through dimensions and back button navigates properly',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(800, 1400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Select manual wheelchair
        await tester.ensureVisible(find.text('Fauteuil roulant manuel'));
        await tester.tap(find.text('Fauteuil roulant manuel'));
        await tester.pumpAndSettle();

        // Tap Continuer
        await tester.tap(find.text('Continuer'));
        await tester.pumpAndSettle();

        // Step 1: Dimensions
        expect(find.text('Dimensions de l\'équipement'), findsOneWidget);

        // Fill dimensions
        await tester.enterText(find.byType(TextFormField).at(0), '65');
        await tester.enterText(find.byType(TextFormField).at(1), '105');
        await tester.enterText(find.byType(TextFormField).at(2), '4');
        await tester.pumpAndSettle();

        // Tap Continuer to Preferences
        await tester.tap(find.text('Continuer'));
        await tester.pumpAndSettle();

        expect(find.text('Vos préférences d\'itinéraire'), findsOneWidget);

        // Tap Retour
        await tester.tap(find.text('Retour'));
        await tester.pumpAndSettle();

        // Back on dimensions step
        expect(find.text('Dimensions de l\'équipement'), findsOneWidget);
      },
    );
  });
}
