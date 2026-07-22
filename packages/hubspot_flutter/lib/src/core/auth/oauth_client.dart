import 'dart:async';

import '../errors/hubspot_exception.dart';
import 'auth_provider.dart';

/// **STUB (backend tier).** OAuth 2.0 auth-code + refresh flow.
///
/// HubSpot's OAuth token exchange **and** refresh both require the
/// `client_secret`, and HubSpot offers **no PKCE / public-client flow** for its
/// general APIs. A mobile app therefore cannot complete OAuth on its own — this
/// provider is server-only and holds a secret.
///
/// > 🔒 **Never** compile a `client_secret` into a mobile build.
///
/// This seam documents the intended shape (auth-code → token, refresh loop with
/// the 30-minute access-token TTL). It is **not implemented** in this release:
/// every method throws [HubSpotUnimplementedError]. The server tier will
/// implement the exchange against `POST api.hubapi.com/oauth/v1/token`.
class OAuthClient implements AuthProvider {
  /// Captures the OAuth app credentials and (optional) current token state for
  /// the future server-tier implementation.
  const OAuthClient({
    required this.clientId,
    required this.clientSecret,
    required this.redirectUri,
    this.refreshToken,
    this.accessToken,
    this.scopes = const <String>[],
  });

  /// The OAuth app's client id.
  final String clientId;

  /// The OAuth app's client secret. Server-side only.
  final String clientSecret;

  /// The redirect URI registered with the OAuth app.
  final String redirectUri;

  /// The long-lived refresh token, once obtained.
  final String? refreshToken;

  /// The short-lived (≈30 min) access token, once obtained.
  final String? accessToken;

  /// The scopes requested for this app.
  final List<String> scopes;

  /// Builds the authorization URL the user is redirected to
  /// (`app.hubspot.com/oauth/authorize?...`).
  Uri buildAuthorizationUrl({String? state}) =>
      throw HubSpotUnimplementedError('OAuthClient.buildAuthorizationUrl');

  /// Exchanges an authorization `code` for access + refresh tokens.
  Future<void> exchangeCode(String code) =>
      throw HubSpotUnimplementedError('OAuthClient.exchangeCode');

  /// Uses the refresh token to obtain a fresh access token.
  Future<void> refresh() =>
      throw HubSpotUnimplementedError('OAuthClient.refresh');

  @override
  bool get isClientSafe => false;

  @override
  FutureOr<Map<String, String>> headers() =>
      throw HubSpotUnimplementedError('OAuthClient');
}
