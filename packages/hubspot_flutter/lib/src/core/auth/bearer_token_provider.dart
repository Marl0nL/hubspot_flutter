import '../errors/hubspot_exception.dart';
import 'auth_provider.dart';

/// **STUB (backend tier).** Authenticates with a static Bearer token — a
/// HubSpot **Private App access token** or an OAuth access token.
///
/// > 🔒 A Private App token is an account-wide secret. **Never** construct this
/// > provider inside a shipped mobile build. It belongs on a trusted server.
///
/// This seam documents the intended server-side shape. It is **not implemented**
/// in this client-safe release: [headers] throws [HubSpotUnimplementedError].
/// The backend tier will wire it up to inject `Authorization: Bearer <token>`.
class BearerTokenProvider implements AuthProvider {
  /// Captures the [token] (and optional [tokenPrefix]) for the future
  /// server-tier implementation. Constructing this does not make the provider
  /// usable — see the class docs.
  const BearerTokenProvider(this.token, {this.tokenPrefix = 'Bearer'});

  /// The Private App / OAuth access token.
  final String token;

  /// The Authorization scheme prefix (almost always `Bearer`).
  final String tokenPrefix;

  @override
  bool get isClientSafe => false;

  @override
  Map<String, String> headers() =>
      throw HubSpotUnimplementedError('BearerTokenProvider');
}
