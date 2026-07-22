import 'package:meta/meta.dart';

/// Optional contextual metadata for a form submission.
///
/// Supplying [hutk] (the `hubspotutk` tracking cookie, when your app has one)
/// lets HubSpot stitch the submission to an existing visitor and enables the
/// analytics/attribution features of forms.
@immutable
class FormContext {
  /// Creates a submission context. All fields are optional.
  const FormContext({this.hutk, this.pageUri, this.pageName, this.ipAddress});

  /// The `hubspotutk` cookie value identifying the visitor, if available.
  final String? hutk;

  /// The URI of the page the form was submitted from.
  final String? pageUri;

  /// A human-readable page/screen name.
  final String? pageName;

  /// The visitor's IP address (only meaningful from a server context).
  final String? ipAddress;

  /// Whether any field is set (an all-null context is omitted from the body).
  bool get isEmpty =>
      hutk == null && pageUri == null && pageName == null && ipAddress == null;

  /// The wire representation.
  Map<String, Object?> toJson() => <String, Object?>{
    if (hutk != null) 'hutk': hutk,
    if (pageUri != null) 'pageUri': pageUri,
    if (pageName != null) 'pageName': pageName,
    if (ipAddress != null) 'ipAddress': ipAddress,
  };
}
