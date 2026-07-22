import '../core/hubspot_options.dart';
import '../core/http/http_client.dart';
import '../core/models/paging.dart';
import '../core/pagination/paginator.dart';
import 'models/hubdb_row.dart';
import 'models/hubdb_table.dart';

/// Client for **client-safe, read-only** public HubDB access.
///
/// `GET {apiBaseUrl}/cms/v3/hubdb/tables/{tableIdOrName}/rows?portalId=` reads
/// the **published** rows of a table that has "Allow public API access" turned
/// on — no auth, only the public `portalId`. This is ideal for secret-free
/// structured content in an app (menus, FAQs, feature flags, ...).
///
/// Writes and draft access are backend-mediated and out of scope here (see the
/// HubDB stub).
class HubDbClient {
  /// Creates a HubDB client. Usually obtained via `HubspotClient.hubdb`.
  HubDbClient({
    required HubspotHttpClient http,
    required HubspotOptions options,
  }) : _http = http,
       _options = options;

  final HubspotHttpClient _http;
  final HubspotOptions _options;

  /// Reads a single page of rows from [tableIdOrName].
  ///
  /// [limit] caps the page size, [after] resumes from a cursor, [sort] applies
  /// server-side ordering (e.g. `['name', '-created_at']`), and [filters] adds
  /// column filters using HubDB's `column__operator` query syntax
  /// (e.g. `{'price__gt': 10}`). Filter keys cannot override the reserved
  /// `portalId` / `limit` / `after` / `sort` parameters.
  Future<Page<HubDbRow>> getRows(
    String tableIdOrName, {
    int? limit,
    String? after,
    List<String> sort = const <String>[],
    Map<String, Object?> filters = const <String, Object?>{},
  }) async {
    final portalId = _options.requirePortalId();
    final query = <String, Object?>{
      ...filters,
      'portalId': portalId,
      if (limit != null) 'limit': limit,
      if (after != null) 'after': after,
      if (sort.isNotEmpty) 'sort': sort,
    };
    final url =
        '${_options.apiBaseUrl}/cms/v3/hubdb/tables/'
        '${Uri.encodeComponent(tableIdOrName)}/rows';
    final response = await _http.getJson(url, query: query);
    return Page<HubDbRow>.fromJson(
      response is Map<String, Object?> ? response : const <String, Object?>{},
      HubDbRow.fromJson,
    );
  }

  /// Reads every row of [tableIdOrName], auto-paging via the `paging.next.after`
  /// cursor and yielding rows lazily.
  Stream<HubDbRow> getAllRows(
    String tableIdOrName, {
    int? pageSize,
    List<String> sort = const <String>[],
    Map<String, Object?> filters = const <String, Object?>{},
  }) => autoPaginate<HubDbRow>(
    (after) => getRows(
      tableIdOrName,
      limit: pageSize,
      after: after,
      sort: sort,
      filters: filters,
    ),
  );

  /// Reads a single row by id from [tableIdOrName].
  Future<HubDbRow> getRow(String tableIdOrName, String rowId) async {
    final portalId = _options.requirePortalId();
    final url =
        '${_options.apiBaseUrl}/cms/v3/hubdb/tables/'
        '${Uri.encodeComponent(tableIdOrName)}/rows/${Uri.encodeComponent(rowId)}';
    final response = await _http.getJson(
      url,
      query: <String, Object?>{'portalId': portalId},
    );
    return HubDbRow.fromJson(
      response is Map<String, Object?> ? response : const <String, Object?>{},
    );
  }

  /// Reads a table's metadata (columns, row count) for [tableIdOrName].
  Future<HubDbTable> getTable(String tableIdOrName) async {
    final portalId = _options.requirePortalId();
    final url =
        '${_options.apiBaseUrl}/cms/v3/hubdb/tables/'
        '${Uri.encodeComponent(tableIdOrName)}';
    final response = await _http.getJson(
      url,
      query: <String, Object?>{'portalId': portalId},
    );
    return HubDbTable.fromJson(
      response is Map<String, Object?> ? response : const <String, Object?>{},
    );
  }
}
