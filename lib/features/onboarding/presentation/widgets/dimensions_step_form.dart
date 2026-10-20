import 'package:flutter/material.dart';
import 'package:astrea/core/theme/app_theme.dart';

class DimensionsStepForm extends StatelessWidget {
  const DimensionsStepForm({
    required this.widthController,
    required this.lengthController,
    required this.stepHeightController,
    required this.onChanged,
    super.key,
  });

  final TextEditingController widthController;
  final TextEditingController lengthController;
  final TextEditingController stepHeightController;
  final VoidCallback onChanged;

  String? _validateDimension(String? value, {required double max}) {
    if (value == null || value.trim().isEmpty) {
      return 'Ce champ est requis';
    }
    final double? parsed = double.tryParse(value.replaceAll(',', '.'));
    if (parsed == null || parsed <= 0) {
      return 'Doit être supérieur à 0';
    }
    if (parsed > max) {
      return 'Doit être ≤ ${max.toInt()} cm';
    }
    return null;
  }

  String? _validateStepHeight(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ce champ est requis';
    }
    final double? parsed = double.tryParse(value.replaceAll(',', '.'));
    if (parsed == null || parsed < 0) {
      return 'Doit être ≥ 0';
    }
    if (parsed > 50) {
      return 'Doit être ≤ 50 cm';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Info card with warm border
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.border),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.badge,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.primaryStrong),
                ),
                child: const Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.primaryStrong,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Pourquoi ces dimensions ?',
                      style: AppTypography.corpsMdGras.copyWith(
                        color: AppColors.primaryStrong,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Pour calculer des itinéraires évitant passages étroits, tourniquets ou portes infranchissables.',
                      style: AppTypography.petit,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s20),

        // Width Field
        _buildDimensionField(
          context: context,
          label: 'Largeur totale de l\'équipement',
          hint: 'ex. 65',
          controller: widthController,
          validator: (String? val) => _validateDimension(val, max: 200),
          icon: Icons.swap_horiz_rounded,
          iconColor: AppColors.accentStrong,
          badgeBg: AppColors.accentBg,
        ),
        const SizedBox(height: AppSpacing.md),

        // Length Field
        _buildDimensionField(
          context: context,
          label: 'Longueur totale de l\'équipement',
          hint: 'ex. 105',
          controller: lengthController,
          validator: (String? val) => _validateDimension(val, max: 250),
          icon: Icons.swap_vert_rounded,
          iconColor: AppColors.tertiary,
          badgeBg: AppColors.tertiaryBg,
        ),
        const SizedBox(height: AppSpacing.md),

        // Step Height Field
        _buildDimensionField(
          context: context,
          label: 'Hauteur max de marche / bordure franchissable',
          hint: 'ex. 4',
          controller: stepHeightController,
          validator: _validateStepHeight,
          icon: Icons.height_rounded,
          iconColor: AppColors.primaryStrong,
          badgeBg: AppColors.badge,
        ),
      ],
    );
  }

  Widget _buildDimensionField({
    required BuildContext context,
    required String label,
    required String hint,
    required TextEditingController controller,
    required String? Function(String?) validator,
    required IconData icon,
    required Color iconColor,
    required Color badgeBg,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(label, style: AppTypography.corpsMdGras)),
            ],
          ),
          const SizedBox(height: AppSpacing.s12),
          TextFormField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: validator,
            onChanged: (_) => onChanged(),
            decoration: InputDecoration(
              hintText: hint,
              suffixText: 'cm',
              suffixStyle: AppTypography.corpsMdGras.copyWith(color: iconColor),
            ),
          ),
        ],
      ),
    );
  }
}
