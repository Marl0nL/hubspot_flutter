import 'auth_provider.dart';

/// The secret-free auth provider for HubSpot's **client-safe** endpoints.
///
/// This is the only [AuthProvider] that is safe to ship inside a customer-facing
/// mobile app. It attaches no credentials; the endpoints it unlocks need only a
/// public `portalId` / `formGuid`:
///
/// * Forms submission (`api.hsforms.com`)
/// * Content Search v2 (published KB / blog / pages)
/// * Public HubDB reads (tables with "Allow public API access" on)
///
/// ```dart
/// final client = HubspotClient(
///   options: const HubspotOptions(portalId: '1234567'),
///   auth: const PublicClient(),
/// );
/// ```
class PublicClient implements AuthProvider {
  /// Creates a no-auth provider.
  const PublicClient();

  @override
  bool get isClientSafe => true;

  @override
  Map<String, String> headers() => const <String, String>{};
}
