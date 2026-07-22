import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// A response specification the [ScriptedAdapter] can materialise fresh on every
/// call.
///
/// A [ResponseBody] wraps a single-subscription stream, so the same instance
/// cannot be replayed across retries. Holding the spec and building a new
/// [ResponseBody] per fetch keeps retry tests honest.
class MockResponse {
  MockResponse(this.statusCode, this.jsonBody, this.headers);

  final int statusCode;
  final Object? jsonBody;
  final Map<String, List<String>> headers;

  ResponseBody build() => ResponseBody.fromString(
    jsonEncode(jsonBody),
    statusCode,
    headers: <String, List<String>>{
      Headers.contentTypeHeader: <String>['application/json'],
      ...headers,
    },
  );
}

/// A deterministic Dio [HttpClientAdapter] for tests.
///
/// It records every request it receives and replies with the scripted responses
/// in order (repeating the last one once the script is exhausted). Because it
/// bypasses the network entirely, tests are fast and offline.
class ScriptedAdapter implements HttpClientAdapter {
  ScriptedAdapter(this._responses);

  /// Convenience for a single scripted response.
  ScriptedAdapter.single(MockResponse response) : _responses = [response];

  final List<MockResponse> _responses;

  /// Every request the adapter has been asked to fetch, in order.
  final List<RequestOptions> received = <RequestOptions>[];

  int _index = 0;

  /// Number of times [fetch] was invoked.
  int get callCount => received.length;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    received.add(options);
    final spec = _index < _responses.length
        ? _responses[_index]
        : _responses.last;
    _index++;
    return spec.build();
  }

  @override
  void close({bool force = false}) {}
}

/// Builds a JSON response spec with the given [statusCode].
MockResponse jsonResponse(
  int statusCode,
  Object? body, {
  Map<String, List<String>> headers = const {},
}) => MockResponse(statusCode, body, headers);

/// Loads and decodes a JSON fixture from `test/fixtures/<name>`.
Map<String, Object?> loadJsonFixture(String name) {
  final file = File('test/fixtures/$name');
  final decoded = jsonDecode(file.readAsStringSync());
  return (decoded as Map).cast<String, Object?>();
}
