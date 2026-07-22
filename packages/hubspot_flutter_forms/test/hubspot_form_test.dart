import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:hubspot_flutter_forms/hubspot_flutter_forms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Minimal scripted Dio adapter returning a fixed JSON response.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.statusCode, this.body);

  final int statusCode;
  final Map<String, Object?> body;
  RequestOptions? lastRequest;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequest = options;
    return ResponseBody.fromString(
      jsonEncode(body),
      statusCode,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

HubspotClient clientWith(HttpClientAdapter adapter) {
  final dio = Dio()..httpClientAdapter = adapter;
  return HubspotClient(
    options: const HubspotOptions(portalId: '1234567'),
    auth: const PublicClient(),
    dio: dio,
  );
}

Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  const fields = <HubSpotFormFieldSpec>[
    HubSpotFormFieldSpec(
      name: 'email',
      label: 'Email',
      type: HubSpotFieldType.email,
      required: true,
    ),
    HubSpotFormFieldSpec(name: 'firstname', label: 'First name'),
    HubSpotFormFieldSpec(
      name: 'consent',
      label: 'I agree',
      type: HubSpotFieldType.checkbox,
      required: true,
    ),
  ];

  testWidgets('renders a field per spec', (tester) async {
    final adapter = _FakeAdapter(200, {'inlineMessage': 'ok'});
    await tester.pumpWidget(
      wrap(
        HubSpotForm(client: clientWith(adapter), formGuid: 'g', fields: fields),
      ),
    );

    expect(find.byKey(const Key('hubspot_field_email')), findsOneWidget);
    expect(find.byKey(const Key('hubspot_field_firstname')), findsOneWidget);
    expect(find.byKey(const Key('hubspot_field_consent')), findsOneWidget);
    expect(find.text('Submit'), findsOneWidget);
  });

  testWidgets('blocks submit and shows validation errors', (tester) async {
    final adapter = _FakeAdapter(200, {'inlineMessage': 'ok'});
    await tester.pumpWidget(
      wrap(
        HubSpotForm(client: clientWith(adapter), formGuid: 'g', fields: fields),
      ),
    );

    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    expect(find.text('Email is required'), findsOneWidget);
    // No network call happened because validation failed.
    expect(adapter.lastRequest, isNull);
  });

  testWidgets('rejects an invalid email', (tester) async {
    final adapter = _FakeAdapter(200, {'inlineMessage': 'ok'});
    await tester.pumpWidget(
      wrap(
        HubSpotForm(client: clientWith(adapter), formGuid: 'g', fields: fields),
      ),
    );

    await tester.enterText(
      find.byKey(const Key('hubspot_field_email')),
      'not-an-email',
    );
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    expect(find.text('Enter a valid email address'), findsOneWidget);
    expect(adapter.lastRequest, isNull);
  });

  testWidgets('submits valid input and shows the inline message', (
    tester,
  ) async {
    final adapter = _FakeAdapter(200, {'inlineMessage': 'Thanks Ada!'});
    FormSubmissionResult? received;
    await tester.pumpWidget(
      wrap(
        HubSpotForm(
          client: clientWith(adapter),
          formGuid: 'lead-form',
          fields: fields,
          onSuccess: (r) => received = r,
        ),
      ),
    );

    await tester.enterText(
      find.byKey(const Key('hubspot_field_email')),
      'ada@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('hubspot_field_firstname')),
      'Ada',
    );
    await tester.tap(find.byKey(const Key('hubspot_field_consent')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('hubspot_form_success')), findsOneWidget);
    expect(find.text('Thanks Ada!'), findsOneWidget);
    expect(received?.inlineMessage, 'Thanks Ada!');

    // Verify the request shape.
    final req = adapter.lastRequest!;
    expect(
      req.uri.toString(),
      'https://api.hsforms.com/submissions/v3/integration/submit/1234567/lead-form',
    );
    final body = req.data as Map<String, Object?>;
    final submittedFields = (body['fields'] as List)
        .cast<Map<String, Object?>>()
        .map((f) => f['name'])
        .toList();
    expect(
      submittedFields,
      containsAll(<String>['email', 'firstname', 'consent']),
    );
  });

  testWidgets('recovers (button re-enabled) when submit throws a non-HubSpot '
      'error', (tester) async {
    // All-optional fields left empty -> FormsClient throws an ArgumentError.
    // The widget must surface it and not stay stuck in the submitting state.
    final adapter = _FakeAdapter(200, {'inlineMessage': 'ok'});
    await tester.pumpWidget(
      wrap(
        HubSpotForm(
          client: clientWith(adapter),
          formGuid: 'g',
          fields: const <HubSpotFormFieldSpec>[
            HubSpotFormFieldSpec(name: 'firstname', label: 'First name'),
          ],
        ),
      ),
    );

    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    expect(adapter.lastRequest, isNull);
    expect(find.byKey(const Key('hubspot_form_error')), findsOneWidget);
    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNotNull); // not stuck disabled
  });

  testWidgets('shows a server validation error', (tester) async {
    final adapter = _FakeAdapter(400, {
      'message': 'Error in fields.email',
      'errors': [
        {'message': 'invalid', 'in': 'fields.email'},
      ],
    });
    HubSpotException? error;
    await tester.pumpWidget(
      wrap(
        HubSpotForm(
          client: clientWith(adapter),
          formGuid: 'g',
          fields: const <HubSpotFormFieldSpec>[
            HubSpotFormFieldSpec(name: 'email', label: 'Email'),
          ],
          onError: (e) => error = e,
        ),
      ),
    );

    await tester.enterText(
      find.byKey(const Key('hubspot_field_email')),
      'x@y.com',
    );
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('hubspot_form_error')), findsOneWidget);
    expect(error, isA<HubSpotValidationException>());
  });
}
