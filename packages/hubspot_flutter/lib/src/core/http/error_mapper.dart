import 'package:dio/dio.dart';

import '../errors/hubspot_exception.dart';

/// Header HubSpot uses to report how long to wait after a 429.
const _retryAfterHeader = 'retry-after';

/// Header carrying the remaining daily quota.
const _dailyRemainingHeader = 'x-hubspot-ratelimit-daily-remaining';

/// Converts a low-level [DioException] into a typed [HubSpotException].
///
/// If the error already carries a [HubSpotException] (e.g. a stubbed auth
/// provider that threw during request preparation), it is returned unchanged so
/// the original, most-specific error reaches the caller.
HubSpotException mapDioException(DioException error) {
  final existing = error.error;
  if (existing is HubSpotException) return existing;

  final response = error.response;
  final uri = error.requestOptions.uri;

  // No response → transport-level failure.
  if (response == null) {
    return HubSpotNetworkException(
      _networkMessage(error),
      uri: uri,
      cause: error,
    );
  }

  final status = response.statusCode ?? 0;
  final body = _asMap(response.data);
  final message = _extractMessage(body) ?? 'HubSpot request failed';
  final correlationId = body?['correlationId']?.toString();

  switch (status) {
    case 401:
    case 403:
      return HubSpotAuthException(
        message,
        statusCode: status,
        correlationId: correlationId,
        details: body ?? const {},
        uri: uri,
        cause: error,
      );
    case 400:
    case 422:
      return HubSpotValidationException(
        message,
        validationErrors: _extractValidationErrors(body),
        statusCode: status,
        correlationId: correlationId,
        details: body ?? const {},
        uri: uri,
        cause: error,
      );
    case 404:
      return HubSpotNotFoundException(
        message,
        statusCode: status,
        correlationId: correlationId,
        details: body ?? const {},
        uri: uri,
        cause: error,
      );
    case 429:
      return HubSpotRateLimitException(
        message,
        retryAfter: _retryAfter(response),
        dailyRemaining: _intHeader(response, _dailyRemainingHeader),
        statusCode: status,
        correlationId: correlationId,
        details: body ?? const {},
        uri: uri,
        cause: error,
      );
    default:
      if (status >= 500) {
        return HubSpotServerException(
          message,
          statusCode: status,
          correlationId: correlationId,
          details: body ?? const {},
          uri: uri,
          cause: error,
        );
      }
      return HubSpotException(
        message,
        statusCode: status,
        correlationId: correlationId,
        details: body ?? const {},
        uri: uri,
        cause: error,
      );
  }
}

String _networkMessage(DioException error) => switch (error.type) {
  DioExceptionType.connectionTimeout => 'Connection to HubSpot timed out',
  DioExceptionType.sendTimeout => 'Sending the request to HubSpot timed out',
  DioExceptionType.receiveTimeout => 'Waiting for a HubSpot response timed out',
  DioExceptionType.badCertificate => 'HubSpot TLS certificate was rejected',
  DioExceptionType.connectionError => 'Could not connect to HubSpot',
  DioExceptionType.cancel => 'The HubSpot request was cancelled',
  _ => error.message ?? 'A network error occurred talking to HubSpot',
};

Map<String, Object?>? _asMap(Object? data) =>
    data is Map<Object?, Object?> ? data.cast<String, Object?>() : null;

String? _extractMessage(Map<String, Object?>? body) {
  if (body == null) return null;
  final message = body['message'];
  if (message is String && message.isNotEmpty) return message;
  return null;
}

List<Map<String, Object?>> _extractValidationErrors(
  Map<String, Object?>? body,
) {
  final errors = body?['errors'];
  if (errors is! List) return const [];
  return errors
      .whereType<Map<Object?, Object?>>()
      .map((e) => e.cast<String, Object?>())
      .toList(growable: false);
}

Duration? _retryAfter(Response<Object?> response) {
  final seconds = _intHeader(response, _retryAfterHeader);
  return seconds == null ? null : Duration(seconds: seconds);
}

int? _intHeader(Response<Object?> response, String name) {
  final values = response.headers.map[name];
  if (values == null || values.isEmpty) return null;
  return int.tryParse(values.first.trim());
}
