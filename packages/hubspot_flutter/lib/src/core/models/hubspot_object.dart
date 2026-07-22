import 'package:meta/meta.dart';

import 'property_bag.dart';

/// A generic HubSpot CRM-style record: an id plus a sparse [PropertyBag] and
/// the standard system timestamps.
///
/// This is the shared shape returned by CRM object endpoints. Those endpoints
/// are backend-mediated and ship as stubs in this release, but the model is
/// part of the core so the eventual typed clients (and any hand-rolled backend
/// code) have a common value type to build on.
@immutable
class HubSpotObject {
  /// Creates a HubSpot object record.
  const HubSpotObject({
    required this.id,
    required this.properties,
    this.createdAt,
    this.updatedAt,
    this.archived = false,
    this.associations = const <String, List<String>>{},
  });

  /// Parses a HubSpot object envelope
  /// (`{ "id": ..., "properties": {...}, "createdAt": ..., ... }`).
  factory HubSpotObject.fromJson(Map<String, Object?> json) {
    final props = json['properties'];
    return HubSpotObject(
      id: json['id']?.toString() ?? '',
      properties: PropertyBag(
        props is Map<String, Object?> ? props : const <String, Object?>{},
      ),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? ''),
      archived: json['archived'] == true,
    );
  }

  /// The record's HubSpot object id.
  final String id;

  /// The record's properties.
  final PropertyBag properties;

  /// When the record was created, if returned.
  final DateTime? createdAt;

  /// When the record was last updated, if returned.
  final DateTime? updatedAt;

  /// Whether the record is archived.
  final bool archived;

  /// Associated record ids by association type, when expanded.
  final Map<String, List<String>> associations;

  @override
  String toString() => 'HubSpotObject(id: $id, properties: $properties)';
}
