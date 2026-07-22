import 'package:meta/meta.dart';

/// A sparse, string-keyed bag of HubSpot object properties.
///
/// HubSpot returns object properties as a flat map in which:
///
/// * only the properties you asked for (or that have values) are present —
///   the bag is *sparse*, so a missing key is normal, not an error; and
/// * values arrive as **strings** over the wire, even for numbers, booleans and
///   timestamps.
///
/// [PropertyBag] wraps the raw map and layers typed getters on top so callers
/// don't hand-parse strings everywhere. Every getter returns `null` when the
/// key is absent or cannot be parsed, matching the sparse reality of the data.
@immutable
class PropertyBag {
  /// Wraps [raw] (an unmodifiable copy is taken so the bag stays immutable).
  PropertyBag(Map<String, Object?> raw)
    : _raw = Map<String, Object?>.unmodifiable(raw);

  /// An empty bag.
  factory PropertyBag.empty() => PropertyBag(const <String, Object?>{});

  final Map<String, Object?> _raw;

  /// The underlying raw property map (unmodifiable).
  Map<String, Object?> get raw => _raw;

  /// All property keys present in the bag.
  Iterable<String> get keys => _raw.keys;

  /// Whether [key] is present (even if its value is `null`).
  bool contains(String key) => _raw.containsKey(key);

  /// The raw, untyped value for [key].
  Object? operator [](String key) => _raw[key];

  /// The value for [key] as a `String`, or `null` if absent/null.
  String? getString(String key) {
    final value = _raw[key];
    if (value == null) return null;
    return value is String ? value : value.toString();
  }

  /// The value for [key] parsed as an `int`, or `null` if absent/unparseable.
  int? getInt(String key) {
    final value = _raw[key];
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  /// The value for [key] parsed as a `double`, or `null` if absent/unparseable.
  double? getDouble(String key) {
    final value = _raw[key];
    if (value == null) return null;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  /// The value for [key] interpreted as a `bool`, or `null` if absent.
  ///
  /// HubSpot booleans arrive as the strings `"true"`/`"false"`.
  bool? getBool(String key) {
    final value = _raw[key];
    if (value == null) return null;
    if (value is bool) return value;
    final text = value.toString().toLowerCase();
    if (text == 'true') return true;
    if (text == 'false') return false;
    return null;
  }

  /// The value for [key] parsed as a `DateTime`, or `null` if absent/unparseable.
  ///
  /// Accepts ISO-8601 strings and epoch-millisecond values, both of which
  /// HubSpot uses for timestamp properties.
  DateTime? getDateTime(String key) {
    final value = _raw[key];
    if (value == null) return null;
    if (value is DateTime) return value;
    final epochMillis = getInt(key);
    // Heuristic: a value that is purely numeric is an epoch-millis timestamp.
    if (epochMillis != null && num.tryParse(value.toString()) != null) {
      return DateTime.fromMillisecondsSinceEpoch(epochMillis, isUtc: true);
    }
    return DateTime.tryParse(value.toString());
  }

  /// Builds a HubSpot-shaped property map from typed values, stringifying each
  /// value the way HubSpot's write endpoints expect.
  static Map<String, String> toWire(Map<String, Object?> properties) {
    final result = <String, String>{};
    properties.forEach((key, value) {
      if (value == null) return;
      if (value is DateTime) {
        result[key] = value.toUtc().toIso8601String();
      } else if (value is bool) {
        result[key] = value ? 'true' : 'false';
      } else {
        result[key] = value.toString();
      }
    });
    return result;
  }

  @override
  String toString() => 'PropertyBag($_raw)';
}
