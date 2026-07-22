# Changelog

## 0.1.0

Initial release — the native chat bridge.

- Type-safe platform channel generated with **Pigeon** (`HubspotChatHostApi`
  / `HubspotChatFlutterApi`), covering Dart, Kotlin and Swift.
- High-level `HubspotChat` Dart API: `configure`, `open`/`close`,
  `setUserIdentity`, `setChatProperties`, `setPushToken`,
  `handlePushNotification`, `logout`, plus `onNewMessage` and
  `onVisibilityChanged` event streams.
- **Android** implementation bridging `com.hubspot.mobilesdk` (artifact
  `com.hubspot.mobilechatsdk:mobile-chat-sdk-android:1.0.7`) — verified to
  compile, and the example builds (`flutter build apk`).
- **iOS** implementation bridging `HubspotMobileSDK` via Swift Package Manager
  (`HubSpot/mobile-chat-sdk-ios`, pinned to `1.0.7` for cross-platform parity).
- 11 Dart unit tests covering the method-channel layer with a mocked host API.
- Example app (Android) demonstrating configure + open.

### Known limitations (honest scope for 1.0.x SDKs)

- **No unread-count event.** Neither native SDK exposes an unread-count
  observer, so no such stream is offered (removed to avoid advertising a dead
  capability).
- **`onVisibilityChanged` close is iOS-only.** The Android SDK opens chat as a
  separate Activity with no close callback, so Android emits only the "opened"
  event.
- **`handlePushNotification` is Android-authoritative.** Android returns `true`
  only for genuine HubSpot pushes; iOS returns a conservative `false` (the iOS
  SDK exposes no detection API) and needs on-device wiring.
- iOS native code (method signatures, deployment target, push, APNs decoding)
  is written against the documented SDK API but **not compiled** here — verify
  on a macOS/device build.

> The visitor-identification token passed to `setUserIdentity` must be minted
> **server-side**; this package only consumes it.
