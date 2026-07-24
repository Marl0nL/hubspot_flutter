import 'chat_web_config.dart';

/// Builds the HTML page + loader URL that embeds HubSpot's browser Conversations
/// widget as a **full-panel inline** chat (not a floating launcher bubble).
///
/// Pure and Flutter-free so it is trivially unit-testable; the WebView glue
/// ([HubSpotChatWebController]) just loads [buildHtml] against [baseUrl].
///
/// The page:
///  * declares `window.hsConversationsSettings.inlineEmbedSelector`, which makes
///    the widget render INLINE inside our container element instead of as the
///    default floating bubble;
///  * injects CSS so the container (and the widget's iframe) fill the WebView;
///  * loads the region-aware HubSpot tracking/loader script, then calls
///    `HubSpotConversations.widget.load()` once ready so the chat opens
///    immediately with no user gesture.
class HubSpotChatEmbed {
  /// Wraps a [config] to produce its embed artefacts.
  const HubSpotChatEmbed(this.config);

  /// The configuration this embed renders.
  final HubSpotChatWebConfig config;

  /// The region-aware HubSpot loader script URL. `na1` uses the bare
  /// `js.hs-scripts.com`; every other hublet uses `js-<hublet>.hs-scripts.com`.
  /// Protocol-relative so it inherits the page's scheme.
  String get scriptUrl {
    final region = config.hublet == 'na1' ? '' : '-${config.hublet}';
    return '//js$region.hs-scripts.com/${config.portalId}.js';
  }

  /// The base URL the embed HTML loads against — [HubSpotChatWebConfig.hostUrl]
  /// when supplied, else the portal's `hs-sites.com` domain.
  String get baseUrl =>
      config.hostUrl ?? 'https://${config.portalId}.hs-sites.com/';

  /// The full HTML document that hosts the inline chat widget.
  String buildHtml() {
    final selector = config.inlineSelector;
    return '''
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
<style>
  html, body {
    height: 100%;
    margin: 0;
    padding: 0;
    background: transparent;
    /* Let the widget own all scrolling; the page itself never scrolls. */
    overflow: hidden;
  }
  #$selector {
    position: absolute;
    inset: 0;
    height: 100%;
    width: 100%;
  }
  /* The widget injects a fixed-position iframe for the inline embed; pin it to
     the container so it fills the bounded WebView rather than the viewport. */
  #$selector iframe {
    height: 100% !important;
    width: 100% !important;
  }
</style>
</head>
<body>
<div id="$selector"></div>
<script type="text/javascript">
  window.hsConversationsSettings = {
    loadImmediately: false,
    inlineEmbedSelector: '#$selector',
  };
  window.hsConversationsOnReady = [
    function () {
      window.HubSpotConversations.widget.load();
    },
  ];
</script>
<script
  type="text/javascript"
  id="hs-script-loader"
  async
  defer
  src="$scriptUrl"></script>
</body>
</html>
''';
  }
}
