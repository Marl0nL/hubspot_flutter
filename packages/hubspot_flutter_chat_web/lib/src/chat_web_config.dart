/// Configuration for embedding HubSpot's **browser** Conversations chat widget
/// inside a Flutter WebView.
///
/// Everything here is PUBLIC (non-secret) configuration — there is no token or
/// client secret. Anonymous chat needs only [portalId] (+ the data-region
/// [hublet]). If you identify visitors, the visitor-identification token is
/// minted on your backend and supplied separately (see the README) — never in
/// this config.
class HubSpotChatWebConfig {
  /// Creates a web-embed chat configuration.
  const HubSpotChatWebConfig({
    required this.portalId,
    this.hublet = 'na1',
    this.chatflow,
    this.hostUrl,
    this.inlineSelector = _defaultInlineSelector,
  });

  /// HubSpot's default inline-embed element id.
  static const String _defaultInlineSelector =
      'hubspot-conversations-inline-embed-selector';

  /// The public HubSpot portal / Hub ID (e.g. `3445699`).
  final String portalId;

  /// The HubSpot hublet (data region), e.g. `na1`, `eu1`, `ap1`. Selects the
  /// region-specific loader host. Defaults to `na1`.
  final String hublet;

  /// The chatflow name for bookkeeping / documentation.
  ///
  /// > ⚠️ The browser widget does **not** let you force a chatflow by name from
  /// > JavaScript. Which chatflow appears is decided by the **targeting rules**
  /// > you configure in HubSpot against the page URL (see [hostUrl]). This field
  /// > is not injected into the embed; it exists so callers can record which
  /// > chatflow they expect targeting to resolve to.
  final String? chatflow;

  /// The origin the embed HTML loads against (the WebView document's base URL).
  ///
  /// Set this to the site whose chatflow targeting rules should apply (HubSpot
  /// matches the chat widget to a chatflow by the page URL). When omitted, the
  /// portal's `hs-sites.com` domain is used. The HubSpot visitor cookies that
  /// key an anonymous thread are set on HubSpot's own domains regardless of this
  /// value.
  final String? hostUrl;

  /// The DOM id of the element the widget renders into (inline, full-panel —
  /// not a floating launcher bubble). Rarely needs changing.
  final String inlineSelector;
}
