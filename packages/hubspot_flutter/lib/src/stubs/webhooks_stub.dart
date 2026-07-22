import '../core/errors/hubspot_exception.dart';

/// **STUB — backend tier.** App-level webhook subscription management.
///
/// Webhooks are inherently server-side: HubSpot **pushes** signed events to a
/// public HTTPS endpoint you host, and managing subscriptions requires a
/// developer app + secret. Nothing here can run in a client. Every method
/// throws [HubSpotUnimplementedError].
class WebhooksStub {
  /// Internal — constructed by `HubspotClient`.
  const WebhooksStub();

  /// Lists the app's webhook subscriptions.
  Future<List<Map<String, Object?>>> listSubscriptions() =>
      throw HubSpotUnimplementedError('Webhooks listSubscriptions');

  /// Creates a webhook subscription (e.g. `contact.propertyChange`).
  Future<Map<String, Object?>> createSubscription(
    Map<String, Object?> subscription,
  ) => throw HubSpotUnimplementedError('Webhooks createSubscription');

  /// Verifies an inbound webhook request's `X-HubSpot-Signature`.
  bool verifySignature({
    required String signature,
    required String requestBody,
    required String appSecret,
    String version = 'v3',
  }) => throw HubSpotUnimplementedError('Webhooks verifySignature');
}
