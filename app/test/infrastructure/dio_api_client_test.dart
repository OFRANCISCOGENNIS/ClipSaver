import 'package:dio/dio.dart';
import 'package:test/test.dart';
import 'package:vidora/core/error/failures.dart';
import 'package:vidora/core/network/dio_api_client.dart';

/// Adapter fake: scripted responses/errors per call, counting attempts.
final class ScriptedAdapter implements HttpClientAdapter {
  ScriptedAdapter(this.script);

  /// Each entry is either a [ResponseBody] or a [DioExceptionType] to throw.
  final List<Object> script;
  int calls = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls += 1;
    final step = script.removeAt(0);
    if (step is DioExceptionType) {
      throw DioException(requestOptions: options, type: step);
    }
    return step as ResponseBody;
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody json(String body, {int status = 200}) => ResponseBody.fromString(
      body,
      status,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );

DioApiClient clientWith(ScriptedAdapter adapter) {
  final dio = Dio();
  dio.httpClientAdapter = adapter;
  return DioApiClient(baseUrl: 'https://api.vidora.example', dio: dio);
}

void main() {
  test('postJson returns the decoded object on 200', () async {
    final adapter = ScriptedAdapter([json('{"ok":true}')]);
    final result =
        await clientWith(adapter).postJson('/analysis', {'url': 'x'});
    expect(result.valueOrNull, {'ok': true});
  });

  test('retries transient connection errors and then succeeds', () async {
    final adapter = ScriptedAdapter([
      DioExceptionType.connectionError,
      DioExceptionType.connectionTimeout,
      json('{"ok":1}'),
    ]);
    final result = await clientWith(adapter).getJson('/eligibility/adapters');
    expect(result.valueOrNull, {'ok': 1});
    expect(adapter.calls, 3);
  });

  test('gives up after two retries with a NetworkFailure', () async {
    final adapter = ScriptedAdapter([
      DioExceptionType.connectionError,
      DioExceptionType.connectionError,
      DioExceptionType.connectionError,
    ]);
    final result = await clientWith(adapter).getJson('/x');
    expect(result.failureOrNull, isA<NetworkFailure>());
    expect(adapter.calls, 3);
  });

  test('does not retry HTTP error statuses', () async {
    final adapter = ScriptedAdapter([json('{"m":"nope"}', status: 500)]);
    final result = await clientWith(adapter).postJson('/x', {});
    final failure = result.failureOrNull;
    expect(failure, isA<ServerFailure>());
    expect((failure! as ServerFailure).statusCode, 500);
    expect(adapter.calls, 1);
  });

  test('maps 429 to a specific rate-limit message', () async {
    final adapter = ScriptedAdapter([json('{}', status: 429)]);
    final result = await clientWith(adapter).postJson('/x', {});
    expect(result.failureOrNull!.message, contains('Aguarde'));
  });

  test('non-object JSON becomes ServerFailure', () async {
    final adapter = ScriptedAdapter([json('[1,2,3]')]);
    final result = await clientWith(adapter).getJson('/x');
    expect(result.failureOrNull, isA<ServerFailure>());
  });
}
