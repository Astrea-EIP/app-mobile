import 'package:astrea/features/map/data/models/user_location.dart';

/// Source of the user's position and shortcuts to the system settings.
abstract interface class LocationRepository {
  /// Asks the permission when needed and returns the current position.
  ///
  /// Throws a `LocationException` subtype when it is not possible.
  Future<UserLocation> getCurrentLocation();

  /// Opens the application settings so the user can grant the permission.
  Future<bool> openAppSettings();

  /// Opens the system location settings so the user can enable the GPS.
  Future<bool> openLocationSettings();
}
