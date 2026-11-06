/// Business-level failures of an itinerary request, mapped from the HTTP
/// status returned by `POST /v0/itinerary`.
///
/// [message] is the backend `error` text (for example "address not found").
sealed class ItineraryException implements Exception {
  const ItineraryException(this.message, {this.errorId});

  final String message;

  /// Support identifier returned by the backend on 500 responses.
  final String? errorId;

  @override
  String toString() => '$runtimeType: $message';
}

/// 400: invalid request body, or an address that could not be found.
final class InvalidItineraryRequestException extends ItineraryException {
  const InvalidItineraryRequestException(super.message, {super.errorId});
}

/// 422: a point is outside the map coverage, or no route matches the
/// mobility profile. This is an expected business case, not a crash.
final class NoRouteFoundException extends ItineraryException {
  const NoRouteFoundException(super.message, {super.errorId});
}

/// 5xx: unexpected backend failure.
final class ItineraryServerException extends ItineraryException {
  const ItineraryServerException(super.message, {super.errorId});
}
