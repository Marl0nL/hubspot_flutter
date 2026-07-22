import 'package:meta/meta.dart';

import 'models/hubspot_region.dart';

/// Configuration shared across every hubspot_flutter module.
@immutable
class HubspotOptions {
  /// Creates options for a [HubspotClient].
  ///
  /// [portalId] (also called the Hub ID) is required by the client-safe
  /// modules (Forms, Content Search, public HubDB). It is a **public**
  /// identifier — not a secret — so it is safe to ship in an app.
  const HubspotOptions({
    this.portalId,
    this.region = HubSpotRegion.na,
    this.apiBaseUrl = 'https://api.hubapi.com',
    this.connectTimeout = const Duration(seconds: 10),
    this.receiveTimeout = const Duration(seconds: 30),
    this.maxRetries = 3,
    this.userAgent = 'hubspot_flutter/$packageVersion (Dart)',
  });

  /// The account's public portal / Hub ID.
  final String? portalId;

  /// The account's hosting region (affects the Forms host).
  final HubSpotRegion region;

  /// Base URL for the main HubSpot API (`api.hubapi.com`).
  final String apiBaseUrl;

  /// Connection timeout for outgoing requests.
  final Duration connectTimeout;

  /// Read timeout for outgoing requests.
  final Duration receiveTimeout;

  /// Maximum retry attempts on rate-limit / transient errors.
  final int maxRetries;

  /// `User-Agent` sent with every request.
  final String userAgent;

  /// Returns [portalId] or throws an [ArgumentError] with a clear message when
  /// it was not configured but a module needs it.
  String requirePortalId() {
    final id = portalId;
    if (id == null || id.isEmpty) {
      throw ArgumentError(
        'This operation requires a portalId. Pass it to HubspotOptions, '
        'e.g. HubspotOptions(portalId: "1234567").',
      );
    }
    return id;
  }
}

/// The published version of the `hubspot_flutter` package.
const String packageVersion = '0.1.0';
