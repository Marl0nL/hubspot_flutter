// A runnable tour of hubspot_flutter's three client-safe modules. It needs no secret —
// only a public portalId (and a formGuid / table for the respective calls).
//
// Run with: dart run example/hubspot_flutter_example.dart
import 'package:hubspot_flutter/hubspot_flutter.dart';

Future<void> main() async {
  // `requireClientSafe: true` asserts the auth strategy carries no secret —
  // exactly what you want in a shipped app.
  final client = HubspotClient(
    options: const HubspotOptions(portalId: '1234567'),
    auth: const PublicClient(),
    requireClientSafe: true,
  );

  try {
    // 1. Forms — lead capture / create-or-update a contact.
    final result = await client.forms.submit(
      formGuid: 'your-form-guid',
      fields: <String, Object?>{'email': 'ada@example.com', 'firstname': 'Ada'},
      context: const FormContext(pageName: 'Signup'),
    );
    print('Form submitted: ${result.inlineMessage ?? result.redirectUri}');

    // 2. Content Search v2 — published help-centre content.
    final page = await client.contentSearch.search(
      term: 'reset password',
      types: const <ContentSearchType>[ContentSearchType.knowledgeArticle],
    );
    print('Found ${page.total} article(s):');
    for (final hit in page.results) {
      print('  - ${hit.title} -> ${hit.url}');
    }

    // 3. Public HubDB — read a public-access table, auto-paged.
    await for (final row in client.hubdb.getAllRows('menu_items')) {
      print('Row ${row.id}: ${row.values.getString('name')}');
    }
  } on HubSpotRateLimitException catch (e) {
    print('Rate limited; retry after ${e.retryAfter}');
  } on HubSpotException catch (e) {
    // Every failure is a typed HubSpotException with a category.
    print('HubSpot error (${e.category.name}): ${e.message}');
  } finally {
    client.close();
  }
}
