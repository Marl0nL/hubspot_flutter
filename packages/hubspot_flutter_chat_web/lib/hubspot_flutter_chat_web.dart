/// Embed HubSpot's browser Conversations chat widget inside a bounded Flutter
/// WebView — an inline, full-panel chat you host in your own app chrome.
///
/// This is the supported, self-hosted alternative to `hubspot_flutter_chat` (the
/// native mobile-SDK bridge, which opens a full-screen HubSpot-owned Activity you
/// cannot embed or intercept). Here the chat is the HubSpot browser widget inside
/// a WebView YOU own, so you can wrap it in native chrome and intercept the links
/// it emits.
///
/// The package is HubSpot-generic: it knows how to load the widget and which
/// navigations are the widget's own machinery, and it hands every other link tap
/// back to the host via a callback — it has no knowledge of any specific app,
/// theme, or link-routing scheme.
library;

export 'src/chat_web_config.dart';
export 'src/chat_web_controller.dart';
export 'src/chat_web_cookies.dart';
export 'src/chat_web_embed.dart';
export 'src/chat_web_navigation.dart';
export 'src/chat_web_view.dart';
