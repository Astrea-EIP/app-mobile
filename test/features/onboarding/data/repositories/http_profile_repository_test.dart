import 'dart:async';

import 'package:astrea/core/network/astrea_api_client.dart';
import 'package:astrea/features/onboarding/data/models/accessibility_profile.dart';
import 'package:astrea/features/onboarding/data/repositories/http_profile_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  const AccessibilityProfile profile = AccessibilityProfile(
    mobilityType: MobilityType.pedestrian,
    preferences: RoutePreferences(),
  );

  test('saves the profile and warms up the token in the background', () async {
    int calls = 0;
    final HttpProfileRepository repository = HttpProfileRepository(
      apiClient: AstreaApiClient(
        baseUrl: 'http://test.local',
        httpClient: MockClient((http.Request request) async {
          calls++;
          return http.Response('{"accessToken":"abc"}', 202);
        }),
      ),
    );

    await repository.saveProfile(profile);
    await pumpEventQueue();

    expect(calls, 1);
    expect(await repository.getProfile(), profile);
  });

  test('does not wait for the network when saving', () async {
    final Completer<http.Response> never = Completer<http.Response>();
    final HttpProfileRepository repository = HttpProfileRepository(
      apiClient: AstreaApiClient(
        baseUrl: 'http://test.local',
        httpClient: MockClient((http.Request request) => never.future),
      ),
    );

    await repository.saveProfile(profile).timeout(const Duration(seconds: 1));

    expect(await repository.getProfile(), profile);
  });

  test('still saves the profile when the API is unreachable', () async {
    final HttpProfileRepository repository = HttpProfileRepository(
      apiClient: AstreaApiClient(
        baseUrl: 'http://test.local',
        httpClient: MockClient(
          (http.Request request) async => throw http.ClientException('down'),
        ),
      ),
    );

    await repository.saveProfile(profile);
    await pumpEventQueue();

    expect(await repository.getProfile(), profile);
  });
}
