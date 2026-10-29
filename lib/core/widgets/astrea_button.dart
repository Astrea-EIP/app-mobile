import 'package:flutter/material.dart';
import 'package:astrea/core/theme/app_theme.dart';

enum AstreaButtonVariant { primary, outlined, text }

/// Reusable accessible button conforming to Astrea Design Tokens & RGAA.
class AstreaButton extends StatelessWidget {
  const AstreaButton({
    required this.label,
    required this.onPressed,
    this.variant = AstreaButtonVariant.primary,
    this.icon,
    this.iconAfter = true,
    this.isLoading = false,
    this.isFullWidth = true,
    super.key,
  });

  const AstreaButton.primary({
    required String label,
    required VoidCallback? onPressed,
    IconData? icon,
    bool iconAfter = true,
    bool isLoading = false,
    bool isFullWidth = true,
    Key? key,
  }) : this(
         label: label,
         onPressed: onPressed,
         variant: AstreaButtonVariant.primary,
         icon: icon,
         iconAfter: iconAfter,
         isLoading: isLoading,
         isFullWidth: isFullWidth,
         key: key,
       );

  const AstreaButton.outlined({
    required String label,
    required VoidCallback? onPressed,
    IconData? icon,
    bool iconAfter = false,
    bool isLoading = false,
    bool isFullWidth = true,
    Key? key,
  }) : this(
         label: label,
         onPressed: onPressed,
         variant: AstreaButtonVariant.outlined,
         icon: icon,
         iconAfter: iconAfter,
         isLoading: isLoading,
         isFullWidth: isFullWidth,
         key: key,
       );

  final String label;
  final VoidCallback? onPressed;
  final AstreaButtonVariant variant;
  final IconData? icon;
  final bool iconAfter;
  final bool isLoading;
  final bool isFullWidth;

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onPressed != null && !isLoading;

    Widget content;
    if (isLoading) {
      content = Semantics(
        label: '$label, chargement en cours',
        excludeSemantics: true,
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(
              variant == AstreaButtonVariant.primary
                  ? AppColors.onPrimary
                  : AppColors.primaryStrong,
            ),
          ),
        ),
      );
    } else {
      final Color textColor = isEnabled
          ? (variant == AstreaButtonVariant.primary
                ? AppColors.onPrimary
                : AppColors.ink)
          : AppColors.muted;

      final List<Widget> children = <Widget>[
        Flexible(
          child: Text(
            label,
            style: AppTypography.corpsLgGras.copyWith(color: textColor),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
      ];

      if (icon != null) {
        final Widget iconWidget = Icon(icon, size: 20, color: textColor);
        if (iconAfter) {
          children.add(const SizedBox(width: AppSpacing.sm));
          children.add(iconWidget);
        } else {
          children.insert(0, const SizedBox(width: AppSpacing.sm));
          children.insert(0, iconWidget);
        }
      }

      content = FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
      );
    }

    Widget button;
    switch (variant) {
      case AstreaButtonVariant.primary:
        button = ElevatedButton(
          onPressed: isEnabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            disabledBackgroundColor: AppColors.border,
            foregroundColor: AppColors.onPrimary,
            disabledForegroundColor: AppColors.muted,
            minimumSize: Size(isFullWidth ? double.infinity : 0, 52),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            elevation: 0,
          ),
          child: content,
        );
        break;

      case AstreaButtonVariant.outlined:
        button = OutlinedButton(
          onPressed: isEnabled ? onPressed : null,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.ink,
            disabledForegroundColor: AppColors.muted,
            minimumSize: Size(isFullWidth ? double.infinity : 0, 52),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            side: BorderSide(
              color: isEnabled ? AppColors.borderStrong : AppColors.border,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
          ),
          child: content,
        );
        break;

      case AstreaButtonVariant.text:
        button = TextButton(
          onPressed: isEnabled ? onPressed : null,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.muted,
            minimumSize: Size(isFullWidth ? double.infinity : 44, 48),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
          ),
          child: content,
        );
        break;
    }

    return button;
  }
}
