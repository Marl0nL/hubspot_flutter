import 'package:dio/dio.dart';
import 'package:hubspot_flutter/hubspot_flutter.dart';
import 'package:test/test.dart';

import 'support/scripted_adapter.dart';

void main() {
  group('PublicClient', () {
    test('is client-safe and attaches no headers', () {
      const auth = PublicClient();
      expect(auth.isClientSafe, isTrue);
      expect(auth.headers(), isEmpty);
    });
  });

  group('stubbed auth providers', () {
    test('are not client-safe', () {
      expect(const BearerTokenProvider('secret').isClientSafe, isFalse);
      expect(
        const OAuthClient(
          clientId: 'a',
          clientSecret: 'b',
          redirectUri: 'https://x',
        ).isClientSafe,
        isFalse,
      );
      expect(
        ProxyAuth(
          backendBaseUrl: Uri.parse('https://api.example.com'),
        ).isClientSafe,
        isFalse,
      );
    });

    test('throw HubSpotUnimplementedError when asked for headers', () {
      expect(
        () => const BearerTokenProvider('secret').headers(),
        throwsA(isA<HubSpotUnimplementedError>()),
      );
      expect(
        () => const OAuthClient(
          clientId: 'a',
          clientSecret: 'b',
          redirectUri: 'https://x',
        ).headers(),
        throwsA(isA<HubSpotUnimplementedError>()),
      );
      expect(
        () => ProxyAuth(backendBaseUrl: Uri.parse('https://x')).headers(),
        throwsA(isA<HubSpotUnimplementedError>()),
      );
    });

    test('OAuthClient flow methods throw with clear messages', () {
      const oauth = OAuthClient(
        clientId: 'a',
        clientSecret: 'b',
        redirectUri: 'https://x',
      );
      expect(oauth.buildAuthorizationUrl, throwsA(isA<UnimplementedError>()));
      expect(
        () => oauth.exchangeCode('c'),
        throwsA(isA<HubSpotUnimplementedError>()),
      );
      expect(oauth.refresh, throwsA(isA<HubSpotUnimplementedError>()));
    });
  });

  group('AuthInterceptor', () {
    test('a stubbed provider surfaces its error through a request', () async {
      final dio = Dio()
        ..httpClientAdapter = ScriptedAdapter.single(jsonResponse(200, {}));
      final client = HubspotClient(
        options: const HubspotOptions(portalId: '1'),
        auth: const BearerTokenProvider('secret'),
        dio: dio,
      );
      await expectLater(
        client.forms.submit(formGuid: 'g', fields: {'email': 'a@b.com'}),
        throwsA(isA<HubSpotUnimplementedError>()),
      );
      client.close();
    });

    test('PublicClient lets the request through', () async {
      final adapter = ScriptedAdapter.single(jsonResponse(200, {'ok': true}));
      final dio = Dio()..httpClientAdapter = adapter;
      final client = HubspotClient(
        options: const HubspotOptions(portalId: '1'),
        auth: const PublicClient(),
        dio: dio,
      );
      await client.forms.submit(formGuid: 'g', fields: {'email': 'a@b.com'});
      expect(adapter.callCount, 1);
      // No Authorization header added by the public client.
      expect(
        adapter.received.first.headers.containsKey('Authorization'),
        isFalse,
      );
      client.close();
    });
  });

  group('requireClientSafe enforcement', () {
    test('rejects a secret-bearing provider when required', () {
      expect(
        () => HubspotClient(
          options: const HubspotOptions(portalId: '1'),
          auth: const BearerTokenProvider('secret'),
          requireClientSafe: true,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('allows PublicClient when required', () {
      final client = HubspotClient(
        options: const HubspotOptions(portalId: '1'),
        auth: const PublicClient(),
        requireClientSafe: true,
      );
      expect(client.auth.isClientSafe, isTrue);
      client.close();
    });

    test('permits a secret-bearing provider by default (server tier)', () {
      // Default requireClientSafe:false — backends legitimately use these.
      final client = HubspotClient(
        options: const HubspotOptions(portalId: '1'),
        auth: const BearerTokenProvider('secret'),
      );
      expect(client.auth.isClientSafe, isFalse);
      client.close();
    });
  });
}
