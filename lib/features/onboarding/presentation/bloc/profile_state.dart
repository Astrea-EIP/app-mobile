import 'package:equatable/equatable.dart';
import 'package:astrea/features/onboarding/data/models/accessibility_profile.dart';

enum ProfileSubmissionStatus { initial, loading, success, failure }

class ProfileState extends Equatable {
  const ProfileState({
    this.currentStep = 0,
    this.status = ProfileSubmissionStatus.initial,
    this.mobilityType,
    this.widthCm,
    this.lengthCm,
    this.maxStepHeightCm,
    this.preferences = const RoutePreferences(),
    this.errorMessage,
  });

  final int currentStep;
  final ProfileSubmissionStatus status;
  final MobilityType? mobilityType;
  final double? widthCm;
  final double? lengthCm;
  final double? maxStepHeightCm;
  final RoutePreferences preferences;
  final String? errorMessage;

  /// Returns total number of steps in the onboarding flow.
  int get totalSteps => 4;

  /// Whether the selected mobility type mandates equipment dimensions.
  bool get requiresDimensions => mobilityType?.requiresDimensions ?? false;

  /// Validates the dimensions input if required.
  bool get isDimensionsValid {
    if (!requiresDimensions) {
      return true;
    }
    if (widthCm == null || lengthCm == null || maxStepHeightCm == null) {
      return false;
    }
    return widthCm! > 0 &&
        widthCm! <= 200 &&
        lengthCm! > 0 &&
        lengthCm! <= 250 &&
        maxStepHeightCm! >= 0 &&
        maxStepHeightCm! <= 50;
  }

  /// Checks if current step has satisfied all validation rules to proceed.
  bool get isCurrentStepValid {
    switch (currentStep) {
      case 0:
        return mobilityType != null;
      case 1:
        return isDimensionsValid;
      case 2:
        return true;
      case 3:
        return canSubmit;
      default:
        return false;
    }
  }

  /// Overall validation for submitting the profile to the backend.
  bool get canSubmit => mobilityType != null && isDimensionsValid;

  /// Builds a validated AccessibilityProfile instance.
  AccessibilityProfile? get toProfile {
    if (!canSubmit || mobilityType == null) {
      return null;
    }

    final WheelchairDimensions? dims = requiresDimensions
        ? WheelchairDimensions(
            widthCm: widthCm!,
            lengthCm: lengthCm!,
            maxStepHeightCm: maxStepHeightCm!,
          )
        : null;

    return AccessibilityProfile(
      mobilityType: mobilityType!,
      dimensions: dims,
      preferences: preferences,
    );
  }

  ProfileState copyWith({
    int? currentStep,
    ProfileSubmissionStatus? status,
    MobilityType? mobilityType,
    double? widthCm,
    double? lengthCm,
    double? maxStepHeightCm,
    RoutePreferences? preferences,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ProfileState(
      currentStep: currentStep ?? this.currentStep,
      status: status ?? this.status,
      mobilityType: mobilityType ?? this.mobilityType,
      widthCm: widthCm ?? this.widthCm,
      lengthCm: lengthCm ?? this.lengthCm,
      maxStepHeightCm: maxStepHeightCm ?? this.maxStepHeightCm,
      preferences: preferences ?? this.preferences,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => <Object?>[
    currentStep,
    status,
    mobilityType,
    widthCm,
    lengthCm,
    maxStepHeightCm,
    preferences,
    errorMessage,
  ];
}
