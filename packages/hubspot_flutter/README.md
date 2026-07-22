# hubspot_flutter

The **pure-Dart** core of [hubspot_flutter](https://github.com/Marl0nL/hubspot_flutter),
an open-source HubSpot client for Dart & Flutter.

This package has **no Flutter dependency**, so it runs on a Dart backend as well
as inside a Flutter app. Native chat (`hubspot_flutter_chat`) and UI widgets
(`hubspot_flutter_forms`) live in sibling packages.

## What's live vs stubbed

hubspot_flutter enforces HubSpot's **two-tier** reality (see the repo root README):

- **Client-safe tier — LIVE.** No secret required, safe to ship in an app:
  **Forms**, **Content Search v2**, **public HubDB reads**.
- **Backend tier — STUBS.** Everything authenticated (CRM, Conversations, CMS
  management, Files, Marketing, Webhooks, OAuth, visitor-ID minting) is present
  as a documented API that throws `HubSpotUnimplementedError`. This makes the
  full intended surface visible while keeping only the secret-free parts callable.

> ## 🔒 Never embed a Private App token or OAuth `client_secret` in a shipped mobile build.
> Those are account-wide secrets. Authenticated calls belong behind a backend
> proxy. The only client-safe auth strategy is `PublicClient`.

## Install

```yaml
dependencies:
  hubspot_flutter: ^0.1.0
```

## Usage

```dart
import 'package:hubspot_flutter/hubspot_flutter.dart';

final client = HubspotClient(
  options: const HubspotOptions(portalId: '1234567'),
  auth: const PublicClient(),
);

// 1. Forms — lead capture / create-or-update a contact
final result = await client.forms.submit(
  formGuid: 'abcd-efgh',
  fields: {'email': 'ada@example.com', 'firstname': 'Ada'},
  context: const FormContext(pageName: 'Signup'),
);
print(result.inlineMessage);

// 2. Content Search v2 — published help-centre content
final page = await client.contentSearch.search(
  term: 'reset password',
  types: [ContentSearchType.knowledgeArticle],
);
for (final hit in page.results) {
  print('${hit.title} -> ${hit.url}');
}

// 3. Public HubDB — read a public-access table, auto-paged
await for (final row in client.hubdb.getAllRows('menu_items')) {
  print(row.values.getString('name'));
}

client.close();
```

### Error handling

Every failure is a typed `HubSpotException`:

```dart
try {
  await client.forms.submit(formGuid: 'g', fields: {'email': 'bad'});
} on HubSpotValidationException catch (e) {
  print('Invalid: ${e.validationErrors}');
} on HubSpotRateLimitException catch (e) {
  print('Rate limited, retry after ${e.retryAfter}');
} on HubSpotException catch (e) {
  print('HubSpot error (${e.category}): ${e.message}');
}
```

429s (and transient 5xx) are retried automatically with exponential backoff.

### Sparse property bags

HubSpot returns object properties as a sparse map of **strings**. `PropertyBag`
layers typed getters on top:

```dart
row.values.getString('name');   // String?
row.values.getDouble('price');   // double?
row.values.getBool('in_stock');  // bool?
row.values.getDateTime('added'); // DateTime? (ISO-8601 or epoch millis)
```

## Regions

EU accounts submit forms to `api-eu1.hsforms.com`. Set it via options:

```dart
HubspotOptions(portalId: '...', region: HubSpotRegion.eu);
```

## Notes on longevity

Content Search v2 is the only public (`portalId`-based) content-search endpoint;
it is **legacy-but-current**. Pin it and monitor for deprecation — if retired,
in-app help search must move behind the backend proxy (Site Search v3).

## Testing

```bash
dart pub get
dart analyze
dart test
```

Tests run fully offline against recorded JSON fixtures using a scripted Dio
adapter. No real tokens are ever used.

## License

[MIT](LICENSE)
