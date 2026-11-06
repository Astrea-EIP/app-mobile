import 'package:astrea/features/itinerary/data/models/itinerary_models.dart';
import 'package:astrea/features/onboarding/data/models/accessibility_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('mobilityTypeToBackendInt', () {
    test('maps every mobile type to a backend profile', () {
      expect(mobilityTypeToBackendInt(MobilityType.pedestrian), 0);
      expect(mobilityTypeToBackendInt(MobilityType.stroller), 0);
      expect(mobilityTypeToBackendInt(MobilityType.manualWheelchair), 1);
      expect(mobilityTypeToBackendInt(MobilityType.electricWheelchair), 1);
      expect(mobilityTypeToBackendInt(MobilityType.walkingWithAssistance), 2);
    });
  });

  group('CreateItineraryRequest.fromProfile', () {
    test('wheelchair sends width in meters', () {
      final CreateItineraryRequest request = CreateItineraryRequest.fromProfile(
        start: '48.8566,2.3522',
        end: '48.8606,2.3376',
        profile: const AccessibilityProfile(
          mobilityType: MobilityType.manualWheelchair,
          preferences: RoutePreferences(),
          dimensions: WheelchairDimensions(
            widthCm: 70,
            lengthCm: 110,
            maxStepHeightCm: 2,
          ),
        ),
      );

      final Map<String, dynamic> json = request.toJson();
      expect(json['mobility_profile'], 1);
      expect(json['wheelchair_width'], closeTo(0.7, 1e-9));
      expect(json.containsKey('can_climb_stairs'), isFalse);
    });

    test('pedestrian omits profile-specific fields', () {
      final Map<String, dynamic> json = CreateItineraryRequest.fromProfile(
        start: 'a',
        end: 'b',
        profile: const AccessibilityProfile(
          mobilityType: MobilityType.pedestrian,
          preferences: RoutePreferences(),
        ),
      ).toJson();

      expect(json, <String, dynamic>{
        'start': 'a',
        'end': 'b',
        'mobility_profile': 0,
      });
    });

    test('crutches derives can_climb_stairs from avoidStairs', () {
      final Map<String, dynamic> json = CreateItineraryRequest.fromProfile(
        start: 'a',
        end: 'b',
        profile: const AccessibilityProfile(
          mobilityType: MobilityType.walkingWithAssistance,
          preferences: RoutePreferences(),
        ),
      ).toJson();

      expect(json['mobility_profile'], 2);
      expect(json['can_climb_stairs'], isFalse);
    });
  });

  group('ItineraryResponse.fromJson', () {
    test('parses ordered points', () {
      final ItineraryResponse response = ItineraryResponse.fromJson(
        <String, dynamic>{
          'points': <Map<String, dynamic>>[
            <String, dynamic>{'lat': 48.8566, 'lng': 2.3522},
            <String, dynamic>{'lat': 48, 'lng': 2},
          ],
        },
      );

      expect(response.points, hasLength(2));
      expect(response.points.first.lat, 48.8566);
      expect(response.points.last.lng, 2.0);
    });
  });
}
