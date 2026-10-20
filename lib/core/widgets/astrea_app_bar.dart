import 'package:flutter/material.dart';
import 'package:astrea/core/theme/app_theme.dart';

/// Reusable Astrea standard AppBar with centered brand title, dot separator and subtitle.
class AstreaAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AstreaAppBar({
    this.subtitle,
    this.leading,
    this.actions,
    this.backgroundColor = Colors.transparent,
    super.key,
  });

  final String? subtitle;
  final Widget? leading;
  final List<Widget>? actions;
  final Color backgroundColor;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      centerTitle: true,
      backgroundColor: backgroundColor,
      leading: leading,
      actions: actions,
      title: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const Text('Astrea', style: AppTypography.brandTitle),
            if (subtitle != null) ...<Widget>[
              const SizedBox(width: AppSpacing.sm),
              const ExcludeSemantics(
                child: SizedBox(
                  width: 4,
                  height: 4,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.borderStrong,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                subtitle!,
                style: AppTypography.corpsMd.copyWith(color: AppColors.muted),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
