import 'package:meta/meta.dart';

import 'content_search_type.dart';

/// A single hit from Content Search v2.
///
/// HubSpot returns a loosely-typed record whose exact fields vary by content
/// [type]. The commonly-present fields are surfaced typed; everything is kept
/// in [raw] for the long tail.
@immutable
class ContentSearchResult {
  /// Creates a result.
  const ContentSearchResult({
    required this.id,
    required this.raw,
    this.type,
    this.title,
    this.url,
    this.description,
    this.featuredImageUrl,
    this.language,
    this.domain,
    this.score,
    this.publishedAt,
  });

  /// Parses one result object.
  factory ContentSearchResult.fromJson(Map<String, Object?> json) {
    final published = json['publishedDate'] ?? json['publishDate'];
    return ContentSearchResult(
      id: json['id']?.toString() ?? '',
      type: ContentSearchType.tryParse(json['type']?.toString()),
      title: json['title']?.toString(),
      url: json['url']?.toString(),
      description: (json['description'] ?? json['metaDescription'])?.toString(),
      featuredImageUrl: json['featuredImageUrl']?.toString(),
      language: json['language']?.toString(),
      domain: json['domain']?.toString(),
      score: switch (json['score']) {
        final num n => n.toDouble(),
        _ => null,
      },
      publishedAt: switch (published) {
        final num ms => DateTime.fromMillisecondsSinceEpoch(
          ms.toInt(),
          isUtc: true,
        ),
        final String s => DateTime.tryParse(s),
        _ => null,
      },
      raw: json,
    );
  }

  /// The content id.
  final String id;

  /// The content type, when recognised.
  final ContentSearchType? type;

  /// The content title.
  final String? title;

  /// The public URL of the content.
  final String? url;

  /// A short description / meta description.
  final String? description;

  /// The featured image URL, when present.
  final String? featuredImageUrl;

  /// The content language code (e.g. `en`).
  final String? language;

  /// The domain the content is published on.
  final String? domain;

  /// The relevance score HubSpot assigned to this hit.
  final double? score;

  /// When the content was published, when present.
  final DateTime? publishedAt;

  /// The raw result object, for fields not surfaced above.
  final Map<String, Object?> raw;

  @override
  String toString() =>
      'ContentSearchResult(id: $id, type: $type, title: $title)';
}
