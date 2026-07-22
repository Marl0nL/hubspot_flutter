import 'dart:async';

import '../errors/hubspot_exception.dart';
import 'auth_provider.dart';

/// **STUB (backend tier).** Points a Flutter app at your backend proxy (BFF)
/// for authenticated calls.
///
/// In the recommended thin-client posture the app never holds a HubSpot secret:
/// authenticated requests go to *your* backend, which authenticates the end
/// user, applies its own authorization, and forwards to HubSpot with the
/// account's Private App token. [ProxyAuth] would rewrite the request's base URL
/// to [backendBaseUrl] and attach *your* app's session credentials (not
/// HubSpot's) via [sessionTokenProvider].
///
/// This seam documents that shape. It is **not implemented** in this release:
/// [headers] throws [HubSpotUnimplementedError]. Implementing it also requires
/// the backend routes it proxies to, which are out of scope for the client-safe
/// tier.
class ProxyAuth implements AuthProvider {
  /// Captures the [backendBaseUrl] to forward authenticated calls to, and an
  /// optional [sessionTokenProvider] that yields *your* app's session token.
  const ProxyAuth({required this.backendBaseUrl, this.sessionTokenProvider});

  /// The base URL of your backend proxy, e.g. `https://api.yourapp.com/hubspot`.
  final Uri backendBaseUrl;

  /// Supplies your app's (non-HubSpot) session token for each request.
  final FutureOr<String?> Function()? sessionTokenProvider;

  @override
  bool get isClientSafe =>
      // The app holds no HubSpot secret, but this seam still requires a backend,
      // so it is not part of the client-safe tier that works with no server.
      false;

  @override
  FutureOr<Map<String, String>> headers() =>
      throw HubSpotUnimplementedError('ProxyAuth');
}
