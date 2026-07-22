import 'package:hubspot_flutter_chat/hubspot_flutter_chat.dart';
import 'package:flutter_test/flutter_test.dart';

/// A fake host API that records calls instead of hitting a platform channel.
class FakeHostApi extends HubspotChatHostApi {
  final List<String> calls = <String>[];
  ChatSetupData? lastSetup;
  VisitorIdentity? lastIdentity;
  Map<String, String>? lastProperties;
  String? lastPushToken;
  String? lastChatFlow;
  Map<String, String>? lastPush;
  bool pushHandledResult = true;

  @override
  Future<void> configure(ChatSetupData setup) async {
    calls.add('configure');
    lastSetup = setup;
  }

  @override
  Future<void> openChat(String? chatFlow) async {
    calls.add('openChat');
    lastChatFlow = chatFlow;
  }

  @override
  Future<void> closeChat() async => calls.add('closeChat');

  @override
  Future<void> setUserIdentity(VisitorIdentity identity) async {
    calls.add('setUserIdentity');
    lastIdentity = identity;
  }

  @override
  Future<void> setChatProperties(Map<String, String> properties) async {
    calls.add('setChatProperties');
    lastProperties = properties;
  }

  @override
  Future<void> setPushToken(String token) async {
    calls.add('setPushToken');
    lastPushToken = token;
  }

  @override
  Future<bool> handlePushNotification(Map<String, String> data) async {
    calls.add('handlePushNotification');
    lastPush = data;
    return pushHandledResult;
  }

  @override
  Future<void> logout() async => calls.add('logout');
}

void main() {
  late FakeHostApi host;
  late HubspotChat chat;

  setUp(() {
    host = FakeHostApi();
    chat = HubspotChat(hostApi: host, registerEventHandler: false);
  });

  tearDown(() async {
    await chat.dispose();
  });

  group('configuration gating', () {
    test('methods throw StateError before configure', () {
      expect(() => chat.open(), throwsStateError);
      expect(() => chat.close(), throwsStateError);
      expect(
        () => chat.setUserIdentity(email: 'a@b.com', identityToken: 't'),
        throwsStateError,
      );
      expect(chat.isConfigured, isFalse);
    });

    test('configure forwards config and flips isConfigured', () async {
      await chat.configure(
        const HubspotChatConfig(
          portalId: '1234567',
          hublet: 'eu1',
          defaultChatFlow: 'support',
          enableLogging: true,
        ),
      );
      expect(chat.isConfigured, isTrue);
      expect(host.calls, ['configure']);
      expect(host.lastSetup?.portalId, '1234567');
      expect(host.lastSetup?.hublet, 'eu1');
      expect(host.lastSetup?.defaultChatFlow, 'support');
      expect(host.lastSetup?.enableLogging, isTrue);
    });
  });

  group('method delegation (after configure)', () {
    setUp(() async {
      await chat.configure(const HubspotChatConfig(portalId: '1'));
      host.calls.clear();
    });

    test('open forwards the chatflow', () async {
      await chat.open(chatFlow: 'sales');
      expect(host.calls, ['openChat']);
      expect(host.lastChatFlow, 'sales');
    });

    test('close delegates', () async {
      await chat.close();
      expect(host.calls, ['closeChat']);
    });

    test('setUserIdentity passes email and token', () async {
      await chat.setUserIdentity(
        email: 'ada@example.com',
        identityToken: 'tok',
      );
      expect(host.calls, ['setUserIdentity']);
      expect(host.lastIdentity?.email, 'ada@example.com');
      expect(host.lastIdentity?.identityToken, 'tok');
    });

    test('setChatProperties passes the map', () async {
      await chat.setChatProperties({'plan': 'pro'});
      expect(host.lastProperties, {'plan': 'pro'});
    });

    test('setPushToken delegates', () async {
      await chat.setPushToken('fcm-token');
      expect(host.lastPushToken, 'fcm-token');
    });

    test('handlePushNotification returns the native result', () async {
      host.pushHandledResult = true;
      expect(await chat.handlePushNotification({'k': 'v'}), isTrue);
      expect(host.lastPush, {'k': 'v'});

      host.pushHandledResult = false;
      expect(await chat.handlePushNotification({'x': 'y'}), isFalse);
    });

    test('logout delegates', () async {
      await chat.logout();
      expect(host.calls, ['logout']);
    });
  });

  group('event streams', () {
    setUp(() async {
      await chat.configure(const HubspotChatConfig(portalId: '1'));
    });

    // These events are genuinely fired by the native side (Android: onNewMessage
    // from handlePushNotification, onChatOpened from openChat — both
    // compile-verified; iOS: onChatOpened/onChatClosed). The tests exercise the
    // Dart receiver -> stream fan-out. There is deliberately no unread-count
    // test: no native SDK exposes that event, so it is not part of the API.
    test('onNewMessage emits when native fires', () {
      expectLater(chat.onNewMessage, emits(null));
      chat.eventReceiver.onNewMessage();
    });

    test('onVisibilityChanged tracks open/close', () {
      // iOS emits both; Android emits only open (no close callback).
      expectLater(chat.onVisibilityChanged, emitsInOrder([true, false]));
      chat.eventReceiver.onChatOpened();
      chat.eventReceiver.onChatClosed();
    });
  });
}
