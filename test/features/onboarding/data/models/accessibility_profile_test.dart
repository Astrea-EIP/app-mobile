import 'package:flutter_test/flutter_test.dart';
import 'package:astrea/features/onboarding/data/models/accessibility_profile.dart';

void main() {
  group('MobilityType', () {
    test('requiresDimensions returns true only for wheelchairs', () {
      expect(MobilityType.manualWheelchair.requiresDimensions, isTrue);
      expect(MobilityType.electricWheelchair.requiresDimensions, isTrue);
      expect(MobilityType.walkingWithAssistance.requiresDimensions, isFalse);
      expect(MobilityType.pedestrian.requiresDimensions, isFalse);
      expect(MobilityType.stroller.requiresDimensions, isFalse);
    });

    test('displayName and description are non-empty for all values', () {
      for (final MobilityType type in MobilityType.values) {
        expect(type.displayName.isNotEmpty, isTrue);
        expect(type.description.isNotEmpty, isTrue);
      }
    });

    test('displayName returns correct French labels', () {
      expect(
        MobilityType.manualWheelchair.displayName,
        equals('Fauteuil roulant manuel'),
      );
      expect(
        MobilityType.electricWheelchair.displayName,
        equals('Fauteuil roulant électrique'),
      );
      expect(
        MobilityType.walkingWithAssistance.displayName,
        equals('Marche avec assistance'),
      );
      expect(MobilityType.pedestrian.displayName, equals('Piéton'));
      expect(MobilityType.stroller.displayName, equals('Poussette / Chariot'));
    });
  });

  group('WheelchairDimensions', () {
    test('isValid returns true for realistic positive values', () {
      const WheelchairDimensions dimensions = WheelchairDimensions(
        widthCm: 65,
        lengthCm: 105,
        maxStepHeightCm: 5,
      );

      expect(dimensions.isValid, isTrue);
    });

    test('isValid boundary checks for widthCm', () {
      expect(
        const WheelchairDimensions(
          widthCm: 0,
          lengthCm: 100,
          maxStepHeightCm: 5,
        ).isValid,
        isFalse,
      );
      expect(
        const WheelchairDimensions(
          widthCm: 200,
          lengthCm: 100,
          maxStepHeightCm: 5,
        ).isValid,
        isTrue,
      );
      expect(
        const WheelchairDimensions(
          widthCm: 200.1,
          lengthCm: 100,
          maxStepHeightCm: 5,
        ).isValid,
        isFalse,
      );
    });

    test('isValid boundary checks for lengthCm', () {
      expect(
        const WheelchairDimensions(
          widthCm: 60,
          lengthCm: 0,
          maxStepHeightCm: 5,
        ).isValid,
        isFalse,
      );
      expect(
        const WheelchairDimensions(
          widthCm: 60,
          lengthCm: 250,
          maxStepHeightCm: 5,
        ).isValid,
        isTrue,
      );
      expect(
        const WheelchairDimensions(
          widthCm: 60,
          lengthCm: 250.1,
          maxStepHeightCm: 5,
        ).isValid,
        isFalse,
      );
    });

    test('isValid boundary checks for maxStepHeightCm', () {
      expect(
        const WheelchairDimensions(
          widthCm: 60,
          lengthCm: 100,
          maxStepHeightCm: -1,
        ).isValid,
        isFalse,
      );
      expect(
        const WheelchairDimensions(
          widthCm: 60,
          lengthCm: 100,
          maxStepHeightCm: 0,
        ).isValid,
        isTrue,
      );
      expect(
        const WheelchairDimensions(
          widthCm: 60,
          lengthCm: 100,
          maxStepHeightCm: 50,
        ).isValid,
        isTrue,
      );
      expect(
        const WheelchairDimensions(
          widthCm: 60,
          lengthCm: 100,
          maxStepHeightCm: 50.1,
        ).isValid,
        isFalse,
      );
    });

    test('copyWith updates specified fields only', () {
      const WheelchairDimensions initial = WheelchairDimensions(
        widthCm: 60,
        lengthCm: 100,
        maxStepHeightCm: 4,
      );

      final WheelchairDimensions updatedWidth = initial.copyWith(widthCm: 70);
      expect(updatedWidth.widthCm, equals(70));
      expect(updatedWidth.lengthCm, equals(100));
      expect(updatedWidth.maxStepHeightCm, equals(4));

      final WheelchairDimensions updatedLength = initial.copyWith(
        lengthCm: 110,
      );
      expect(updatedLength.widthCm, equals(60));
      expect(updatedLength.lengthCm, equals(110));

      final WheelchairDimensions updatedStep = initial.copyWith(
        maxStepHeightCm: 6,
      );
      expect(updatedStep.maxStepHeightCm, equals(6));
    });

    test('equality and props work as expected', () {
      const WheelchairDimensions dim1 = WheelchairDimensions(
        widthCm: 65,
        lengthCm: 105,
        maxStepHeightCm: 5,
      );
      const WheelchairDimensions dim2 = WheelchairDimensions(
        widthCm: 65,
        lengthCm: 105,
        maxStepHeightCm: 5,
      );
      const WheelchairDimensions dim3 = WheelchairDimensions(
        widthCm: 70,
        lengthCm: 105,
        maxStepHeightCm: 5,
      );

      expect(dim1, equals(dim2));
      expect(dim1, isNot(equals(dim3)));
      expect(dim1.props, equals(<Object?>[65.0, 105.0, 5.0]));
    });

    test('toJson and fromJson serialize properly', () {
      const WheelchairDimensions dimensions = WheelchairDimensions(
        widthCm: 70,
        lengthCm: 110,
        maxStepHeightCm: 4,
      );

      final Map<String, dynamic> json = dimensions.toJson();
      final WheelchairDimensions parsed = WheelchairDimensions.fromJson(json);

      expect(parsed, equals(dimensions));
    });
  });

  group('RoutePreferences', () {
    test('default values are set as expected', () {
      const RoutePreferences prefs = RoutePreferences();

      expect(prefs.dogFriendly, isFalse);
      expect(prefs.avoidStairs, isTrue);
      expect(prefs.avoidSteepSlopes, isFalse);
      expect(prefs.avoidUnevenSurfaces, isFalse);
      expect(prefs.preferElevators, isTrue);
    });

    test('copyWith updates specified fields only', () {
      const RoutePreferences prefs = RoutePreferences();
      final RoutePreferences updated1 = prefs.copyWith(dogFriendly: true);
      expect(updated1.dogFriendly, isTrue);
      expect(updated1.avoidStairs, isTrue);

      final RoutePreferences updated2 = prefs.copyWith(avoidStairs: false);
      expect(updated2.avoidStairs, isFalse);

      final RoutePreferences updated3 = prefs.copyWith(avoidSteepSlopes: true);
      expect(updated3.avoidSteepSlopes, isTrue);

      final RoutePreferences updated4 = prefs.copyWith(
        avoidUnevenSurfaces: true,
      );
      expect(updated4.avoidUnevenSurfaces, isTrue);

      final RoutePreferences updated5 = prefs.copyWith(preferElevators: false);
      expect(updated5.preferElevators, isFalse);
    });

    test('equality and props work as expected', () {
      const RoutePreferences p1 = RoutePreferences(dogFriendly: true);
      const RoutePreferences p2 = RoutePreferences(dogFriendly: true);
      const RoutePreferences p3 = RoutePreferences(dogFriendly: false);

      expect(p1, equals(p2));
      expect(p1, isNot(equals(p3)));
      expect(p1.props, equals(<Object?>[true, true, false, false, true]));
    });

    test('toJson and fromJson serialize properly', () {
      const RoutePreferences prefs = RoutePreferences(
        dogFriendly: true,
        avoidStairs: false,
        avoidSteepSlopes: true,
      );

      final Map<String, dynamic> json = prefs.toJson();
      final RoutePreferences parsed = RoutePreferences.fromJson(json);

      expect(parsed, equals(prefs));
    });

    test('fromJson handles empty json with defaults', () {
      final RoutePreferences parsed = RoutePreferences.fromJson(
        <String, dynamic>{},
      );
      expect(parsed.dogFriendly, isFalse);
      expect(parsed.avoidStairs, isTrue);
      expect(parsed.avoidSteepSlopes, isFalse);
      expect(parsed.avoidUnevenSurfaces, isFalse);
      expect(parsed.preferElevators, isTrue);
    });
  });

  group('AccessibilityProfile', () {
    test('isValid is true when wheelchair has valid dimensions', () {
      const AccessibilityProfile profile = AccessibilityProfile(
        mobilityType: MobilityType.manualWheelchair,
        dimensions: WheelchairDimensions(
          widthCm: 65,
          lengthCm: 105,
          maxStepHeightCm: 3,
        ),
        preferences: RoutePreferences(),
      );

      expect(profile.isValid, isTrue);
    });

    test(
      'isValid is false when wheelchair lacks dimensions or has invalid dimensions',
      () {
        const AccessibilityProfile missingDimensions = AccessibilityProfile(
          mobilityType: MobilityType.electricWheelchair,
          preferences: RoutePreferences(),
        );
        expect(missingDimensions.isValid, isFalse);

        const AccessibilityProfile invalidDimensions = AccessibilityProfile(
          mobilityType: MobilityType.manualWheelchair,
          dimensions: WheelchairDimensions(
            widthCm: -10,
            lengthCm: 100,
            maxStepHeightCm: 2,
          ),
          preferences: RoutePreferences(),
        );
        expect(invalidDimensions.isValid, isFalse);
      },
    );

    test('isValid is true for non-wheelchair profiles without dimensions', () {
      const AccessibilityProfile pedestrian = AccessibilityProfile(
        mobilityType: MobilityType.pedestrian,
        preferences: RoutePreferences(),
      );
      expect(pedestrian.isValid, isTrue);

      const AccessibilityProfile stroller = AccessibilityProfile(
        mobilityType: MobilityType.stroller,
        preferences: RoutePreferences(),
      );
      expect(stroller.isValid, isTrue);

      const AccessibilityProfile walking = AccessibilityProfile(
        mobilityType: MobilityType.walkingWithAssistance,
        preferences: RoutePreferences(),
      );
      expect(walking.isValid, isTrue);
    });

    test('copyWith updates specified fields only', () {
      const AccessibilityProfile initial = AccessibilityProfile(
        mobilityType: MobilityType.pedestrian,
        preferences: RoutePreferences(),
      );

      final AccessibilityProfile updatedMobility = initial.copyWith(
        mobilityType: MobilityType.stroller,
      );
      expect(updatedMobility.mobilityType, equals(MobilityType.stroller));

      const WheelchairDimensions dims = WheelchairDimensions(
        widthCm: 70,
        lengthCm: 110,
        maxStepHeightCm: 4,
      );
      final AccessibilityProfile updatedDims = initial.copyWith(
        dimensions: dims,
      );
      expect(updatedDims.dimensions, equals(dims));

      final AccessibilityProfile updatedPrefs = initial.copyWith(
        preferences: const RoutePreferences(dogFriendly: true),
      );
      expect(updatedPrefs.preferences.dogFriendly, isTrue);
    });

    test('equality and props work as expected', () {
      const AccessibilityProfile p1 = AccessibilityProfile(
        mobilityType: MobilityType.pedestrian,
        preferences: RoutePreferences(),
      );
      const AccessibilityProfile p2 = AccessibilityProfile(
        mobilityType: MobilityType.pedestrian,
        preferences: RoutePreferences(),
      );
      const AccessibilityProfile p3 = AccessibilityProfile(
        mobilityType: MobilityType.stroller,
        preferences: RoutePreferences(),
      );

      expect(p1, equals(p2));
      expect(p1, isNot(equals(p3)));
    });

    test('toJson and fromJson serialize properly', () {
      const AccessibilityProfile profile = AccessibilityProfile(
        mobilityType: MobilityType.manualWheelchair,
        dimensions: WheelchairDimensions(
          widthCm: 68,
          lengthCm: 115,
          maxStepHeightCm: 5,
        ),
        preferences: RoutePreferences(dogFriendly: true),
      );

      final Map<String, dynamic> json = profile.toJson();
      final AccessibilityProfile parsed = AccessibilityProfile.fromJson(json);

      expect(parsed, equals(profile));
    });

    test('fromJson falls back to pedestrian for unknown mobilityType', () {
      final AccessibilityProfile parsed = AccessibilityProfile.fromJson(
        <String, dynamic>{'mobilityType': 'unknownType'},
      );

      expect(parsed.mobilityType, equals(MobilityType.pedestrian));
      expect(parsed.dimensions, isNull);
      expect(parsed.preferences, equals(const RoutePreferences()));
    });
  });
}
