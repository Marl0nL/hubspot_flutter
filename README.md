# hubspot_flutter

An open-source [HubSpot](https://www.hubspot.com/) integration toolkit for **Dart & Flutter**.

hubspot_flutter is a mono-repo of focused packages. The **core is pure Dart** (no Flutter
dependency) so it runs equally on a Dart backend and inside a Flutter app; the
native chat bridge and UI widgets are kept in separate Flutter packages.

> There is no official HubSpot SDK for Dart/Flutter. hubspot_flutter aims to be the
> general-purpose client the ecosystem is missing, with a first-class,
> secret-free path for customer-facing mobile apps.

---

## ⚠️ The two-tier security model — read this first

A customer-facing mobile app **cannot** authenticate directly to HubSpot's general
APIs. The only credentials HubSpot offers — a Private App access token, or an
OAuth `client_secret` + refresh token — are **long-lived secrets**, and HubSpot
does **not** offer a PKCE / public-client OAuth flow for its general APIs. This
forces every HubSpot integration into two tiers:

### Tier 1 — client-safe (ships in the app, needs no secret)

Callable directly from a Flutter app using only a public `portalId` / `formGuid`:

| Capability | Status in this release |
|---|---|
| **Forms** submission (`api.hsforms.com`) | ✅ live |
| **Content Search v2** (published KB / blog / pages) | ✅ live |
| **Public HubDB reads** (public-access tables) | ✅ live |
| **Chat** (native iOS/Android mobile chat SDK bridge) | ✅ live (`hubspot_flutter_chat`) |

### Tier 2 — backend-mediated (requires your server; holds the secret)

Everything authenticated: all of **CRM** (objects, search, batch, associations,
properties), **Conversations Inbox & Messages**, **CMS** pages/blog/HubDB-writes,
**Files**, **Marketing**, **Webhooks**, **Site Search v3**, **KB GraphQL**, the
**OAuth** token exchange, and **visitor-identification token minting**. In this
release these ship as **documented stubs** — the full API shape is visible and
navigable, but the methods throw a clear "requires the backend tier" error.

> ## 🔒 **NEVER embed a Private App token or an OAuth `client_secret` in a shipped mobile build.**
> They are account-wide secrets. Anyone who extracts one from your binary gains
> your HubSpot account's access. Authenticated calls must go through a backend you
> control, which holds the secret and applies its own per-user authorization.

The recommended posture is **thin-client + backend-proxy (BFF)**: the app talks to
your backend for anything authenticated, and uses hubspot_flutter's secret-free
`PublicClient` directly for the Tier-1 paths above.

---

## Packages

| Package | Kind | Contents |
|---|---|---|
| [`hubspot_flutter`](packages/hubspot_flutter) | **Pure Dart** | Core HTTP client, pluggable auth, pagination, typed errors, and the client-safe REST modules (Forms, Content Search v2, public HubDB). Backend-tier modules ship as stubs. |
| [`hubspot_flutter_chat`](packages/hubspot_flutter_chat) | Flutter **plugin** | Platform-channel (Pigeon) bridge over HubSpot's native iOS & Android mobile chat SDKs. |
| [`hubspot_flutter_chat_web`](packages/hubspot_flutter_chat_web) | Flutter package | Embeds HubSpot's **browser** Conversations widget in a bounded WebView as inline, full-panel chat — the self-hosted alternative to the native SDK bridge, with a link-tap delegate the host app routes. |
| [`hubspot_flutter_forms`](packages/hubspot_flutter_forms) | Flutter package | Optional UI helpers — e.g. a drop-in HubSpot form widget built on `hubspot_flutter`'s Forms client. |

## Quick start (client-safe tier)

```dart
import 'package:hubspot_flutter/hubspot_flutter.dart';

final client = HubspotClient(
  options: const HubspotOptions(portalId: '1234567'),
  auth: const PublicClient(), // no secret — client-safe tier only
);

// Submit a form (lead capture / create-or-update contact)
await client.forms.submit(
  formGuid: 'abcd-efgh-ijkl',
  fields: {'email': 'ada@example.com', 'firstname': 'Ada'},
);

// Search published help-centre content
final results = await client.contentSearch.search(term: 'reset password');

// Read a public HubDB table
final rows = await client.hubdb.getRows('menu_items');

client.close();
```

## Development

This mono-repo uses independent, per-package resolution (it is also
[`melos`](https://melos.invertase.dev/)-ready — see `melos.yaml`).

```bash
export PATH="/path/to/flutter/bin:$PATH"

# Pure-Dart core:
cd packages/hubspot_flutter && dart pub get && dart analyze && dart test

# Flutter packages:
cd packages/hubspot_flutter_chat   && flutter pub get && flutter test
cd packages/hubspot_flutter_forms && flutter pub get && flutter test
```

## License

[MIT](LICENSE)

## Scope & design

Each package's README covers its modules in detail, including the reasoning
behind what is client-safe, what is backend-mediated, and the known limitations
of HubSpot's current APIs and mobile SDKs.
