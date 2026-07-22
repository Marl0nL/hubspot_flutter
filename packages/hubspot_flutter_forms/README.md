# hubspot_flutter_forms

Flutter UI helpers for [hubspot_flutter](https://github.com/Marl0nL/hubspot_flutter).

Currently ships **`HubSpotForm`** — a drop-in widget that makes "add a HubSpot
form to the app" a few lines. It renders fields, validates them, submits via the
client-safe Forms API (no secret required), and shows the result.

## Usage

```dart
import 'package:hubspot_flutter_forms/hubspot_flutter_forms.dart';

final client = HubspotClient(
  options: const HubspotOptions(portalId: '1234567'),
  auth: const PublicClient(),
);

HubSpotForm(
  client: client,
  formGuid: 'abcd-efgh-ijkl',
  submitLabel: 'Sign up',
  fields: const [
    HubSpotFormFieldSpec(
      name: 'email',
      label: 'Email',
      type: HubSpotFieldType.email,
      required: true,
    ),
    HubSpotFormFieldSpec(name: 'firstname', label: 'First name'),
    HubSpotFormFieldSpec(
      name: 'consent',
      label: 'I agree to be contacted',
      type: HubSpotFieldType.checkbox,
      required: true,
    ),
  ],
  onSuccess: (result) => debugPrint(result.inlineMessage),
  onError: (error) => debugPrint('Failed: ${error.message}'),
);
```

Field types: `text`, `email`, `phone`, `multiline`, `checkbox`. `required` and a
custom `validator` are supported per field. On success the widget shows
HubSpot's returned inline message; on failure it shows the error and calls
`onError` with the typed `HubSpotException`.

For anything more elaborate, call `client.forms.submit(...)` from the core and
build your own UI.

## Notes

- This package re-exports the `hubspot_flutter` core (so you can depend on just this
  package), **hiding** the core's `FormField` model to avoid a clash with
  Flutter's `FormField` widget. Import `package:hubspot_flutter/hubspot_flutter.dart` directly
  if you need that model.
- It uses a mono-repo `path` dependency on `hubspot_flutter` and is marked
  `publish_to: none` for now; switch to a hosted version before publishing.

## License

[MIT](LICENSE)
