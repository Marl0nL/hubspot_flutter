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
  group('HubDbClient.getRows', () {
    test('parses a page with typed cell values and a cursor', () async {
      final adapter = ScriptedAdapter.single(
        jsonResponse(200, loadJsonFixture('hubdb_rows_page1.json')),
      );
      final client = buildClient(adapter);

      final page = await client.hubdb.getRows(
        'menu',
        limit: 2,
        sort: ['name'],
        filters: {'price__gt': 3},
      );

      expect(page.results, hasLength(2));
      expect(page.hasMore, isTrue);
      expect(page.nextAfter, '7002');

      final espresso = page.results.first;
      expect(espresso.id, '7001');
      expect(espresso.values.getString('name'), 'Espresso');
      expect(espresso.values.getDouble('price'), 3.5);
      expect(espresso.values.getBool('in_stock'), isTrue);
      expect(espresso.values.getInt('calories'), 5);

      final request = adapter.received.single;
      expect(request.uri.path, '/cms/v3/hubdb/tables/menu/rows');
      expect(request.uri.queryParameters['portalId'], '1234567');
      expect(request.uri.queryParameters['limit'], '2');
      expect(request.uri.queryParameters['price__gt'], '3');
      expect(request.uri.queryParametersAll['sort'], ['name']);
      client.close();
    });

    test('getAllRows follows the cursor across pages', () async {
      final adapter = ScriptedAdapter(<MockResponse>[
        jsonResponse(200, loadJsonFixture('hubdb_rows_page1.json')),
        jsonResponse(200, loadJsonFixture('hubdb_rows_page2.json')),
      ]);
      final client = buildClient(adapter);

      final rows = await client.hubdb.getAllRows('menu').toList();
      expect(rows.map((r) => r.id), ['7001', '7002', '7003']);
      expect(adapter.callCount, 2);
      expect(adapter.received[1].uri.queryParameters['after'], '7002');
      client.close();
    });

    test('getRow reads a single row', () async {
      final adapter = ScriptedAdapter.single(
        jsonResponse(200, {
          'id': '7001',
          'values': {'name': 'Espresso'},
        }),
      );
      final client = buildClient(adapter);
      final row = await client.hubdb.getRow('menu', '7001');
      expect(row.id, '7001');
      expect(row.values.getString('name'), 'Espresso');
      expect(
        adapter.received.single.uri.path,
        '/cms/v3/hubdb/tables/menu/rows/7001',
      );
      client.close();
    });

    test('percent-encodes the table name and row id in the path', () async {
      final adapter = ScriptedAdapter(<MockResponse>[
        jsonResponse(200, {'results': <Object?>[]}),
        jsonResponse(200, {'id': '1', 'values': <String, Object?>{}}),
      ]);
      final client = buildClient(adapter);

      await client.hubdb.getRows('menu items/specials?x=1');
      await client.hubdb.getRow('menu', 'a/b');

      expect(
        adapter.received[0].uri.path,
        '/cms/v3/hubdb/tables/menu%20items%2Fspecials%3Fx%3D1/rows',
      );
      expect(
        adapter.received[1].uri.path,
        '/cms/v3/hubdb/tables/menu/rows/a%2Fb',
      );
      client.close();
    });

    test('filters cannot override the reserved query parameters', () async {
      final adapter = ScriptedAdapter.single(
        jsonResponse(200, {'results': <Object?>[]}),
      );
      final client = buildClient(adapter);

      await client.hubdb.getRows(
        'menu',
        limit: 5,
        filters: {'portalId': 'evil', 'limit': 999, 'price__gt': 3},
      );

      final params = adapter.received.single.uri.queryParameters;
      expect(params['portalId'], '1234567');
      expect(params['limit'], '5');
      expect(params['price__gt'], '3');
      client.close();
    });

    test('getTable parses columns', () async {
      final adapter = ScriptedAdapter.single(
        jsonResponse(200, {
          'id': '42',
          'name': 'menu',
          'label': 'Menu',
          'rowCount': 3,
          'columns': [
            {'name': 'name', 'label': 'Name', 'type': 'TEXT'},
            {'name': 'price', 'label': 'Price', 'type': 'NUMBER'},
          ],
        }),
      );
      final client = buildClient(adapter);
      final table = await client.hubdb.getTable('menu');
      expect(table.name, 'menu');
      expect(table.rowCount, 3);
      expect(table.columns.map((c) => c.name), ['name', 'price']);
      expect(table.columns.last.type, 'NUMBER');
      client.close();
    });
  });
}
