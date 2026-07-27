import 'package:flutter/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'chat_web_controller.dart';

/// Renders the [HubSpotChatWebController]'s WebView. A thin wrapper over
/// [WebViewWidget] so the host embeds the chat in its own bounded layout region
/// (between native header/selector chrome and a bottom nav, for example).
class HubSpotChatWebView extends StatelessWidget {
  /// Creates the chat WebView for [controller].
  const HubSpotChatWebView({required this.controller, super.key});

  /// The controller whose [HubSpotChatWebController.webViewController] backs the
  /// WebView. Must have been [HubSpotChatWebController.load]ed (or will be).
  final HubSpotChatWebController controller;

  @override
  Widget build(BuildContext context) =>
      WebViewWidget(controller: controller.webViewController);
}
