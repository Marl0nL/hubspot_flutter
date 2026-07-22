import 'package:dio/dio.dart';
import 'package:hubspot_flutter/hubspot_flutter.dart';
import 'package:test/test.dart';

import 'support/scripted_adapter.dart';

/// Zero-delay backoff so retry tests run instantly.
Duration _noWait(int attempt, Duration? retryAfter) => Duration.zero;

void main() {
  group('RateLimitInterceptor', () {
    test('retries a 429 then succeeds', () async {
      final dio = Dio();
      final adapter = ScriptedAdapter(<MockResponse>[
        jsonResponse(429, {'message': 'slow down'}),
        jsonResponse(200, {'ok': true}),
      ]);
      dio.httpClientAdapter = adapter;
      dio.interceptors.add(
        RateLimitInterceptor(dio: dio, maxRetries: 3, backoff: _noWait),
      );

      final response = await dio.get<Object?>('https://api.hubapi.com/x');
      expect(response.statusCode, 200);
      expect(adapter.callCount, 2); // one 429 + one success
    });

    test('gives up after maxRetries and rethrows the 429', () async {
      final dio = Dio();
      final adapter = ScriptedAdapter.single(jsonResponse(429, {'m': 'no'}));
      dio.httpClientAdapter = adapter;
      dio.interceptors.add(
        RateLimitInterceptor(dio: dio, maxRetries: 2, backoff: _noWait),
      );

      await expectLater(
        dio.get<Object?>('https://api.hubapi.com/x'),
        throwsA(isA<DioException>()),
      );
      // initial + 2 retries = 3 calls
      expect(adapter.callCount, 3);
    });

    test('retries transient 503 when enabled', () async {
      final dio = Dio();
      final adapter = ScriptedAdapter(<MockResponse>[
        jsonResponse(503, {'m': 'later'}),
        jsonResponse(200, {'ok': true}),
      ]);
      dio.httpClientAdapter = adapter;
      dio.interceptors.add(
        RateLimitInterceptor(dio: dio, maxRetries: 3, backoff: _noWait),
      );

      final response = await dio.get<Object?>('https://api.hubapi.com/x');
      expect(response.statusCode, 200);
      expect(adapter.callCount, 2);
    });

    test('does not retry non-retryable statuses', () async {
      final dio = Dio();
      final adapter = ScriptedAdapter.single(jsonResponse(404, {'m': 'gone'}));
      dio.httpClientAdapter = adapter;
      dio.interceptors.add(
        RateLimitInterceptor(dio: dio, maxRetries: 3, backoff: _noWait),
      );

      await expectLater(
        dio.get<Object?>('https://api.hubapi.com/x'),
        throwsA(isA<DioException>()),
      );
      expect(adapter.callCount, 1);
    });

    test('does not retry 5xx when retryOnServerError is false', () async {
      final dio = Dio();
      final adapter = ScriptedAdapter.single(jsonResponse(503, {'m': 'no'}));
      dio.httpClientAdapter = adapter;
      dio.interceptors.add(
        RateLimitInterceptor(
          dio: dio,
          maxRetries: 3,
          retryOnServerError: false,
          backoff: _noWait,
        ),
      );

      await expectLater(
        dio.get<Object?>('https://api.hubapi.com/x'),
        throwsA(isA<DioException>()),
      );
      expect(adapter.callCount, 1);
    });
  });
}
