import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:hubspot_flutter/hubspot_flutter.dart';
import 'package:test/test.dart';

import 'support/scripted_adapter.dart';

/// Builds an http client whose single scripted response is [response].
HubspotHttpClient clientReturning(MockResponse response) {
  final dio = Dio();
  dio.httpClientAdapter = ScriptedAdapter.single(response);
  return HubspotHttpClient(
    options: const HubspotOptions(portalId: '1'),
    auth: const PublicClient(),
    dio: dio,
  );
}

void main() {
  group('mapDioException via the HTTP client', () {
    test('401/403 -> HubSpotAuthException', () async {
      final http = clientReturning(jsonResponse(401, {'message': 'nope'}));
      await expectLater(
        http.getJson('https://api.hubapi.com/x'),
        throwsA(
          isA<HubSpotAuthException>()
              .having((e) => e.statusCode, 'statusCode', 401)
              .having((e) => e.category, 'category', HubSpotErrorCategory.auth),
        ),
      );
    });

    test('400 -> HubSpotValidationException with per-field errors', () async {
      final body = loadJsonFixture('form_submission_error.json');
      final http = clientReturning(jsonResponse(400, body));
      await expectLater(
        http.getJson('https://api.hubapi.com/x'),
        throwsA(
          isA<HubSpotValidationException>()
              .having((e) => e.statusCode, 'statusCode', 400)
              .having(
                (e) => e.correlationId,
                'correlationId',
                'd3d9446802a44259755d38e6d163e820',
              )
              .having(
                (e) => e.validationErrors,
                'validationErrors',
                hasLength(1),
              )
              .having((e) => e.message, 'message', contains('valid email')),
        ),
      );
    });

    test('404 -> HubSpotNotFoundException with correlationId', () async {
      final body = loadJsonFixture('error_body.json');
      final http = clientReturning(jsonResponse(404, body));
      await expectLater(
        http.getJson('https://api.hubapi.com/x'),
        throwsA(
          isA<HubSpotNotFoundException>()
              .having((e) => e.statusCode, 'statusCode', 404)
              .having(
                (e) => e.correlationId,
                'correlationId',
                'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee',
              ),
        ),
      );
    });

    test('429 -> HubSpotRateLimitException carrying Retry-After', () async {
      // maxRetries 0 so the 429 surfaces immediately without retry delay.
      final dio = Dio()
        ..httpClientAdapter = ScriptedAdapter.single(
          jsonResponse(
            429,
            {'message': 'slow down'},
            headers: {
              'retry-after': ['7'],
              'x-hubspot-ratelimit-daily-remaining': ['1234'],
            },
          ),
        );
      final http = HubspotHttpClient(
        options: const HubspotOptions(portalId: '1', maxRetries: 0),
        auth: const PublicClient(),
        dio: dio,
      );
      await expectLater(
        http.getJson('https://api.hubapi.com/x'),
        throwsA(
          isA<HubSpotRateLimitException>()
              .having(
                (e) => e.retryAfter,
                'retryAfter',
                const Duration(seconds: 7),
              )
              .having((e) => e.dailyRemaining, 'dailyRemaining', 1234),
        ),
      );
      http.close();
    });

    test('5xx -> HubSpotServerException', () async {
      final dio = Dio()
        ..httpClientAdapter = ScriptedAdapter.single(
          jsonResponse(503, {'message': 'boom'}),
        );
      final http = HubspotHttpClient(
        options: const HubspotOptions(portalId: '1', maxRetries: 0),
        auth: const PublicClient(),
        dio: dio,
      );
      await expectLater(
        http.getJson('https://api.hubapi.com/x'),
        throwsA(
          isA<HubSpotServerException>().having(
            (e) => e.statusCode,
            'statusCode',
            503,
          ),
        ),
      );
    });

    test('connection error -> HubSpotNetworkException', () async {
      final dio = Dio();
      dio.httpClientAdapter = _ThrowingAdapter();
      final http = HubspotHttpClient(
        options: const HubspotOptions(portalId: '1', maxRetries: 0),
        auth: const PublicClient(),
        dio: dio,
      );
      await expectLater(
        http.getJson('https://api.hubapi.com/x'),
        throwsA(isA<HubSpotNetworkException>()),
      );
    });

    test('toString includes status and correlationId', () {
      const e = HubSpotAuthException(
        'bad',
        statusCode: 403,
        correlationId: 'cid',
      );
      expect(e.toString(), contains('HTTP 403'));
      expect(e.toString(), contains('cid'));
    });
  });
}

class _ThrowingAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    throw DioException.connectionError(
      requestOptions: options,
      reason: 'refused',
    );
  }

  @override
  void close({bool force = false}) {}
}
