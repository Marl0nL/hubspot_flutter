/// What the WebView should do with a navigation the chat widget triggers.
enum HubSpotNavAction {
  /// Let the WebView load it — it is the widget's own infrastructure (loader
  /// script, iframes, HubSpot asset/API hosts, in-page anchors).
  allowInWebView,

  /// A link the user tapped that leaves the chat widget (a KB article, an
  /// external site, a `mailto:`/`tel:`). The HOST app decides what to do with
  /// it — open it in-app, in a browser, etc. This package deliberately does not
  /// know or care what the link points at.
  delegateToHost,
}

/// Decides, for each main-frame navigation, whether it is the chat widget's own
/// machinery (allow) or a link the host app should handle (delegate).
///
/// Pure and Flutter-free so the policy is unit-tested without a WebView. The
/// rule is intentionally HubSpot-generic: allow HubSpot infrastructure hosts and
/// non-navigational schemes the widget uses internally; delegate every other
/// http(s) host and every app scheme (`mailto:`, `tel:`, …) to the host. The
/// package has NO knowledge of any specific host app or its link routing.
class HubSpotChatNavigationPolicy {
  /// Creates the policy. (Stateless; a const constructor for ergonomics.)
  const HubSpotChatNavigationPolicy();

  /// Host suffixes owned by HubSpot's chat/tracking infrastructure. A URL whose
  /// host equals one of these, or ends with `.<suffix>`, is the widget's own
  /// machinery and stays in the WebView.
  static const Set<String> infraHostSuffixes = <String>{
    'hs-scripts.com',
    'hs-analytics.net',
    'hscollectedforms.net',
    'hs-banner.com',
    'usemessages.com',
    'hsforms.com',
    'hsforms.net',
    'hsappstatic.net',
    'hubspot.com',
    'hubapi.com',
    'hs-sites.com',
    'hubspotusercontent.com',
    'hubspotusercontent-na1.net',
    'hubspotusercontent-eu1.net',
    'hscta.net',
  };

  /// Classifies [url]. [isMainFrame] is `false` for sub-frame (iframe) requests,
  /// which are always allowed — the widget renders in an iframe and must load
  /// freely; only top-level (main-frame) navigations can be a user link tap.
  HubSpotNavAction classify(String url, {bool isMainFrame = true}) {
    if (!isMainFrame) return HubSpotNavAction.allowInWebView;

    final uri = Uri.tryParse(url);
    if (uri == null) return HubSpotNavAction.allowInWebView;

    // Non-http(s) schemes the widget uses internally stay in the WebView;
    // app-launch schemes (mailto/tel/sms) are delegated so the host can launch
    // the relevant app.
    final scheme = uri.scheme.toLowerCase();
    if (scheme.isEmpty ||
        scheme == 'about' ||
        scheme == 'data' ||
        scheme == 'blob' ||
        scheme == 'javascript') {
      return HubSpotNavAction.allowInWebView;
    }
    if (scheme != 'http' && scheme != 'https') {
      return HubSpotNavAction.delegateToHost;
    }

    return _isInfraHost(uri.host)
        ? HubSpotNavAction.allowInWebView
        : HubSpotNavAction.delegateToHost;
  }

  bool _isInfraHost(String host) {
    final h = host.toLowerCase();
    for (final suffix in infraHostSuffixes) {
      if (h == suffix || h.endsWith('.$suffix')) return true;
    }
    return false;
  }
}
