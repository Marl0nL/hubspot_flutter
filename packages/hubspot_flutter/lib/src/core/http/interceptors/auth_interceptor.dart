import 'package:dio/dio.dart';

import '../../auth/auth_provider.dart';

/// Dio interceptor that asks the configured [AuthProvider] for headers and
/// attaches them to every outgoing request.
///
/// For [PublicClient] this is a no-op (it returns no headers). For the stubbed
/// server-tier providers, [AuthProvider.headers] throws
/// [HubSpotUnimplementedError]; the interceptor turns that into a rejected
/// request carrying the original error, so callers still see the clear
/// "not implemented" message.
class AuthInterceptor extends Interceptor {
  /// Creates an interceptor backed by [auth].
  AuthInterceptor(this.auth);

  /// The active auth strategy.
  final AuthProvider auth;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final headers = await auth.headers();
      if (headers.isNotEmpty) options.headers.addAll(headers);
      handler.next(options);
    } catch (error, stackTrace) {
      handler.reject(
        DioException(
          requestOptions: options,
          error: error,
          stackTrace: stackTrace,
          type: DioExceptionType.unknown,
        ),
        true,
      );
    }
  }
}
