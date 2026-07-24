# hubspot_flutter_chat_web

Embed HubSpot's **browser** Conversations chat widget inside a bounded Flutter
`WebView` — an inline, full-panel chat you host in your own app chrome.

This is the supported, self-hosted alternative to
[`hubspot_flutter_chat`](../hubspot_flutter_chat) (the native mobile-SDK bridge).
The native SDK opens a full-screen, HubSpot-owned Activity you cannot embed or
intercept. Here the chat is the HubSpot browser widget inside a WebView **you**
own, so you can:

- wrap it in your own native header / tab / selector chrome (the WebView is just
  the content region);
- intercept the links the widget emits (KB deflection articles, external links)
  and route them however you like;
- keep it anonymous with only the public `portalId`.

It is **HubSpot-generic**: it knows how to load the widget and which navigations
are the widget's own machinery, and it hands every other link tap back to your
app via a callback. It has no knowledge of any specific app, theme, or routing.

## Usage

```dart
final controller = HubSpotChatWebController(
  config: const HubSpotChatWebConfig(
    portalId: '3445699',
    hublet: 'ap1',
    // Which chatflow appears is decided by HubSpot targeting rules against this
    // origin — set it to the site whose targeting should apply.
    hostUrl: 'https://help.example.com',
  ),
  // A link the user tapped that leaves the widget — YOU decide what to do.
  onLinkTap: (url) {
    // e.g. open a KB article in-app if it's yours, else launch a browser.
  },
  onWebResourceError: (err) {/* show a retry affordance */},
);
await controller.load();

// The WebView is just the content region; your header/nav stay native.
HubSpotChatWebView(controller: controller);
```

Keep the controller alive (a long-lived provider or a retained `State`) so the
WebView — and thus the open chat socket and the anonymous thread — survives
in-app navigation.

## Inline (full-panel) vs floating bubble

The embed sets `hsConversationsSettings.inlineEmbedSelector`, which renders the
widget **inline** inside a container element (filling the bounded WebView),
instead of the default floating launcher bubble, and calls
`HubSpotConversations.widget.load()` on ready so chat opens with no user gesture.

## Chatflow selection

The browser widget does **not** let you force a chatflow by name from
JavaScript. Which chatflow appears is decided by the **targeting rules** you
configure in HubSpot, matched against the page URL (`hostUrl`). The `chatflow`
config field is bookkeeping only.

## Thread persistence (anonymous)

An anonymous conversation is keyed to HubSpot's `messagesUtk` visitor cookie
(set on HubSpot's domains). The platform WebView persists cookies across app
restarts on Android, so the thread survives automatically — there is no
save/restore to call. `HubSpotChatWebCookies.clear()` drops the store to start a
fresh thread.

## Identified chat

Anonymous chat needs no backend. To identify a logged-in user, mint a
visitor-identification token **on your backend** (never in the app) and supply it
to the widget — see `hubspot_flutter`'s `VisitorIdentificationStub`. That is an
additive step and orthogonal to this package.

## Testing

The valuable logic is pure and exhaustively unit-tested:
`HubSpotChatEmbed` (the HTML/loader) and `HubSpotChatNavigationPolicy` (the
allow/delegate decision). `HubSpotChatWebController` takes an injectable
`WebViewController` so the wiring stays testable.

```
flutter test
```
