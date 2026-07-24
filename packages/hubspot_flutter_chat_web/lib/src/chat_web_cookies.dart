import 'package:webview_flutter/webview_flutter.dart';

/// Helpers for the WebView cookie store that backs anonymous-thread persistence.
///
/// HubSpot keys an anonymous conversation to the `messagesUtk` visitor cookie
/// (set on HubSpot's own domains). To keep the same thread across app restarts,
/// the WebView's cookie store must persist — which it does automatically on
/// Android (the platform WebView writes cookies to the app's WebView data
/// directory). So there is deliberately **no `save()`/`restore()` here**:
/// persistence is the platform's job, and this package must not fight it.
///
/// What IS actionable is CLEARING the store — e.g. when the host app wants to
/// end the anonymous session and start a fresh thread (a "clear chat history"
/// action, or on logout). [clear] does that.
class HubSpotChatWebCookies {
  /// Creates the helper. Inject a [manager] in tests; defaults to the real
  /// [WebViewCookieManager].
  HubSpotChatWebCookies([WebViewCookieManager? manager])
    : _manager = manager ?? WebViewCookieManager();

  final WebViewCookieManager _manager;

  /// Clears all WebView cookies, dropping the anonymous thread. The next load
  /// starts a fresh visitor (and thus a new conversation).
  Future<void> clear() => _manager.clearCookies();
}
