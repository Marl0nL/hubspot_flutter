import 'messages.g.dart';

/// Configuration for the HubSpot native mobile chat SDK.
///
/// [portalId] is your public HubSpot portal / Hub ID. Everything here is public
/// (non-secret) configuration — there is no token or client secret. The
/// visitor-identification token, if you identify visitors, is supplied
/// separately to [HubspotChat.setUserIdentity] and is minted on your backend.
///
/// > ⚠️ **The native SDKs read most of this from bundled files, not from
/// > Dart.** HubSpot's 1.0.x mobile SDKs load `portalId` / [hublet] /
/// > [environment] from the app's native config (`assets/hubspot-info.json` on
/// > Android, the HubSpot config file in the iOS bundle) at `configure()` time —
/// > see the README's *Native setup*. Those Dart fields exist for forward
/// > compatibility and your own bookkeeping; today only [defaultChatFlow] is
/// > applied by the bridge itself. Keep the Dart values in sync with the native
/// > files to avoid confusion.
class HubspotChatConfig {
  /// Creates a chat configuration.
  const HubspotChatConfig({
    required this.portalId,
    this.hublet,
    this.defaultChatFlow,
    this.environment,
    this.enableLogging = false,
  });

  /// The public HubSpot portal / Hub ID.
  final String portalId;

  /// The HubSpot hublet (data region), e.g. `na1` or `eu1`. Defaults to the
  /// SDK's own default when omitted.
  final String? hublet;

  /// The chatflow to open when [HubspotChat.open] is called without one.
  final String? defaultChatFlow;

  /// The HubSpot environment (`PROD` by default in the native SDK).
  final String? environment;

  /// Whether to enable verbose native SDK logging (useful during development).
  final bool enableLogging;

  /// Converts to the generated Pigeon transport type.
  ChatSetupData toPigeon() => ChatSetupData(
    portalId: portalId,
    hublet: hublet,
    defaultChatFlow: defaultChatFlow,
    environment: environment,
    enableLogging: enableLogging,
  );
}
