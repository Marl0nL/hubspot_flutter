// Hide the core's `FormField` submission model so Flutter's `FormField` widget
// (used below for the checkbox) is unambiguous. Callers who need the core model
// can import `package:hubspot_flutter/hubspot_flutter.dart` directly.
import 'package:hubspot_flutter/hubspot_flutter.dart' hide FormField;
import 'package:flutter/material.dart';

import 'hubspot_form_field.dart';

final RegExp _emailRegExp = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

/// A drop-in widget that renders a simple HubSpot form and submits it via the
/// client-safe Forms API.
///
/// This is the "add a form to the app easily" helper: give it a [client], a
/// [formGuid] and a list of [fields], and it handles rendering, validation,
/// the submit call, loading state, and success/error display.
///
/// ```dart
/// HubSpotForm(
///   client: client,
///   formGuid: 'abcd-efgh',
///   fields: const [
///     HubSpotFormFieldSpec(name: 'email', label: 'Email',
///         type: HubSpotFieldType.email, required: true),
///     HubSpotFormFieldSpec(name: 'firstname', label: 'First name'),
///   ],
///   onSuccess: (result) => print(result.inlineMessage),
/// )
/// ```
///
/// For anything beyond a basic form, call [FormsClient.submit] directly and
/// build your own UI.
class HubSpotForm extends StatefulWidget {
  /// Creates a HubSpot form widget.
  const HubSpotForm({
    required this.client,
    required this.formGuid,
    required this.fields,
    this.formContext,
    this.submitLabel = 'Submit',
    this.onSuccess,
    this.onError,
    this.showInlineMessage = true,
    super.key,
  });

  /// The hubspot_flutter client used to submit (typically backed by a [PublicClient]).
  final HubspotClient client;

  /// The HubSpot form GUID to submit to.
  final String formGuid;

  /// The fields to render, in order.
  final List<HubSpotFormFieldSpec> fields;

  /// Optional HubSpot submission context (tracking cookie / page metadata).
  final FormContext? formContext;

  /// Label for the submit button.
  final String submitLabel;

  /// Called with the result after a successful submission.
  final void Function(FormSubmissionResult result)? onSuccess;

  /// Called with the error after a failed submission.
  final void Function(HubSpotException error)? onError;

  /// Whether to render HubSpot's returned inline thank-you message on success.
  final bool showInlineMessage;

  @override
  State<HubSpotForm> createState() => _HubSpotFormState();
}

class _HubSpotFormState extends State<HubSpotForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers =
      <String, TextEditingController>{};
  final Map<String, bool> _checkboxes = <String, bool>{};

  bool _submitting = false;
  String? _successMessage;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    for (final field in widget.fields) {
      if (field.type == HubSpotFieldType.checkbox) {
        _checkboxes[field.name] = field.initialValue == 'true';
      } else {
        _controllers[field.name] = TextEditingController(
          text: field.initialValue,
        );
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  String? _validate(HubSpotFormFieldSpec field, String? value) {
    final text = value?.trim() ?? '';
    if (field.required && text.isEmpty) {
      return '${field.label} is required';
    }
    if (field.type == HubSpotFieldType.email &&
        text.isNotEmpty &&
        !_emailRegExp.hasMatch(text)) {
      return 'Enter a valid email address';
    }
    return field.validator?.call(value);
  }

  Future<void> _submit() async {
    setState(() {
      _successMessage = null;
      _errorMessage = null;
    });
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final values = <String, Object?>{};
    for (final field in widget.fields) {
      if (field.type == HubSpotFieldType.checkbox) {
        values[field.name] = _checkboxes[field.name] ?? false;
      } else {
        final text = _controllers[field.name]?.text.trim() ?? '';
        if (text.isNotEmpty) values[field.name] = text;
      }
    }

    setState(() => _submitting = true);
    try {
      final result = await widget.client.forms.submit(
        formGuid: widget.formGuid,
        fields: values,
        context: widget.formContext,
      );
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _successMessage = result.inlineMessage;
      });
      widget.onSuccess?.call(result);
    } on HubSpotException catch (error) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _errorMessage = error.message;
      });
      widget.onError?.call(error);
    } catch (error) {
      // e.g. an ArgumentError from FormsClient (no non-empty fields). Recover
      // the UI rather than leaving the button stuck in the submitting state.
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _errorMessage = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (final field in widget.fields) _buildField(field),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _submitting ? null : _submit,
            child: _submitting
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(widget.submitLabel),
          ),
          if (widget.showInlineMessage && _successMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                _successMessage!,
                key: const Key('hubspot_form_success'),
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                _errorMessage!,
                key: const Key('hubspot_form_error'),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildField(HubSpotFormFieldSpec field) {
    if (field.type == HubSpotFieldType.checkbox) {
      return FormField<bool>(
        initialValue: _checkboxes[field.name],
        validator: (value) => field.required && !(value ?? false)
            ? '${field.label} is required'
            : field.validator?.call(value == true ? 'true' : 'false'),
        builder: (state) => CheckboxListTile(
          key: Key('hubspot_field_${field.name}'),
          contentPadding: EdgeInsets.zero,
          title: Text(field.label),
          subtitle: state.hasError
              ? Text(
                  state.errorText!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                )
              : null,
          value: _checkboxes[field.name] ?? false,
          onChanged: (value) {
            setState(() => _checkboxes[field.name] = value ?? false);
            state.didChange(value);
          },
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        key: Key('hubspot_field_${field.name}'),
        controller: _controllers[field.name],
        keyboardType: _keyboardFor(field.type),
        maxLines: field.type == HubSpotFieldType.multiline ? 4 : 1,
        decoration: InputDecoration(
          labelText: field.required ? '${field.label} *' : field.label,
          hintText: field.hint,
          border: const OutlineInputBorder(),
        ),
        validator: (value) => _validate(field, value),
      ),
    );
  }

  TextInputType? _keyboardFor(HubSpotFieldType type) => switch (type) {
    HubSpotFieldType.email => TextInputType.emailAddress,
    HubSpotFieldType.phone => TextInputType.phone,
    HubSpotFieldType.multiline => TextInputType.multiline,
    _ => TextInputType.text,
  };
}
