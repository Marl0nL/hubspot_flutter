import 'package:meta/meta.dart';

import '../../core/models/property_bag.dart';

/// A single row from a HubDB table.
///
/// Cell values live in [values], keyed by column name. Unlike CRM property
/// bags, HubDB values arrive already typed (numbers as numbers, etc.), but
/// [values] still wraps them in a [PropertyBag] so the same typed getters work.
@immutable
class HubDbRow {
  /// Creates a HubDB row.
  const HubDbRow({
    required this.id,
    required this.values,
    this.path,
    this.name,
    this.createdAt,
    this.updatedAt,
    this.childTableId,
  });

  /// Parses a HubDB row object.
  factory HubDbRow.fromJson(Map<String, Object?> json) {
    final rawValues = json['values'];
    return HubDbRow(
      id: json['id']?.toString() ?? '',
      values: PropertyBag(
        rawValues is Map<String, Object?>
            ? rawValues
            : const <String, Object?>{},
      ),
      path: json['path']?.toString(),
      name: json['name']?.toString(),
      childTableId: json['childTableId']?.toString(),
      createdAt: switch (json['createdAt']) {
        final num ms => DateTime.fromMillisecondsSinceEpoch(
          ms.toInt(),
          isUtc: true,
        ),
        final String s => DateTime.tryParse(s),
        _ => null,
      },
      updatedAt: switch (json['updatedAt']) {
        final num ms => DateTime.fromMillisecondsSinceEpoch(
          ms.toInt(),
          isUtc: true,
        ),
        final String s => DateTime.tryParse(s),
        _ => null,
      },
    );
  }

  /// The row id.
  final String id;

  /// The cell values keyed by column name.
  final PropertyBag values;

  /// The row's page path, for dynamic-page tables.
  final String? path;

  /// The row's page name, for dynamic-page tables.
  final String? name;

  /// When the row was created, if returned.
  final DateTime? createdAt;

  /// When the row was last updated, if returned.
  final DateTime? updatedAt;

  /// The id of a child table, for hierarchical tables.
  final String? childTableId;

  @override
  String toString() => 'HubDbRow(id: $id, values: $values)';
}
