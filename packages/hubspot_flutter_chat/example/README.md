# hubspot_flutter_chat example

A minimal Flutter app demonstrating the `hubspot_flutter_chat` plugin: configure the
HubSpot chat bridge, open the chat UI, and observe the event streams.

## Run it

1. Create `android/app/src/main/assets/hubspot-info.json` from the adjacent
   `hubspot-info.json.example`, filling in your own HubSpot portal ID (the
   native HubSpot SDK reads its configuration from that file).
2. `flutter run` on an Android device/emulator (API 26+).

iOS requires a macOS build with Flutter's Swift Package Manager support and the
HubSpot config file added to the app bundle — see the package README.
