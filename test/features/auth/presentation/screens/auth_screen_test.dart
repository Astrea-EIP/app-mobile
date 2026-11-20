import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../test_account.dart';
import 'package:astrea/core/theme/app_theme.dart';
import 'package:astrea/features/auth/data/repositories/auth_repository.dart';
import 'package:astrea/features/auth/data/storage/token_storage.dart';
import 'package:astrea/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:astrea/features/auth/presentation/bloc/auth_event.dart';
import 'package:astrea/features/auth/presentation/screens/auth_gate.dart';
import 'package:astrea/features/onboarding/data/repositories/profile_repository.dart';
import 'package:astrea/features/onboarding/presentation/bloc/profile_bloc.dart';

void main() {
  late InMemoryTokenStorage storage;

  setUp(() {
    storage = InMemoryTokenStorage();
  });

  Future<void> pumpGate(WidgetTester tester) async {
    tester.view.physicalSize = const Size(780, 1800);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final MockProfileRepository profileRepository = MockProfileRepository(
      simulatedDelay: Duration.zero,
    );
    final MockAuthRepository authRepository = MockAuthRepository(
      simulatedDelay: Duration.zero,
    );
    // Real async work: Future.delayed never fires inside the fake-async zone.
    await tester.runAsync(
      () => authRepository.register(TestAccount.registration),
    );
    await tester.pumpWidget(
      RepositoryProvider<ProfileRepository>.value(
        value: profileRepository,
        child: MultiBlocProvider(
          providers: <BlocProvider<dynamic>>[
            BlocProvider<AuthBloc>(
              create: (_) => AuthBloc(
                authRepository: authRepository,
                tokenStorage: storage,
              )..add(const AuthStarted()),
            ),
            BlocProvider<ProfileBloc>(
              create: (_) => ProfileBloc(
                profileRepository: MockProfileRepository(
                  simulatedDelay: Duration.zero,
                ),
              ),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const AuthGate(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> enter(WidgetTester tester, String hint, String text) async {
    await tester.enterText(find.widgetWithText(TextFormField, hint), text);
  }

  group('login', () {
    testWidgets('matches the Figma content', (WidgetTester tester) async {
      await pumpGate(tester);

      expect(find.text('Astrea'), findsOneWidget);
      expect(find.text('Mobilité accessible, simplifiée'), findsOneWidget);
      expect(find.text('Adresse e-mail'), findsOneWidget);
      expect(find.text('Mot de passe'), findsOneWidget);
      expect(find.text('Mot de passe oublié ?'), findsOneWidget);
      expect(find.text('Continuer avec Google'), findsOneWidget);
      expect(
        find.text('Pas encore de compte ? Créer un compte'),
        findsOneWidget,
      );
      // Segmented control + submit button share the "Se connecter" label.
      expect(find.text('Se connecter'), findsNWidgets(2));
      expect(find.text('Créer un compte'), findsOneWidget);
    });

    testWidgets('lays out like the 390 px Figma frame', (
      WidgetTester tester,
    ) async {
      await pumpGate(tester);
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpAndSettle();

      Rect rect(Finder finder) => tester.getRect(finder);
      final Rect email = rect(
        find.widgetWithText(TextFormField, 'Adresse e-mail'),
      );
      final Rect password = rect(
        find.widgetWithText(TextFormField, 'Mot de passe'),
      );

      // Figma frame 150:168: x = 20, width = 350, height = 48, 12 px gaps.
      // Only relative distances are asserted: the test font (Ahem) is wider
      // than Inter, so the tagline wraps here and shifts absolute y values.
      expect(email.left, 20);
      expect(email.width, 350);
      expect(email.height, 48);
      expect(password.top - email.bottom, 12);
      expect(
        rect(find.text('Mot de passe oublié ?')).top - password.bottom,
        closeTo(12, 1),
      );
      // Password bottom (392) -> primary button top (436) in Figma.
      expect(
        rect(find.widgetWithText(ElevatedButton, 'Se connecter')).top -
            password.bottom,
        44,
      );
    });

    testWidgets('validates empty fields without calling the API', (
      WidgetTester tester,
    ) async {
      await pumpGate(tester);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Se connecter'));
      await tester.pumpAndSettle();

      expect(
        find.text('Veuillez saisir votre adresse e-mail.'),
        findsOneWidget,
      );
      expect(find.text('Veuillez saisir votre mot de passe.'), findsOneWidget);
    });

    testWidgets('shows an error state on invalid credentials', (
      WidgetTester tester,
    ) async {
      await pumpGate(tester);

      await enter(tester, 'Adresse e-mail', TestAccount.email);
      await enter(tester, 'Mot de passe', 'mauvais-mot-de-passe');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Se connecter'));
      await tester.pumpAndSettle();

      expect(find.text('E-mail ou mot de passe incorrect.'), findsOneWidget);
      expect(find.text('Comment vous déplacez-vous ?'), findsNothing);
      expect(await storage.read(), isNull);
    });

    testWidgets('logs in with valid credentials, stores the token and opens '
        'the main app', (WidgetTester tester) async {
      await pumpGate(tester);

      await enter(tester, 'Adresse e-mail', TestAccount.email);
      await enter(tester, 'Mot de passe', TestAccount.password);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Se connecter'));
      await tester.pumpAndSettle();

      expect(find.text('Comment vous déplacez-vous ?'), findsOneWidget);
      expect(await storage.read(), isNotNull);
    });

    testWidgets('the error clears when switching tab', (
      WidgetTester tester,
    ) async {
      await pumpGate(tester);
      await enter(tester, 'Adresse e-mail', TestAccount.email);
      await enter(tester, 'Mot de passe', 'nope');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Se connecter'));
      await tester.pumpAndSettle();
      expect(find.text('E-mail ou mot de passe incorrect.'), findsOneWidget);

      await tester.tap(find.text('Créer un compte'));
      await tester.pumpAndSettle();

      expect(find.text('E-mail ou mot de passe incorrect.'), findsNothing);
    });
  });

  group('register', () {
    Future<void> openRegister(WidgetTester tester) async {
      await pumpGate(tester);
      await tester.tap(find.text('Créer un compte'));
      await tester.pumpAndSettle();
    }

    testWidgets('matches the Figma content', (WidgetTester tester) async {
      await openRegister(tester);

      expect(find.text('Prénom et nom'), findsOneWidget);
      expect(find.text('Adresse e-mail'), findsOneWidget);
      expect(find.text('Mot de passe'), findsOneWidget);
      expect(find.text('Date de naissance (JJ / MM / AAAA)'), findsOneWidget);
      expect(
        find.textContaining("J'accepte que ma localisation"),
        findsOneWidget,
      );
      expect(
        find.text(
          "En continuant, vous acceptez nos Conditions générales d'utilisation.",
        ),
        findsOneWidget,
      );
      expect(find.text('Déjà un compte ? Se connecter'), findsOneWidget);
    });

    testWidgets('requires every field and the consent', (
      WidgetTester tester,
    ) async {
      await openRegister(tester);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Créer un compte'));
      await tester.pumpAndSettle();

      expect(
        find.text('Veuillez saisir votre prénom et votre nom.'),
        findsOneWidget,
      );
      expect(
        find.text('Veuillez saisir votre adresse e-mail.'),
        findsOneWidget,
      );
      expect(find.text('Veuillez choisir un mot de passe.'), findsOneWidget);
      expect(
        find.text('Veuillez saisir votre date de naissance.'),
        findsOneWidget,
      );
      expect(
        find.text('Votre accord est nécessaire pour créer un compte.'),
        findsOneWidget,
      );
    });

    testWidgets('formats the birth date while typing', (
      WidgetTester tester,
    ) async {
      await openRegister(tester);

      await enter(tester, 'Date de naissance (JJ / MM / AAAA)', '17051995');

      expect(find.text('17 / 05 / 1995'), findsOneWidget);
    });

    testWidgets('creates the account and opens the main app', (
      WidgetTester tester,
    ) async {
      await openRegister(tester);

      await enter(tester, 'Prénom et nom', 'Camille Martin');
      await enter(tester, 'Adresse e-mail', 'nouveau@astrea.app');
      await enter(tester, 'Mot de passe', 'motdepasse1');
      await enter(tester, 'Date de naissance (JJ / MM / AAAA)', '17051995');
      await tester.tap(find.textContaining("J'accepte que ma localisation"));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Créer un compte'));
      await tester.pumpAndSettle();

      expect(find.text('Comment vous déplacez-vous ?'), findsOneWidget);
      expect(await storage.read(), isNotNull);
    });

    testWidgets('shows an error when the e-mail is already used', (
      WidgetTester tester,
    ) async {
      await openRegister(tester);

      await enter(tester, 'Prénom et nom', 'Camille Martin');
      await enter(tester, 'Adresse e-mail', TestAccount.email);
      await enter(tester, 'Mot de passe', 'motdepasse1');
      await enter(tester, 'Date de naissance (JJ / MM / AAAA)', '17051995');
      await tester.tap(find.textContaining("J'accepte que ma localisation"));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Créer un compte'));
      await tester.pumpAndSettle();

      expect(
        find.text('Un compte existe déjà avec cette adresse e-mail.'),
        findsOneWidget,
      );
    });

    testWidgets('can switch back to login through the bottom link', (
      WidgetTester tester,
    ) async {
      await openRegister(tester);

      await tester.tap(find.text('Déjà un compte ? Se connecter'));
      await tester.pumpAndSettle();

      expect(find.text('Mot de passe oublié ?'), findsOneWidget);
    });
  });
}
