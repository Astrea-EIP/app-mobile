import 'dart:async';
import 'dart:convert';

import 'package:astrea/features/auth/data/models/auth_exceptions.dart';
import 'package:astrea/features/auth/data/models/auth_session.dart';

/// Contract of the authentication API.
///
/// Implementations throw [AuthException] for business errors (wrong
/// credentials, e-mail already used, expired session). Any other exception is
/// treated as a technical failure (network, server...).
abstract class AuthRepository {
  Future<AuthSession> login({required String email, required String password});

  Future<AuthSession> register(AuthRegistration registration);

  /// Validates a token read from local storage and returns its session.
  ///
  /// Throws [AuthException] with [AuthFailure.sessionExpired] when the token
  /// is no longer valid.
  Future<AuthSession> restoreSession(String token);

  Future<void> logout(String token);
}

/// Mocked implementation used until the backend exposes the auth routes.
///
/// Accounts live in memory only: a user must register first, and accounts are
/// lost when the app restarts. Tokens are self-describing
/// (`mock.<expiry>.<payload>`), so a token stored on the device is still
/// valid after a restart even though the in-memory accounts are gone.
class MockAuthRepository implements AuthRepository {
  MockAuthRepository({
    this.simulatedDelay = const Duration(milliseconds: 600),
    this.tokenLifetime = const Duration(days: 30),
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final Duration simulatedDelay;
  final Duration tokenLifetime;
  final DateTime Function() _clock;
  final Map<String, _MockAccount> _accounts = <String, _MockAccount>{};

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(simulatedDelay);
    final String normalized = _normalize(email);
    final _MockAccount? account = _accounts[normalized];
    if (account == null || account.password != password) {
      throw const AuthException.invalidCredentials();
    }
    return _issueSession(normalized, account.displayName);
  }

  @override
  Future<AuthSession> register(AuthRegistration registration) async {
    await Future<void>.delayed(simulatedDelay);
    final String normalized = _normalize(registration.email);
    if (_accounts.containsKey(normalized)) {
      throw const AuthException.emailAlreadyUsed();
    }
    final String name = registration.fullName.trim();
    _accounts[normalized] = _MockAccount(
      password: registration.password,
      displayName: name,
    );
    return _issueSession(normalized, name);
  }

  @override
  Future<AuthSession> restoreSession(String token) async {
    await Future<void>.delayed(simulatedDelay);
    try {
      final List<String> parts = token.split('.');
      if (parts.length != 3 || parts[0] != 'mock') {
        throw const AuthException.sessionExpired();
      }
      final DateTime expiresAt = DateTime.fromMillisecondsSinceEpoch(
        int.parse(parts[1]),
      );
      if (!_clock().isBefore(expiresAt)) {
        throw const AuthException.sessionExpired();
      }
      final Map<String, dynamic> payload =
          jsonDecode(utf8.decode(base64Url.decode(parts[2])))
              as Map<String, dynamic>;
      return AuthSession(
        token: token,
        email: payload['e'] as String,
        displayName: payload['n'] as String,
      );
    } on AuthException {
      rethrow;
    } on Object {
      throw const AuthException.sessionExpired();
    }
  }

  @override
  Future<void> logout(String token) async {
    await Future<void>.delayed(simulatedDelay);
  }

  AuthSession _issueSession(String email, String displayName) {
    final int expiry = _clock().add(tokenLifetime).millisecondsSinceEpoch;
    final String payload = base64Url.encode(
      utf8.encode(jsonEncode(<String, String>{'e': email, 'n': displayName})),
    );
    return AuthSession(
      token: 'mock.$expiry.$payload',
      email: email,
      displayName: displayName,
    );
  }

  static String _normalize(String email) => email.trim().toLowerCase();
}

class _MockAccount {
  const _MockAccount({required this.password, required this.displayName});

  final String password;
  final String displayName;
}
