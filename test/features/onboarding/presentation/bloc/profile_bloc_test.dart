import 'package:flutter_test/flutter_test.dart';
import 'package:astrea/features/onboarding/data/models/accessibility_profile.dart';
import 'package:astrea/features/onboarding/data/repositories/profile_repository.dart';
import 'package:astrea/features/onboarding/presentation/bloc/profile_bloc.dart';
import 'package:astrea/features/onboarding/presentation/bloc/profile_event.dart';
import 'package:astrea/features/onboarding/presentation/bloc/profile_state.dart';

void main() {
  group('ProfileState Unit Tests', () {
    test('initial state defaults', () {
      const ProfileState state = ProfileState();
      expect(state.currentStep, equals(0));
      expect(state.status, equals(ProfileSubmissionStatus.initial));
      expect(state.mobilityType, isNull);
      expect(state.widthCm, isNull);
      expect(state.lengthCm, isNull);
      expect(state.maxStepHeightCm, isNull);
      expect(state.errorMessage, isNull);
      expect(state.totalSteps, equals(4));
      expect(state.requiresDimensions, isFalse);
      expect(state.isCurrentStepValid, isFalse);
      expect(state.canSubmit, isFalse);
      expect(state.toProfile, isNull);
    });

    test('requiresDimensions reflects mobility type', () {
      const ProfileState wheelchairState = ProfileState(
        mobilityType: MobilityType.manualWheelchair,
      );
      expect(wheelchairState.requiresDimensions, isTrue);

      const ProfileState pedestrianState = ProfileState(
        mobilityType: MobilityType.pedestrian,
      );
      expect(pedestrianState.requiresDimensions, isFalse);
    });

    test('isDimensionsValid validates correctly for wheelchair', () {
      const ProfileState emptyDims = ProfileState(
        mobilityType: MobilityType.manualWheelchair,
      );
      expect(emptyDims.isDimensionsValid, isFalse);

      const ProfileState invalidDims = ProfileState(
        mobilityType: MobilityType.manualWheelchair,
        widthCm: -5,
        lengthCm: 100,
        maxStepHeightCm: 3,
      );
      expect(invalidDims.isDimensionsValid, isFalse);

      const ProfileState validDims = ProfileState(
        mobilityType: MobilityType.manualWheelchair,
        widthCm: 65,
        lengthCm: 105,
        maxStepHeightCm: 3,
      );
      expect(validDims.isDimensionsValid, isTrue);
    });

    test('isCurrentStepValid handles all steps', () {
      const ProfileState step0Invalid = ProfileState(currentStep: 0);
      expect(step0Invalid.isCurrentStepValid, isFalse);

      const ProfileState step0Valid = ProfileState(
        currentStep: 0,
        mobilityType: MobilityType.pedestrian,
      );
      expect(step0Valid.isCurrentStepValid, isTrue);

      const ProfileState step1Invalid = ProfileState(
        currentStep: 1,
        mobilityType: MobilityType.manualWheelchair,
      );
      expect(step1Invalid.isCurrentStepValid, isFalse);

      const ProfileState step1Valid = ProfileState(
        currentStep: 1,
        mobilityType: MobilityType.manualWheelchair,
        widthCm: 65,
        lengthCm: 100,
        maxStepHeightCm: 4,
      );
      expect(step1Valid.isCurrentStepValid, isTrue);

      const ProfileState step2 = ProfileState(currentStep: 2);
      expect(step2.isCurrentStepValid, isTrue);

      const ProfileState step3Invalid = ProfileState(currentStep: 3);
      expect(step3Invalid.isCurrentStepValid, isFalse);

      const ProfileState step3Valid = ProfileState(
        currentStep: 3,
        mobilityType: MobilityType.pedestrian,
      );
      expect(step3Valid.isCurrentStepValid, isTrue);

      const ProfileState unknownStep = ProfileState(currentStep: 99);
      expect(unknownStep.isCurrentStepValid, isFalse);
    });

    test('toProfile builds model correctly', () {
      const ProfileState pedestrianState = ProfileState(
        mobilityType: MobilityType.pedestrian,
        preferences: RoutePreferences(dogFriendly: true),
      );
      final AccessibilityProfile? pedestrianProfile = pedestrianState.toProfile;
      expect(pedestrianProfile, isNotNull);
      expect(pedestrianProfile!.mobilityType, equals(MobilityType.pedestrian));
      expect(pedestrianProfile.dimensions, isNull);
      expect(pedestrianProfile.preferences.dogFriendly, isTrue);

      const ProfileState wheelchairState = ProfileState(
        mobilityType: MobilityType.manualWheelchair,
        widthCm: 65,
        lengthCm: 105,
        maxStepHeightCm: 5,
      );
      final AccessibilityProfile? wheelchairProfile = wheelchairState.toProfile;
      expect(wheelchairProfile, isNotNull);
      expect(
        wheelchairProfile!.mobilityType,
        equals(MobilityType.manualWheelchair),
      );
      expect(wheelchairProfile.dimensions!.widthCm, equals(65));
      expect(wheelchairProfile.dimensions!.lengthCm, equals(105));
    });

    test('copyWith and clearError work as expected', () {
      const ProfileState initial = ProfileState(
        errorMessage: 'Une erreur est survenue',
      );
      expect(initial.errorMessage, equals('Une erreur est survenue'));

      final ProfileState cleared = initial.copyWith(clearError: true);
      expect(cleared.errorMessage, isNull);

      final ProfileState updatedStep = initial.copyWith(currentStep: 2);
      expect(updatedStep.currentStep, equals(2));
      expect(updatedStep.errorMessage, equals('Une erreur est survenue'));
    });

    test('copyWith can clear nullable fields back to null', () {
      const ProfileState withDims = ProfileState(
        mobilityType: MobilityType.manualWheelchair,
        widthCm: 65,
        lengthCm: 105,
        maxStepHeightCm: 4,
      );
      expect(withDims.isDimensionsValid, isTrue);

      final ProfileState cleared = withDims.copyWith(
        widthCm: null,
        lengthCm: null,
        maxStepHeightCm: null,
      );
      expect(cleared.widthCm, isNull);
      expect(cleared.lengthCm, isNull);
      expect(cleared.maxStepHeightCm, isNull);
      expect(cleared.isDimensionsValid, isFalse);
    });

    test('equality and props work as expected', () {
      const ProfileState s1 = ProfileState(currentStep: 1);
      const ProfileState s2 = ProfileState(currentStep: 1);
      const ProfileState s3 = ProfileState(currentStep: 2);

      expect(s1, equals(s2));
      expect(s1, isNot(equals(s3)));
    });
  });

  group('ProfileBloc', () {
    late MockProfileRepository repository;
    late ProfileBloc bloc;

    setUp(() {
      repository = MockProfileRepository(simulatedDelay: Duration.zero);
      bloc = ProfileBloc(profileRepository: repository);
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state has default values', () {
      expect(bloc.state.currentStep, equals(0));
      expect(bloc.state.status, equals(ProfileSubmissionStatus.initial));
      expect(bloc.state.mobilityType, isNull);
      expect(bloc.state.isCurrentStepValid, isFalse);
    });

    test('ProfileMobilitySelected updates mobilityType', () async {
      bloc.add(const ProfileMobilitySelected(MobilityType.pedestrian));
      await expectLater(
        bloc.stream,
        emits(
          predicate<ProfileState>(
            (ProfileState s) =>
                s.mobilityType == MobilityType.pedestrian &&
                s.isCurrentStepValid == true,
          ),
        ),
      );
    });

    test('ProfileDimensionsChanged updates dimensions and validity', () async {
      bloc.add(const ProfileMobilitySelected(MobilityType.manualWheelchair));
      bloc.add(
        const ProfileDimensionsChanged(
          widthCm: 65,
          lengthCm: 105,
          maxStepHeightCm: 4,
        ),
      );

      await expectLater(
        bloc.stream,
        emitsThrough(
          predicate<ProfileState>(
            (ProfileState s) =>
                s.mobilityType == MobilityType.manualWheelchair &&
                s.widthCm == 65 &&
                s.lengthCm == 105 &&
                s.maxStepHeightCm == 4 &&
                s.isDimensionsValid == true,
          ),
        ),
      );
    });

    test('Preferences toggle events update RoutePreferences', () async {
      bloc.add(const ProfileDogFriendlyToggled(true));
      bloc.add(const ProfileAvoidStairsToggled(false));
      bloc.add(const ProfileAvoidSteepSlopesToggled(true));
      bloc.add(const ProfileAvoidUnevenSurfacesToggled(true));
      bloc.add(const ProfilePreferElevatorsToggled(false));

      await expectLater(
        bloc.stream,
        emitsThrough(
          predicate<ProfileState>(
            (ProfileState s) =>
                s.preferences.dogFriendly == true &&
                s.preferences.avoidStairs == false &&
                s.preferences.avoidSteepSlopes == true &&
                s.preferences.avoidUnevenSurfaces == true &&
                s.preferences.preferElevators == false,
          ),
        ),
      );
    });

    test(
      'Next step is blocked with error message if step is incomplete',
      () async {
        bloc.add(const ProfileNextStepRequested());

        await expectLater(
          bloc.stream,
          emits(
            predicate<ProfileState>(
              (ProfileState s) => s.currentStep == 0 && s.errorMessage != null,
            ),
          ),
        );
      },
    );

    test('Next step skips dimensions to step 2 for pedestrian', () async {
      bloc.add(const ProfileMobilitySelected(MobilityType.pedestrian));
      bloc.add(const ProfileNextStepRequested());

      await expectLater(
        bloc.stream,
        emitsThrough(
          predicate<ProfileState>((ProfileState s) => s.currentStep == 2),
        ),
      );
    });

    test('Next step advances to step 1 for wheelchair', () async {
      bloc.add(const ProfileMobilitySelected(MobilityType.manualWheelchair));
      bloc.add(const ProfileNextStepRequested());

      await expectLater(
        bloc.stream,
        emitsThrough(
          predicate<ProfileState>((ProfileState s) => s.currentStep == 1),
        ),
      );
    });

    test('Next step from step 1 blocked if dimensions invalid', () async {
      bloc.add(const ProfileMobilitySelected(MobilityType.manualWheelchair));
      bloc.add(const ProfileStepChanged(1));
      bloc.add(const ProfileNextStepRequested());

      await expectLater(
        bloc.stream,
        emitsThrough(
          predicate<ProfileState>(
            (ProfileState s) => s.currentStep == 1 && s.errorMessage != null,
          ),
        ),
      );
    });

    test(
      'Next step from step 1 advances to step 2 when dimensions valid',
      () async {
        bloc.add(const ProfileMobilitySelected(MobilityType.manualWheelchair));
        bloc.add(const ProfileStepChanged(1));
        bloc.add(
          const ProfileDimensionsChanged(
            widthCm: 65,
            lengthCm: 105,
            maxStepHeightCm: 4,
          ),
        );
        bloc.add(const ProfileNextStepRequested());

        await expectLater(
          bloc.stream,
          emitsThrough(
            predicate<ProfileState>((ProfileState s) => s.currentStep == 2),
          ),
        );
      },
    );

    test('Next step from step 2 advances to step 3', () async {
      bloc.add(const ProfileMobilitySelected(MobilityType.pedestrian));
      bloc.add(const ProfileStepChanged(2));
      bloc.add(const ProfileNextStepRequested());

      await expectLater(
        bloc.stream,
        emitsThrough(
          predicate<ProfileState>((ProfileState s) => s.currentStep == 3),
        ),
      );
    });

    test('Next step from step 3 does not advance beyond total steps', () async {
      bloc.add(const ProfileMobilitySelected(MobilityType.pedestrian));
      bloc.add(const ProfileStepChanged(3));
      await expectLater(
        bloc.stream,
        emitsThrough(
          predicate<ProfileState>((ProfileState s) => s.currentStep == 3),
        ),
      );

      bloc.add(const ProfileNextStepRequested());
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.currentStep, equals(3));
    });

    test(
      'Previous step skips back to step 0 for pedestrian from step 2',
      () async {
        bloc.add(const ProfileMobilitySelected(MobilityType.pedestrian));
        bloc.add(const ProfileNextStepRequested());
        bloc.add(const ProfilePreviousStepRequested());

        await expectLater(
          bloc.stream,
          emitsThrough(
            predicate<ProfileState>((ProfileState s) => s.currentStep == 0),
          ),
        );
      },
    );

    test(
      'Previous step goes back to step 1 from step 2 for wheelchair',
      () async {
        bloc.add(const ProfileMobilitySelected(MobilityType.manualWheelchair));
        bloc.add(const ProfileStepChanged(2));
        bloc.add(const ProfilePreviousStepRequested());

        await expectLater(
          bloc.stream,
          emitsThrough(
            predicate<ProfileState>((ProfileState s) => s.currentStep == 1),
          ),
        );
      },
    );

    test('Previous step from step 0 stays at step 0', () async {
      bloc.add(const ProfilePreviousStepRequested());
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.currentStep, equals(0));
    });

    test(
      'ProfileStepChanged jumps to valid step and ignores invalid',
      () async {
        bloc.add(const ProfileStepChanged(2));
        await expectLater(
          bloc.stream,
          emitsThrough(
            predicate<ProfileState>((ProfileState s) => s.currentStep == 2),
          ),
        );

        bloc.add(const ProfileStepChanged(-1));
        await Future<void>.delayed(Duration.zero);
        expect(bloc.state.currentStep, equals(2));

        bloc.add(const ProfileStepChanged(10));
        await Future<void>.delayed(Duration.zero);
        expect(bloc.state.currentStep, equals(2));
      },
    );

    test('ProfileSubmitted blocked if profile cannot submit', () async {
      bloc.add(const ProfileSubmitted());

      await expectLater(
        bloc.stream,
        emits(
          predicate<ProfileState>(
            (ProfileState s) =>
                s.status == ProfileSubmissionStatus.initial &&
                s.errorMessage != null,
          ),
        ),
      );
    });

    test('ProfileSubmitted succeeds and saves profile', () async {
      bloc.add(const ProfileMobilitySelected(MobilityType.pedestrian));
      bloc.add(const ProfileStepChanged(3));
      bloc.add(const ProfileSubmitted());

      await expectLater(
        bloc.stream,
        emitsThrough(
          predicate<ProfileState>(
            (ProfileState s) => s.status == ProfileSubmissionStatus.success,
          ),
        ),
      );

      final AccessibilityProfile? saved = await repository.getProfile();
      expect(saved, isNotNull);
      expect(saved!.mobilityType, equals(MobilityType.pedestrian));
    });

    test('ProfileSubmitted emits failure when repository throws', () async {
      final MockProfileRepository failingRepo = MockProfileRepository(
        simulatedDelay: Duration.zero,
        shouldFail: true,
      );
      final ProfileBloc failingBloc = ProfileBloc(
        profileRepository: failingRepo,
      );

      failingBloc.add(const ProfileMobilitySelected(MobilityType.pedestrian));
      failingBloc.add(const ProfileStepChanged(3));
      failingBloc.add(const ProfileSubmitted());

      await expectLater(
        failingBloc.stream,
        emitsThrough(
          predicate<ProfileState>(
            (ProfileState s) =>
                s.status == ProfileSubmissionStatus.failure &&
                s.errorMessage != null,
          ),
        ),
      );

      failingBloc.close();
    });

    test(
      'ProfileDimensionsChanged with null values invalidates previously filled dimensions',
      () async {
        bloc.add(const ProfileMobilitySelected(MobilityType.manualWheelchair));
        bloc.add(
          const ProfileDimensionsChanged(
            widthCm: 65,
            lengthCm: 105,
            maxStepHeightCm: 4,
          ),
        );
        await expectLater(
          bloc.stream,
          emitsThrough(
            predicate<ProfileState>((ProfileState s) => s.isDimensionsValid),
          ),
        );

        // User clears the fields — should invalidate
        bloc.add(
          const ProfileDimensionsChanged(
            widthCm: null,
            lengthCm: null,
            maxStepHeightCm: null,
          ),
        );
        await expectLater(
          bloc.stream,
          emits(
            predicate<ProfileState>(
              (ProfileState s) =>
                  s.widthCm == null &&
                  s.lengthCm == null &&
                  s.maxStepHeightCm == null &&
                  s.isDimensionsValid == false,
            ),
          ),
        );
      },
    );

    test('ProfileResetRequested resets state to initial', () async {
      bloc.add(const ProfileMobilitySelected(MobilityType.pedestrian));
      bloc.add(const ProfileResetRequested());

      await expectLater(
        bloc.stream,
        emitsThrough(
          predicate<ProfileState>(
            (ProfileState s) =>
                s.currentStep == 0 &&
                s.mobilityType == null &&
                s.status == ProfileSubmissionStatus.initial,
          ),
        ),
      );
    });
  });
}
