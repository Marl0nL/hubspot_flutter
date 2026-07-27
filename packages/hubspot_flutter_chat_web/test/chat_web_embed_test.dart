import 'package:flutter_test/flutter_test.dart';
import 'package:hubspot_flutter_chat_web/hubspot_flutter_chat_web.dart';

void main() {
  group('scriptUrl (region-aware loader)', () {
    test('na1 uses the bare js.hs-scripts.com host', () {
      const embed = HubSpotChatEmbed(HubSpotChatWebConfig(portalId: '1234567'));
      expect(embed.scriptUrl, '//js.hs-scripts.com/1234567.js');
    });

    test('ap1 uses the region-suffixed host', () {
      const embed = HubSpotChatEmbed(
        HubSpotChatWebConfig(portalId: '3445699', hublet: 'ap1'),
      );
      expect(embed.scriptUrl, '//js-ap1.hs-scripts.com/3445699.js');
    });

    test('eu1 uses the region-suffixed host', () {
      const embed = HubSpotChatEmbed(
        HubSpotChatWebConfig(portalId: '42', hublet: 'eu1'),
      );
      expect(embed.scriptUrl, '//js-eu1.hs-scripts.com/42.js');
    });
  });

  group('baseUrl', () {
    test('defaults to the portal hs-sites domain', () {
      const embed = HubSpotChatEmbed(HubSpotChatWebConfig(portalId: '3445699'));
      expect(embed.baseUrl, 'https://3445699.hs-sites.com/');
    });

    test('uses hostUrl when supplied (targeting origin)', () {
      const embed = HubSpotChatEmbed(
        HubSpotChatWebConfig(
          portalId: '3445699',
          hostUrl: 'https://help.repositpower.com',
        ),
      );
      expect(embed.baseUrl, 'https://help.repositpower.com');
    });
  });

  group('buildHtml', () {
    const embed = HubSpotChatEmbed(
      HubSpotChatWebConfig(portalId: '3445699', hublet: 'ap1'),
    );
    final html = embed.buildHtml();

    test('loads the region-aware loader script', () {
      expect(html, contains('src="//js-ap1.hs-scripts.com/3445699.js"'));
      expect(html, contains('id="hs-script-loader"'));
    });

    test('configures an INLINE embed (full-panel, not a floating bubble)', () {
      expect(
        html,
        contains(
          "inlineEmbedSelector: '#hubspot-conversations-inline-embed-selector'",
        ),
      );
      expect(
        html,
        contains('<div id="hubspot-conversations-inline-embed-selector">'),
      );
    });

    test('auto-loads the widget on ready (opens with no user gesture)', () {
      expect(html, contains('window.hsConversationsOnReady'));
      expect(html, contains('window.HubSpotConversations.widget.load();'));
    });

    test('honours a custom inline selector', () {
      const custom = HubSpotChatEmbed(
        HubSpotChatWebConfig(portalId: '1', inlineSelector: 'chat-here'),
      );
      final out = custom.buildHtml();
      expect(out, contains("inlineEmbedSelector: '#chat-here'"));
      expect(out, contains('<div id="chat-here">'));
    });
  });
}
