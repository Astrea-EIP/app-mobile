import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:astrea/features/auth/data/models/auth_exceptions.dart';
import 'package:astrea/features/auth/data/models/auth_session.dart';
import 'package:astrea/features/auth/data/repositories/auth_repository.dart';
import 'package:astrea/features/auth/data/storage/token_storage.dart';
import 'package:astrea/features/auth/presentation/bloc/auth_event.dart';
import 'package:astrea/features/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required AuthRepository authRepository,
    required TokenStorage tokenStorage,
  }) : _authRepository = authRepository,
       _tokenStorage = tokenStorage,
       super(const AuthState()) {
    on<AuthStarted>(_onStarted);
    on<AuthLoginSubmitted>(_onLoginSubmitted);
    on<AuthRegisterSubmitted>(_onRegisterSubmitted);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthErrorCleared>(_onErrorCleared);
  }

  static const String _genericError =
      'Une erreur est survenue. Veuillez réessayer.';

  final AuthRepository _authRepository;
  final TokenStorage _tokenStorage;

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    final String? token = await _tokenStorage.read();
    if (token == null) {
      emit(const AuthState.unauthenticated());
      return;
    }

    try {
      final AuthSession session = await _authRepository.restoreSession(token);
      emit(AuthState.authenticated(session));
    } on AuthException {
      // The stored token is no longer valid: forget it.
      await _tokenStorage.delete();
      emit(const AuthState.unauthenticated());
    } on Object {
      // Technical failure (offline...): keep the token for the next launch.
      emit(const AuthState.unauthenticated());
    }
  }

  Future<void> _onLoginSubmitted(
    AuthLoginSubmitted event,
    Emitter<AuthState> emit,
  ) {
    return _authenticate(
      emit,
      () => _authRepository.login(
        email: event.email.trim(),
        password: event.password,
      ),
    );
  }

  Future<void> _onRegisterSubmitted(
    AuthRegisterSubmitted event,
    Emitter<AuthState> emit,
  ) {
    return _authenticate(
      emit,
      () => _authRepository.register(
        AuthRegistration(
          fullName: event.fullName.trim(),
          email: event.email.trim(),
          password: event.password,
          birthDate: event.birthDate,
        ),
      ),
    );
  }

  Future<void> _authenticate(
    Emitter<AuthState> emit,
    Future<AuthSession> Function() request,
  ) async {
    if (state.isSubmitting) {
      return;
    }
    emit(const AuthState.submitting());
    try {
      final AuthSession session = await request();
      await _tokenStorage.write(session.token);
      emit(AuthState.authenticated(session));
    } on AuthException catch (e) {
      emit(AuthState.failure(e.message));
    } on Object {
      emit(const AuthState.failure(_genericError));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    final AuthSession? session = state.session;
    // Local sign-out must never depend on the network.
    await _tokenStorage.delete();
    emit(const AuthState.unauthenticated());
    if (session != null) {
      try {
        await _authRepository.logout(session.token);
      } on Object {
        // Best effort: the token is already gone from the device.
      }
    }
  }

  void _onErrorCleared(AuthErrorCleared event, Emitter<AuthState> emit) {
    if (state.status == AuthStatus.failure) {
      emit(const AuthState.unauthenticated());
    }
  }
}
