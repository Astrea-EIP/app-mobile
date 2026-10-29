import 'package:astrea/core/network/astrea_api_client.dart';
import 'package:astrea/features/itinerary/data/models/itinerary_models.dart';
import 'package:astrea/features/onboarding/data/models/accessibility_profile.dart';

abstract class ItineraryRepository {
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
    final request = CreateItineraryRequest.fromProfile(
      start: start,
      end: end,
      profile: profile,
    );
    final json = await _apiClient.postItinerary(request.toJson());
    return ItineraryResponse.fromJson(json);
  }
}
