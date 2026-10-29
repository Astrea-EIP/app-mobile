import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:astrea/core/theme/app_theme.dart';
import 'package:astrea/core/widgets/widgets.dart';
import 'package:astrea/features/onboarding/data/models/accessibility_profile.dart';
import 'package:astrea/features/onboarding/presentation/bloc/profile_bloc.dart';
import 'package:astrea/features/onboarding/presentation/bloc/profile_event.dart';
import 'package:astrea/features/onboarding/presentation/bloc/profile_state.dart';
import 'package:astrea/features/onboarding/presentation/screens/onboarding_success_screen.dart';
import 'package:astrea/features/onboarding/presentation/widgets/dimensions_step_form.dart';
import 'package:astrea/features/onboarding/presentation/widgets/mobility_type_card.dart';
import 'package:astrea/features/onboarding/presentation/widgets/onboarding_progress_bar.dart';
import 'package:astrea/features/onboarding/presentation/widgets/preference_toggle_tile.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final PageController _pageController;
  late final TextEditingController _widthController;
  late final TextEditingController _lengthController;
  late final TextEditingController _stepHeightController;
  final GlobalKey<FormState> _dimensionsFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _widthController = TextEditingController();
    _lengthController = TextEditingController();
    _stepHeightController = TextEditingController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _widthController.dispose();
    _lengthController.dispose();
    _stepHeightController.dispose();
    super.dispose();
  }

  void _syncDimensionsToBloc() {
    final double? width = double.tryParse(
      _widthController.text.replaceAll(',', '.'),
    );
    final double? length = double.tryParse(
      _lengthController.text.replaceAll(',', '.'),
    );
    final double? stepHeight = double.tryParse(
      _stepHeightController.text.replaceAll(',', '.'),
    );

    context.read<ProfileBloc>().add(
      ProfileDimensionsChanged(
        widthCm: width,
        lengthCm: length,
        maxStepHeightCm: stepHeight,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listenWhen: (ProfileState prev, ProfileState curr) =>
          prev.status != curr.status ||
          prev.currentStep != curr.currentStep ||
          prev.errorMessage != curr.errorMessage,
      listener: (BuildContext context, ProfileState state) {
        if (state.errorMessage != null &&
            state.status != ProfileSubmissionStatus.loading) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.errorMessage!,
                style: const TextStyle(color: AppColors.onError),
              ),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }

        if (state.status == ProfileSubmissionStatus.success) {
          SemanticsService.sendAnnouncement(
            View.of(context),
            'Profil créé avec succès ! Astrea calculera désormais des itinéraires adaptés à vos besoins.',
            TextDirection.ltr,
          );
        }

        if (_pageController.hasClients &&
            _pageController.page?.round() != state.currentStep) {
          _pageController.animateToPage(
            state.currentStep,
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeInOut,
          );
          SemanticsService.sendAnnouncement(
            View.of(context),
            'Étape ${state.currentStep + 1} sur ${state.totalSteps}',
            TextDirection.ltr,
          );
        }
      },
      builder: (BuildContext context, ProfileState state) {
        if (state.status == ProfileSubmissionStatus.success) {
          final AccessibilityProfile? profile = state.toProfile;
          if (profile != null) {
            return OnboardingSuccessScreen(
              profile: profile,
              onRestart: () {
                _widthController.clear();
                _lengthController.clear();
                _stepHeightController.clear();
                context.read<ProfileBloc>().add(const ProfileResetRequested());
              },
            );
          }
        }

        return Scaffold(
          backgroundColor: AppColors.page,
          appBar: const AstreaAppBar(subtitle: 'Profil d\'accès'),
          body: SafeArea(
            child: Column(
              children: <Widget>[
                OnboardingProgressBar(
                  currentStep: state.currentStep,
                  totalSteps: state.totalSteps,
                ),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: <Widget>[
                      _buildMobilityStep(context, state),
                      _buildDimensionsStep(context, state),
                      _buildPreferencesStep(context, state),
                      _buildSummaryStep(context, state),
                    ],
                  ),
                ),
                _buildBottomBar(context, state),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMobilityStep(BuildContext context, ProfileState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s20,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Comment vous déplacez-vous ?',
            style: AppTypography.titreLg,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Choisissez votre profil principal pour adapter la pente, les largeurs et les alertes d\'itinéraires.',
            style: AppTypography.corpsMd.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: AppSpacing.s20),
          ...MobilityType.values.map(
            (MobilityType type) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s12),
              child: MobilityTypeCard(
                type: type,
                isSelected: state.mobilityType == type,
                onTap: () {
                  context.read<ProfileBloc>().add(
                    ProfileMobilitySelected(type),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDimensionsStep(BuildContext context, ProfileState state) {
    if (!state.requiresDimensions) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: AppColors.badge,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline_rounded,
                  color: AppColors.primaryStrong,
                  size: 48,
                ),
              ),
              const SizedBox(height: AppSpacing.s20),
              const Text(
                'Aucune mesure requise !',
                style: AppTypography.titreMd,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Votre mode (${state.mobilityType?.displayName ?? "sélectionné"}) ne nécessite pas de gabarit de passage contraignant.',
                style: AppTypography.corpsMd.copyWith(color: AppColors.muted),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s20,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Dimensions de l\'équipement',
            style: AppTypography.titreLg,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Indiquez vos mensurations pour vérifier chaque porte, ascenseur et trottoir.',
            style: AppTypography.corpsMd.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: AppSpacing.s20),
          DimensionsStepForm(
            widthController: _widthController,
            lengthController: _lengthController,
            stepHeightController: _stepHeightController,
            onChanged: _syncDimensionsToBloc,
            formKey: _dimensionsFormKey,
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesStep(BuildContext context, ProfileState state) {
    final RoutePreferences prefs = state.preferences;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s20,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Vos préférences d\'itinéraire',
            style: AppTypography.titreLg,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Personnalisez le calcul de vos trajets selon vos besoins et votre confort.',
            style: AppTypography.corpsMd.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: AppSpacing.s20),
          PreferenceToggleTile(
            title: 'Itinéraires adaptés aux chiens',
            subtitle:
                'Chiens d\'assistance ou de compagnie bienvenus, évite zones denses',
            icon: Icons.pets_rounded,
            value: prefs.dogFriendly,
            iconColor: AppColors.accentStrong,
            badgeBg: AppColors.accentBg,
            onChanged: (bool val) {
              context.read<ProfileBloc>().add(ProfileDogFriendlyToggled(val));
            },
          ),
          PreferenceToggleTile(
            title: 'Éviter impérativement les escaliers',
            subtitle: 'Priorise rampes douces, plans inclinés et ascenseurs',
            icon: Icons.stairs_rounded,
            value: prefs.avoidStairs,
            iconColor: AppColors.primaryStrong,
            badgeBg: AppColors.badge,
            onChanged: (bool val) {
              context.read<ProfileBloc>().add(ProfileAvoidStairsToggled(val));
            },
          ),
          PreferenceToggleTile(
            title: 'Éviter les fortes pentes (> 6%)',
            subtitle:
                'Privilégie les axes à faible déclivité pour moins d\'effort',
            icon: Icons.trending_up_rounded,
            value: prefs.avoidSteepSlopes,
            iconColor: AppColors.tertiary,
            badgeBg: AppColors.tertiaryBg,
            onChanged: (bool val) {
              context.read<ProfileBloc>().add(
                ProfileAvoidSteepSlopesToggled(val),
              );
            },
          ),
          PreferenceToggleTile(
            title: 'Éviter les sols accidentés / pavés',
            subtitle:
                'Écarte les pavés déchaussés, graviers et terrains irréguliers',
            icon: Icons.terrain_rounded,
            value: prefs.avoidUnevenSurfaces,
            iconColor: AppColors.accentStrong,
            badgeBg: AppColors.accentBg,
            onChanged: (bool val) {
              context.read<ProfileBloc>().add(
                ProfileAvoidUnevenSurfacesToggled(val),
              );
            },
          ),
          PreferenceToggleTile(
            title: 'Privilégier les ascenseurs actifs',
            subtitle:
                'Sélectionne les accès garantis avec ascenseur fonctionnel',
            icon: Icons.elevator_rounded,
            value: prefs.preferElevators,
            iconColor: AppColors.primaryStrong,
            badgeBg: AppColors.badge,
            onChanged: (bool val) {
              context.read<ProfileBloc>().add(
                ProfilePreferElevatorsToggled(val),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStep(BuildContext context, ProfileState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s20,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Récapitulatif de votre profil',
            style: AppTypography.titreLg,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Vérifiez vos paramètres avant de finaliser l\'onboarding.',
            style: AppTypography.corpsMd.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: AppSpacing.s20),

          // Passport card with Astrea gradient header
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.border),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: AppColors.shadowMd,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: <Widget>[
                // Card header with gradient
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.s12,
                  ),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: <Color>[
                        AppColors.brandGradientStart,
                        AppColors.brandGradientEnd,
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(AppRadius.lg),
                      topRight: Radius.circular(AppRadius.lg),
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      const Icon(
                        Icons.verified_user_rounded,
                        color: AppColors.onPrimary,
                        size: 20,
                        semanticLabel: 'Passeport vérifié',
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Passeport d\'Accessibilité Astrea',
                        style: AppTypography.corpsMdGras.copyWith(
                          color: AppColors.onPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    children: <Widget>[
                      _buildSummaryRow(
                        label: 'Mode de mobilité',
                        value: state.mobilityType?.displayName ?? 'Non choisi',
                        badgeColor: AppColors.primaryStrong,
                        badgeBg: AppColors.badge,
                      ),
                      if (state.requiresDimensions) ...<Widget>[
                        const Divider(height: 24, color: AppColors.border),
                        _buildSummaryRow(
                          label: 'Gabarit (L × L)',
                          value:
                              '${state.widthCm?.toStringAsFixed(0) ?? "-"} × ${state.lengthCm?.toStringAsFixed(0) ?? "-"} cm',
                          badgeColor: AppColors.accentStrong,
                          badgeBg: AppColors.accentBg,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _buildSummaryRow(
                          label: 'Seuil max de marche',
                          value:
                              '${state.maxStepHeightCm?.toStringAsFixed(0) ?? "-"} cm',
                          badgeColor: AppColors.tertiary,
                          badgeBg: AppColors.tertiaryBg,
                        ),
                      ],
                      const Divider(height: 24, color: AppColors.border),
                      _buildSummaryRow(
                        label: 'Chiens acceptés',
                        value: state.preferences.dogFriendly ? 'Oui' : 'Non',
                        badgeColor: state.preferences.dogFriendly
                            ? AppColors.primaryStrong
                            : AppColors.muted,
                        badgeBg: state.preferences.dogFriendly
                            ? AppColors.badge
                            : AppColors.page,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _buildSummaryRow(
                        label: 'Éviter les escaliers',
                        value: state.preferences.avoidStairs ? 'Oui' : 'Non',
                        badgeColor: state.preferences.avoidStairs
                            ? AppColors.primaryStrong
                            : AppColors.muted,
                        badgeBg: state.preferences.avoidStairs
                            ? AppColors.badge
                            : AppColors.page,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _buildSummaryRow(
                        label: 'Éviter fortes pentes',
                        value: state.preferences.avoidSteepSlopes
                            ? 'Oui'
                            : 'Non',
                        badgeColor: state.preferences.avoidSteepSlopes
                            ? AppColors.primaryStrong
                            : AppColors.muted,
                        badgeBg: state.preferences.avoidSteepSlopes
                            ? AppColors.badge
                            : AppColors.page,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow({
    required String label,
    required String value,
    required Color badgeColor,
    required Color badgeBg,
  }) {
    return MergeSemantics(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            label,
            style: AppTypography.corpsMd.copyWith(color: AppColors.muted),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s12,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(AppRadius.full),
              border: Border.all(color: badgeColor.withAlpha(51)),
            ),
            child: Text(
              value,
              style: AppTypography.corpsMdGras.copyWith(color: badgeColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, ProfileState state) {
    final bool isLastStep = state.currentStep == state.totalSteps - 1;
    final bool isLoading = state.status == ProfileSubmissionStatus.loading;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: <Widget>[
          if (state.currentStep > 0) ...<Widget>[
            Expanded(
              child: AstreaButton.outlined(
                label: 'Retour',
                onPressed: isLoading
                    ? null
                    : () {
                        context.read<ProfileBloc>().add(
                          const ProfilePreviousStepRequested(),
                        );
                      },
              ),
            ),
            const SizedBox(width: AppSpacing.s12),
          ],
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap:
                  state.currentStep == 1 &&
                      !state.isCurrentStepValid &&
                      !isLoading
                  ? () => _dimensionsFormKey.currentState?.validate()
                  : null,
              child: AstreaButton.primary(
                label: isLastStep ? 'Valider mon profil' : 'Continuer',
                icon: isLastStep
                    ? Icons.check_circle_rounded
                    : Icons.arrow_forward_rounded,
                isLoading: isLoading,
                onPressed: isLoading || !state.isCurrentStepValid
                    ? null
                    : () {
                        if (isLastStep) {
                          context.read<ProfileBloc>().add(
                            const ProfileSubmitted(),
                          );
                        } else {
                          if (state.currentStep == 1) {
                            _dimensionsFormKey.currentState?.validate();
                          }
                          context.read<ProfileBloc>().add(
                            const ProfileNextStepRequested(),
                          );
                        }
                      },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
