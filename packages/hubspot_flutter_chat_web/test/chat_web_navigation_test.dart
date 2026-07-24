import 'package:flutter_test/flutter_test.dart';
import 'package:hubspot_flutter_chat_web/hubspot_flutter_chat_web.dart';

void main() {
  const policy = HubSpotChatNavigationPolicy();

  HubSpotNavAction classify(String url, {bool isMainFrame = true}) =>
      policy.classify(url, isMainFrame: isMainFrame);

  group('widget infrastructure stays in the WebView', () {
    test('the loader script host', () {
      expect(
        classify('https://js-ap1.hs-scripts.com/3445699.js'),
        HubSpotNavAction.allowInWebView,
      );
    });

    test('HubSpot API / app / messages / asset hosts', () {
      for (final url in <String>[
        'https://api.hubspot.com/livechat',
        'https://app.hubspot.com/conversations',
        'https://something.usemessages.com/x',
        'https://3445699.hs-sites.com/',
        'https://cdn.hubspotusercontent-na1.net/a.png',
        'https://track.hs-analytics.net/x',
      ]) {
        expect(classify(url), HubSpotNavAction.allowInWebView, reason: url);
      }
    });

    test('about:/data:/blank internals are allowed', () {
      expect(classify('about:blank'), HubSpotNavAction.allowInWebView);
      expect(
        classify('data:text/html,<p>x</p>'),
        HubSpotNavAction.allowInWebView,
      );
    });

    test('sub-frame (iframe) requests are always allowed', () {
      // Even an external host, if it is a sub-frame load, must not be blocked —
      // only top-level navigations can be a user link tap.
      expect(
        classify(
          'https://help.repositpower.com/knowledge/x',
          isMainFrame: false,
        ),
        HubSpotNavAction.allowInWebView,
      );
    });
  });

  group('links the user tapped are delegated to the host', () {
    test('a knowledge-base article on the account KB host', () {
      // The package does NOT know this is a KB link — it just knows the host is
      // not HubSpot infrastructure, so the HOST decides.
      expect(
        classify('https://help.repositpower.com/knowledge/pre-charging'),
        HubSpotNavAction.delegateToHost,
      );
    });

    test('an arbitrary external site', () {
      expect(
        classify('https://www.example.com/pricing'),
        HubSpotNavAction.delegateToHost,
      );
    });

    test('a HubSpot look-alike host is NOT treated as infra', () {
      expect(
        classify('https://hubspot.com.evil.example/x'),
        HubSpotNavAction.delegateToHost,
      );
    });

    test('mailto: and tel: are delegated (host launches the app)', () {
      expect(
        classify('mailto:support@example.com'),
        HubSpotNavAction.delegateToHost,
      );
      expect(classify('tel:+61000'), HubSpotNavAction.delegateToHost);
    });
  });
}
