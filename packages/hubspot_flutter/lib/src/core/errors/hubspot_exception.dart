import 'package:meta/meta.dart';

/// Broad classification of a [HubSpotException], useful for `switch`-style
/// handling without depending on concrete subtypes.
enum HubSpotErrorCategory {
  /// Authentication or authorization failure (HTTP 401 / 403).
  auth,

  /// Request validation failure (HTTP 400 / 422).
  validation,

  /// The requested resource does not exist (HTTP 404).
  notFound,

  /// The account/token rate limit was exceeded (HTTP 429).
  rateLimit,

  /// HubSpot returned a 5xx server error.
  server,

  /// A transport-level problem (timeout, connection reset, DNS, ...).
  network,

  /// The feature is not implemented in this tier of the package.
  notImplemented,

  /// Anything else.
  unknown,
}

/// Base class for every error surfaced by hubspot_flutter.
///
/// Concrete subtypes ([HubSpotAuthException], [HubSpotRateLimitException], ...)
/// let callers pattern-match on the failure mode; [category] provides the same
/// information as an enum when a `switch` is more convenient than `is` checks.
@immutable
class HubSpotException implements Exception {
  const HubSpotException(
    this.message, {
    this.category = HubSpotErrorCategory.unknown,
    this.statusCode,
    this.correlationId,
    this.details = const <String, Object?>{},
    this.uri,
    this.cause,
  });

  /// Human-readable description of what went wrong.
  final String message;

  /// Coarse classification of the failure.
  final HubSpotErrorCategory category;

  /// The HTTP status code that produced this error, when there was a response.
  final int? statusCode;

  /// HubSpot's `correlationId`, echoed from the error body when present. Quote
  /// it when contacting HubSpot support.
  final String? correlationId;

  /// The parsed HubSpot error body (or other structured context), if any.
  final Map<String, Object?> details;

  /// The request URI that failed, when known.
  final Uri? uri;

  /// The underlying error (e.g. a `DioException` or `SocketException`).
  final Object? cause;

  @override
  String toString() {
    final buffer = StringBuffer('$runtimeType: $message');
    if (statusCode != null) buffer.write(' (HTTP $statusCode)');
    if (correlationId != null) buffer.write(' [correlationId: $correlationId]');
    return buffer.toString();
  }
}

/// Authentication or authorization failure (HTTP 401 / 403).
class HubSpotAuthException extends HubSpotException {
  const HubSpotAuthException(
    super.message, {
    super.statusCode,
    super.correlationId,
    super.details,
    super.uri,
    super.cause,
  }) : super(category: HubSpotErrorCategory.auth);
}

/// Request validation failure (HTTP 400 / 422).
class HubSpotValidationException extends HubSpotException {
  const HubSpotValidationException(
    super.message, {
    this.validationErrors = const <Map<String, Object?>>[],
    super.statusCode,
    super.correlationId,
    super.details,
    super.uri,
    super.cause,
  }) : super(category: HubSpotErrorCategory.validation);

  /// The per-field validation errors HubSpot returned, when present. Each entry
  /// typically has `message`, `in` and `subCategory` keys.
  final List<Map<String, Object?>> validationErrors;
}

/// The requested resource does not exist (HTTP 404).
class HubSpotNotFoundException extends HubSpotException {
  const HubSpotNotFoundException(
    super.message, {
    super.statusCode,
    super.correlationId,
    super.details,
    super.uri,
    super.cause,
  }) : super(category: HubSpotErrorCategory.notFound);
}

/// The account/token rate limit was exceeded (HTTP 429).
///
/// HubSpot rate limits are a per-account shared pool. [retryAfter] is populated
/// from the `Retry-After` header when HubSpot supplies it.
class HubSpotRateLimitException extends HubSpotException {
  const HubSpotRateLimitException(
    super.message, {
    this.retryAfter,
    this.dailyRemaining,
    super.statusCode,
    super.correlationId,
    super.details,
    super.uri,
    super.cause,
  }) : super(category: HubSpotErrorCategory.rateLimit);

  /// How long HubSpot asked us to wait before retrying, if provided.
  final Duration? retryAfter;

  /// Remaining daily quota, from `X-HubSpot-RateLimit-Daily-Remaining`, if sent.
  final int? dailyRemaining;
}

/// HubSpot returned a 5xx server error.
class HubSpotServerException extends HubSpotException {
  const HubSpotServerException(
    super.message, {
    super.statusCode,
    super.correlationId,
    super.details,
    super.uri,
    super.cause,
  }) : super(category: HubSpotErrorCategory.server);
}

/// A transport-level failure (timeout, connection reset, DNS, cancellation).
class HubSpotNetworkException extends HubSpotException {
  const HubSpotNetworkException(super.message, {super.uri, super.cause})
    : super(category: HubSpotErrorCategory.network);
}

/// Thrown by the backend-mediated modules and stubbed auth providers that are
/// not part of this client-safe release.
///
/// It is both a [HubSpotException] (so generic error handling still works) and
/// an [UnimplementedError] (so it reads idiomatically at the call site).
class HubSpotUnimplementedError extends HubSpotException
    implements UnimplementedError {
  HubSpotUnimplementedError(String feature, {String? reason})
    : super(
        '$feature is not implemented in this release. '
        '${reason ?? 'It requires the backend/server tier — see the hubspot_flutter README.'}',
        category: HubSpotErrorCategory.notImplemented,
      );

  /// Satisfies the [Error] contract inherited via [UnimplementedError]. These
  /// are expected, documented errors, so no stack trace is attached.
  @override
  StackTrace? get stackTrace => null;

  @override
  String toString() => 'HubSpotUnimplementedError: $message';
}
