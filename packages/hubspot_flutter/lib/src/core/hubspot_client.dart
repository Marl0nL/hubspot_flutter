import 'package:dio/dio.dart';

import '../content_search/content_search_client.dart';
import '../forms/forms_client.dart';
import '../hubdb/hubdb_client.dart';
import '../stubs/cms_stub.dart';
import '../stubs/conversations_stub.dart';
import '../stubs/crm_stub.dart';
import '../stubs/files_stub.dart';
import '../stubs/marketing_stub.dart';
import '../stubs/webhooks_stub.dart';
import 'auth/auth_provider.dart';
import 'auth/public_client.dart';
import 'hubspot_options.dart';
import 'http/http_client.dart';

/// The entry point to hubspot_flutter.
///
/// Construct one client per HubSpot account and reach every module through its
/// getters. In this release the **client-safe** modules ([forms],
/// [contentSearch], [hubdb]) are live; the backend-tier modules ([crm],
/// [conversations], [cms], [files], [marketing], [webhooks],
/// [visitorIdentification]) are documented stubs that throw a clear
/// "requires the backend tier" error.
///
/// ```dart
/// final client = HubspotClient(
///   options: const HubspotOptions(portalId: '1234567'),
///   auth: const PublicClient(),
/// );
/// await client.forms.submit(formGuid: '...', fields: {'email': 'a@b.com'});
/// client.close();
/// ```
class HubspotClient {
  /// Builds a client from [options] and an [auth] strategy.
  ///
  /// [auth] defaults to [PublicClient] (the client-safe tier). Pass a
  /// server-tier provider only from a backend — see the two-tier model in the
  /// README. [dio] can be injected for testing.
  ///
  /// Set [requireClientSafe] to `true` in code that ships inside a mobile app:
  /// it asserts up front that [auth] carries no secret
  /// ([AuthProvider.isClientSafe]) and throws an [ArgumentError] otherwise, so a
  /// secret-bearing provider can never be compiled into a client build by
  /// mistake. It defaults to `false` because the same package is also used
  /// server-side, where secret-bearing providers are expected.
  factory HubspotClient({
    required HubspotOptions options,
    AuthProvider auth = const PublicClient(),
    bool requireClientSafe = false,
    Dio? dio,
  }) {
    if (requireClientSafe && !auth.isClientSafe) {
      throw ArgumentError.value(
        auth.runtimeType,
        'auth',
        'is not client-safe: it carries (or requires) a HubSpot secret and must '
            'not be used in a shipped mobile build. Use PublicClient for the '
            'client-safe tier, or drop requireClientSafe on a trusted server.',
      );
    }
    final http = HubspotHttpClient(options: options, auth: auth, dio: dio);
    return HubspotClient._(options: options, auth: auth, http: http);
  }

  HubspotClient._({
    required this.options,
    required this.auth,
    required HubspotHttpClient http,
  }) : _http = http,
       forms = FormsClient(http: http, options: options),
       contentSearch = ContentSearchClient(http: http, options: options),
       hubdb = HubDbClient(http: http, options: options);

  /// The shared configuration.
  final HubspotOptions options;

  /// The active auth strategy.
  final AuthProvider auth;

  final HubspotHttpClient _http;

  // ---- Client-safe modules (live) ----

  /// Forms submission (client-safe).
  final FormsClient forms;

  /// Content Search v2 — published help-centre content (client-safe).
  final ContentSearchClient contentSearch;

  /// Public HubDB reads (client-safe, read-only).
  final HubDbClient hubdb;

  // ---- Backend-tier modules (stubs) ----

  /// CRM objects/search/batch/associations/properties (**stub**).
  final CrmStub crm = const CrmStub();

  /// Conversations Inbox & Messages + custom channels (**stub**).
  final ConversationsStub conversations = const ConversationsStub();

  /// Visitor-identification token minting (**stub**; mint server-side).
  final VisitorIdentificationStub visitorIdentification =
      const VisitorIdentificationStub();

  /// CMS pages/blog/HubDB-writes, Site Search v3, KB GraphQL (**stub**).
  final CmsStub cms = const CmsStub();

  /// Files API (**stub**).
  final FilesStub files = const FilesStub();

  /// Marketing events + transactional email (**stub**).
  final MarketingStub marketing = const MarketingStub();

  /// Webhook subscription management (**stub**).
  final WebhooksStub webhooks = const WebhooksStub();

  /// The underlying HTTP client (for advanced use / testing).
  HubspotHttpClient get httpClient => _http;

  /// Releases HTTP resources. Call when the client is no longer needed.
  void close({bool force = false}) => _http.close(force: force);
}
