import '../core/errors/hubspot_exception.dart';

/// **STUB — backend tier.** Marketing events and transactional (single-send)
/// email.
///
/// Both are authenticated and often gated behind add-ons/tiers, so they are
/// backend-only. Every method throws [HubSpotUnimplementedError].
class MarketingStub {
  /// Internal — constructed by `HubspotClient`.
  const MarketingStub();

  /// `POST /marketing/v3/marketing-events/events`.
  Future<Map<String, Object?>> createEvent(Map<String, Object?> event) =>
      throw HubSpotUnimplementedError('Marketing createEvent');

  /// Sets a participant's state (`REGISTERED` / `ATTENDED` / `CANCELLED`).
  Future<void> setParticipantState({
    required String externalEventId,
    required String state,
    required List<String> contactEmails,
  }) => throw HubSpotUnimplementedError('Marketing setParticipantState');

  /// `POST /marketing/v3/transactional/single-email/send` (requires the
  /// transactional-email add-on).
  Future<Map<String, Object?>> sendTransactionalEmail({
    required int emailId,
    required String to,
    Map<String, Object?> customProperties = const {},
  }) => throw HubSpotUnimplementedError('Marketing sendTransactionalEmail');
}
