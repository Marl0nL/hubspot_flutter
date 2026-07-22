import 'package:flutter/widgets.dart';

/// The kind of input to render for a [HubSpotFormFieldSpec].
enum HubSpotFieldType {
  /// A single-line text input.
  text,

  /// An email input (keyboard + basic email validation).
  email,

  /// A phone-number input.
  phone,

  /// A multi-line text area.
  multiline,

  /// A boolean checkbox (submitted as `"true"` / `"false"`).
  checkbox,
}

/// Describes one field to render in a [HubSpotForm].
///
/// [name] must be the HubSpot property internal name (e.g. `email`,
/// `firstname`) — it becomes the submitted field key.
@immutable
class HubSpotFormFieldSpec {
  /// Creates a field spec.
  const HubSpotFormFieldSpec({
    required this.name,
    required this.label,
    this.type = HubSpotFieldType.text,
    this.required = false,
    this.hint,
    this.initialValue,
    this.validator,
  });

  /// The HubSpot property internal name (the submitted key).
  final String name;

  /// The human-readable label shown above the input.
  final String label;

  /// The input type to render.
  final HubSpotFieldType type;

  /// Whether the field must be filled before submission.
  final bool required;

  /// Optional placeholder/hint text.
  final String? hint;

  /// Optional initial value.
  final String? initialValue;

  /// Optional extra validator, run after the built-in required/email checks.
  /// Returns an error string, or `null` when valid.
  final String? Function(String? value)? validator;
}
