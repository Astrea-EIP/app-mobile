import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Fired once at startup: restores the session from the stored token.
class AuthStarted extends AuthEvent {
  const AuthStarted();
}

class AuthLoginSubmitted extends AuthEvent {
  const AuthLoginSubmitted({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => <Object?>[email, password];
}

class AuthRegisterSubmitted extends AuthEvent {
  const AuthRegisterSubmitted({
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

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

/// Dismisses the current error (e.g. when switching login / register tab).
class AuthErrorCleared extends AuthEvent {
  const AuthErrorCleared();
}
