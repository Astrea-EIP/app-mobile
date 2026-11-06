import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:astrea/core/network/api_constants.dart';

/// Error raised when the Astrea API answers with a non-2xx status.
///
/// The backend error body is `{ "error": "..." }` (plus `errorId` on 500);
/// [message] holds the parsed `error` text, or `HTTP <status>` when the body
/// is not in that shape.
class ApiException implements Exception {
  const ApiException(this.statusCode, this.message, {this.errorId});

  factory ApiException.fromResponse(http.Response response) {
    String? message;
    String? errorId;
    try {
      final Object? decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        final Object? error = decoded['error'];
        final Object? id = decoded['errorId'];
        message = error is String && error.isNotEmpty ? error : null;
        errorId = id is String ? id : null;
      }
    } on FormatException {
      // Non-JSON body (empty 401, proxy error page...): use the fallback.
    }
    return ApiException(
      response.statusCode,
      message ?? 'HTTP ${response.statusCode}',
      errorId: errorId,
    );
  }

  final int statusCode;
  final String message;

  /// Support identifier returned by the backend on 500 responses.
  final String? errorId;

  @override
  String toString() =>
      'ApiException($statusCode): $message'
      '${errorId == null ? '' : ' [errorId: $errorId]'}';
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
  Future<String>? _pendingToken;

  /// Ensures a valid anonymous token is cached.
  Future<void> ensureAuthenticated() async {
    await _token();
  }

  /// Returns the cached token, or fetches one.
  ///
  /// Concurrent callers share the same in-flight request so only one token
  /// is generated (the backend never purges tokens).
  Future<String> _token() async {
    final String? cached = _accessToken;
    if (cached != null) {
      return cached;
    }
    return _pendingToken ??= _acquireToken();
  }

  Future<String> _acquireToken() async {
    try {
      final String token = await _fetchAnonymousToken();
      _accessToken = token;
      return token;
    } finally {
      _pendingToken = null;
    }
  }

  Future<String> _fetchAnonymousToken() async {
    final http.Response response = await _httpClient
        .get(Uri.parse('$_baseUrl${ApiConstants.anonymousTokenEndpoint}'))
        .timeout(requestTimeout);
    if (!_isSuccess(response.statusCode)) {
      throw ApiException.fromResponse(response);
    }
    final Map<String, dynamic> json =
        jsonDecode(response.body) as Map<String, dynamic>;
    // ASP.NET serialises to camelCase by default; accept PascalCase too.
    final Object? token = json['accessToken'] ?? json['AccessToken'];
    if (token is! String || token.isEmpty) {
      throw ApiException(response.statusCode, 'Token missing from response');
    }
    return token;
  }

  /// Sends a POST /v0/itinerary request and returns the decoded JSON body.
  ///
  /// On 401 (backend restart invalidated the token) retries once with a
  /// fresh token. Any other non-2xx answer throws an [ApiException].
  Future<Map<String, dynamic>> postItinerary(Map<String, dynamic> body) async {
    String token = await _token();
    http.Response response = await _doPostItinerary(body, token);

    if (response.statusCode == 401) {
      // Only drop the token we actually used: a concurrent request may
      // already have replaced it with a fresh one.
      if (_accessToken == token) {
        _accessToken = null;
      }
      token = await _token();
      response = await _doPostItinerary(body, token);
    }

    if (!_isSuccess(response.statusCode)) {
      throw ApiException.fromResponse(response);
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<http.Response> _doPostItinerary(
    Map<String, dynamic> body,
    String token,
  ) {
    return _httpClient
        .post(
          Uri.parse('$_baseUrl${ApiConstants.itineraryEndpoint}'),
          headers: <String, String>{
            'Content-Type': 'application/json',
            ApiConstants.accessTokenHeader: token,
          },
          body: jsonEncode(body),
        )
        .timeout(requestTimeout);
  }

  static bool _isSuccess(int statusCode) =>
      statusCode >= 200 && statusCode < 300;
}
