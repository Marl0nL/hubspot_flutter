import 'dart:ui' show Color;

import 'package:flutter/foundation.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'chat_web_config.dart';
import 'chat_web_embed.dart';
import 'chat_web_navigation.dart';

/// Owns a [WebViewController] configured to host HubSpot's inline browser chat
/// widget, with a navigation delegate that hands link taps back to the host app.
///
/// Lifecycle is the HOST's responsibility: keep this instance alive (e.g. in a
/// long-lived provider or a retained `State`) so the WebView — and thus the open
/// chat socket and the anonymous thread — survives in-app navigation. Cookies
/// (including the `messagesUtk` visitor cookie that keys an anonymous thread) are
/// persisted by the platform WebView across app restarts on Android; see
/// [HubSpotChatWebCookies].
///
/// The [WebViewController] is injectable so the wiring stays testable; the pure,
/// exhaustively-tested pieces are [HubSpotChatEmbed] (the HTML) and
/// [HubSpotChatNavigationPolicy] (the allow/delegate decision).
class HubSpotChatWebController {
  /// Creates a controller for [config].
  ///
  /// [onLinkTap] is called with a link the user tapped that leaves the widget
  /// (a KB article, an external site, a `mailto:`) — the host decides what to do
  /// with it. [onWebResourceError] surfaces load failures so the host can show a
  /// retry affordance. Pass [controller] to inject a pre-built (or fake) one.
  HubSpotChatWebController({
    required this.config,
    required this.onLinkTap,
    this.onWebResourceError,
    this.onPageFinished,
    WebViewController? controller,
  }) : webViewController = controller ?? WebViewController(),
       _embed = HubSpotChatEmbed(config);

  /// The embed configuration.
  final HubSpotChatWebConfig config;

  /// Called with a link the user tapped that the host app should handle.
  final void Function(Uri url) onLinkTap;

  /// Called when the WebView reports a load error (host can show retry).
  final void Function(WebResourceError error)? onWebResourceError;

  /// Called when the embed page finishes loading.
  final void Function(String url)? onPageFinished;

  /// The underlying WebView controller — pass to [HubSpotChatWebView].
  final WebViewController webViewController;

  final HubSpotChatEmbed _embed;
  static const HubSpotChatNavigationPolicy _policy =
      HubSpotChatNavigationPolicy();

  /// Configures the WebView and loads the inline chat embed. Idempotent-ish:
  /// call once when the chat surface is first shown; call again to reload.
  Future<void> load() async {
    await webViewController.setJavaScriptMode(JavaScriptMode.unrestricted);
    // Transparent so the host's background/theme shows behind the widget while
    // it loads.
    await webViewController.setBackgroundColor(const Color(0x00000000));
    await webViewController.setNavigationDelegate(
      NavigationDelegate(
        onNavigationRequest: decide,
        onWebResourceError: onWebResourceError,
        onPageFinished: onPageFinished,
      ),
    );
    await webViewController.loadHtmlString(
      _embed.buildHtml(),
      baseUrl: _embed.baseUrl,
    );
  }

  /// Reloads the embed (e.g. after a load error → user taps "Try again").
  Future<void> reload() => webViewController.loadHtmlString(
    _embed.buildHtml(),
    baseUrl: _embed.baseUrl,
  );

  @visibleForTesting
  NavigationDecision decide(NavigationRequest request) {
    switch (_policy.classify(request.url, isMainFrame: request.isMainFrame)) {
      case HubSpotNavAction.allowInWebView:
        return NavigationDecision.navigate;
      case HubSpotNavAction.delegateToHost:
        final uri = Uri.tryParse(request.url);
        if (uri != null) onLinkTap(uri);
        return NavigationDecision.prevent;
    }
  }
}
