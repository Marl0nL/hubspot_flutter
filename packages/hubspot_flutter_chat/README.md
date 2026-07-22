# hubspot_flutter_chat

A Flutter plugin that bridges HubSpot's **native iOS & Android mobile chat SDKs**
to Flutter via type-safe [Pigeon](https://pub.dev/packages/pigeon) platform
channels. Part of the [hubspot_flutter](https://github.com/Marl0nL/hubspot_flutter)
toolkit.

HubSpot ships no Flutter chat SDK — only native SDKs. `hubspot_flutter_chat` wraps them
in a clean Dart API so a Flutter app gets live chat, bots, KB deflection and
push, with no HubSpot secret in the app (chat is client-safe by design).

## Dart API

```dart
import 'package:hubspot_flutter_chat/hubspot_flutter_chat.dart';

final chat = HubspotChat.instance;

await chat.configure(const HubspotChatConfig(
  portalId: '1234567',
  defaultChatFlow: 'support',
));

// Optional: identify a logged-in visitor.
await chat.setUserIdentity(email: 'ada@example.com', identityToken: token);

await chat.open();                         // present the chat UI
chat.onNewMessage.listen((_) => refresh());  // react to events
await chat.logout();                          // clear on sign-out
```

Events are exposed as broadcast streams: `onNewMessage` and
`onVisibilityChanged`.

> **Event caveats (be honest with your UI):**
> * There is **no unread-count stream** — neither the Android nor iOS HubSpot
>   SDK (1.0.x) exposes an unread-message-count observer, so it would be dead.
> * `onVisibilityChanged` emits `true` (opened) on both platforms but `false`
>   (closed) on **iOS only** — the Android SDK opens chat as a separate Activity
>   with no close callback.

### ⚠️ Visitor-identification token is minted server-side

`setUserIdentity` takes a token your **backend** mints via
`POST /visitor-identification/v3/tokens/create` (it needs a secret scope).
This package **accepts** that token; it does **not** mint it. Never mint it in
the app.

## Native setup

### Android

The HubSpot Android SDK reads its config from
`android/app/src/main/assets/hubspot-info.json`. Create it (see
`example/android/app/src/main/assets/hubspot-info.json.example`):

```json
{ "portalId": "1234567", "hublet": "na1", "environment": "PROD", "defaultChatFlow": "support" }
```

The plugin declares the SDK dependency
(`com.hubspot.mobilechatsdk:mobile-chat-sdk-android`) itself; `minSdk` must be
**≥ 26**.

Push (optional): register your FCM service, forward the token via
`chat.setPushToken(token)`, and on message call
`chat.handlePushNotification(data)`. On **Android** this returns `true` only for
genuine HubSpot chat pushes (via `HubspotManager.isHubspotNotification`) and
emits `onNewMessage`.

### iOS

HubSpot's iOS SDK is distributed via **Swift Package Manager only**, so iOS
integration requires Flutter's SPM support (the default for new iOS projects).
The plugin's `ios/hubspot_flutter_chat/Package.swift` declares
`HubSpot/mobile-chat-sdk-ios`. Add your HubSpot config file to the app bundle per
HubSpot's iOS guide. Pass the APNs device token (hex-encoded) to
`chat.setPushToken(...)`.

> ⚠️ **`handlePushNotification` is Android-authoritative only.** On iOS the SDK
> (1.0.x) exposes no "is this push ours" check, so the plugin returns a
> conservative `false` for every payload and emits no event — do not use its
> iOS return value to gate your own push handling (it would never suppress).
> Integrate HubSpot chat pushes on iOS via HubSpot's AppDelegate flow. This
> becomes authoritative once the iOS SDK adds detection. *(iOS behaviour is
> unverified here — needs an on-device/macOS build.)*

## Architecture

```
Dart  HubspotChat  ──(Pigeon HostApi)──►  Kotlin HubspotChatPlugin ─► com.hubspot.mobilesdk
      ▲  streams    ◄─(Pigeon FlutterApi)─  Swift  HubspotChatPlugin ─► HubspotMobileSDK
```

Regenerate the channel code after editing `pigeons/messages.dart`:

```bash
flutter pub get
dart run pigeon --input pigeons/messages.dart
```

## SDK versions

Android pins `com.hubspot.mobilechatsdk:mobile-chat-sdk-android:1.0.7` and iOS
pins `HubSpot/mobile-chat-sdk-ios` exactly `1.0.7`, kept aligned. HubSpot ships
the two platforms on independent cadences (Android is currently further ahead at
1.0.9); bump both together when the iOS SDK advances.

## Status / verification

- ✅ Dart method-channel layer: 11 unit tests (`flutter test`), mocked host API.
- ✅ Android native: compiles against HubSpot SDK 1.0.7 (`gradlew
  :hubspot_flutter_chat:compileDebugKotlin`); the example builds (`flutter build apk`).
- ⏳ iOS native: written against the SDK's documented Swift API; **not compiled**
  here (needs macOS/Xcode). Items needing an on-device/macOS build: the exact
  iOS SDK method signatures, `handlePushNotification` behaviour, the iOS
  deployment target (declared `13.0`; the SDK may require a higher minimum such
  as 15/16 — confirm and raise if needed), and APNs hex→Data decoding.
- ⏳ End-to-end chat requires a device build with a real HubSpot portal.

## License

[MIT](LICENSE)
