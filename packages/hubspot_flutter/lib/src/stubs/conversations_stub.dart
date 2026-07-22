import '../core/errors/hubspot_exception.dart';
import '../core/models/paging.dart';

/// **STUB — backend tier.** The Conversations Inbox & Messages API (the
/// agent/CRM side of conversations).
///
/// This surface exposes **all** customers' threads, messages and PII, so it must
/// **never** be reachable from a customer-facing app — it belongs behind a
/// backend with per-user authorization. Every method throws
/// [HubSpotUnimplementedError] in this release.
///
/// > Note the breaking change to the Conversations API / Help Desk / Comments
/// > scheduled for 2026-09-23 — pin versions and monitor before implementing.
class ConversationsStub {
  /// Internal — constructed by `HubspotClient`.
  const ConversationsStub();

  /// `GET /conversations/v3/conversations/threads`.
  Future<Page<Map<String, Object?>>> listThreads({int? limit, String? after}) =>
      throw HubSpotUnimplementedError('Conversations listThreads');

  /// `GET /conversations/v3/conversations/threads/{id}`.
  Future<Map<String, Object?>> getThread(String threadId) =>
      throw HubSpotUnimplementedError('Conversations getThread');

  /// `GET /conversations/v3/conversations/threads/{id}/messages`.
  Future<Page<Map<String, Object?>>> listMessages(
    String threadId, {
    int? limit,
    String? after,
  }) => throw HubSpotUnimplementedError('Conversations listMessages');

  /// `POST /conversations/v3/conversations/threads/{id}/messages`.
  Future<Map<String, Object?>> sendMessage(
    String threadId,
    Map<String, Object?> message,
  ) => throw HubSpotUnimplementedError('Conversations sendMessage');

  /// `GET /conversations/v3/conversations/inboxes`.
  Future<List<Map<String, Object?>>> listInboxes() =>
      throw HubSpotUnimplementedError('Conversations listInboxes');

  /// `GET /conversations/v3/conversations/channels`.
  Future<List<Map<String, Object?>>> listChannels() =>
      throw HubSpotUnimplementedError('Conversations listChannels');

  /// Custom conversation channels (`/conversations/v3/custom-channels`).
  CustomChannelsStub get customChannels => const CustomChannelsStub._();
}

/// **STUB — backend tier.** Custom conversation channels.
class CustomChannelsStub {
  const CustomChannelsStub._();

  /// `GET /conversations/v3/custom-channels`.
  Future<List<Map<String, Object?>>> list() =>
      throw HubSpotUnimplementedError('Custom channels list');

  /// `POST /conversations/v3/custom-channels/{channelId}/messages`.
  Future<Map<String, Object?>> sendMessage(
    String channelId,
    Map<String, Object?> message,
  ) => throw HubSpotUnimplementedError('Custom channels sendMessage');
}

/// **STUB — split tier (mint server-side, consume client-side).** Mints the
/// visitor-identification token that the native chat SDK consumes to identify a
/// logged-in visitor.
///
/// `POST /visitor-identification/v3/tokens/create` takes an email (+ context)
/// and returns a ~12h token. It requires the `conversations.visitor_identification.tokens.create`
/// scope and therefore a secret — so it **must be minted on your backend**. The
/// client passes the resulting token to `hubspot_flutter_chat`'s
/// `setUserIdentity(email, identityToken)`; it does **not** mint it.
///
/// This method throws [HubSpotUnimplementedError]: token minting lives in the
/// backend tier.
class VisitorIdentificationStub {
  /// Internal — constructed by `HubspotClient`.
  const VisitorIdentificationStub();

  /// `POST /visitor-identification/v3/tokens/create` — **server-side only.**
  Future<String> createToken({
    required String email,
    String? firstName,
    String? lastName,
  }) => throw HubSpotUnimplementedError(
    'Visitor-identification token minting',
    reason:
        'Mint this on your backend (it needs a secret scope) and pass '
        'the token to hubspot_flutter_chat.setUserIdentity — see the README.',
  );
}
