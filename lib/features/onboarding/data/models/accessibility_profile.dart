import 'package:equatable/equatable.dart';

/// Represents the mobility profile / mode of transportation.
enum MobilityType {
  manualWheelchair,
  electricWheelchair,
  walkingWithAssistance,
  pedestrian,
  stroller;

  /// Returns true if this mobility type requires dimensions constraints.
  bool get requiresDimensions =>
      this == MobilityType.manualWheelchair ||
      this == MobilityType.electricWheelchair;

  /// Libellé pour l'affichage dans l'interface.
  String get displayName {
    switch (this) {
      case MobilityType.manualWheelchair:
        return 'Fauteuil roulant manuel';
      case MobilityType.electricWheelchair:
        return 'Fauteuil roulant électrique';
      case MobilityType.walkingWithAssistance:
        return 'Marche avec assistance';
      case MobilityType.pedestrian:
        return 'Piéton';
      case MobilityType.stroller:
        return 'Poussette / Chariot';
    }
  }

  /// Description détaillée pour guider l'utilisateur.
  String get description {
    switch (this) {
      case MobilityType.manualWheelchair:
        return 'Itinéraires adaptés avec contraintes de pente douce et de largeur minimale.';
      case MobilityType.electricWheelchair:
        return 'Itinéraires adaptés aux équipements motorisés avec passages larges.';
      case MobilityType.walkingWithAssistance:
        return 'Itinéraires évitant les longs escaliers, les pentes raides et les sols instables.';
      case MobilityType.pedestrian:
        return 'Trajets piétons classiques empruntant trottoirs et passages standards.';
      case MobilityType.stroller:
        return 'Itinéraires avec rampes d\'accès évitant tourniquets et marches hautes.';
    }
  }
}

/// Represents dimensions for mobility equipment in centimeters.
class WheelchairDimensions extends Equatable {
  const WheelchairDimensions({
    required this.widthCm,
    required this.lengthCm,
    required this.maxStepHeightCm,
  });

  factory WheelchairDimensions.fromJson(Map<String, dynamic> json) {
    return WheelchairDimensions(
      widthCm: (json['widthCm'] as num).toDouble(),
      lengthCm: (json['lengthCm'] as num).toDouble(),
      maxStepHeightCm: (json['maxStepHeightCm'] as num).toDouble(),
    );
  }

  final double widthCm;
  final double lengthCm;
  final double maxStepHeightCm;

  /// Validates that dimension values are positive and physically plausible.
  bool get isValid =>
      widthCm > 0 &&
      widthCm <= 200 &&
      lengthCm > 0 &&
      lengthCm <= 250 &&
      maxStepHeightCm >= 0 &&
      maxStepHeightCm <= 50;

  WheelchairDimensions copyWith({
    double? widthCm,
    double? lengthCm,
    double? maxStepHeightCm,
  }) {
    return WheelchairDimensions(
      widthCm: widthCm ?? this.widthCm,
      lengthCm: lengthCm ?? this.lengthCm,
      maxStepHeightCm: maxStepHeightCm ?? this.maxStepHeightCm,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'widthCm': widthCm,
      'lengthCm': lengthCm,
      'maxStepHeightCm': maxStepHeightCm,
    };
  }

  @override
  List<Object?> get props => <Object?>[widthCm, lengthCm, maxStepHeightCm];
}

/// User routing preferences (e.g. dog-friendly, avoid stairs).
class RoutePreferences extends Equatable {
  const RoutePreferences({
    this.dogFriendly = false,
    this.avoidStairs = true,
    this.avoidSteepSlopes = false,
    this.avoidUnevenSurfaces = false,
    this.preferElevators = true,
  });

  factory RoutePreferences.fromJson(Map<String, dynamic> json) {
    return RoutePreferences(
      dogFriendly: json['dogFriendly'] as bool? ?? false,
      avoidStairs: json['avoidStairs'] as bool? ?? true,
      avoidSteepSlopes: json['avoidSteepSlopes'] as bool? ?? false,
      avoidUnevenSurfaces: json['avoidUnevenSurfaces'] as bool? ?? false,
      preferElevators: json['preferElevators'] as bool? ?? true,
    );
  }

  final bool dogFriendly;
  final bool avoidStairs;
  final bool avoidSteepSlopes;
  final bool avoidUnevenSurfaces;
  final bool preferElevators;

  RoutePreferences copyWith({
    bool? dogFriendly,
    bool? avoidStairs,
    bool? avoidSteepSlopes,
    bool? avoidUnevenSurfaces,
    bool? preferElevators,
  }) {
    return RoutePreferences(
      dogFriendly: dogFriendly ?? this.dogFriendly,
      avoidStairs: avoidStairs ?? this.avoidStairs,
      avoidSteepSlopes: avoidSteepSlopes ?? this.avoidSteepSlopes,
      avoidUnevenSurfaces: avoidUnevenSurfaces ?? this.avoidUnevenSurfaces,
      preferElevators: preferElevators ?? this.preferElevators,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'dogFriendly': dogFriendly,
      'avoidStairs': avoidStairs,
      'avoidSteepSlopes': avoidSteepSlopes,
      'avoidUnevenSurfaces': avoidUnevenSurfaces,
      'preferElevators': preferElevators,
    };
  }

  @override
  List<Object?> get props => <Object?>[
    dogFriendly,
    avoidStairs,
    avoidSteepSlopes,
    avoidUnevenSurfaces,
    preferElevators,
  ];
}

/// The complete accessibility profile collected during onboarding.
class AccessibilityProfile extends Equatable {
  const AccessibilityProfile({
    required this.mobilityType,
    required this.preferences,
    this.dimensions,
  });

  factory AccessibilityProfile.fromJson(Map<String, dynamic> json) {
    final String mobilityTypeName = json['mobilityType'] as String;
    final MobilityType type = MobilityType.values.firstWhere(
      (MobilityType e) => e.name == mobilityTypeName,
      orElse: () => MobilityType.pedestrian,
    );

    return AccessibilityProfile(
      mobilityType: type,
      dimensions: json['dimensions'] != null
          ? WheelchairDimensions.fromJson(
              json['dimensions'] as Map<String, dynamic>,
            )
          : null,
      preferences: json['preferences'] != null
          ? RoutePreferences.fromJson(
              json['preferences'] as Map<String, dynamic>,
            )
          : const RoutePreferences(),
    );
  }

  final MobilityType mobilityType;
  final WheelchairDimensions? dimensions;
  final RoutePreferences preferences;

  /// Profile is valid if required dimensions are provided and valid when required.
  bool get isValid {
    if (mobilityType.requiresDimensions) {
      return dimensions != null && dimensions!.isValid;
    }
    return true;
  }

  AccessibilityProfile copyWith({
    MobilityType? mobilityType,
    WheelchairDimensions? dimensions,
    RoutePreferences? preferences,
  }) {
    return AccessibilityProfile(
      mobilityType: mobilityType ?? this.mobilityType,
      dimensions: dimensions ?? this.dimensions,
      preferences: preferences ?? this.preferences,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'mobilityType': mobilityType.name,
      'dimensions': dimensions?.toJson(),
      'preferences': preferences.toJson(),
    };
  }

  @override
  List<Object?> get props => <Object?>[mobilityType, dimensions, preferences];
}
