import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vidora/core/domain/value_objects/file_size.dart';
import 'package:vidora/core/domain/value_objects/media_format.dart';
import 'package:vidora/core/storage/database.dart';
import 'package:vidora/features/library/application/reconcile_library_files_use_case.dart';
import 'package:vidora/features/library/domain/library_entry.dart';
import 'package:vidora/features/library/domain/library_repository.dart';
import 'package:vidora/features/library/infrastructure/drift_library_repository.dart';

import '../support/download_fakes.dart';

void main() {
  late AppDatabase db;
  late DriftLibraryRepository repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = DriftLibraryRepository(db);
  });

  tearDown(() async => db.close());

  Future<LibraryEntry> seed({
    required String id,
    MediaKind kind = MediaKind.video,
    bool favorite = false,
    String path = '',
  }) async {
    final entry = LibraryEntry(
      id: id,
      title: 'Título $id',
      filePath: path.isEmpty ? '/library/$id.mp4' : path,
      kind: kind,
      size: FileSize.ofBytes(1000),
      downloadedAt: DateTime.utc(2026, 7, 1),
      favorite: favorite,
    );
    await repository.save(entry);
    return entry;
  }

  group('tab counts', () {
    test('counts videos, audios, favorites and trash separately', () async {
      await seed(id: 'v1');
      await seed(id: 'v2', favorite: true);
      await seed(id: 'a1', kind: MediaKind.audio);
      await seed(id: 't1');
      await repository.moveToTrash('t1', DateTime.utc(2026, 7, 10));

      final counts = (await repository.counts()).valueOrNull!;
      expect(counts.videos, 2);
      expect(counts.audios, 1);
      expect(counts.favorites, 1);
      expect(counts.trashed, 1);
      expect(counts.total, 3);
    });

    test('an empty library counts zero everywhere', () async {
      final counts = (await repository.counts()).valueOrNull!;
      expect(counts.total, 0);
      expect(counts.trashed, 0);
    });
  });

  group('favorites', () {
    test('sets and clears the flag', () async {
      await seed(id: 'a');
      expect(
          (await repository.setFavorite('a', favorite: true))
              .valueOrNull!
              .favorite,
          isTrue);
      expect(
        (await repository.setFavorite('a', favorite: false))
            .valueOrNull!
            .favorite,
        isFalse,
      );
    });

    test('reports an unknown id instead of failing silently', () async {
      expect(
          (await repository.setFavorite('nope', favorite: true)).isErr, isTrue);
    });
  });

  group('rename', () {
    test('trims the new title', () async {
      await seed(id: 'a');
      final renamed =
          (await repository.rename('a', '  Novo nome  ')).valueOrNull!;
      expect(renamed.title, 'Novo nome');
    });

    test('refuses an empty title', () async {
      await seed(id: 'a');
      expect((await repository.rename('a', '   ')).isErr, isTrue);
    });
  });

  group('tags', () {
    test('normalizes to lowercase, deduplicated and sorted', () async {
      await seed(id: 'a');
      final tagged =
          (await repository.setTags('a', ['  Flutter ', 'aula', 'FLUTTER', '']))
              .valueOrNull!;
      expect(tagged.tags, ['aula', 'flutter']);
    });

    test('an empty list clears the tags', () async {
      await seed(id: 'a');
      await repository.setTags('a', ['x']);
      expect((await repository.setTags('a', [])).valueOrNull!.tags, isEmpty);
    });
  });

  group('missing files (section 9)', () {
    test('marks and clears the missing status', () async {
      await seed(id: 'a');
      expect(
        (await repository.markMissing('a')).valueOrNull!.status,
        LibraryFileStatus.missing,
      );
      expect(
        (await repository.markAvailable('a')).valueOrNull!.status,
        LibraryFileStatus.available,
      );
    });

    test('refuses to flag a trashed entry', () async {
      await seed(id: 'a');
      await repository.moveToTrash('a', DateTime.utc(2026, 7, 10));
      expect((await repository.markMissing('a')).isErr, isTrue);
      expect((await repository.markAvailable('a')).isErr, isTrue);
    });
  });

  group('trash listing', () {
    test('lists only trashed entries, newest first', () async {
      await seed(id: 'a');
      await seed(id: 'b');
      await seed(id: 'keep');
      await repository.moveToTrash('a', DateTime.utc(2026, 7, 1));
      await repository.moveToTrash('b', DateTime.utc(2026, 7, 5));

      final trashed = (await repository.listTrashed()).valueOrNull!;
      expect(trashed.map((e) => e.id), ['b', 'a']);
    });
  });

  group('ReconcileLibraryFilesUseCase', () {
    late FakeFileSystem fs;
    late ReconcileLibraryFilesUseCase useCase;

    setUp(() {
      fs = FakeFileSystem();
      useCase = ReconcileLibraryFilesUseCase(
        repository: repository,
        fileSystem: fs,
      );
    });

    test('flags entries whose file disappeared', () async {
      await seed(id: 'gone');
      await seed(id: 'here');
      fs.files['/library/here.mp4'] = [1, 2, 3];

      final report = (await useCase()).valueOrNull!;
      expect(report.wentMissing, 1);
      expect(report.cameBack, 0);
      expect(
        (await repository.findById('gone')).valueOrNull!.status,
        LibraryFileStatus.missing,
      );
      expect(
        (await repository.findById('here')).valueOrNull!.status,
        LibraryFileStatus.available,
      );
    });

    test('clears the flag when the file comes back', () async {
      await seed(id: 'a');
      await repository.markMissing('a');
      fs.files['/library/a.mp4'] = [1];

      final report = (await useCase()).valueOrNull!;
      expect(report.cameBack, 1);
      expect(
        (await repository.findById('a')).valueOrNull!.status,
        LibraryFileStatus.available,
      );
    });

    test('reports no changes when everything is in place', () async {
      await seed(id: 'a');
      fs.files['/library/a.mp4'] = [1];
      final report = (await useCase()).valueOrNull!;
      expect(report.hasChanges, isFalse);
    });

    test('leaves trashed entries alone — their file may be gone already',
        () async {
      await seed(id: 'a');
      await repository.moveToTrash('a', DateTime.utc(2026, 7, 10));

      final report = (await useCase()).valueOrNull!;
      expect(report.hasChanges, isFalse);
      expect(
        (await repository.findById('a')).valueOrNull!.status,
        LibraryFileStatus.trashed,
      );
    });
  });

  group('sorting', () {
    test('sorts by every documented key in both directions', () async {
      await repository.save(
        LibraryEntry(
          id: 'a',
          title: 'Zebra',
          filePath: '/library/a.mp4',
          kind: MediaKind.video,
          size: FileSize.ofBytes(10),
          downloadedAt: DateTime.utc(2026, 7, 1),
          duration: const Duration(minutes: 1),
          platform: 'zzz',
        ),
      );
      await repository.save(
        LibraryEntry(
          id: 'b',
          title: 'Abacate',
          filePath: '/library/b.mp4',
          kind: MediaKind.video,
          size: FileSize.ofBytes(999),
          downloadedAt: DateTime.utc(2026, 7, 5),
          duration: const Duration(minutes: 9),
          platform: 'aaa',
        ),
      );

      Future<List<String>> ids(LibrarySort sort, {bool desc = true}) async =>
          (await repository.list(sort: sort, descending: desc))
              .valueOrNull!
              .map((e) => e.id)
              .toList();

      expect(await ids(LibrarySort.name, desc: false), ['b', 'a']);
      expect(await ids(LibrarySort.name), ['a', 'b']);
      expect(await ids(LibrarySort.size, desc: false), ['a', 'b']);
      expect(await ids(LibrarySort.duration, desc: false), ['a', 'b']);
      expect(await ids(LibrarySort.platform, desc: false), ['b', 'a']);
      expect(await ids(LibrarySort.downloadedAt), ['b', 'a']);
    });
  });
}
