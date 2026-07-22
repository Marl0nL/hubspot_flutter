import 'package:meta/meta.dart';

import 'content_search_result.dart';

/// One page of Content Search v2 results.
///
/// Content Search v2 pages with `offset`/`limit` (not cursors), and reports the
/// full [total] so callers can page through or show a count.
@immutable
class ContentSearchResponse {
  /// Creates a response page.
  const ContentSearchResponse({
    required this.results,
    required this.total,
    required this.offset,
    required this.limit,
  });

  /// Parses the search envelope.
  factory ContentSearchResponse.fromJson(Map<String, Object?> json) {
    final rawResults = (json['results'] as List<Object?>? ?? const [])
        .whereType<Map<String, Object?>>()
        .map(ContentSearchResult.fromJson)
        .toList(growable: false);
    return ContentSearchResponse(
      results: rawResults,
      total: (json['total'] as num?)?.toInt() ?? rawResults.length,
      offset: (json['offset'] as num?)?.toInt() ?? 0,
      limit: (json['limit'] as num?)?.toInt() ?? rawResults.length,
    );
  }

  /// The hits on this page.
  final List<ContentSearchResult> results;

  /// The total number of matching items across all pages.
  final int total;

  /// The offset this page started at.
  final int offset;

  /// The page size requested.
  final int limit;

  /// Whether another page is available after this one.
  bool get hasMore => offset + results.length < total;

  /// The offset to request for the next page.
  int get nextOffset => offset + results.length;
}
