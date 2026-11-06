import 'dart:convert';

import 'package:astrea/core/network/astrea_api_client.dart';
import 'package:astrea/features/itinerary/data/models/itinerary_exceptions.dart';
import 'package:astrea/features/itinerary/data/models/itinerary_models.dart';
import 'package:astrea/features/itinerary/data/repositories/itinerary_repository.dart';
import 'package:astrea/features/onboarding/data/models/accessibility_profile.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  const AccessibilityProfile profile = AccessibilityProfile(
    mobilityType: MobilityType.pedestrian,
    preferences: RoutePreferences(),
  );

  HttpItineraryRepository repositoryAnswering(http.Response itinerary) {
    return HttpItineraryRepository(
      apiClient: AstreaApiClient(
        baseUrl: 'http://test.local',
        httpClient: MockClient((http.Request request) async {
          if (request.url.path == '/v0/auth/anonymous') {
            return http.Response('{"accessToken":"abc"}', 202);
          }
          return itinerary;
        }),
      ),
    );
  }

  Future<ItineraryResponse> request(HttpItineraryRepository repository) {
    return repository.createItinerary(start: 'a', end: 'b', profile: profile);
  }

  http.Response error(int status, String message, {String? errorId}) {
    return http.Response(
      jsonEncode(<String, String>{'error': message, 'errorId': ?errorId}),
      status,
    );
  }

  group('HttpItineraryRepository', () {
    test('returns the points on success', () async {
      final HttpItineraryRepository repository = repositoryAnswering(
        http.Response(
          jsonEncode(<String, Object>{
            'points': <Map<String, double>>[
              <String, double>{'lat': 48.8566, 'lng': 2.3522},
            ],
          }),
          201,
        ),
      );

      final ItineraryResponse response = await request(repository);

      expect(response.points, hasLength(1));
    });

    test('maps 400 to InvalidItineraryRequestException', () async {
      final HttpItineraryRepository repository = repositoryAnswering(
        error(400, 'Address not found'),
      );

      await expectLater(
        request(repository),
        throwsA(
          isA<InvalidItineraryRequestException>().having(
            (InvalidItineraryRequestException e) => e.message,
            'message',
            'Address not found',
          ),
        ),
      );
    });

    test('maps 422 to NoRouteFoundException', () async {
      final HttpItineraryRepository repository = repositoryAnswering(
        error(422, 'Point outside map coverage'),
      );

      await expectLater(
        request(repository),
        throwsA(
          isA<NoRouteFoundException>().having(
            (NoRouteFoundException e) => e.message,
            'message',
            'Point outside map coverage',
          ),
        ),
      );
    });

    test('maps 500 to ItineraryServerException with the errorId', () async {
      final HttpItineraryRepository repository = repositoryAnswering(
        error(500, 'API error', errorId: 'e-1'),
      );

      await expectLater(
        request(repository),
        throwsA(
          isA<ItineraryServerException>().having(
            (ItineraryServerException e) => e.errorId,
            'errorId',
            'e-1',
          ),
        ),
      );
    });

    test('keeps other statuses as ApiException', () async {
      final HttpItineraryRepository repository = repositoryAnswering(
        error(404, 'Not found'),
      );

      await expectLater(request(repository), throwsA(isA<ApiException>()));
    });
  });
}
