import 'package:dio/dio.dart';
import 'package:hubspot_flutter/hubspot_flutter.dart';
import 'package:test/test.dart';

import 'support/scripted_adapter.dart';

HubspotClient buildClient(
  ScriptedAdapter adapter, {
  String portalId = '1234567',
  HubSpotRegion region = HubSpotRegion.na,
}) {
  final dio = Dio()..httpClientAdapter = adapter;
  return HubspotClient(
    options: HubspotOptions(portalId: portalId, region: region),
    auth: const PublicClient(),
    dio: dio,
  );
}

void main() {
  group('FormsClient.submit', () {
    test('posts to the NA host and returns the inline message', () async {
      final adapter = ScriptedAdapter.single(
        jsonResponse(200, loadJsonFixture('form_submission_success.json')),
      );
      final client = buildClient(adapter);

      final result = await client.forms.submit(
        formGuid: 'form-guid-123',
        fields: {'email': 'ada@example.com', 'firstname': 'Ada'},
        context: const FormContext(pageName: 'Signup'),
      );

      expect(result.inlineMessage, 'Thanks for submitting the form.');

      final request = adapter.received.single;
      expect(
        request.uri.toString(),
        'https://api.hsforms.com/submissions/v3/integration/submit/1234567/form-guid-123',
      );
      final body = request.data as Map<String, Object?>;
      final fields = body['fields'] as List<Object?>;
      expect(fields, hasLength(2));
      expect(fields.first, <String, Object?>{
        'name': 'email',
        'value': 'ada@example.com',
      });
      expect((body['context'] as Map)['pageName'], 'Signup');
      client.close();
    });

    test('uses the EU host for EU accounts', () async {
      final adapter = ScriptedAdapter.single(
        jsonResponse(200, loadJsonFixture('form_submission_success.json')),
      );
      final client = buildClient(adapter, region: HubSpotRegion.eu);
      await client.forms.submit(formGuid: 'g', fields: {'email': 'a@b.com'});
      expect(adapter.received.single.uri.host, 'api-eu1.hsforms.com');
      client.close();
    });

    test('joins list values with a semicolon', () async {
      final adapter = ScriptedAdapter.single(
        jsonResponse(200, loadJsonFixture('form_submission_success.json')),
      );
      final client = buildClient(adapter);
      await client.forms.submit(
        formGuid: 'g',
        fields: {
          'favourite_colors': ['red', 'green', 'blue'],
        },
      );
      final body = adapter.received.single.data as Map<String, Object?>;
      final field = (body['fields'] as List).first as Map;
      expect(field['value'], 'red;green;blue');
      client.close();
    });

    test('maps a validation error to HubSpotValidationException', () async {
      final adapter = ScriptedAdapter.single(
        jsonResponse(400, loadJsonFixture('form_submission_error.json')),
      );
      final client = buildClient(adapter);
      await expectLater(
        client.forms.submit(formGuid: 'g', fields: {'email': 'not-an-email'}),
        throwsA(
          isA<HubSpotValidationException>().having(
            (e) => e.validationErrors,
            'validationErrors',
            hasLength(1),
          ),
        ),
      );
      client.close();
    });

    test('percent-encodes the portalId and formGuid in the path', () async {
      final adapter = ScriptedAdapter.single(
        jsonResponse(200, loadJsonFixture('form_submission_success.json')),
      );
      final client = buildClient(adapter);
      await client.forms.submit(
        formGuid: 'guid/../evil?x=1',
        fields: {'email': 'a@b.com'},
      );
      expect(
        adapter.received.single.uri.path,
        '/submissions/v3/integration/submit/1234567/guid%2F..%2Fevil%3Fx%3D1',
      );
      client.close();
    });

    test('rejects an empty formGuid', () async {
      final client = buildClient(ScriptedAdapter.single(jsonResponse(200, {})));
      await expectLater(
        client.forms.submit(formGuid: '', fields: {'email': 'a@b.com'}),
        throwsA(isA<ArgumentError>()),
      );
      client.close();
    });

    test('rejects a submission with no fields', () async {
      final client = buildClient(ScriptedAdapter.single(jsonResponse(200, {})));
      await expectLater(
        client.forms.submit(formGuid: 'g'),
        throwsA(isA<ArgumentError>()),
      );
      client.close();
    });

    test('requires a portalId', () async {
      final client = buildClient(
        ScriptedAdapter.single(jsonResponse(200, {})),
        portalId: '',
      );
      await expectLater(
        client.forms.submit(formGuid: 'g', fields: {'email': 'a@b.com'}),
        throwsA(isA<ArgumentError>()),
      );
      client.close();
    });
  });
}
