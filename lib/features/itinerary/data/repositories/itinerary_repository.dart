import 'package:astrea/core/network/astrea_api_client.dart';
import 'package:astrea/features/itinerary/data/models/itinerary_exceptions.dart';
import 'package:astrea/features/itinerary/data/models/itinerary_models.dart';
import 'package:astrea/features/onboarding/data/models/accessibility_profile.dart';

abstract class ItineraryRepository {
  /// Computes an itinerary.
  ///
  /// Throws an [ItineraryException] for the backend business errors
  /// (400, 422, 5xx); other failures surface as [ApiException] or
  /// `TimeoutException`.
  Future<ItineraryResponse> createItinerary({
    required String start,
    required String end,
    required AccessibilityProfile profile,
  });
}

class HttpItineraryRepository implements ItineraryRepository {
  const HttpItineraryRepository({required AstreaApiClient apiClient})
    : _apiClient = apiClient;

  final AstreaApiClient _apiClient;

  @override
  Future<ItineraryResponse> createItinerary({
    required String start,
    required String end,
    required AccessibilityProfile profile,
  }) async {
    final CreateItineraryRequest request = CreateItineraryRequest.fromProfile(
      start: start,
      end: end,
      profile: profile,
    );
    final Map<String, dynamic> json;
    try {
      json = await _apiClient.postItinerary(request.toJson());
    } on ApiException catch (e, stackTrace) {
      Error.throwWithStackTrace(_mapError(e), stackTrace);
    }
    return ItineraryResponse.fromJson(json);
  }

  Exception _mapError(ApiException e) {
    if (e.statusCode == 400) {
      return InvalidItineraryRequestException(e.message, errorId: e.errorId);
    }
    if (e.statusCode == 422) {
      return NoRouteFoundException(e.message, errorId: e.errorId);
    }
    if (e.statusCode >= 500) {
      return ItineraryServerException(e.message, errorId: e.errorId);
    }
    return e;
  }
}
