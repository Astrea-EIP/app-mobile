import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:astrea/features/onboarding/data/models/accessibility_profile.dart';
import 'package:astrea/features/onboarding/data/repositories/profile_repository.dart';
import 'package:astrea/features/onboarding/presentation/bloc/profile_event.dart';
import 'package:astrea/features/onboarding/presentation/bloc/profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({required ProfileRepository profileRepository})
    : _profileRepository = profileRepository,
      super(const ProfileState()) {
    on<ProfileMobilitySelected>(_onMobilitySelected);
    on<ProfileDimensionsChanged>(_onDimensionsChanged);
    on<ProfileDogFriendlyToggled>(_onDogFriendlyToggled);
    on<ProfileAvoidStairsToggled>(_onAvoidStairsToggled);
    on<ProfileAvoidSteepSlopesToggled>(_onAvoidSteepSlopesToggled);
    on<ProfileAvoidUnevenSurfacesToggled>(_onAvoidUnevenSurfacesToggled);
    on<ProfilePreferElevatorsToggled>(_onPreferElevatorsToggled);
    on<ProfileStepChanged>(_onStepChanged);
    on<ProfileNextStepRequested>(_onNextStepRequested);
    on<ProfilePreviousStepRequested>(_onPreviousStepRequested);
    on<ProfileSubmitted>(_onSubmitted);
    on<ProfileResetRequested>(_onResetRequested);
  }

  final ProfileRepository _profileRepository;

  void _onMobilitySelected(
    ProfileMobilitySelected event,
    Emitter<ProfileState> emit,
  ) {
    emit(state.copyWith(mobilityType: event.mobilityType, clearError: true));
  }

  void _onDimensionsChanged(
    ProfileDimensionsChanged event,
    Emitter<ProfileState> emit,
  ) {
    emit(
      state.copyWith(
        widthCm: event.widthCm,
        lengthCm: event.lengthCm,
        maxStepHeightCm: event.maxStepHeightCm,
        clearError: true,
      ),
    );
  }

  void _onDogFriendlyToggled(
    ProfileDogFriendlyToggled event,
    Emitter<ProfileState> emit,
  ) {
    emit(
      state.copyWith(
        preferences: state.preferences.copyWith(dogFriendly: event.enabled),
      ),
    );
  }

  void _onAvoidStairsToggled(
    ProfileAvoidStairsToggled event,
    Emitter<ProfileState> emit,
  ) {
    emit(
      state.copyWith(
        preferences: state.preferences.copyWith(avoidStairs: event.enabled),
      ),
    );
  }

  void _onAvoidSteepSlopesToggled(
    ProfileAvoidSteepSlopesToggled event,
    Emitter<ProfileState> emit,
  ) {
    emit(
      state.copyWith(
        preferences: state.preferences.copyWith(
          avoidSteepSlopes: event.enabled,
        ),
      ),
    );
  }

  void _onAvoidUnevenSurfacesToggled(
    ProfileAvoidUnevenSurfacesToggled event,
    Emitter<ProfileState> emit,
  ) {
    emit(
      state.copyWith(
        preferences: state.preferences.copyWith(
          avoidUnevenSurfaces: event.enabled,
        ),
      ),
    );
  }

  void _onPreferElevatorsToggled(
    ProfilePreferElevatorsToggled event,
    Emitter<ProfileState> emit,
  ) {
    emit(
      state.copyWith(
        preferences: state.preferences.copyWith(preferElevators: event.enabled),
      ),
    );
  }

  void _onStepChanged(ProfileStepChanged event, Emitter<ProfileState> emit) {
    if (event.stepIndex >= 0 && event.stepIndex < state.totalSteps) {
      emit(state.copyWith(currentStep: event.stepIndex, clearError: true));
    }
  }

  void _onNextStepRequested(
    ProfileNextStepRequested event,
    Emitter<ProfileState> emit,
  ) {
    if (!state.isCurrentStepValid) {
      emit(
        state.copyWith(
          errorMessage:
              'Veuillez renseigner les champs obligatoires avant de continuer.',
        ),
      );
      return;
    }

    int nextStep = state.currentStep + 1;
    // Skip dimensions step if the selected mobility does not require it
    if (state.currentStep == 0 && !state.requiresDimensions) {
      nextStep = 2; // Jump directly to preferences
    }

    if (nextStep < state.totalSteps) {
      emit(state.copyWith(currentStep: nextStep, clearError: true));
    }
  }

  void _onPreviousStepRequested(
    ProfilePreviousStepRequested event,
    Emitter<ProfileState> emit,
  ) {
    int prevStep = state.currentStep - 1;
    // Skip dimensions step on back navigation if not required
    if (state.currentStep == 2 && !state.requiresDimensions) {
      prevStep = 0;
    }

    if (prevStep >= 0) {
      emit(state.copyWith(currentStep: prevStep, clearError: true));
    }
  }

  Future<void> _onSubmitted(
    ProfileSubmitted event,
    Emitter<ProfileState> emit,
  ) async {
    if (!state.canSubmit) {
      emit(
        state.copyWith(
          errorMessage:
              'Veuillez vérifier vos informations avant de valider votre profil.',
        ),
      );
      return;
    }

    final AccessibilityProfile? profile = state.toProfile;
    if (profile == null) {
      emit(state.copyWith(errorMessage: 'Données de profil incomplètes.'));
      return;
    }

    emit(
      state.copyWith(status: ProfileSubmissionStatus.loading, clearError: true),
    );

    try {
      await _profileRepository.saveProfile(profile);
      emit(state.copyWith(status: ProfileSubmissionStatus.success));
    } catch (e) {
      emit(
        state.copyWith(
          status: ProfileSubmissionStatus.failure,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  void _onResetRequested(
    ProfileResetRequested event,
    Emitter<ProfileState> emit,
  ) {
    emit(const ProfileState());
  }
}
