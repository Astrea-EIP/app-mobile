import 'package:flutter/services.dart';

/// Form validators for the auth screens. Each returns an error message, or
/// `null` when the value is valid (the contract of `FormField.validator`).
abstract final class AuthValidators {
  static const int minPasswordLength = 8;

  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? email(String? value) {
    final String text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'Veuillez saisir votre adresse e-mail.';
    }
    if (!_emailPattern.hasMatch(text)) {
      return 'Cette adresse e-mail ne semble pas valide.';
    }
    return null;
  }

  /// Login only checks presence: the server decides if it is correct.
  static String? requiredPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez saisir votre mot de passe.';
    }
    return null;
  }

  static String? newPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez choisir un mot de passe.';
    }
    if (value.length < minPasswordLength) {
      return 'Utilisez au moins $minPasswordLength caractères.';
    }
    return null;
  }

  static String? fullName(String? value) {
    if ((value?.trim().length ?? 0) < 2) {
      return 'Veuillez saisir votre prénom et votre nom.';
    }
    return null;
  }

  static String? birthDate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Veuillez saisir votre date de naissance.';
    }
    if (parseBirthDate(value) == null) {
      return 'Utilisez le format JJ / MM / AAAA avec une date valide.';
    }
    return null;
  }

  /// Parses `JJ / MM / AAAA` (spaces and slashes optional). Returns `null`
  /// for an incomplete, impossible (31/02) or future date.
  static DateTime? parseBirthDate(String value, {DateTime? now}) {
    final String digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 8) {
      return null;
    }
    final int day = int.parse(digits.substring(0, 2));
    final int month = int.parse(digits.substring(2, 4));
    final int year = int.parse(digits.substring(4, 8));
    final DateTime date = DateTime(year, month, day);
    final bool isRealDate =
        date.year == year && date.month == month && date.day == day;
    if (!isRealDate || year < 1900 || date.isAfter(now ?? DateTime.now())) {
      return null;
    }
    return date;
  }
}

/// Formats typed digits as `JJ / MM / AAAA`.
class BirthDateInputFormatter extends TextInputFormatter {
  const BirthDateInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 8) {
      digits = digits.substring(0, 8);
    }
    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i == 2 || i == 4) {
        buffer.write(' / ');
      }
      buffer.write(digits[i]);
    }
    final String text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
