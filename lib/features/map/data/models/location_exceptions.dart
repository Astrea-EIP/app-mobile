/// Reasons why the user's current position could not be obtained.
sealed class LocationException implements Exception {
  const LocationException([this.message = '']);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// The user refused the location permission (it can be asked again).
final class LocationPermissionDeniedException extends LocationException {
  const LocationPermissionDeniedException([super.message]);
}

/// The permission is permanently refused: only the system settings can
/// grant it again.
final class LocationPermissionDeniedForeverException extends LocationException {
  const LocationPermissionDeniedForeverException([super.message]);
}

/// The device location service (GPS) is switched off.
final class LocationServiceDisabledException extends LocationException {
  const LocationServiceDisabledException([super.message]);
}

/// The position could not be read (timeout, no fix, plugin error).
final class LocationUnavailableException extends LocationException {
  const LocationUnavailableException([super.message]);
}
