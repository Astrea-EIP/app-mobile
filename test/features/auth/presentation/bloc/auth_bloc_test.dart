import 'package:flutter_test/flutter_test.dart';
import '../../test_account.dart';
import 'package:astrea/features/auth/data/models/auth_exceptions.dart';
import 'package:astrea/features/auth/data/models/auth_session.dart';
import 'package:astrea/features/auth/data/repositories/auth_repository.dart';
import 'package:astrea/features/auth/data/storage/token_storage.dart';
import 'package:astrea/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:astrea/features/auth/presentation/bloc/auth_event.dart';
import 'package:astrea/features/auth/presentation/bloc/auth_state.dart';

class _ThrowingRepository extends MockAuthRepository {
  _ThrowingRepository() : super(simulatedDelay: Duration.zero);

  @override
  Future<AuthSession> login({required String email, required String password}) {
    throw Exception('network down');
  }

  @override
  Future<AuthSession> restoreSession(String token) {
    throw Exception('network down');
  }

  @override
  Future<void> logout(String token) {
    throw Exception('network down');
  }
}

void main() {
  late MockAuthRepository repository;
  late InMemoryTokenStorage storage;

  AuthBloc buildBloc({AuthRepository? repo}) =>
      AuthBloc(authRepository: repo ?? repository, tokenStorage: storage);

  Future<AuthState> nextState(AuthBloc bloc, AuthEvent event) {
    final Future<AuthState> future = bloc.stream.first;
    bloc.add(event);
    return future;
  }

  setUp(() async {
    repository = MockAuthRepository(simulatedDelay: Duration.zero);
    storage = InMemoryTokenStorage();
    // The repository starts empty: the user registers first.
    await repository.register(TestAccount.registration);
  });

  group('AuthStarted', () {
    test('is unauthenticated without a stored token', () async {
      final AuthBloc bloc = buildBloc();
      expect(bloc.state.status, AuthStatus.checking);

      expect(
        (await nextState(bloc, const AuthStarted())).status,
        AuthStatus.unauthenticated,
      );
      await bloc.close();
    });

    test('restores the session from a valid stored token', () async {
      final AuthSession session = await repository.login(
        email: TestAccount.email,
        password: TestAccount.password,
      );
      await storage.write(session.token);
      final AuthBloc bloc = buildBloc();

      final AuthState state = await nextState(bloc, const AuthStarted());

      expect(state.status, AuthStatus.authenticated);
      expect(state.session, session);
      await bloc.close();
    });

    test('discards an invalid stored token', () async {
      await storage.write('garbage');
      final AuthBloc bloc = buildBloc();

      final AuthState state = await nextState(bloc, const AuthStarted());

      expect(state.status, AuthStatus.unauthenticated);
      expect(await storage.read(), isNull);
      await bloc.close();
    });

    test('keeps the token on a technical failure', () async {
      await storage.write('some-token');
      final AuthBloc bloc = buildBloc(repo: _ThrowingRepository());

      final AuthState state = await nextState(bloc, const AuthStarted());

      expect(state.status, AuthStatus.unauthenticated);
      expect(await storage.read(), 'some-token');
      await bloc.close();
    });
  });

  group('AuthLoginSubmitted', () {
    test(
      'emits submitting then authenticated and persists the token',
      () async {
        final AuthBloc bloc = buildBloc();
        final Future<List<AuthState>> states = bloc.stream.take(2).toList();

        bloc.add(
          const AuthLoginSubmitted(
            email: TestAccount.email,
            password: TestAccount.password,
          ),
        );
        final List<AuthState> emitted = await states;

        expect(emitted[0].status, AuthStatus.submitting);
        expect(emitted[1].status, AuthStatus.authenticated);
        expect(await storage.read(), emitted[1].session!.token);
        await bloc.close();
      },
    );

    test('shows the error and stores nothing on bad credentials', () async {
      final AuthBloc bloc = buildBloc();
      final Future<List<AuthState>> states = bloc.stream.take(2).toList();

      bloc.add(
        const AuthLoginSubmitted(email: TestAccount.email, password: 'wrong'),
      );
      final List<AuthState> emitted = await states;

      expect(emitted[1].status, AuthStatus.failure);
      expect(emitted[1].errorMessage, 'E-mail ou mot de passe incorrect.');
      expect(await storage.read(), isNull);
      await bloc.close();
    });

    test('falls back to a generic message on unexpected errors', () async {
      final AuthBloc bloc = buildBloc(repo: _ThrowingRepository());
      final Future<List<AuthState>> states = bloc.stream.take(2).toList();

      bloc.add(const AuthLoginSubmitted(email: 'a@b.fr', password: 'x'));
      final List<AuthState> emitted = await states;

      expect(emitted[1].status, AuthStatus.failure);
      expect(emitted[1].errorMessage, contains('Une erreur est survenue'));
      await bloc.close();
    });
  });

  test('AuthRegisterSubmitted creates the account and signs in', () async {
    final AuthBloc bloc = buildBloc();
    final Future<List<AuthState>> states = bloc.stream.take(2).toList();

    bloc.add(
      AuthRegisterSubmitted(
        fullName: 'Camille Martin',
        email: 'nouveau@astrea.app',
        password: 'motdepasse1',
        birthDate: DateTime(1995, 5, 17),
      ),
    );
    final List<AuthState> emitted = await states;

    expect(emitted[1].status, AuthStatus.authenticated);
    expect(emitted[1].session!.displayName, 'Camille Martin');
    expect(await storage.read(), isNotNull);
    await bloc.close();
  });

  test('AuthRegisterSubmitted reports an already used e-mail', () async {
    final AuthBloc bloc = buildBloc();
    final Future<List<AuthState>> states = bloc.stream.take(2).toList();

    bloc.add(
      AuthRegisterSubmitted(
        fullName: 'Autre',
        email: TestAccount.email,
        password: 'motdepasse1',
        birthDate: DateTime(1990, 1, 1),
      ),
    );
    final List<AuthState> emitted = await states;

    expect(emitted[1].status, AuthStatus.failure);
    expect(
      emitted[1].errorMessage,
      const AuthException.emailAlreadyUsed().message,
    );
    await bloc.close();
  });

  group('AuthLogoutRequested', () {
    test('clears the stored token and returns to unauthenticated', () async {
      final AuthBloc bloc = buildBloc();
      await nextState(bloc, const AuthStarted());
      final Future<List<AuthState>> states = bloc.stream.take(2).toList();
      bloc.add(
        const AuthLoginSubmitted(
          email: TestAccount.email,
          password: TestAccount.password,
        ),
      );
      await states;
      expect(await storage.read(), isNotNull);

      final AuthState state = await nextState(
        bloc,
        const AuthLogoutRequested(),
      );

      expect(state.status, AuthStatus.unauthenticated);
      expect(await storage.read(), isNull);
      await bloc.close();
    });

    test('signs out locally even if the API call fails', () async {
      await storage.write('some-token');
      final AuthBloc bloc = buildBloc(repo: _ThrowingRepository());

      final AuthState state = await nextState(
        bloc,
        const AuthLogoutRequested(),
      );

      expect(state.status, AuthStatus.unauthenticated);
      expect(await storage.read(), isNull);
      await bloc.close();
    });
  });

  test('AuthErrorCleared leaves the failure state', () async {
    final AuthBloc bloc = buildBloc();
    final Future<List<AuthState>> failed = bloc.stream.take(2).toList();
    bloc.add(const AuthLoginSubmitted(email: 'x@y.fr', password: 'bad'));
    await failed;

    final AuthState state = await nextState(bloc, const AuthErrorCleared());

    expect(state.status, AuthStatus.unauthenticated);
    expect(state.errorMessage, isNull);
    await bloc.close();
  });
}
