import 'dart:math';

import 'package:dio/dio.dart';

/// Computes how long to wait before retry [attempt] (0-based), given the
/// server-suggested [retryAfter] (from the `Retry-After` header) when present.
typedef BackoffStrategy = Duration Function(int attempt, Duration? retryAfter);

/// Marks a request the interceptor is itself replaying, so a nested `onError`
/// (should Dio re-dispatch one) does not retry it a second time.
const _skipRetryExtraKey = '__hubspot_flutter_skip_retry';

/// Dio interceptor that retries rate-limited (HTTP 429) and transient server
/// (502/503/504) responses with exponential backoff.
///
/// HubSpot rate limits are a per-account shared pool; the Search API omits the
/// rate-limit headers entirely, so honouring 429 with backoff — rather than
/// tracking a header budget — is the robust strategy. When HubSpot sends a
/// `Retry-After`, that value is respected; otherwise an exponential backoff with
/// jitter is used.
///
/// The backoff is injectable ([backoff]) so tests can run with zero delay.
class RateLimitInterceptor extends Interceptor {
  /// Creates the interceptor. [dio] is the instance used to replay retried
  /// requests (pass the same [Dio] the interceptor is attached to).
  RateLimitInterceptor({
    required Dio dio,
    this.maxRetries = 3,
    this.retryOnServerError = true,
    BackoffStrategy? backoff,
    Random? random,
  }) : _dio = dio,
       _random = random ?? Random(),
       _backoff = backoff {
    // Default backoff needs `_random`, so it is wired after the field is set.
    _resolvedBackoff = _backoff ?? _defaultBackoff;
  }

  final Dio _dio;
  final Random _random;
  final BackoffStrategy? _backoff;
  late final BackoffStrategy _resolvedBackoff;

  /// Maximum number of retry attempts before giving up.
  final int maxRetries;

  /// Whether transient 5xx (502/503/504) responses are retried too.
  final bool retryOnServerError;

  Duration _defaultBackoff(int attempt, Duration? retryAfter) {
    if (retryAfter != null) return retryAfter;
    // 2^attempt seconds, capped, plus up to 1s of jitter.
    final base = min(1 << attempt, 30);
    final jitterMs = _random.nextInt(1000);
    return Duration(seconds: base, milliseconds: jitterMs);
  }

  bool _isRetryable(int? status) {
    if (status == 429) return true;
    if (retryOnServerError &&
        (status == 502 || status == 503 || status == 504)) {
      return true;
    }
    return false;
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;

    // Give up immediately if this is a replay we issued, or the status is not
    // one we retry.
    if (options.extra[_skipRetryExtraKey] == true ||
        !_isRetryable(err.response?.statusCode)) {
      handler.next(err);
      return;
    }

    var lastError = err;
    for (var attempt = 0; attempt < maxRetries; attempt++) {
      final delay = _resolvedBackoff(attempt, _retryAfter(lastError.response));
      if (delay > Duration.zero) await Future<void>.delayed(delay);

      // Mark the replay so a nested onError does not retry it again; the loop
      // here owns the retry budget.
      options.extra[_skipRetryExtraKey] = true;
      try {
        final response = await _dio.fetch<Object?>(options);
        handler.resolve(response);
        return;
      } on DioException catch (retryError) {
        lastError = retryError;
        if (!_isRetryable(retryError.response?.statusCode)) break;
      }
    }
    handler.next(lastError);
  }

  Duration? _retryAfter(Response<Object?>? response) {
    final values = response?.headers.map['retry-after'];
    if (values == null || values.isEmpty) return null;
    final seconds = int.tryParse(values.first.trim());
    return seconds == null ? null : Duration(seconds: seconds);
  }
}
