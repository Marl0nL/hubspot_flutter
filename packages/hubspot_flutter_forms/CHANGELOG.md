# Changelog

## 0.1.0

Initial release.

- `HubSpotForm` — a drop-in widget that renders fields from
  `HubSpotFormFieldSpec`s (text / email / phone / multiline / checkbox), handles
  validation, submits via the client-safe Forms API, and shows the loading
  state plus HubSpot's inline message or a typed error.
- Re-exports the `hubspot_flutter` core so a Flutter app can depend on just this
  package.
- 5 widget tests covering rendering, validation, submission and error display.
- `example/` demonstrating a contact form built with `HubSpotForm`.

