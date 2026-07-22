import 'package:meta/meta.dart';

/// Metadata for a HubDB table (the subset useful for read-only clients).
@immutable
class HubDbTable {
  /// Creates a table descriptor.
  const HubDbTable({
    required this.id,
    required this.name,
    required this.columns,
    this.label,
    this.rowCount,
    this.raw = const <String, Object?>{},
  });

  /// Parses a HubDB table object.
  factory HubDbTable.fromJson(Map<String, Object?> json) => HubDbTable(
    id: json['id']?.toString() ?? '',
    name: json['name']?.toString() ?? '',
    label: json['label']?.toString(),
    rowCount: (json['rowCount'] as num?)?.toInt(),
    columns: (json['columns'] as List<Object?>? ?? const [])
        .whereType<Map<String, Object?>>()
        .map(HubDbColumn.fromJson)
        .toList(growable: false),
    raw: json,
  );

  /// The table id.
  final String id;

  /// The table's internal name.
  final String name;

  /// The table's human-readable label.
  final String? label;

  /// The number of published rows, when reported.
  final int? rowCount;

  /// The table's column definitions.
  final List<HubDbColumn> columns;

  /// The raw table object.
  final Map<String, Object?> raw;
}

/// A HubDB column definition.
@immutable
class HubDbColumn {
  /// Creates a column definition.
  const HubDbColumn({required this.name, this.label, this.type});

  /// Parses a column object.
  factory HubDbColumn.fromJson(Map<String, Object?> json) => HubDbColumn(
    name: json['name']?.toString() ?? '',
    label: json['label']?.toString(),
    type: json['type']?.toString(),
  );

  /// The column's internal name (the key used in [HubDbRow.values]).
  final String name;

  /// The column's human-readable label.
  final String? label;

  /// The column's HubDB type (`TEXT`, `NUMBER`, `DATE`, `SELECT`, ...).
  final String? type;
}
