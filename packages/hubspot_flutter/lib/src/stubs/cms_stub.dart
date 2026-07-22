import '../core/errors/hubspot_exception.dart';
import '../core/models/paging.dart';

/// **STUB — backend tier.** Authenticated CMS management: pages, blog, HubDB
/// writes, Site Search v3 and Knowledge Base GraphQL.
///
/// The client-safe reads (Content Search v2, public HubDB reads) live in their
/// own live clients. Everything here needs the broad `content` scope (or the KB
/// GraphQL scopes) and a secret, so it is backend-only. Every method throws
/// [HubSpotUnimplementedError].
class CmsStub {
  /// Internal — constructed by `HubspotClient`.
  const CmsStub();

  /// Website + landing pages.
  CmsPagesStub get pages => const CmsPagesStub._();

  /// Blog posts, authors and tags.
  CmsBlogStub get blog => const CmsBlogStub._();

  /// Authenticated HubDB writes / drafts / publish.
  HubDbWriteStub get hubdb => const HubDbWriteStub._();

  /// Token-gated Site Search v3 (no public `portalId` option — unlike the
  /// client-safe Content Search v2).
  SiteSearchV3Stub get siteSearch => const SiteSearchV3Stub._();

  /// Knowledge Base via GraphQL (`POST /collector/graphql`).
  KnowledgeBaseGraphQLStub get knowledgeBase =>
      const KnowledgeBaseGraphQLStub._();
}

/// **STUB — backend tier.** CMS site + landing pages.
class CmsPagesStub {
  const CmsPagesStub._();

  /// `GET /cms/v3/pages/site-pages`.
  Future<Page<Map<String, Object?>>> listSitePages({
    int? limit,
    String? after,
  }) => throw HubSpotUnimplementedError('CMS listSitePages');

  /// `GET /cms/v3/pages/landing-pages`.
  Future<Page<Map<String, Object?>>> listLandingPages({
    int? limit,
    String? after,
  }) => throw HubSpotUnimplementedError('CMS listLandingPages');

  /// `POST /cms/v3/pages/site-pages`.
  Future<Map<String, Object?>> createSitePage(Map<String, Object?> page) =>
      throw HubSpotUnimplementedError('CMS createSitePage');
}

/// **STUB — backend tier.** CMS blog.
class CmsBlogStub {
  const CmsBlogStub._();

  /// `GET /cms/v3/blogs/posts`.
  Future<Page<Map<String, Object?>>> listPosts({int? limit, String? after}) =>
      throw HubSpotUnimplementedError('CMS blog listPosts');

  /// `GET /cms/v3/blogs/authors`.
  Future<Page<Map<String, Object?>>> listAuthors({int? limit, String? after}) =>
      throw HubSpotUnimplementedError('CMS blog listAuthors');

  /// `GET /cms/v3/blogs/tags`.
  Future<Page<Map<String, Object?>>> listTags({int? limit, String? after}) =>
      throw HubSpotUnimplementedError('CMS blog listTags');
}

/// **STUB — backend tier.** Authenticated HubDB writes.
class HubDbWriteStub {
  const HubDbWriteStub._();

  /// `POST /cms/v3/hubdb/tables/{id}/rows/draft`.
  Future<Map<String, Object?>> createRow(
    String tableIdOrName,
    Map<String, Object?> values,
  ) => throw HubSpotUnimplementedError('HubDB createRow');

  /// `PATCH /cms/v3/hubdb/tables/{id}/rows/{rowId}/draft`.
  Future<Map<String, Object?>> updateRow(
    String tableIdOrName,
    String rowId,
    Map<String, Object?> values,
  ) => throw HubSpotUnimplementedError('HubDB updateRow');

  /// `DELETE /cms/v3/hubdb/tables/{id}/rows/{rowId}/draft`.
  Future<void> deleteRow(String tableIdOrName, String rowId) =>
      throw HubSpotUnimplementedError('HubDB deleteRow');

  /// `POST /cms/v3/hubdb/tables/{id}/draft/publish`.
  Future<void> publish(String tableIdOrName) =>
      throw HubSpotUnimplementedError('HubDB publish');
}

/// **STUB — backend tier.** Token-gated Site Search v3.
class SiteSearchV3Stub {
  const SiteSearchV3Stub._();

  /// `GET /cms/v3/site-search/search` (requires the `content` scope).
  Future<Map<String, Object?>> search({
    required String q,
    List<String> type = const [],
    int? limit,
    int? offset,
  }) => throw HubSpotUnimplementedError('Site Search v3');
}

/// **STUB — backend tier.** Knowledge Base via GraphQL.
class KnowledgeBaseGraphQLStub {
  const KnowledgeBaseGraphQLStub._();

  /// `POST /collector/graphql` — run a GraphQL query against KB data.
  Future<Map<String, Object?>> query(
    String graphqlQuery, {
    Map<String, Object?> variables = const {},
  }) => throw HubSpotUnimplementedError('Knowledge Base GraphQL');
}
