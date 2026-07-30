import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vidora/core/domain/value_objects/media_url.dart';
import 'package:vidora/core/error/failures.dart';
import 'package:vidora/core/error/result.dart';
import 'package:vidora/core/network/api_client.dart';
import 'package:vidora/core/storage/database.dart';
import 'package:vidora/features/analyze/domain/authorization_source.dart';
import 'package:vidora/features/analyze/infrastructure/analyze_repository_impl.dart';

/// Deterministic [ApiClient]: replies from a queue and records calls.
final class FakeApiClient implements ApiClient {
  final List<(String, Map<String, dynamic>)> posts = [];
  final List<Result<Map<String, dynamic>>> replies = [];

  @override
  Future<Result<Map<String, dynamic>>> postJson(
    String path,
    Map<String, dynamic> body,
  ) async {
    posts.add((path, body));
    return replies.removeAt(0);
  }

  @override
  Future<Result<Map<String, dynamic>>> getJson(String path) async =>
      const Result.err(ServerFailure('não usado neste teste'));
}

Map<String, dynamic> eligibleResponse(String url) => {
      'id': 'abc123',
      'url': url,
      'title': 'Aula aberta',
      'author': 'Prof. Silva',
      'eligibility': {
        'eligible': true,
        'source': 'open_license',
        'license': 'CC-BY-4.0',
        'reason': 'Conteúdo sob Licença CC-BY.',
        'availableFormats': [
          {'id': 'v720', 'kind': 'video', 'container': 'mp4', 'height': 720},
        ],
        'restrictions': ['atribuição obrigatória'],
      },
      'cached': false,
    };

void main() {
  late AppDatabase db;
  late FakeApiClient api;
  late AnalyzeRepositoryImpl repository;
  var now = DateTime.utc(2026, 7, 1);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    api = FakeApiClient();
    repository = AnalyzeRepositoryImpl(
      client: api,
      db: db,
      clock: () => now,
    );
  });

  tearDown(() async => db.close());

  final url = MediaUrl.create('https://cc.example.com/aula').valueOrNull!;

  test('analyze maps an eligible response into a MediaItem', () async {
    api.replies.add(Result.ok(eligibleResponse(url.value)));
    final item = (await repository.analyze(url)).valueOrNull!;
    expect(api.posts.single.$1, '/analysis');
    expect(api.posts.single.$2, {'url': url.value});
    expect(item.title, 'Aula aberta');
    expect(item.isDownloadable, isTrue);
    expect(item.eligibility.source, AuthorizationSource.openLicense);
    expect(item.eligibility.availableFormats.single.qualityLabel, '720p');
  });

  test('analyze maps an ineligible response, keeping the reason', () async {
    api.replies.add(
      Result.ok({
        'id': 'x1',
        'url': url.value,
        'eligibility': {
          'eligible': false,
          'source': 'none',
          'reason': 'Este conteúdo é protegido por DRM e não pode ser baixado.',
          'availableFormats': <Object>[],
          'restrictions': <Object>[],
        },
      }),
    );
    final item = (await repository.analyze(url)).valueOrNull!;
    expect(item.isDownloadable, isFalse);
    expect(item.eligibility.reason, contains('DRM'));
    // Fallback title: the URL itself.
    expect(item.title, url.value);
  });

  test('analyze propagates network failures without recording history',
      () async {
    api.replies.add(const Result.err(NetworkFailure('Sem conexão.')));
    final result = await repository.analyze(url);
    expect(result.failureOrNull, isA<NetworkFailure>());
    expect((await repository.recentAnalyses()).valueOrNull, isEmpty);
  });

  test('malformed or invariant-violating payloads become ServerFailure',
      () async {
    // Eligible with no formats violates the compliance invariant.
    api.replies.add(
      Result.ok({
        'id': 'bad',
        'url': url.value,
        'eligibility': {
          'eligible': true,
          'source': 'direct_file',
          'reason': 'x',
          'availableFormats': <Object>[],
          'restrictions': <Object>[],
        },
      }),
    );
    expect(
      (await repository.analyze(url)).failureOrNull,
      isA<ServerFailure>(),
    );

    api.replies.add(const Result.ok({'nada': true}));
    expect(
      (await repository.analyze(url)).failureOrNull,
      isA<ServerFailure>(),
    );
  });

  test('recentAnalyses returns newest first, capped at limit', () async {
    for (var i = 0; i < 7; i++) {
      now = DateTime.utc(2026, 7, 1 + i);
      final response = eligibleResponse('https://cc.example.com/aula$i');
      response['id'] = 'id$i';
      api.replies.add(Result.ok(response));
      await repository.analyze(
        MediaUrl.create('https://cc.example.com/aula$i').valueOrNull!,
      );
    }
    final recents = (await repository.recentAnalyses()).valueOrNull!;
    expect(recents, hasLength(5));
    expect(recents.first.id, 'id6');
    expect(recents.last.id, 'id2');
    expect(recents.first.eligibility.restrictions, ['atribuição obrigatória']);
  });

  test('re-analyzing the same URL updates history instead of duplicating',
      () async {
    api.replies
      ..add(Result.ok(eligibleResponse(url.value)))
      ..add(Result.ok(eligibleResponse(url.value)));
    await repository.analyze(url);
    await repository.analyze(url);
    expect((await repository.recentAnalyses()).valueOrNull, hasLength(1));
  });
}
