import 'package:meta/meta.dart';

/// One cursor page of a HubSpot collection response.
///
/// HubSpot collection endpoints share the shape:
/// ```json
/// { "results": [ ... ], "paging": { "next": { "after": "...", "link": "..." } } }
/// ```
/// [Page] models exactly that envelope. When [paging] (or `paging.next`) is
/// absent, the current page is the last one.
@immutable
class Page<T> {
  /// Creates a page from already-parsed [results] and an optional [paging]
  /// envelope.
  const Page({required this.results, this.paging});

  /// Parses a raw HubSpot collection envelope, mapping each result with
  /// [fromJson]. [resultsKey] overrides the `results` array key for the few
  /// endpoints that name it differently.
  factory Page.fromJson(
    Map<String, Object?> json,
    T Function(Map<String, Object?>) fromJson, {
    String resultsKey = 'results',
  }) {
    final rawResults = (json[resultsKey] as List<Object?>? ?? const [])
        .whereType<Map<String, Object?>>()
        .map(fromJson)
        .toList(growable: false);
    final rawPaging = json['paging'];
    return Page<T>(
      results: rawResults,
      paging: rawPaging is Map<String, Object?>
          ? Paging.fromJson(rawPaging)
          : null,
    );
  }

  /// The items on this page.
  final List<T> results;

  /// The paging envelope, if the response included one.
  final Paging? paging;

  /// The cursor to pass as `after` to fetch the next page, or `null` if this is
  /// the last page.
  String? get nextAfter => paging?.next?.after;

  /// Whether another page is available.
  bool get hasMore => nextAfter != null;
}

/// The `paging` object of a HubSpot collection response.
@immutable
class Paging {
  /// Creates a paging envelope.
  const Paging({this.next, this.prev});

  /// Parses a raw `paging` object.
  factory Paging.fromJson(Map<String, Object?> json) => Paging(
    next: switch (json['next']) {
      final Map<String, Object?> n => PagingRef.fromJson(n),
      _ => null,
    },
    prev: switch (json['prev']) {
      final Map<String, Object?> p => PagingRef.fromJson(p),
      _ => null,
    },
  );

  /// The forward cursor, present when more results are available.
  final PagingRef? next;

  /// The backward cursor, present on endpoints that support it.
  final PagingRef? prev;
}

/// A single cursor reference within a [Paging] envelope.
@immutable
class PagingRef {
  /// Creates a cursor reference.
  const PagingRef({required this.after, this.link, this.before});

  /// Parses a raw cursor reference.
  factory PagingRef.fromJson(Map<String, Object?> json) => PagingRef(
    after: json['after']?.toString() ?? '',
    before: json['before']?.toString(),
    link: json['link']?.toString(),
  );

  /// The opaque cursor to pass back as the `after` query parameter.
  final String after;

  /// The cursor for the previous page, when present.
  final String? before;

  /// A fully-formed URL for the page, when HubSpot provides one.
  final String? link;
}
