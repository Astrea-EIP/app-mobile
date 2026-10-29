import 'dart:async';
import 'dart:convert';

import 'package:astrea/core/network/astrea_api_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  const String base = 'http://test.local';

  http.Response token(String value) =>
      http.Response(jsonEncode(<String, String>{'accessToken': value}), 202);

  group('AstreaApiClient', () {
    test('fetches the camelCase accessToken and sends it as header', () async {
      String? sentToken;
      final MockClient mock = MockClient((http.Request request) async {
        if (request.url.path == '/v0/auth/anonymous') {
          return token('abc');
        }
        sentToken = request.headers['access-token'];
        return http.Response(jsonEncode(<String, Object>{'points': []}), 201);
      });
      final AstreaApiClient client = AstreaApiClient(
        httpClient: mock,
        baseUrl: base,
      );

      final Map<String, dynamic> json = await client.postItinerary(
        <String, dynamic>{'start': 'a'},
      );

      expect(sentToken, 'abc');
      expect(json['points'], isEmpty);
    });

    test('accepts a PascalCase AccessToken too', () async {
      String? sentToken;
      final MockClient mock = MockClient((http.Request request) async {
        if (request.url.path == '/v0/auth/anonymous') {
          return http.Response(
            jsonEncode(<String, String>{'AccessToken': 'xyz'}),
            202,
          );
        }
        sentToken = request.headers['access-token'];
        return http.Response(jsonEncode(<String, Object>{'points': []}), 201);
      });
      final AstreaApiClient client = AstreaApiClient(
        httpClient: mock,
        baseUrl: base,
      );

      await client.postItinerary(<String, dynamic>{});

      expect(sentToken, 'xyz');
    });

    test('caches the token between calls', () async {
      int tokenCalls = 0;
      final MockClient mock = MockClient((http.Request request) async {
        tokenCalls++;
        return token('abc');
      });
      final AstreaApiClient client = AstreaApiClient(
        httpClient: mock,
        baseUrl: base,
      );
      await client.ensureAuthenticated();
      await client.ensureAuthenticated();
      expect(tokenCalls, 1);
    });

    test('retries once with a new token after a 401', () async {
      int tokenCalls = 0;
      final List<String?> used = <String?>[];
      final MockClient mock = MockClient((http.Request request) async {
        if (request.url.path == '/v0/auth/anonymous') {
          tokenCalls++;
          return token('t$tokenCalls');
        }
        used.add(request.headers['access-token']);
        return used.length == 1
            ? http.Response('', 401)
            : http.Response(jsonEncode(<String, Object>{'points': []}), 201);
      });
      final AstreaApiClient client = AstreaApiClient(
        httpClient: mock,
        baseUrl: base,
      );

      await client.postItinerary(<String, dynamic>{});

      expect(used, <String?>['t1', 't2']);
    });

    test('throws ApiException on unexpected status', () async {
      final MockClient mock = MockClient((http.Request request) async {
        if (request.url.path == '/v0/auth/anonymous') {
          return token('abc');
        }
        return http.Response('{"error":"no route"}', 422);
      });
      final AstreaApiClient client = AstreaApiClient(
        httpClient: mock,
        baseUrl: base,
      );

      expect(
        client.postItinerary(<String, dynamic>{}),
        throwsA(
          isA<ApiException>().having(
            (ApiException e) => e.statusCode,
            'status',
            422,
          ),
        ),
      );
    });

    test('times out instead of hanging when the API never answers', () async {
      final Completer<http.Response> never = Completer<http.Response>();
      final AstreaApiClient client = AstreaApiClient(
        httpClient: MockClient((http.Request request) => never.future),
        baseUrl: base,
        requestTimeout: const Duration(milliseconds: 50),
      );
      expect(client.ensureAuthenticated(), throwsA(isA<TimeoutException>()));
    });

    test('throws ApiException when token endpoint fails', () async {
      final MockClient mock = MockClient(
        (http.Request request) async => http.Response('', 500),
      );
      final AstreaApiClient client = AstreaApiClient(
        httpClient: mock,
        baseUrl: base,
      );
      expect(client.ensureAuthenticated(), throwsA(isA<ApiException>()));
    });
  });
}
