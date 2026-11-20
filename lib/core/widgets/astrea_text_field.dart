import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:astrea/core/theme/app_theme.dart';

/// Single-line text field matching the Figma "Input" component:
/// 48 px high, 1.5 px strong border, 10 px radius, muted placeholder.
///
/// The error state swaps the border to the error colour and shows the
/// message under the field.
class AstreaTextField extends StatelessWidget {
  const AstreaTextField({
    required this.controller,
    required this.hint,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.inputFormatters,
    this.onFieldSubmitted,
    this.obscureText = false,
    this.enabled = true,
    super.key,
  });

  final TextEditingController controller;
  final String hint;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onFieldSubmitted;
  final bool obscureText;
  final bool enabled;

  static OutlineInputBorder _border(Color color, double width) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      obscureText: obscureText,
      enableSuggestions: !obscureText,
      autocorrect: !obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      inputFormatters: inputFormatters,
      validator: validator,
      onFieldSubmitted: onFieldSubmitted,
      style: AppTypography.corpsLg,
      cursorColor: AppColors.primaryStrong,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTypography.corpsLg.copyWith(color: AppColors.muted),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.s12,
        ),
        errorStyle: AppTypography.petit.copyWith(color: AppColors.error),
        errorMaxLines: 2,
        border: _border(AppColors.borderStrong, 1.5),
        enabledBorder: _border(AppColors.borderStrong, 1.5),
        disabledBorder: _border(AppColors.border, 1.5),
        focusedBorder: _border(AppColors.primaryStrong, 2),
        errorBorder: _border(AppColors.errorBorder, 1.5),
        focusedErrorBorder: _border(AppColors.errorBorder, 2),
      ),
    );
  }
}
