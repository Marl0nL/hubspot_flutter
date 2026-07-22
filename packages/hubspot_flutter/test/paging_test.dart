import 'package:hubspot_flutter/hubspot_flutter.dart';
import 'package:test/test.dart';

void main() {
  group('Page.fromJson', () {
    test('parses results and next cursor', () {
      final page = Page<Map<String, Object?>>.fromJson(<String, Object?>{
        'results': [
          {'id': '1'},
          {'id': '2'},
        ],
        'paging': {
          'next': {'after': 'CURSOR2', 'link': 'https://x/y?after=CURSOR2'},
        },
      }, (json) => json);
      expect(page.results, hasLength(2));
      expect(page.hasMore, isTrue);
      expect(page.nextAfter, 'CURSOR2');
      expect(page.paging?.next?.link, contains('CURSOR2'));
    });

    test('treats a missing paging.next as the last page', () {
      final page = Page<Map<String, Object?>>.fromJson(<String, Object?>{
        'results': [
          {'id': '1'},
        ],
        'paging': <String, Object?>{},
      }, (json) => json);
      expect(page.hasMore, isFalse);
      expect(page.nextAfter, isNull);
    });
  });

  group('autoPaginate', () {
    test('walks every page until the cursor runs out', () async {
      final pages = <Page<int>>[
        const Page<int>(
          results: [1, 2],
          paging: Paging(next: PagingRef(after: 'a1')),
        ),
        const Page<int>(
          results: [3, 4],
          paging: Paging(next: PagingRef(after: 'a2')),
        ),
        const Page<int>(results: [5]),
      ];
      final seenCursors = <String?>[];

      final items = await autoPaginate<int>((after) async {
        seenCursors.add(after);
        return pages[seenCursors.length - 1];
      }).toList();

      expect(items, [1, 2, 3, 4, 5]);
      expect(seenCursors, [null, 'a1', 'a2']);
    });

    test('stops early when the consumer takes fewer items', () async {
      var fetches = 0;
      final stream = autoPaginate<int>((after) async {
        fetches++;
        return Page<int>(
          results: [fetches],
          paging: Paging(next: PagingRef(after: 'next$fetches')),
        );
      });

      final first = await stream.take(2).toList();
      expect(first, [1, 2]);
      // Lazy: only two pages fetched despite an endless cursor.
      expect(fetches, 2);
    });

    test('guards against a repeating cursor', () async {
      var fetches = 0;
      final items = await autoPaginate<int>((after) async {
        fetches++;
        return const Page<int>(
          results: [1],
          paging: Paging(next: PagingRef(after: 'STUCK')),
        );
      }, startAfter: 'STUCK').toList();
      // First fetch uses startAfter 'STUCK', next cursor is also 'STUCK' -> stop.
      expect(fetches, 1);
      expect(items, [1]);
    });

    test('honours maxPages', () async {
      var fetches = 0;
      final items = await autoPaginate<int>((after) async {
        fetches++;
        return Page<int>(
          results: [fetches],
          paging: Paging(next: PagingRef(after: 'c$fetches')),
        );
      }, maxPages: 3).toList();
      expect(fetches, 3);
      expect(items, [1, 2, 3]);
    });
  });

  group('collectPages', () {
    test('collects up to a limit', () async {
      final items = await collectPages<int>((after) async {
        final start = after == null ? 0 : int.parse(after);
        return Page<int>(
          results: [start, start + 1],
          paging: Paging(next: PagingRef(after: '${start + 2}')),
        );
      }, limit: 5);
      expect(items, [0, 1, 2, 3, 4]);
    });
  });
}
