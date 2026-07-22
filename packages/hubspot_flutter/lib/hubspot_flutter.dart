/// hubspot_flutter — a pure-Dart HubSpot client.
///
/// This library exposes the core (HTTP client, pluggable auth, pagination,
/// typed errors, shared models) and the **client-safe** REST modules (Forms,
/// Content Search v2, public HubDB reads). Backend-tier modules are present as
/// documented stubs. See the package README for the two-tier security model.
library;

// Core
export 'src/core/hubspot_client.dart';
export 'src/core/hubspot_options.dart' show HubspotOptions, packageVersion;
export 'src/core/http/http_client.dart' show HubspotHttpClient;
export 'src/core/http/interceptors/rate_limit_interceptor.dart'
    show RateLimitInterceptor, BackoffStrategy;

// Auth
export 'src/core/auth/auth_provider.dart';
export 'src/core/auth/public_client.dart';
export 'src/core/auth/bearer_token_provider.dart';
export 'src/core/auth/oauth_client.dart';
export 'src/core/auth/proxy_auth.dart';

// Errors
export 'src/core/errors/hubspot_exception.dart';

// Pagination
export 'src/core/pagination/paginator.dart';

// Shared models
export 'src/core/models/hubspot_region.dart';
export 'src/core/models/hubspot_object.dart';
export 'src/core/models/property_bag.dart';
export 'src/core/models/paging.dart';

// Client-safe modules
export 'src/forms/forms_client.dart';
export 'src/forms/models/form_field.dart';
export 'src/forms/models/form_context.dart';
export 'src/forms/models/form_submission_result.dart';

export 'src/content_search/content_search_client.dart';
export 'src/content_search/models/content_search_type.dart';
export 'src/content_search/models/content_search_result.dart';
export 'src/content_search/models/content_search_response.dart';

export 'src/hubdb/hubdb_client.dart';
export 'src/hubdb/models/hubdb_row.dart';
export 'src/hubdb/models/hubdb_table.dart';

// Backend-tier stubs (documented; throw HubSpotUnimplementedError)
export 'src/stubs/crm_stub.dart';
export 'src/stubs/conversations_stub.dart';
export 'src/stubs/cms_stub.dart';
export 'src/stubs/files_stub.dart';
export 'src/stubs/marketing_stub.dart';
export 'src/stubs/webhooks_stub.dart';
