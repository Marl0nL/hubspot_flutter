import 'dart:async';

import 'package:hubspot_flutter_chat/hubspot_flutter_chat.dart';
import 'package:flutter/material.dart';

void main() => runApp(const ChatDemoApp());

class ChatDemoApp extends StatelessWidget {
  const ChatDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'hubspot_flutter Chat Demo',
      home: ChatDemoPage(),
    );
  }
}

class ChatDemoPage extends StatefulWidget {
  const ChatDemoPage({super.key});

  @override
  State<ChatDemoPage> createState() => _ChatDemoPageState();
}

class _ChatDemoPageState extends State<ChatDemoPage> {
  final HubspotChat _chat = HubspotChat.instance;
  StreamSubscription<bool>? _visibilitySub;
  StreamSubscription<void>? _messageSub;
  String _status = 'Not configured';
  String _lastEvent = '—';

  @override
  void initState() {
    super.initState();
    // Only real, native-fired events are demoed. (There is no unread-count
    // stream: the HubSpot SDKs do not expose one.)
    _visibilitySub = _chat.onVisibilityChanged.listen(
      (visible) => setState(
        () => _lastEvent = visible ? 'chat opened' : 'chat closed (iOS only)',
      ),
    );
    _messageSub = _chat.onNewMessage.listen(
      (_) => setState(() => _lastEvent = 'new message'),
    );
  }

  @override
  void dispose() {
    _visibilitySub?.cancel();
    _messageSub?.cancel();
    super.dispose();
  }

  Future<void> _configure() async {
    // portalId / hublet / environment come from the bundled hubspot-info.json
    // (Android assets) — see example/android/app/src/main/assets/.
    await _chat.configure(
      const HubspotChatConfig(portalId: '1234567', defaultChatFlow: 'support'),
    );
    if (mounted) setState(() => _status = 'Configured');
  }

  Future<void> _open() => _chat.open();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('hubspot_flutter Chat Demo')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Status: $_status'),
            Text('Last event: $_lastEvent'),
            const SizedBox(height: 24),
            FilledButton(onPressed: _configure, child: const Text('Configure')),
            FilledButton(
              onPressed: _chat.isConfigured ? _open : null,
              child: const Text('Open chat'),
            ),
          ],
        ),
      ),
    );
  }
}
