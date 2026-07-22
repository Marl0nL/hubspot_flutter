import 'dart:async';

/// Strategy for authenticating outgoing HubSpot requests.
///
/// hubspot_flutter's auth layer is deliberately pluggable so a single package can
/// serve both a Flutter app (which must never hold a secret) and a Dart backend
/// (which may). The core ships four implementations:
///
/// * [PublicClient] — no credentials; the only client-safe implementation, used
///   for Forms, Content Search v2 and public HubDB reads. **Live in this release.**
/// * `BearerTokenProvider` — a Private App / static Bearer token (server only).
/// * `OAuthClient` — OAuth auth-code + refresh (server only; holds a secret).
/// * `ProxyAuth` — points a Flutter app at your backend proxy (BFF).
///
/// The latter three are **stubs** in this release (see the README's two-tier
/// model) and throw [HubSpotUnimplementedError] when used.
abstract interface class AuthProvider {
  /// Whether this provider is safe to compile into a shipped mobile binary.
  ///
  /// Only [PublicClient] is client-safe. Providers that carry a secret return
  /// `false`.
  ///
  /// This is advisory metadata that callers can inspect. To have it *enforced*,
  /// construct the client with `HubspotClient(requireClientSafe: true)` — it
  /// throws if the provider is not client-safe. (Enforcement is opt-in because
  /// the same package is also used server-side, where secret-bearing providers
  /// are expected.)
  bool get isClientSafe;

  /// Headers to attach to each outgoing request.
  ///
  /// [PublicClient] returns an empty map. Secret-bearing providers return e.g.
  /// `{'Authorization': 'Bearer ...'}`.
  FutureOr<Map<String, String>> headers();
}
