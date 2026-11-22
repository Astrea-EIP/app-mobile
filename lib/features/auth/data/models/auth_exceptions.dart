enum AuthFailure { invalidCredentials, emailAlreadyUsed, sessionExpired }

/// Business error raised by an auth repository.
///
/// [message] is already user-facing (French) and can be shown as is.
class AuthException implements Exception {
  const AuthException(this.failure, this.message);

  const AuthException.invalidCredentials()
    : this(AuthFailure.invalidCredentials, 'E-mail ou mot de passe incorrect.');

  const AuthException.emailAlreadyUsed()
    : this(
        AuthFailure.emailAlreadyUsed,
        'Un compte existe déjà avec cette adresse e-mail.',
      );

  const AuthException.sessionExpired()
    : this(
        AuthFailure.sessionExpired,
        'Votre session a expiré. Veuillez vous reconnecter.',
      );

  final AuthFailure failure;
  final String message;

  @override
  String toString() => 'AuthException(${failure.name}): $message';
}
