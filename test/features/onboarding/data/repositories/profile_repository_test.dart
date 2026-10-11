import 'package:flutter_test/flutter_test.dart';
import 'package:astrea/features/onboarding/data/models/accessibility_profile.dart';
import 'package:astrea/features/onboarding/data/repositories/profile_repository.dart';

void main() {
  group('MockProfileRepository', () {
    late MockProfileRepository repository;

    setUp(() {
      repository = MockProfileRepository(simulatedDelay: Duration.zero);
    });

    test('initial getProfile returns null', () async {
      final AccessibilityProfile? profile = await repository.getProfile();
      expect(profile, isNull);
    });

    test('saveProfile persists profile and getProfile retrieves it', () async {
      const AccessibilityProfile profile = AccessibilityProfile(
        mobilityType: MobilityType.manualWheelchair,
        dimensions: WheelchairDimensions(
          widthCm: 65,
          lengthCm: 105,
          maxStepHeightCm: 5,
        ),
        preferences: RoutePreferences(dogFriendly: true),
      );

      await repository.saveProfile(profile);
      final AccessibilityProfile? retrieved = await repository.getProfile();

      expect(retrieved, equals(profile));
    });

    test('saveProfile throws Exception when shouldFail is true', () async {
      final MockProfileRepository failingRepo = MockProfileRepository(
        simulatedDelay: Duration.zero,
        shouldFail: true,
      );

      const AccessibilityProfile profile = AccessibilityProfile(
        mobilityType: MobilityType.pedestrian,
        preferences: RoutePreferences(),
      );

      expect(
        () async => failingRepo.saveProfile(profile),
        throwsA(isA<Exception>()),
      );
    });

    test('getProfile throws Exception when shouldFail is true', () async {
      final MockProfileRepository failingRepo = MockProfileRepository(
        simulatedDelay: Duration.zero,
        shouldFail: true,
      );

      expect(() async => failingRepo.getProfile(), throwsA(isA<Exception>()));
    });
  });
}
