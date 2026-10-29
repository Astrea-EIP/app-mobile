import 'package:equatable/equatable.dart';
import 'package:astrea/features/onboarding/data/models/accessibility_profile.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => <Object?>[];
}

class ProfileMobilitySelected extends ProfileEvent {
  const ProfileMobilitySelected(this.mobilityType);

  final MobilityType mobilityType;

  @override
  List<Object?> get props => <Object?>[mobilityType];
}

class ProfileDimensionsChanged extends ProfileEvent {
  const ProfileDimensionsChanged({
    this.widthCm,
    this.lengthCm,
    this.maxStepHeightCm,
  });

  final double? widthCm;
  final double? lengthCm;
  final double? maxStepHeightCm;

  @override
  List<Object?> get props => <Object?>[widthCm, lengthCm, maxStepHeightCm];
}

class ProfileDogFriendlyToggled extends ProfileEvent {
  const ProfileDogFriendlyToggled(this.enabled);

  final bool enabled;

  @override
  List<Object?> get props => <Object?>[enabled];
}

class ProfileAvoidStairsToggled extends ProfileEvent {
  const ProfileAvoidStairsToggled(this.enabled);

  final bool enabled;

  @override
  List<Object?> get props => <Object?>[enabled];
}

class ProfileAvoidSteepSlopesToggled extends ProfileEvent {
  const ProfileAvoidSteepSlopesToggled(this.enabled);

  final bool enabled;

  @override
  List<Object?> get props => <Object?>[enabled];
}

class ProfileAvoidUnevenSurfacesToggled extends ProfileEvent {
  const ProfileAvoidUnevenSurfacesToggled(this.enabled);

  final bool enabled;

  @override
  List<Object?> get props => <Object?>[enabled];
}

class ProfilePreferElevatorsToggled extends ProfileEvent {
  const ProfilePreferElevatorsToggled(this.enabled);

  final bool enabled;

  @override
  List<Object?> get props => <Object?>[enabled];
}

class ProfileStepChanged extends ProfileEvent {
  const ProfileStepChanged(this.stepIndex);

  final int stepIndex;

  @override
  List<Object?> get props => <Object?>[stepIndex];
}

class ProfileNextStepRequested extends ProfileEvent {
  const ProfileNextStepRequested();
}

class ProfilePreviousStepRequested extends ProfileEvent {
  const ProfilePreviousStepRequested();
}

class ProfileSubmitted extends ProfileEvent {
  const ProfileSubmitted();
}

class ProfileResetRequested extends ProfileEvent {
  const ProfileResetRequested();
}
