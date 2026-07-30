import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vidora/core/domain/value_objects/file_size.dart';
import 'package:vidora/core/domain/value_objects/license.dart';
import 'package:vidora/core/domain/value_objects/media_format.dart';
import 'package:vidora/core/storage/database.dart';
import 'package:vidora/features/library/domain/library_entry.dart';
import 'package:vidora/features/library/domain/library_repository.dart';
import 'package:vidora/features/library/infrastructure/drift_library_repository.dart';

void main() {
  late AppDatabase db;
  late DriftLibraryRepository repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = DriftLibraryRepository(db);
  });

  tearDown(() async => db.close());

  LibraryEntry entry(
    String id, {
    MediaKind kind = MediaKind.video,
    int sizeBytes = 1000,
    bool favorite = false,
    DateTime? downloadedAt,
  }) =>
      LibraryEntry(
        id: id,
        title: 'Título $id',
        filePath: '/library/$id.mp4',
        kind: kind,
        size: FileSize.ofBytes(sizeBytes),
        downloadedAt: downloadedAt ?? DateTime.utc(2026, 7, 1),
        license: License.ccBy,
        favorite: favorite,
        tags: const ['flutter'],
      );

  test('save + findById round-trips fields including license and tags',
      () async {
    await repository.save(entry('l1'));
    final loaded = (await repository.findById('l1')).valueOrNull!;
    expect(loaded.license, License.ccBy);
    expect(loaded.tags, ['flutter']);
    expect(loaded.size, FileSize.ofBytes(1000));
    expect(loaded.status, LibraryFileStatus.available);
  });

  test('list filters by kind and favorites, excluding trashed', () async {
    await repository.save(entry('v1'));
    await repository.save(entry('v2', favorite: true));
    await repository.save(entry('a1', kind: MediaKind.audio));
    await repository.save(entry('t1'));
    await repository.moveToTrash('t1', DateTime.utc(2026, 7, 10));

    final videos = (await repository.list(kind: MediaKind.video)).valueOrNull!;
    expect(videos.map((e) => e.id).toSet(), {'v1', 'v2'});

    final favorites = (await repository.list(favoritesOnly: true)).valueOrNull!;
    expect(favorites.map((e) => e.id), ['v2']);
  });

  test('list sorts by the requested key and direction', () async {
    await repository.save(entry('small', sizeBytes: 10));
    await repository.save(entry('big', sizeBytes: 999));
    final ascending = (await repository.list(
      sort: LibrarySort.size,
      descending: false,
    ))
        .valueOrNull!;
    expect(ascending.map((e) => e.id), ['small', 'big']);
    final descending =
        (await repository.list(sort: LibrarySort.size)).valueOrNull!;
    expect(descending.map((e) => e.id), ['big', 'small']);
  });

  test('trash lifecycle: move, restore, refuse invalid transitions', () async {
    await repository.save(entry('l2'));
    final trashed =
        (await repository.moveToTrash('l2', DateTime.utc(2026, 7, 10)))
            .valueOrNull!;
    expect(trashed.status, LibraryFileStatus.trashed);
    expect(trashed.trashedAt, DateTime.utc(2026, 7, 10));

    // Double-trash refused.
    expect(
      (await repository.moveToTrash('l2', DateTime.utc(2026, 7, 11))).isErr,
      isTrue,
    );

    final restored = (await repository.restoreFromTrash('l2')).valueOrNull!;
    expect(restored.status, LibraryFileStatus.available);
    expect(restored.trashedAt, isNull);

    // Restore of a non-trashed entry refused; unknown id refused.
    expect((await repository.restoreFromTrash('l2')).isErr, isTrue);
    expect((await repository.restoreFromTrash('nope')).isErr, isTrue);
  });

  test('purgeExpiredTrash removes only entries past retention', () async {
    await repository.save(entry('old'));
    await repository.save(entry('fresh'));
    await repository.moveToTrash('old', DateTime.utc(2026, 7, 1));
    await repository.moveToTrash('fresh', DateTime.utc(2026, 7, 9));

    final purged =
        (await repository.purgeExpiredTrash(DateTime.utc(2026, 7, 10)))
            .valueOrNull;
    expect(purged, 1);
    expect((await repository.findById('old')).valueOrNull, isNull);
    expect((await repository.findById('fresh')).valueOrNull, isNotNull);
  });
}
