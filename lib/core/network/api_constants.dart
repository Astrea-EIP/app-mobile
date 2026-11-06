abstract class ApiConstants {
  /// Overridable at build time: `--dart-define=API_BASE_URL=http://192.168.1.42:5217`.
  ///
  /// Defaults to the Android emulator alias of the host machine. Use
  /// `http://localhost:5217` for the iOS simulator / desktop / web, or the
  /// computer LAN IP for a real phone.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:5217',
  );

  static const String anonymousTokenEndpoint = '/v0/auth/anonymous';
  static const String itineraryEndpoint = '/v0/itinerary';

  static const String accessTokenHeader = 'access-token';
}
