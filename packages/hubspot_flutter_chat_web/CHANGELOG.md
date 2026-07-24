# Changelog

## 0.1.0

Initial release.

- `HubSpotChatWebConfig` — public, non-secret embed config (portalId, hublet,
  optional chatflow/hostUrl/inline selector).
- `HubSpotChatEmbed` — pure builder for the inline-embed HTML + region-aware
  loader URL + base URL. Renders the widget as a full-panel inline chat, not a
  floating launcher bubble, and auto-loads it on ready.
- `HubSpotChatNavigationPolicy` — pure allow/delegate classifier: HubSpot
  infrastructure hosts stay in the WebView; every other link tap is delegated to
  the host app (which decides — the package has no app-specific knowledge).
- `HubSpotChatWebController` — configures an injectable `WebViewController`,
  wires the navigation delegate, and loads the embed.
- `HubSpotChatWebView` — the `WebViewWidget` wrapper.
- `HubSpotChatWebCookies` — clear the visitor cookie store (start a fresh
  anonymous thread); platform persistence is documented, not fought.
- 17 unit tests over the pure embed + navigation logic; `example/` shows a
  bounded chat embedded in native chrome.
