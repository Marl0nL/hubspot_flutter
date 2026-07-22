# Changelog

## 0.1.0

Initial release — the pure-Dart core and the client-safe REST modules.

### Live (client-safe tier)

- **Core**
  - Dio-based HTTP client with a pluggable auth layer.
  - `PublicClient` (no-auth, client-safe) fully implemented.
  - Typed `HubSpotException` hierarchy (auth / validation / not-found /
    rate-limit / server / network / unimplemented).
  - Cursor-pagination helpers (`autoPaginate`, `collectPages`) over
    `paging.next.after`.
  - Rate-limit / 429 (+ transient 5xx) backoff retry interceptor.
  - Shared models: `PropertyBag` (sparse, string-valued property bags with
    typed getters), `Page`/`Paging` envelope, `HubSpotObject`, `HubSpotRegion`.
  - `HubspotClient(requireClientSafe: true)` opt-in guard that rejects a
    secret-bearing auth provider up front (for mobile builds).
  - Runnable `example/` covering all three client-safe calls.
- **Forms** — client-safe submission to `api.hsforms.com` (NA/EU), typed result
  and errors.
- **Content Search v2** — published KB / blog / page search, offset paging,
  `searchAll` streaming.
- **Public HubDB reads** — read-only rows/tables for public-access tables, with
  cursor auto-paging.

### Stubs (backend tier — throw `HubSpotUnimplementedError`)

- `BearerTokenProvider`, `OAuthClient`, `ProxyAuth` auth seams.
- CRM (objects / search / batch / associations / properties).
- Conversations Inbox & Messages, custom channels, visitor-identification token
  minting.
- CMS pages / blog / HubDB writes, Site Search v3, Knowledge Base GraphQL.
- Files, Marketing, Webhooks.

