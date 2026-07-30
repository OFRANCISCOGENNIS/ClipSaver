/// dio-backed implementation of [ApiClient].
///
/// Responsibility: configure timeouts and retry, and translate transport
/// errors into the app's typed failures with user-facing messages
/// (section 7.2: mensagens específicas por tipo de erro).
library;

import 'package:dio/dio.dart';

import '../error/failures.dart';
import '../error/result.dart';
import 'api_client.dart';
import 'retry_interceptor.dart';

/// Production [ApiClient] speaking to the Vidora backend.
final class DioApiClient implements ApiClient {
  /// Builds a client for [baseUrl]; [dio] is injectable for tests.
  DioApiClient({required String baseUrl, Dio? dio}) : _dio = dio ?? Dio() {
    _dio.options
      ..baseUrl = baseUrl
      ..connectTimeout = const Duration(seconds: 10)
      ..receiveTimeout = const Duration(seconds: 10)
      ..headers = {'accept': 'application/json'};
    _dio.interceptors.add(RetryInterceptor(dio: _dio));
  }

  final Dio _dio;

  @override
  Future<Result<Map<String, dynamic>>> postJson(
    String path,
    Map<String, dynamic> body,
  ) =>
      _request(() => _dio.post<dynamic>(path, data: body));

  @override
  Future<Result<Map<String, dynamic>>> getJson(String path) =>
      _request(() => _dio.get<dynamic>(path));

  Future<Result<Map<String, dynamic>>> _request(
    Future<Response<dynamic>> Function() send,
  ) async {
    try {
      final response = await send();
      final data = response.data;
      if (data is! Map<String, dynamic>) {
        return const Result.err(
          ServerFailure('Resposta inesperada do servidor.'),
        );
      }
      return Result.ok(data);
    } on DioException catch (error) {
      return Result.err(_toFailure(error));
    }
  }

  Failure _toFailure(DioException error) {
    final status = error.response?.statusCode;
    if (status != null) {
      if (status == 429) {
        return const ServerFailure(
          'Muitas solicitações. Aguarde um instante e tente novamente.',
          statusCode: 429,
        );
      }
      if (status >= 500) {
        return ServerFailure(
          'O serviço está indisponível no momento. Tente novamente.',
          statusCode: status,
        );
      }
      return ServerFailure(
        'Não foi possível completar a solicitação.',
        statusCode: status,
      );
    }
    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        const NetworkFailure('Tempo esgotado. Verifique sua conexão.'),
      DioExceptionType.cancel => const NetworkFailure('Solicitação cancelada.'),
      _ => const NetworkFailure('Sem conexão com a internet.'),
    };
  }
}
