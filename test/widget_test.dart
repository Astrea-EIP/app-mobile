import 'package:flutter_test/flutter_test.dart';
import 'features/auth/test_account.dart';
import 'package:astrea/features/auth/data/models/auth_session.dart';
import 'package:astrea/features/auth/data/repositories/auth_repository.dart';
import 'package:astrea/features/auth/data/storage/token_storage.dart';
import 'package:astrea/features/onboarding/data/repositories/profile_repository.dart';
import 'package:astrea/main.dart';
import 'features/map/fake_location_repository.dart';

void main() {
  testWidgets('App smoke test shows the login screen when logged out', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MyApp(
        profileRepository: MockProfileRepository(),
        locationRepository: FakeLocationRepository(),
        authRepository: MockAuthRepository(simulatedDelay: Duration.zero),
        tokenStorage: InMemoryTokenStorage(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Astrea'), findsOneWidget);
    expect(find.text('Mobilité accessible, simplifiée'), findsOneWidget);
    expect(find.text('Adresse e-mail'), findsOneWidget);
    expect(find.text('Comment vous déplacez-vous ?'), findsNothing);
  });

  testWidgets('App skips login when a valid token is stored', (
    WidgetTester tester,
  ) async {
    final MockAuthRepository authRepository = MockAuthRepository(
      simulatedDelay: Duration.zero,
    );
    // Real async work: Future.delayed never fires inside the fake-async zone.
    final AuthSession session = (await tester.runAsync(
      () => authRepository.register(TestAccount.registration),
    ))!;
    final String token = session.token;

    await tester.pumpWidget(
      MyApp(
        profileRepository: MockProfileRepository(),
        locationRepository: FakeLocationRepository(),
        authRepository: authRepository,
        tokenStorage: InMemoryTokenStorage(token),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Comment vous déplacez-vous ?'), findsOneWidget);
    expect(find.text('Se connecter'), findsNothing);
  });
}
