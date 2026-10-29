import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:astrea/core/network/api_constants.dart';

/// Error raised when the Astrea API answers with an unexpected status.
class ApiException implements Exception {
  const ApiException(this.statusCode, this.message);

  final int statusCode;
  final String message;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// HTTP client for the Astrea backend API.
///
/// Handles anonymous token acquisition and propagation.
/// Tokens are in-memory only; they are lost when the app restarts,
/// matching the backend's own in-memory token store.
class AstreaApiClient {
  AstreaApiClient({
    http.Client? httpClient,
    String? baseUrl,
    this.requestTimeout = const Duration(seconds: 10),
  }) : _httpClient = httpClient ?? http.Client(),
       _baseUrl = baseUrl ?? ApiConstants.baseUrl;

  /// Maximum wait for a single HTTP call; a [TimeoutException] is thrown
  /// beyond it so an unreachable API never blocks the UI indefinitely.
  final Duration requestTimeout;

  final http.Client _httpClient;
  final String _baseUrl;
  String? _accessToken;

  /// Ensures a valid anonymous token is cached.
  Future<void> ensureAuthenticated() async {
    if (_accessToken != null) {
      return;
    }
    _accessToken = await _fetchAnonymousToken();
  }

  Future<String> _fetchAnonymousToken() async {
    final http.Response response = await _httpClient
        .get(Uri.parse('$_baseUrl${ApiConstants.anonymousTokenEndpoint}'))
        .timeout(requestTimeout);
    if (response.statusCode != 202) {
      throw ApiException(response.statusCode, 'Failed to get anonymous token');
    }
    final Map<String, dynamic> json =
        jsonDecode(response.body) as Map<String, dynamic>;
    // ASP.NET serialises to camelCase by default; accept PascalCase too.
    final Object? token = json['accessToken'] ?? json['AccessToken'];
    if (token is! String || token.isEmpty) {
      throw const ApiException(202, 'Token missing from response');
    }
    return token;
  }

  /// Sends a POST /v0/itinerary request and returns the decoded JSON body.
  ///
  /// On 401 (backend restart invalidated the token) retries once with a
  /// fresh token.
  Future<Map<String, dynamic>> postItinerary(Map<String, dynamic> body) async {
    await ensureAuthenticated();
    http.Response response = await _doPostItinerary(body);

    if (response.statusCode == 401) {
      _accessToken = null;
      await ensureAuthenticated();
      response = await _doPostItinerary(body);
    }

    if (response.statusCode != 201) {
      throw ApiException(response.statusCode, response.body);
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<http.Response> _doPostItinerary(Map<String, dynamic> body) {
    return _httpClient
        .post(
          Uri.parse('$_baseUrl${ApiConstants.itineraryEndpoint}'),
          headers: <String, String>{
            'Content-Type': 'application/json',
            ApiConstants.accessTokenHeader: _accessToken!,
          },
          body: jsonEncode(body),
        )
        .timeout(requestTimeout);
  }
}
