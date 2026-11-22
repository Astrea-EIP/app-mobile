import 'package:flutter_test/flutter_test.dart';
import '../../test_account.dart';
import 'package:astrea/features/auth/data/models/auth_exceptions.dart';
import 'package:astrea/features/auth/data/models/auth_session.dart';
import 'package:astrea/features/auth/data/repositories/auth_repository.dart';

void main() {
  group('MockAuthRepository', () {
    late DateTime now;
    late MockAuthRepository repository;

    setUp(() async {
      now = DateTime(2026, 1, 1);
      repository = MockAuthRepository(
        simulatedDelay: Duration.zero,
        clock: () => now,
      );
      // The repository starts empty: the user registers first.
      await repository.register(TestAccount.registration);
    });

    test('starts without any account', () {
      expect(
        MockAuthRepository(
          simulatedDelay: Duration.zero,
        ).login(email: TestAccount.email, password: TestAccount.password),
        throwsA(isA<AuthException>()),
      );
    });

    test('logs in a registered account', () async {
      final AuthSession session = await repository.login(
        email: TestAccount.email,
        password: TestAccount.password,
      );

      expect(session.email, TestAccount.email);
      expect(session.token, isNotEmpty);
    });

    test('rejects a wrong password', () {
      expect(
        repository.login(email: TestAccount.email, password: 'wrong'),
        throwsA(
          isA<AuthException>().having(
            (AuthException e) => e.failure,
            'failure',
            AuthFailure.invalidCredentials,
          ),
        ),
      );
    });

    test('rejects an unknown e-mail', () {
      expect(
        repository.login(email: 'nobody@astrea.app', password: 'whatever'),
        throwsA(isA<AuthException>()),
      );
    });

    test('registers then logs in, ignoring e-mail case', () async {
      final AuthRegistration registration = AuthRegistration(
        fullName: ' Léa Dupont ',
        email: 'Lea@Astrea.app',
        password: 'motdepasse1',
        birthDate: DateTime(1995, 5, 17),
      );

      final AuthSession registered = await repository.register(registration);
      expect(registered.displayName, 'Léa Dupont');
      expect(registered.email, 'lea@astrea.app');

      final AuthSession session = await repository.login(
        email: 'LEA@astrea.app',
        password: 'motdepasse1',
      );
      expect(session.displayName, 'Léa Dupont');
    });

    test('refuses to register an e-mail twice', () {
      expect(
        repository.register(
          AuthRegistration(
            fullName: 'Autre',
            email: TestAccount.email,
            password: 'motdepasse1',
            birthDate: DateTime(1990, 1, 1),
          ),
        ),
        throwsA(
          isA<AuthException>().having(
            (AuthException e) => e.failure,
            'failure',
            AuthFailure.emailAlreadyUsed,
          ),
        ),
      );
    });

    test(
      'restores a session from its token, even on a fresh instance',
      () async {
        final AuthSession session = await repository.login(
          email: TestAccount.email,
          password: TestAccount.password,
        );

        final MockAuthRepository afterRestart = MockAuthRepository(
          simulatedDelay: Duration.zero,
          clock: () => now,
        );
        final AuthSession restored = await afterRestart.restoreSession(
          session.token,
        );

        expect(restored, session);
      },
    );

    test('rejects an expired token', () async {
      final AuthSession session = await repository.login(
        email: TestAccount.email,
        password: TestAccount.password,
      );
      now = now.add(const Duration(days: 31));

      expect(
        repository.restoreSession(session.token),
        throwsA(
          isA<AuthException>().having(
            (AuthException e) => e.failure,
            'failure',
            AuthFailure.sessionExpired,
          ),
        ),
      );
    });

    test('rejects a malformed token', () {
      expect(
        repository.restoreSession('not-a-token'),
        throwsA(isA<AuthException>()),
      );
      expect(
        repository.restoreSession('mock.abc.def'),
        throwsA(isA<AuthException>()),
      );
    });
  });
}
