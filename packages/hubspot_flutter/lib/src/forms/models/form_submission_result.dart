import 'package:meta/meta.dart';

/// The result of a successful HubSpot form submission.
///
/// HubSpot responds with either an inline thank-you message or a redirect URI,
/// depending on how the form is configured.
@immutable
class FormSubmissionResult {
  /// Creates a submission result.
  const FormSubmissionResult({this.inlineMessage, this.redirectUri, this.raw});

  /// Parses HubSpot's submit response body.
  factory FormSubmissionResult.fromJson(Map<String, Object?> json) =>
      FormSubmissionResult(
        inlineMessage: json['inlineMessage']?.toString(),
        redirectUri: json['redirectUri']?.toString(),
        raw: json,
      );

  /// The thank-you message to display, when the form uses an inline message.
  final String? inlineMessage;

  /// The URI to redirect to, when the form uses a redirect.
  final String? redirectUri;

  /// The raw response body.
  final Map<String, Object?>? raw;

  @override
  String toString() =>
      'FormSubmissionResult(inlineMessage: $inlineMessage, '
      'redirectUri: $redirectUri)';
}
