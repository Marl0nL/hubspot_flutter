// Pigeon interface definitions for the hubspot_flutter chat bridge.
//
// Run code generation from the package root with:
//   flutter pub get
//   dart run pigeon --input pigeons/messages.dart
//
// The generated files (lib/src/messages.g.dart, android/.../Messages.g.kt,
// ios/Classes/Messages.g.swift) are committed and must be regenerated whenever
// this file changes.
import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/messages.g.dart',
    dartOptions: DartOptions(),
    kotlinOut:
        'android/src/main/kotlin/io/github/marl0nl/hubspot_flutter_chat/Messages.g.kt',
    kotlinOptions: KotlinOptions(
      package: 'io.github.marl0nl.hubspot_flutter_chat',
    ),
    swiftOut:
        'ios/hubspot_flutter_chat/Sources/hubspot_flutter_chat/Messages.g.swift',
    swiftOptions: SwiftOptions(),
    dartPackageName: 'hubspot_flutter_chat',
  ),
)
/// Configuration for the HubSpot mobile chat SDK.
class ChatSetupData {
  ChatSetupData({
    required this.portalId,
    this.hublet,
    this.defaultChatFlow,
    this.environment,
    this.enableLogging = false,
  });

  /// The public HubSpot portal / Hub ID.
  String portalId;

  /// The HubSpot hublet (data-hosting region), e.g. `na1` / `eu1`.
  String? hublet;

  /// The default chatflow to open when none is specified.
  String? defaultChatFlow;

  /// The HubSpot environment (`PROD` by default).
  String? environment;

  /// Whether to enable verbose native SDK logging.
  bool enableLogging;
}

/// A visitor identity for authenticated chat.
///
/// The [identityToken] is minted **server-side** via
/// `POST /visitor-identification/v3/tokens/create`; the client only consumes it.
class VisitorIdentity {
  VisitorIdentity({required this.email, required this.identityToken});

  /// The visitor's email address.
  String email;

  /// The server-minted visitor-identification token.
  String identityToken;
}

/// Dart -> native calls.
@HostApi()
abstract class HubspotChatHostApi {
  /// Initialises the native HubSpot chat SDK. Must be called before any other
  /// method.
  @async
  void configure(ChatSetupData setup);

  /// Presents the chat UI, optionally targeting a specific [chatFlow].
  @async
  void openChat(String? chatFlow);

  /// Dismisses the chat UI if it is visible.
  @async
  void closeChat();

  /// Associates the current session with an identified visitor.
  @async
  void setUserIdentity(VisitorIdentity identity);

  /// Sets custom chat properties attached to subsequent conversations.
  @async
  void setChatProperties(Map<String, String> properties);

  /// Registers the device push token (FCM on Android, APNs on iOS) so HubSpot
  /// can deliver chat push notifications.
  @async
  void setPushToken(String token);

  /// Asks the native SDK whether it recognises and will handle a push payload.
  /// Returns true if the payload was a HubSpot chat notification.
  @async
  bool handlePushNotification(Map<String, String> data);

  /// Clears the identified visitor and cached conversation state.
  @async
  void logout();
}

/// Native -> Dart callbacks (chat events).
///
/// NOTE: neither native SDK (Android com.hubspot.mobilesdk 1.0.x, iOS
/// HubspotMobileSDK 1.0.x) exposes an unread-message-count observer, so no
/// `onUnreadCountChanged` event is declared — it would be dead on both
/// platforms. Add it back only once the SDKs expose such an observer.
@FlutterApi()
abstract class HubspotChatFlutterApi {
  /// A new inbound chat message arrived. Fired on both platforms when a HubSpot
  /// chat push is handed to `handlePushNotification` (Android gates on
  /// `HubspotManager.isHubspotNotification`).
  void onNewMessage();

  /// The chat UI was presented.
  void onChatOpened();

  /// The chat UI was dismissed. **iOS only** — the Android SDK opens chat as a
  /// separate Activity with no close callback, so Android never fires this.
  void onChatClosed();
}
