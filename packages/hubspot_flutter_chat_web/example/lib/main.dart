// Illustrative usage of hubspot_flutter_chat_web: embed the HubSpot browser
// chat widget in a bounded WebView, wrapped in your own app chrome, and route
// the links it emits however you like (here: open externally).
import 'package:flutter/material.dart';
import 'package:hubspot_flutter_chat_web/hubspot_flutter_chat_web.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) => const MaterialApp(home: ChatPage());
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final HubSpotChatWebController _controller;

  @override
  void initState() {
    super.initState();
    _controller = HubSpotChatWebController(
      config: const HubSpotChatWebConfig(
        portalId: '3445699',
        hublet: 'ap1',
        chatflow: 'customer-app',
        hostUrl: 'https://help.example.com',
      ),
      // A link the user tapped that leaves the widget — the HOST decides. Here
      // we would open it (KB article in-app, everything else in a browser).
      onLinkTap: (url) => debugPrint('link tapped: $url'),
    );
    _controller.load();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Support chat')),
    // The WebView is just the content region; your own header/nav stay native.
    body: HubSpotChatWebView(controller: _controller),
  );
}
