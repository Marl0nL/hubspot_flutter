import '../models/paging.dart';

/// Signature for a function that fetches a single [Page] given a cursor.
///
/// [after] is `null` for the first page and the previous page's
/// [Page.nextAfter] thereafter.
typedef PageFetcher<T> = Future<Page<T>> Function(String? after);

/// Lazily walks HubSpot cursor pagination, yielding each item across all pages.
///
/// HubSpot collection endpoints page with an opaque `paging.next.after` cursor
/// and signal the end by omitting `paging.next`. [autoPaginate] hides that loop
/// behind a normal [Stream]:
///
/// ```dart
/// await for (final row in autoPaginate(client.hubdb.fetchRowPage(tableId))) {
///   print(row);
/// }
/// ```
///
/// Pages are fetched on demand as the stream is consumed, so a caller that
/// `.take(n)`s will only fetch as many pages as needed.
///
/// [startAfter] resumes from a known cursor. [maxPages] caps the number of HTTP
/// requests as a safety valve (0 or negative means unbounded). A page whose
/// `next` cursor repeats the current one terminates the stream to avoid an
/// infinite loop on a misbehaving endpoint.
Stream<T> autoPaginate<T>(
  PageFetcher<T> fetchPage, {
  String? startAfter,
  int maxPages = 0,
}) async* {
  String? after = startAfter;
  var pagesFetched = 0;
  while (true) {
    final page = await fetchPage(after);
    pagesFetched++;
    for (final item in page.results) {
      yield item;
    }
    final next = page.nextAfter;
    if (next == null || next == after) break;
    if (maxPages > 0 && pagesFetched >= maxPages) break;
    after = next;
  }
}

/// Collects up to [limit] items from an [autoPaginate] stream (or all of them
/// when [limit] is `null`).
Future<List<T>> collectPages<T>(
  PageFetcher<T> fetchPage, {
  int? limit,
  String? startAfter,
  int maxPages = 0,
}) async {
  final out = <T>[];
  await for (final item in autoPaginate(
    fetchPage,
    startAfter: startAfter,
    maxPages: maxPages,
  )) {
    out.add(item);
    if (limit != null && out.length >= limit) break;
  }
  return out;
}
