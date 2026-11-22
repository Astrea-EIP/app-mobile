import 'package:flutter_test/flutter_test.dart';
import 'package:astrea/features/auth/presentation/auth_validators.dart';

void main() {
  group('AuthValidators', () {
    test('email', () {
      expect(AuthValidators.email(''), isNotNull);
      expect(AuthValidators.email('   '), isNotNull);
      expect(AuthValidators.email('pas-un-mail'), isNotNull);
      expect(AuthValidators.email('a@b'), isNotNull);
      expect(AuthValidators.email('a@b.fr'), isNull);
      expect(AuthValidators.email('  a@b.fr '), isNull);
    });

    test('email is limited to 254 characters (accounts contract)', () {
      // '@b.fr' is 5 characters long.
      final String atLimit = '${'a' * 249}@b.fr';
      final String tooLong = '${'a' * 250}@b.fr';
      expect(atLimit.length, 254);
      expect(tooLong.length, 255);
      expect(AuthValidators.email(atLimit), isNull);
      expect(AuthValidators.email(tooLong), isNotNull);
    });

    test('requiredPassword only checks presence', () {
      expect(AuthValidators.requiredPassword(null), isNotNull);
      expect(AuthValidators.requiredPassword(''), isNotNull);
      expect(AuthValidators.requiredPassword('x'), isNull);
    });

    test('newPassword follows the contract: 8 to 128 characters', () {
      expect(AuthValidators.newPassword(''), isNotNull);
      expect(AuthValidators.newPassword('1234567'), isNotNull);
      expect(AuthValidators.newPassword('12345678'), isNull);
      expect(AuthValidators.newPassword('a' * 128), isNull);
      expect(AuthValidators.newPassword('a' * 129), isNotNull);
    });

    test('fullName follows the contract: 1 to 80 characters', () {
      expect(AuthValidators.fullName(null), isNotNull);
      expect(AuthValidators.fullName(' '), isNotNull);
      expect(AuthValidators.fullName('A'), isNull);
      expect(AuthValidators.fullName('Léa Dupont'), isNull);
      expect(AuthValidators.fullName('a' * 80), isNull);
      expect(AuthValidators.fullName('a' * 81), isNotNull);
    });

    test('birthDate accepts real past dates only', () {
      final DateTime now = DateTime(2026, 6, 15);
      expect(
        AuthValidators.parseBirthDate('17 / 05 / 1995', now: now),
        DateTime(1995, 5, 17),
      );
      expect(AuthValidators.parseBirthDate('31 / 02 / 1995', now: now), isNull);
      expect(AuthValidators.parseBirthDate('17 / 05 / 1899', now: now), isNull);
      expect(AuthValidators.parseBirthDate('16 / 06 / 2026', now: now), isNull);
      // Strictly in the past: today is refused, yesterday is accepted.
      expect(AuthValidators.parseBirthDate('15 / 06 / 2026', now: now), isNull);
      expect(
        AuthValidators.parseBirthDate('14 / 06 / 2026', now: now),
        DateTime(2026, 6, 14),
      );
      expect(AuthValidators.parseBirthDate('17 / 05', now: now), isNull);
      expect(AuthValidators.birthDate(''), isNotNull);
      expect(AuthValidators.birthDate('17 / 05 / 1995'), isNull);
    });
  });

  group('BirthDateInputFormatter', () {
    const BirthDateInputFormatter formatter = BirthDateInputFormatter();

    String format(String typed) => formatter
        .formatEditUpdate(TextEditingValue.empty, TextEditingValue(text: typed))
        .text;

    test('inserts separators progressively', () {
      expect(format('1'), '1');
      expect(format('12'), '12');
      expect(format('123'), '12 / 3');
      expect(format('1234'), '12 / 34');
      expect(format('12345'), '12 / 34 / 5');
      expect(format('12341995'), '12 / 34 / 1995');
    });

    test('drops non digits and caps at 8 digits', () {
      expect(format('12/34/19959999'), '12 / 34 / 1995');
      expect(format('ab'), '');
    });
  });
}
