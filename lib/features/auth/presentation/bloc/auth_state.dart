import 'package:equatable/equatable.dart';
import 'package:astrea/features/auth/data/models/auth_session.dart';

enum AuthStatus {
  /// Startup: looking for a stored token.
  checking,
  unauthenticated,

  /// A login / register request is in flight.
  submitting,
  authenticated,

  /// The last login / register attempt failed; see [AuthState.errorMessage].
  failure,
}

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.checking,
    this.session,
    this.errorMessage,
  });

  const AuthState.unauthenticated() : this(status: AuthStatus.unauthenticated);

  const AuthState.submitting() : this(status: AuthStatus.submitting);

  const AuthState.authenticated(AuthSession session)
    : this(status: AuthStatus.authenticated, session: session);

  const AuthState.failure(String message)
    : this(status: AuthStatus.failure, errorMessage: message);

  final AuthStatus status;
  final AuthSession? session;
  final String? errorMessage;

  bool get isSubmitting => status == AuthStatus.submitting;

  @override
  List<Object?> get props => <Object?>[status, session, errorMessage];
}
