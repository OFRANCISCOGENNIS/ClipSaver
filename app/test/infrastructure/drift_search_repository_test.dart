import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vidora/core/domain/value_objects/file_size.dart';
import 'package:vidora/core/domain/value_objects/media_format.dart';
import 'package:vidora/core/storage/database.dart';
import 'package:vidora/core/storage/search_index.dart';
import 'package:vidora/features/library/domain/library_entry.dart';
import 'package:vidora/features/library/infrastructure/drift_library_repository.dart';
import 'package:vidora/features/search/domain/search_query.dart';
import 'package:vidora/features/search/infrastructure/drift_search_repository.dart';

void main() {
  late AppDatabase db;
  late DriftLibraryRepository library;
  late DriftSearchRepository search;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    library = DriftLibraryRepository(db);
    search = DriftSearchRepository(db: db, library: library);
  });

  tearDown(() async => db.close());

  Future<void> seed({
    required String id,
    required String title,
    String? author,
    String? platform,
    MediaKind kind = MediaKind.video,
    List<String> tags = const [],
    Duration? duration,
    int sizeBytes = 1000,
    String extension = 'mp4',
    DateTime? downloadedAt,
  }) async {
    await library.save(
      LibraryEntry(
        id: id,
        title: title,
        filePath: '/library/$id.$extension',
        kind: kind,
        size: FileSize.ofBytes(sizeBytes),
        downloadedAt: downloadedAt ?? DateTime.utc(2026, 7, 1),
        author: author,
        platform: platform,
        duration: duration,
        tags: tags,
      ),
    );
  }

  Future<List<String>> idsFor(SearchQuery query) async {
    final result = await search.search(query);
    return result.valueOrNull!.map((hit) => hit.entry.id).toList();
  }

  group('full-text matching', () {
    test('finds by title, author, platform and tag', () async {
      await seed(
        id: 'a',
        title: 'Aula de Flutter',
        author: 'Prof. Silva',
        platform: 'archive_org',
        tags: const ['programacao'],
      );
      await seed(id: 'b', title: 'Receita de bolo');

      expect(await idsFor(SearchQuery(text: 'Flutter')), ['a']);
      expect(await idsFor(SearchQuery(text: 'Silva')), ['a']);
      expect(await idsFor(SearchQuery(text: 'archive_org')), ['a']);
      expect(await idsFor(SearchQuery(text: 'programacao')), ['a']);
    });

    test('matches by prefix while the user is still typing', () async {
      await seed(id: 'a', title: 'Aula de Flutter');
      expect(await idsFor(SearchQuery(text: 'Flut')), ['a']);
      expect(await idsFor(SearchQuery(text: 'Au')), ['a']);
    });

    test('ignores accents in both directions', () async {
      await seed(id: 'a', title: 'Música brasileira');
      await seed(id: 'b', title: 'Programacao em Dart');

      expect(await idsFor(SearchQuery(text: 'musica')), ['a']);
      expect(await idsFor(SearchQuery(text: 'música')), ['a']);
      expect(await idsFor(SearchQuery(text: 'programação')), ['b']);
    });

    test('requires every term to match', () async {
      await seed(id: 'a', title: 'Aula de Flutter');
      await seed(id: 'b', title: 'Aula de Dart');
      expect(await idsFor(SearchQuery(text: 'aula flutter')), ['a']);
    });

    test('treats FTS operators as literal text, not syntax', () async {
      await seed(id: 'a', title: 'Aula de Flutter');
      // None of these should throw an FTS5 syntax error.
      for (final text in ['aula OR', 'NEAR(', '"unclosed', 'a*b', '-aula']) {
        final result = await search.search(SearchQuery(text: text));
        expect(result.isOk, isTrue, reason: text);
      }
    });

    test('an empty query with no filters returns the whole library', () async {
      await seed(id: 'a', title: 'Um');
      await seed(id: 'b', title: 'Dois');
      expect((await idsFor(SearchQuery())).length, 2);
    });
  });

  group('typo tolerance (edit distance 1)', () {
    test('falls back to fuzzy matching when nothing matches exactly', () async {
      await seed(id: 'a', title: 'Aula de Flutter');

      final result = await search.search(SearchQuery(text: 'flutger'));
      final hits = result.valueOrNull!;
      expect(hits.map((hit) => hit.entry.id), ['a']);
      expect(hits.single.matchedByTypoTolerance, isTrue);
    });

    test('exact matches are not flagged as fuzzy', () async {
      await seed(id: 'a', title: 'Aula de Flutter');
      final hits =
          (await search.search(SearchQuery(text: 'flutter'))).valueOrNull!;
      expect(hits.single.matchedByTypoTolerance, isFalse);
    });

    test('gives up beyond one edit', () async {
      await seed(id: 'a', title: 'Aula de Flutter');
      expect(await idsFor(SearchQuery(text: 'xyzabc')), isEmpty);
    });
  });

  group('filters (section 10)', () {
    test('filters by media kind', () async {
      await seed(id: 'v', title: 'Vídeo');
      await seed(id: 'a', title: 'Áudio', kind: MediaKind.audio);
      expect(await idsFor(SearchQuery(kind: MediaKind.audio)), ['a']);
    });

    test('filters by platform', () async {
      await seed(id: 'a', title: 'Um', platform: 'archive_org');
      await seed(id: 'b', title: 'Dois', platform: 'podcast_rss');
      expect(await idsFor(SearchQuery(platform: 'podcast_rss')), ['b']);
    });

    test('filters by duration bucket', () async {
      await seed(
          id: 'curto', title: 'Curto', duration: const Duration(minutes: 3));
      await seed(
          id: 'medio', title: 'Médio', duration: const Duration(minutes: 10));
      await seed(
          id: 'longo', title: 'Longo', duration: const Duration(minutes: 40));

      expect(await idsFor(SearchQuery(durationBucket: DurationBucket.short)),
          ['curto']);
      expect(await idsFor(SearchQuery(durationBucket: DurationBucket.medium)),
          ['medio']);
      expect(await idsFor(SearchQuery(durationBucket: DurationBucket.long)),
          ['longo']);
    });

    test('filters by download date range', () async {
      await seed(
        id: 'velho',
        title: 'Velho',
        downloadedAt: DateTime.utc(2026, 1, 1),
      );
      await seed(
        id: 'novo',
        title: 'Novo',
        downloadedAt: DateTime.utc(2026, 7, 20),
      );

      final ids = await idsFor(
        SearchQuery(
          dateRange: DateRange(
            from: DateTime.utc(2026, 7, 1),
            to: DateTime.utc(2026, 7, 31),
          ),
        ),
      );
      expect(ids, ['novo']);
    });

    test('filters by size bounds', () async {
      await seed(id: 'pequeno', title: 'Pequeno', sizeBytes: 100);
      await seed(id: 'grande', title: 'Grande', sizeBytes: 10000);

      expect(
        await idsFor(SearchQuery(minSize: FileSize.ofBytes(1000))),
        ['grande'],
      );
      expect(
        await idsFor(SearchQuery(maxSize: FileSize.ofBytes(1000))),
        ['pequeno'],
      );
    });

    test('filters by container', () async {
      await seed(id: 'v', title: 'Vídeo', extension: 'mp4');
      await seed(id: 'a', title: 'Áudio', extension: 'mp3');
      expect(await idsFor(SearchQuery(containers: const {'mp3'})), ['a']);
    });

    test('requires all requested tags to be present', () async {
      await seed(id: 'a', title: 'Um', tags: const ['aula', 'flutter']);
      await seed(id: 'b', title: 'Dois', tags: const ['aula']);

      expect(
          await idsFor(SearchQuery(tags: const {'aula'}))
              .then((v) => v..sort()),
          ['a', 'b']);
      expect(await idsFor(SearchQuery(tags: const {'aula', 'flutter'})), ['a']);
    });

    test('combines text with filters', () async {
      await seed(id: 'a', title: 'Aula de Flutter', kind: MediaKind.video);
      await seed(id: 'b', title: 'Aula de Flutter', kind: MediaKind.audio);
      expect(
        await idsFor(SearchQuery(text: 'flutter', kind: MediaKind.audio)),
        ['b'],
      );
    });

    test('trashed entries never appear in results', () async {
      await seed(id: 'a', title: 'Aula de Flutter');
      await library.moveToTrash('a', DateTime.utc(2026, 7, 10));
      expect(await idsFor(SearchQuery(text: 'flutter')), isEmpty);
      expect(await idsFor(SearchQuery()), isEmpty);
    });

    test('restoring from trash puts the entry back in the index', () async {
      await seed(id: 'a', title: 'Aula de Flutter');
      await library.moveToTrash('a', DateTime.utc(2026, 7, 10));
      await library.restoreFromTrash('a');
      expect(await idsFor(SearchQuery(text: 'flutter')), ['a']);
    });
  });

  group('index maintenance', () {
    test('renaming updates what search finds', () async {
      await seed(id: 'a', title: 'Aula de Flutter');
      await library.rename('a', 'Receita de bolo');

      expect(await idsFor(SearchQuery(text: 'flutter')), isEmpty);
      expect(await idsFor(SearchQuery(text: 'bolo')), ['a']);
    });

    test('editing tags updates what search finds', () async {
      await seed(id: 'a', title: 'Aula', tags: const ['antiga']);
      await library.setTags('a', ['nova']);

      expect(await idsFor(SearchQuery(text: 'antiga')), isEmpty);
      expect(await idsFor(SearchQuery(text: 'nova')), ['a']);
    });

    test('purging the trash drops the entry from the index', () async {
      await seed(id: 'a', title: 'Aula de Flutter');
      await library.moveToTrash('a', DateTime.utc(2026, 7, 1));
      await library.purgeExpiredTrash(DateTime.utc(2026, 7, 20));

      expect(await idsFor(SearchQuery(text: 'flutter')), isEmpty);
    });
  });

  group('suggestions and facets', () {
    test('suggests titles by prefix', () async {
      await seed(id: 'a', title: 'Aula de Flutter');
      await seed(id: 'b', title: 'Aula de Dart');
      final suggestions = (await search.suggest('aula')).valueOrNull!;
      expect(suggestions, hasLength(2));
      expect(suggestions.every((s) => s.startsWith('Aula')), isTrue);
    });

    test('an empty prefix suggests nothing', () async {
      await seed(id: 'a', title: 'Aula');
      expect((await search.suggest('   ')).valueOrNull, isEmpty);
    });

    test('lists the distinct platforms and tags present', () async {
      await seed(
          id: 'a', title: 'Um', platform: 'archive_org', tags: const ['x']);
      await seed(
          id: 'b',
          title: 'Dois',
          platform: 'podcast_rss',
          tags: const ['y', 'x']);

      expect((await search.knownPlatforms()).valueOrNull,
          ['archive_org', 'podcast_rss']);
      expect((await search.knownTags()).valueOrNull, ['x', 'y']);
    });
  });

  group('escapeFtsQuery', () {
    test('quotes tokens and adds a prefix wildcard to the last one', () {
      expect(escapeFtsQuery('aula flutter'), '"aula" "flutter"*');
    });

    test('drops punctuation that would be FTS syntax', () {
      expect(escapeFtsQuery('aula- OR "x"'), '"aula" "OR" "x"*');
    });

    test('returns empty for input with no usable tokens', () {
      expect(escapeFtsQuery('   '), '');
      expect(escapeFtsQuery('---'), '');
    });

    test('can build a non-prefix expression', () {
      expect(escapeFtsQuery('aula', prefix: false), '"aula"');
    });
  });
}
