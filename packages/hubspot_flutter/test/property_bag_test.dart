import 'package:hubspot_flutter/hubspot_flutter.dart';
import 'package:test/test.dart';

void main() {
  group('PropertyBag typed getters', () {
    final bag = PropertyBag(<String, Object?>{
      'firstname': 'Ada',
      'age': '37',
      'score': '9.5',
      'subscribed': 'true',
      'unsubscribed': 'false',
      'created': '2026-03-01T12:00:00Z',
      'created_ms': '1710000000000',
      'native_int': 42,
      'native_bool': true,
      'null_value': null,
    });

    test('getString returns strings and stringifies non-strings', () {
      expect(bag.getString('firstname'), 'Ada');
      expect(bag.getString('native_int'), '42');
      expect(bag.getString('missing'), isNull);
      expect(bag.getString('null_value'), isNull);
    });

    test('getInt parses string and native ints', () {
      expect(bag.getInt('age'), 37);
      expect(bag.getInt('native_int'), 42);
      expect(bag.getInt('firstname'), isNull);
    });

    test('getDouble parses string and native numbers', () {
      expect(bag.getDouble('score'), 9.5);
      expect(bag.getDouble('age'), 37.0);
    });

    test('getBool handles string and native booleans', () {
      expect(bag.getBool('subscribed'), isTrue);
      expect(bag.getBool('unsubscribed'), isFalse);
      expect(bag.getBool('native_bool'), isTrue);
      expect(bag.getBool('firstname'), isNull);
    });

    test('getDateTime handles ISO strings and epoch millis', () {
      expect(bag.getDateTime('created'), DateTime.utc(2026, 3, 1, 12));
      expect(
        bag.getDateTime('created_ms'),
        DateTime.fromMillisecondsSinceEpoch(1710000000000, isUtc: true),
      );
      expect(bag.getDateTime('missing'), isNull);
    });

    test('contains and keys reflect the raw bag', () {
      expect(bag.contains('null_value'), isTrue);
      expect(bag.contains('missing'), isFalse);
      expect(bag.keys, contains('firstname'));
    });

    test('is immutable', () {
      expect(() => bag.raw['x'] = 'y', throwsUnsupportedError);
    });
  });

  group('PropertyBag.toWire', () {
    test('stringifies values HubSpot-style and drops nulls', () {
      final wire = PropertyBag.toWire(<String, Object?>{
        'name': 'Ada',
        'count': 3,
        'flag': true,
        'when': DateTime.utc(2026, 1, 2, 3, 4, 5),
        'skip': null,
      });
      expect(wire, <String, String>{
        'name': 'Ada',
        'count': '3',
        'flag': 'true',
        'when': '2026-01-02T03:04:05.000Z',
      });
      expect(wire.containsKey('skip'), isFalse);
    });
  });
}
