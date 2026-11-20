import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Local persistence of the auth token.
abstract class TokenStorage {
  Future<String?> read();

  Future<void> write(String token);

  Future<void> delete();
}

/// Production storage backed by the platform keystore / keychain.
class SecureTokenStorage implements TokenStorage {
  SecureTokenStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const String _key = 'astrea_auth_token';

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read() async {
    try {
      return await _storage.read(key: _key);
    } on PlatformException {
      // Unreadable keystore (e.g. restored backup): behave as logged out.
      return null;
    }
  }

  @override
  Future<void> write(String token) => _storage.write(key: _key, value: token);

  @override
  Future<void> delete() => _storage.delete(key: _key);
}

/// Volatile storage for tests and previews.
class InMemoryTokenStorage implements TokenStorage {
  InMemoryTokenStorage([this._token]);

  String? _token;

  @override
  Future<String?> read() async => _token;

  @override
  Future<void> write(String token) async => _token = token;

  @override
  Future<void> delete() async => _token = null;
}
