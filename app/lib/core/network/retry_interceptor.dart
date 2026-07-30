/// Retry interceptor for transient failures (section 7.2: timeout de 10s
/// com retry ×2; section 5: "dio + retry interceptor").
///
/// Responsibility: transparently retry connection-level failures with a
/// short exponential backoff. Only network-ish errors retry — HTTP 4xx/5xx
/// responses pass through, because retrying a 400 or 403 is never correct
/// and retrying 5xx is the caller's policy decision.
library;

import 'package:dio/dio.dart';

/// Retries connection errors/timeouts up to [maxRetries] times.
class RetryInterceptor extends Interceptor {
  /// Creates the interceptor; [delays] grow per attempt (backoff).
  RetryInterceptor({
    required this.dio,
    this.maxRetries = 2,
    this.delays = const [
      Duration(milliseconds: 300),
      Duration(milliseconds: 900),
    ],
  }) : assert(delays.length >= maxRetries, 'one delay per retry attempt');

  /// Client used to re-issue the request.
  final Dio dio;

  /// Maximum retry attempts per request.
  final int maxRetries;

  /// Backoff delay before each retry attempt.
  final List<Duration> delays;

  static const _attemptKey = 'vidora_retry_attempt';

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final attempt = (err.requestOptions.extra[_attemptKey] as int?) ?? 0;
    if (!_isTransient(err) || attempt >= maxRetries) {
      handler.next(err);
      return;
    }
    await Future<void>.delayed(delays[attempt]);
    final options = err.requestOptions..extra[_attemptKey] = attempt + 1;
    try {
      final response = await dio.fetch<dynamic>(options);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  bool _isTransient(DioException err) => switch (err.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.sendTimeout ||
        DioExceptionType.receiveTimeout ||
        DioExceptionType.connectionError =>
          true,
        _ => false,
      };
}
