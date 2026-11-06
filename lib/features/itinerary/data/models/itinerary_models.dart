import 'package:astrea/features/onboarding/data/models/accessibility_profile.dart';

// ---------------------------------------------------------------------------
// Request
// ---------------------------------------------------------------------------

/// Maps the mobile [MobilityType] to the backend MobilityProfile int enum.
///
/// Backend values: 0=Pedestrian, 1=Wheelchair, 2=Crutches, 3=Blind
int mobilityTypeToBackendInt(MobilityType type) {
  switch (type) {
    case MobilityType.manualWheelchair:
    case MobilityType.electricWheelchair:
      return 1; // Wheelchair
    case MobilityType.walkingWithAssistance:
      return 2; // Crutches (closest semantic match)
    case MobilityType.pedestrian:
    case MobilityType.stroller:
      return 0; // Pedestrian
  }
}

class CreateItineraryRequest {
  const CreateItineraryRequest({
    required this.start,
    required this.end,
    required this.mobilityProfile,
    this.wheelchairWidth,
    this.physicalStrength,
    this.isAccompanied,
    this.canClimbStairs,
    this.pathPreferences,
  });

  /// Builds a [CreateItineraryRequest] from an [AccessibilityProfile] and
  /// human-readable start / end addresses (or "lat,lng" strings).
  factory CreateItineraryRequest.fromProfile({
    required String start,
    required String end,
    required AccessibilityProfile profile,
  }) {
    final int backendProfile = mobilityTypeToBackendInt(profile.mobilityType);
    final WheelchairDimensions? dims = profile.dimensions;

    return CreateItineraryRequest(
      start: start,
      end: end,
      mobilityProfile: backendProfile,
      // wheelchair_width: meters; backend accepts (0, 2.0].
      wheelchairWidth: (backendProfile == 1 && dims != null)
          ? dims.widthCm / 100.0
          : null,
      // can_climb_stairs: Crutches profile only.
      canClimbStairs: backendProfile == 2
          ? !profile.preferences.avoidStairs
          : null,
    );
  }

  /// Start address or "lat,lng" (decimal separator must be ".").
  final String start;

  /// End address or "lat,lng".
  final String end;

  /// 0=Pedestrian, 1=Wheelchair, 2=Crutches, 3=Blind
  final int mobilityProfile;

  /// Wheelchair width in meters (Wheelchair profile only, range (0, 2.0]).
  final double? wheelchairWidth;

  /// 0=Low, 1=Medium, 2=High (Wheelchair profile only).
  final int? physicalStrength;

  /// Wheelchair and Blind profiles.
  final bool? isAccompanied;

  /// Crutches profile only.
  final bool? canClimbStairs;

  /// Bit-flags: Stairs=1, Slopes=2, WidePathways=4, LitStreets=8, Benches=16
  /// (Pedestrian profile only).
  final int? pathPreferences;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'start': start,
      'end': end,
      'mobility_profile': mobilityProfile,
      if (wheelchairWidth != null) 'wheelchair_width': wheelchairWidth,
      if (physicalStrength != null) 'physical_strength': physicalStrength,
      if (isAccompanied != null) 'is_accompanied': isAccompanied,
      if (canClimbStairs != null) 'can_climb_stairs': canClimbStairs,
      if (pathPreferences != null) 'path_preferences': pathPreferences,
    };
  }
}

// ---------------------------------------------------------------------------
// Response
// ---------------------------------------------------------------------------

class PointResponse {
  const PointResponse({required this.lat, required this.lng});

  factory PointResponse.fromJson(Map<String, dynamic> json) {
    return PointResponse(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );
  }

  final double lat;
  final double lng;

  @override
  String toString() => 'PointResponse(lat: $lat, lng: $lng)';
}

class ItineraryResponse {
  const ItineraryResponse({required this.points});

  factory ItineraryResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawPoints = json['points'] as List<dynamic>;
    return ItineraryResponse(
      points: rawPoints
          .map((dynamic e) => PointResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  final List<PointResponse> points;

  @override
  String toString() => 'ItineraryResponse(${points.length} points)';
}
