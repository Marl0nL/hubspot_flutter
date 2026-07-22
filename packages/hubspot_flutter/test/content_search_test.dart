import 'package:dio/dio.dart';
import 'package:hubspot_flutter/hubspot_flutter.dart';
import 'package:test/test.dart';

import 'support/scripted_adapter.dart';

HubspotClient buildClient(ScriptedAdapter adapter) {
  final dio = Dio()..httpClientAdapter = adapter;
  return HubspotClient(
    options: const HubspotOptions(portalId: '1234567'),
    auth: const PublicClient(),
    dio: dio,
  );
}

void main() {
  group('ContentSearchClient.search', () {
    test('parses results and passes query params', () async {
      final adapter = ScriptedAdapter.single(
        jsonResponse(200, loadJsonFixture('content_search_page1.json')),
      );
      final client = buildClient(adapter);

      final page = await client.contentSearch.search(
        term: 'password',
        types: [ContentSearchType.knowledgeArticle, ContentSearchType.blogPost],
        limit: 2,
      );

      expect(page.total, 3);
      expect(page.results, hasLength(2));
      expect(page.hasMore, isTrue);
      expect(page.nextOffset, 2);

      final first = page.results.first;
      expect(first.type, ContentSearchType.knowledgeArticle);
      expect(first.title, 'How to reset your password');
      expect(first.url, 'https://help.example.com/kb/reset-password');
      expect(first.score, 12.5);
      expect(
        first.publishedAt,
        DateTime.fromMillisecondsSinceEpoch(1710000000000, isUtc: true),
      );

      final request = adapter.received.single;
      expect(request.uri.path, '/contentsearch/v2/search');
      expect(request.uri.queryParameters['portalId'], '1234567');
      expect(request.uri.queryParameters['term'], 'password');
      expect(request.uri.queryParametersAll['type'], [
        'KNOWLEDGE_ARTICLE',
        'BLOG_POST',
      ]);
      client.close();
    });

    test('searchAll pages through offsets to yield every result', () async {
      final adapter = ScriptedAdapter(<MockResponse>[
        jsonResponse(200, loadJsonFixture('content_search_page1.json')),
        jsonResponse(200, loadJsonFixture('content_search_page2.json')),
      ]);
      final client = buildClient(adapter);

      final all = await client.contentSearch
          .searchAll(term: 'password', pageSize: 2)
          .toList();

      expect(all.map((r) => r.id), ['1001', '1002', '1003']);
      expect(adapter.callCount, 2);
      // Second request advanced the offset.
      expect(adapter.received[1].uri.queryParameters['offset'], '2');
      client.close();
    });

    test('unknown content type parses to null but keeps raw', () {
      final result = ContentSearchResult.fromJson(<String, Object?>{
        'id': '9',
        'type': 'FUTURE_TYPE',
        'title': 'x',
      });
      expect(result.type, isNull);
      expect(result.raw['type'], 'FUTURE_TYPE');
    });
  });
}
