import 'package:equatable/equatable.dart';

/// An authenticated user session, as returned by the auth API.
class AuthSession extends Equatable {
  const AuthSession({
    required this.token,
    required this.email,
    required this.displayName,
  });

  /// Opaque bearer token; this is the only value persisted on the device.
  final String token;
  final String email;
  final String displayName;

  @override
  List<Object?> get props => <Object?>[token, email, displayName];
}

/// Data collected by the "Créer un compte" form.
class AuthRegistration extends Equatable {
  const AuthRegistration({
    required this.fullName,
    required this.email,
    required this.password,
    required this.birthDate,
  });

  final String fullName;
  final String email;
  final String password;
  final DateTime birthDate;

  @override
  List<Object?> get props => <Object?>[fullName, email, password, birthDate];
}
