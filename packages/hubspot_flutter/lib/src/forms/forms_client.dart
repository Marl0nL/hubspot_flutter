import '../core/hubspot_options.dart';
import '../core/http/http_client.dart';
import 'models/form_context.dart';
import 'models/form_field.dart';
import 'models/form_submission_result.dart';

/// Client for HubSpot's **client-safe** Forms submission API.
///
/// This is the one first-class customer-facing *write* path that needs no
/// secret — it creates or updates a contact (lead capture) using only the
/// public `portalId` and a `formGuid`. It targets
/// `POST {host}/submissions/v3/integration/submit/{portalId}/{formGuid}`, where
/// `{host}` is region-dependent (`api.hsforms.com` / `api-eu1.hsforms.com`).
///
/// HubSpot limits submissions to **50 requests / 10 seconds**; the core's 429
/// backoff interceptor absorbs bursts past that.
class FormsClient {
  /// Creates a Forms client. Usually obtained via `HubspotClient.forms`.
  FormsClient({
    required HubspotHttpClient http,
    required HubspotOptions options,
  }) : _http = http,
       _options = options;

  final HubspotHttpClient _http;
  final HubspotOptions _options;

  /// Submits a form.
  ///
  /// [formGuid] is the form's GUID. Provide the submitted values as [fields]
  /// (a simple `name → value` map, the common case) and/or [fieldObjects] (for
  /// advanced cases needing a per-field `objectTypeId`). [context] carries the
  /// optional tracking cookie / page metadata; [legalConsentOptions] is passed
  /// through verbatim for GDPR consent capture. [submittedAt] defaults to the
  /// current time on HubSpot's side when omitted.
  ///
  /// Returns a [FormSubmissionResult] on success; throws a
  /// [HubSpotValidationException] for a rejected submission (e.g. a required
  /// field missing) and a [HubSpotRateLimitException] once retries are
  /// exhausted.
  Future<FormSubmissionResult> submit({
    required String formGuid,
    Map<String, Object?> fields = const <String, Object?>{},
    List<FormField> fieldObjects = const <FormField>[],
    FormContext? context,
    Map<String, Object?>? legalConsentOptions,
    DateTime? submittedAt,
  }) async {
    final portalId = _options.requirePortalId();
    if (formGuid.isEmpty) {
      throw ArgumentError.value(formGuid, 'formGuid', 'must not be empty');
    }

    final allFields = <FormField>[
      ...fields.entries.map((e) => FormField(name: e.key, value: e.value)),
      ...fieldObjects,
    ];
    if (allFields.isEmpty) {
      throw ArgumentError('A form submission must include at least one field.');
    }

    final body = <String, Object?>{
      'fields': allFields.map((f) => f.toJson()).toList(growable: false),
      if (context != null && !context.isEmpty) 'context': context.toJson(),
      if (legalConsentOptions != null)
        'legalConsentOptions': legalConsentOptions,
      if (submittedAt != null)
        'submittedAt': submittedAt.toUtc().millisecondsSinceEpoch,
    };

    final url =
        'https://${_options.region.formsHost}'
        '/submissions/v3/integration/submit/'
        '${Uri.encodeComponent(portalId)}/${Uri.encodeComponent(formGuid)}';

    final response = await _http.postJson(url, data: body);
    return FormSubmissionResult.fromJson(
      response is Map<String, Object?> ? response : const <String, Object?>{},
    );
  }
}
