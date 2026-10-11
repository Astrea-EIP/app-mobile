import 'package:flutter/material.dart';
import 'package:astrea/core/theme/app_theme.dart';
import 'package:astrea/features/onboarding/data/models/accessibility_profile.dart';

class OnboardingSuccessScreen extends StatelessWidget {
  const OnboardingSuccessScreen({
    required this.profile,
    this.onRestart,
    super.key,
  });

  final AccessibilityProfile profile;
  final VoidCallback? onRestart;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.page,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: AppSpacing.s20),
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: AppColors.badge,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryStrong, width: 2),
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.primaryStrong,
                  size: 54,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const Text(
                'Profil créé avec succès !',
                style: AppTypography.titreLg,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.s12),
              Text(
                'Vos préférences d\'accessibilité ont été enregistrées. Astrea calculera désormais des itinéraires adaptés à vos besoins.',
                textAlign: TextAlign.center,
                style: AppTypography.corpsMd.copyWith(color: AppColors.muted),
              ),
              const SizedBox(height: AppSpacing.lg),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'Mobilité',
                            style: AppTypography.corpsMd.copyWith(
                              color: AppColors.muted,
                            ),
                          ),
                          Text(
                            profile.mobilityType.displayName,
                            style: AppTypography.corpsMdGras,
                          ),
                        ],
                      ),
                      if (profile.dimensions != null) ...<Widget>[
                        const Divider(
                          height: AppSpacing.lg,
                          color: AppColors.border,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              'Dimensions (L × L)',
                              style: AppTypography.corpsMd.copyWith(
                                color: AppColors.muted,
                              ),
                            ),
                            Text(
                              '${profile.dimensions!.widthCm.toStringAsFixed(0)} × ${profile.dimensions!.lengthCm.toStringAsFixed(0)} cm',
                              style: AppTypography.corpsMdGras,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              'Seuil max de marche',
                              style: AppTypography.corpsMd.copyWith(
                                color: AppColors.muted,
                              ),
                            ),
                            Text(
                              '${profile.dimensions!.maxStepHeightCm.toStringAsFixed(0)} cm',
                              style: AppTypography.corpsMdGras,
                            ),
                          ],
                        ),
                      ],
                      const Divider(
                        height: AppSpacing.lg,
                        color: AppColors.border,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'Chiens acceptés',
                            style: AppTypography.corpsMd.copyWith(
                              color: AppColors.muted,
                            ),
                          ),
                          Text(
                            profile.preferences.dogFriendly ? 'Oui' : 'Non',
                            style: AppTypography.corpsMdGras,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'Éviter les escaliers',
                            style: AppTypography.corpsMd.copyWith(
                              color: AppColors.muted,
                            ),
                          ),
                          Text(
                            profile.preferences.avoidStairs ? 'Oui' : 'Non',
                            style: AppTypography.corpsMdGras,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Configuration terminée ! Bienvenue sur Astrea.',
                        style: TextStyle(color: AppColors.onPrimary),
                      ),
                      backgroundColor: AppColors.primaryStrong,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  elevation: 0,
                ),
                child: const Text('Commencer l\'exploration'),
              ),
              if (onRestart != null) ...<Widget>[
                const SizedBox(height: AppSpacing.s12),
                TextButton(
                  onPressed: onRestart,
                  child: Text(
                    'Recommencer l\'onboarding (Démo)',
                    style: AppTypography.corpsMd.copyWith(
                      color: AppColors.muted,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
