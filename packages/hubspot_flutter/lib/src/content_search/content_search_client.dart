import '../core/hubspot_options.dart';
import '../core/http/http_client.dart';
import 'models/content_search_response.dart';
import 'models/content_search_result.dart';
import 'models/content_search_type.dart';

/// Client for HubSpot's **client-safe** Content Search v2 API.
///
/// `GET {apiBaseUrl}/contentsearch/v2/search?portalId=&term=&type=` — full-text
/// search and retrieval of **published** knowledge-base articles, blog posts and
/// pages. It needs no auth, only the public `portalId`, which makes it the
/// correct way to render in-app help-centre content directly from a Flutter app.
///
/// > **Legacy-but-current.** v2 is the only public (`portalId`-based) content
/// > search endpoint; HubSpot's newer Site Search v3 is token-gated. Treat v2 as
/// > "works today, legacy": pin it and monitor for deprecation. If it is ever
/// > retired, in-app help search must move behind the backend proxy (v3).
class ContentSearchClient {
  /// Creates a Content Search client. Usually obtained via
  /// `HubspotClient.contentSearch`.
  ContentSearchClient({
    required HubspotHttpClient http,
    required HubspotOptions options,
  }) : _http = http,
       _options = options;

  final HubspotHttpClient _http;
  final HubspotOptions _options;

  /// Runs a single search and returns one page of results.
  ///
  /// [term] is the query. [types] restricts to specific content types (all
  /// types when empty). [limit]/[offset] control paging; [language] and
  /// [domain] narrow the corpus when set.
  Future<ContentSearchResponse> search({
    required String term,
    List<ContentSearchType> types = const <ContentSearchType>[],
    int limit = 10,
    int offset = 0,
    String? language,
    String? domain,
  }) async {
    final portalId = _options.requirePortalId();
    final query = <String, Object?>{
      'portalId': portalId,
      'term': term,
      'limit': limit,
      'offset': offset,
      if (types.isNotEmpty)
        'type': types.map((t) => t.wireValue).toList(growable: false),
      if (language != null) 'language': language,
      if (domain != null) 'domain': domain,
    };

    final url = '${_options.apiBaseUrl}/contentsearch/v2/search';
    final response = await _http.getJson(url, query: query);
    return ContentSearchResponse.fromJson(
      response is Map<String, Object?> ? response : const <String, Object?>{},
    );
  }

  /// Searches and yields every matching result across pages, fetching pages of
  /// [pageSize] lazily as the stream is consumed (respecting the search corpus'
  /// reported total).
  Stream<ContentSearchResult> searchAll({
    required String term,
    List<ContentSearchType> types = const <ContentSearchType>[],
    int pageSize = 20,
    String? language,
    String? domain,
  }) async* {
    var offset = 0;
    while (true) {
      final page = await search(
        term: term,
        types: types,
        limit: pageSize,
        offset: offset,
        language: language,
        domain: domain,
      );
      for (final result in page.results) {
        yield result;
      }
      if (!page.hasMore || page.results.isEmpty) break;
      offset = page.nextOffset;
    }
  }
}
