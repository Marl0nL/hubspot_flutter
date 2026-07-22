/// The kinds of published content the Content Search v2 API can return.
enum ContentSearchType {
  /// A CMS website page.
  sitePage('SITE_PAGE'),

  /// A landing page.
  landingPage('LANDING_PAGE'),

  /// A blog post.
  blogPost('BLOG_POST'),

  /// A blog listing page.
  listingPage('LISTING_PAGE'),

  /// A knowledge-base article.
  knowledgeArticle('KNOWLEDGE_ARTICLE');

  const ContentSearchType(this.wireValue);

  /// The value HubSpot expects in the `type` query parameter.
  final String wireValue;

  /// Parses a HubSpot `type` string back to an enum, or `null` if unknown.
  static ContentSearchType? tryParse(String? value) {
    if (value == null) return null;
    for (final type in ContentSearchType.values) {
      if (type.wireValue == value) return type;
    }
    return null;
  }
}
