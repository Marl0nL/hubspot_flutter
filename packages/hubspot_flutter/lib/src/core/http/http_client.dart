import 'package:dio/dio.dart';

import '../auth/auth_provider.dart';
import '../errors/hubspot_exception.dart';
import '../hubspot_options.dart';
import 'error_mapper.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/rate_limit_interceptor.dart';

/// Thin wrapper over [Dio] that every hubspot_flutter module shares.
///
/// It wires up the auth and rate-limit interceptors once, decodes JSON, and
/// converts transport/HTTP failures into the typed [HubSpotException]
/// hierarchy. Modules build absolute URLs (they span several hosts) and call
/// [getJson] / [postJson].
class HubspotHttpClient {
  /// Builds a client from [options] and an [auth] strategy.
  ///
  /// [dio] can be injected in tests (e.g. wrapped with a mock adapter); when
  /// omitted a configured instance is created.
  factory HubspotHttpClient({
    required HubspotOptions options,
    required AuthProvider auth,
    Dio? dio,
  }) {
    final instance =
        dio ??
        Dio(
          BaseOptions(
            baseUrl: options.apiBaseUrl,
            connectTimeout: options.connectTimeout,
            receiveTimeout: options.receiveTimeout,
            headers: <String, Object?>{'User-Agent': options.userAgent},
            // Do not throw on any status; we map statuses ourselves so the
            // rate-limit interceptor sees 429s as errors to retry.
            validateStatus: (status) => status != null && status < 400,
          ),
        );
    instance.interceptors.add(AuthInterceptor(auth));
    instance.interceptors.add(
      RateLimitInterceptor(dio: instance, maxRetries: options.maxRetries),
    );
    return HubspotHttpClient._(instance);
  }

  HubspotHttpClient._(this._dio);

  final Dio _dio;

  /// The underlying Dio instance (exposed for advanced use / testing).
  Dio get dio => _dio;

  /// Performs a GET returning the decoded JSON body.
  ///
  /// [url] is an absolute URL. [query] values are appended as query parameters.
  Future<Object?> getJson(
    String url, {
    Map<String, Object?>? query,
    Map<String, String>? headers,
  }) => _send(
    () => _dio.get<Object?>(
      url,
      queryParameters: _clean(query),
      options: Options(headers: headers),
    ),
  );

  /// Performs a POST returning the decoded JSON body.
  Future<Object?> postJson(
    String url, {
    Object? data,
    Map<String, Object?>? query,
    Map<String, String>? headers,
    String contentType = Headers.jsonContentType,
  }) => _send(
    () => _dio.post<Object?>(
      url,
      data: data,
      queryParameters: _clean(query),
      options: Options(headers: headers, contentType: contentType),
    ),
  );

  Future<Object?> _send(Future<Response<Object?>> Function() run) async {
    try {
      final response = await run();
      return response.data;
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  /// Drops null-valued query params (Dio would serialise them as empty).
  Map<String, Object?>? _clean(Map<String, Object?>? query) {
    if (query == null) return null;
    final cleaned = <String, Object?>{};
    query.forEach((key, value) {
      if (value != null) cleaned[key] = value;
    });
    return cleaned;
  }

  /// Releases the underlying HTTP resources.
  void close({bool force = false}) => _dio.close(force: force);
}
