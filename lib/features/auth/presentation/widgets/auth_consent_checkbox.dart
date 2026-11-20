import 'package:flutter/material.dart';
import 'package:astrea/core/theme/app_theme.dart';

/// Consent checkbox of the register form (22 px box + 12 px legal text).
/// The whole row is tappable.
class AuthConsentCheckbox extends StatelessWidget {
  const AuthConsentCheckbox({
    required this.label,
    required this.value,
    required this.onChanged,
    this.errorText,
    this.enabled = true,
    super.key,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? errorText;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Semantics(
          checked: value,
          enabled: enabled,
          label: label,
          excludeSemantics: true,
          onTap: enabled ? () => onChanged(!value) : null,
          child: InkWell(
            onTap: enabled ? () => onChanged(!value) : null,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10,
                children: <Widget>[
                  _Box(checked: value, hasError: errorText != null),
                  Expanded(
                    child: Text(
                      label,
                      style: AppTypography.petit.copyWith(
                        color: AppColors.ink,
                        height: 16 / 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Text(
              errorText!,
              style: AppTypography.petit.copyWith(color: AppColors.error),
            ),
          ),
      ],
    );
  }
}

class _Box extends StatelessWidget {
  const _Box({required this.checked, required this.hasError});

  final bool checked;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: checked ? AppColors.primary : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(
          color: hasError
              ? AppColors.errorBorder
              : (checked ? AppColors.primaryStrong : AppColors.borderStrong),
          width: 2,
        ),
      ),
      child: checked
          ? const Icon(
              Icons.check_rounded,
              size: 16,
              color: AppColors.onPrimary,
            )
          : null,
    );
  }
}
