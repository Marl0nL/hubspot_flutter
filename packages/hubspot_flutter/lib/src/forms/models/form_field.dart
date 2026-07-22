import 'package:meta/meta.dart';

/// A single field in a HubSpot form submission.
///
/// Most callers can ignore this type and pass a plain `Map<String, Object?>` to
/// [FormsClient.submit]; use [FormField] directly only when you need to target a
/// non-contact object ([objectTypeId]) for a given field.
@immutable
class FormField {
  /// Creates a form field with a HubSpot property [name] and its [value].
  const FormField({required this.name, required this.value, this.objectTypeId});

  /// The HubSpot property internal name (e.g. `email`, `firstname`).
  final String name;

  /// The submitted value. Lists are joined with `;` (HubSpot's multi-value
  /// convention); other values are stringified.
  final Object? value;

  /// The CRM object type id this field maps to (e.g. `0-1` contact). Omit for
  /// the form's default object.
  final String? objectTypeId;

  /// The wire representation HubSpot's submit endpoint expects.
  Map<String, Object?> toJson() => <String, Object?>{
    'name': name,
    'value': _encodeValue(value),
    if (objectTypeId != null) 'objectTypeId': objectTypeId,
  };

  static String _encodeValue(Object? value) {
    if (value == null) return '';
    if (value is Iterable) return value.map((e) => e.toString()).join(';');
    return value.toString();
  }
}
