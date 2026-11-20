import 'package:astrea/features/auth/data/models/auth_session.dart';

/// Account used by the auth tests; registered explicitly, since the mock
/// repository starts empty.
abstract final class TestAccount {
  static const String email = 'camille@astrea.app';
  static const String password = 'motdepasse1';
  static const String name = 'Camille Martin';

  static AuthRegistration get registration => AuthRegistration(
    fullName: name,
    email: email,
    password: password,
    birthDate: DateTime(1995, 5, 17),
  );
}
