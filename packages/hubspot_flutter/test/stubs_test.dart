import 'package:hubspot_flutter/hubspot_flutter.dart';
import 'package:test/test.dart';

void main() {
  final client = HubspotClient(
    options: const HubspotOptions(portalId: '1'),
    auth: const PublicClient(),
  );

  final throwsUnimplemented = throwsA(
    isA<HubSpotUnimplementedError>()
        .having((e) => e, 'is UnimplementedError', isA<UnimplementedError>())
        .having(
          (e) => e.category,
          'category',
          HubSpotErrorCategory.notImplemented,
        ),
  );

  group('CRM stubs throw HubSpotUnimplementedError', () {
    test('objects', () {
      expect(() => client.crm.contacts.getById('1'), throwsUnimplemented);
      expect(() => client.crm.deals.list(), throwsUnimplemented);
      expect(() => client.crm.companies.create({}), throwsUnimplemented);
      expect(() => client.crm.tickets.update('1', {}), throwsUnimplemented);
      expect(() => client.crm.objects('0-1').search(), throwsUnimplemented);
      expect(() => client.crm.contacts.batchRead(['1']), throwsUnimplemented);
    });
    test('associations & properties', () {
      expect(
        () => client.crm.associations.associate(
          fromObjectType: 'contacts',
          fromId: '1',
          toObjectType: 'companies',
          toId: '2',
        ),
        throwsUnimplemented,
      );
      expect(() => client.crm.properties.list('contacts'), throwsUnimplemented);
    });
  });

  group('Conversations & visitor identification stubs throw', () {
    test('conversations', () {
      expect(client.conversations.listThreads, throwsUnimplemented);
      expect(() => client.conversations.getThread('1'), throwsUnimplemented);
      expect(client.conversations.customChannels.list, throwsUnimplemented);
    });
    test('visitor identification token minting', () {
      expect(
        () => client.visitorIdentification.createToken(email: 'a@b.com'),
        throwsUnimplemented,
      );
    });
  });

  group('CMS/Files/Marketing/Webhooks stubs throw', () {
    test('cms', () {
      expect(client.cms.pages.listSitePages, throwsUnimplemented);
      expect(client.cms.blog.listPosts, throwsUnimplemented);
      expect(() => client.cms.hubdb.publish('t'), throwsUnimplemented);
      expect(() => client.cms.siteSearch.search(q: 'x'), throwsUnimplemented);
      expect(() => client.cms.knowledgeBase.query('{}'), throwsUnimplemented);
    });
    test('files', () {
      expect(
        () => client.files.upload(bytes: [], fileName: 'x', folderPath: '/'),
        throwsUnimplemented,
      );
    });
    test('marketing', () {
      expect(() => client.marketing.createEvent({}), throwsUnimplemented);
    });
    test('webhooks', () {
      expect(client.webhooks.listSubscriptions, throwsUnimplemented);
      expect(
        () => client.webhooks.verifySignature(
          signature: 's',
          requestBody: 'b',
          appSecret: 'x',
        ),
        throwsUnimplemented,
      );
    });
  });

  group('error message quality', () {
    test('mentions the backend tier and the feature', () {
      try {
        client.crm.contacts.getById('1');
        fail('should have thrown');
      } on HubSpotUnimplementedError catch (e) {
        expect(e.message, contains('CRM contacts getById'));
        expect(e.message.toLowerCase(), contains('backend'));
      }
    });

    test('visitor id minting points to setUserIdentity', () {
      try {
        client.visitorIdentification.createToken(email: 'a@b.com');
        fail('should have thrown');
      } on HubSpotUnimplementedError catch (e) {
        expect(e.message, contains('setUserIdentity'));
      }
    });
  });
}
