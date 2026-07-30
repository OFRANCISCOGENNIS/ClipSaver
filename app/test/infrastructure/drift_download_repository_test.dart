import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vidora/core/domain/value_objects/checksum.dart';
import 'package:vidora/core/domain/value_objects/file_size.dart';
import 'package:vidora/core/domain/value_objects/media_format.dart';
import 'package:vidora/core/storage/database.dart';
import 'package:vidora/features/downloads/domain/download_state.dart';
import 'package:vidora/features/downloads/domain/download_task.dart';
import 'package:vidora/features/downloads/infrastructure/drift_download_repository.dart';

void main() {
  late AppDatabase db;
  late DriftDownloadRepository repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = DriftDownloadRepository(db);
  });

  tearDown(() async => db.close());

  DownloadTask task(String id, {int priority = 0}) => DownloadTask(
        id: id,
        mediaItemId: 'm1',
        title: 'Item $id',
        format: const MediaFormat(
          id: 'f1',
          kind: MediaKind.video,
          container: 'mp4',
          codec: 'h264',
          height: 720,
        ),
        sourceUrl: 'https://files.example.com/a.mp4',
        destinationPath: '/downloads/$id.mp4',
        priority: priority,
        totalBytes: FileSize.ofBytes(1000),
        createdAt: DateTime.utc(2026, 7, 1),
      );

  test('enqueue + findById round-trips every field', () async {
    final checksum = Checksum.create(
      ChecksumAlgorithm.sha256,
      'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
    ).valueOrNull!;
    final original = DownloadTask(
      id: 't1',
      mediaItemId: 'm9',
      title: 'Com checksum',
      format: const MediaFormat(
        id: 'a1',
        kind: MediaKind.audio,
        container: 'mp3',
        bitrateKbps: 192,
      ),
      sourceUrl: 'https://files.example.com/a.mp4',
      destinationPath: '/d/a.mp3',
      expectedChecksum: checksum,
      totalBytes: FileSize.ofBytes(500),
      createdAt: DateTime.utc(2026, 7, 2, 10, 30),
    );
    await repository.enqueue(original);

    final loaded = (await repository.findById('t1')).valueOrNull!;
    expect(loaded, isNotNull);
    expect(loaded.mediaItemId, 'm9');
    expect(loaded.format.bitrateKbps, 192);
    expect(loaded.format.kind, MediaKind.audio);
    expect(loaded.expectedChecksum!.matches(checksum), isTrue);
    expect(loaded.totalBytes, FileSize.ofBytes(500));
    expect(loaded.createdAt, DateTime.utc(2026, 7, 2, 10, 30));
    expect(loaded.state, DownloadState.queued);
  });

  test('enqueue refuses tasks not in queued state', () async {
    final active =
        task('t2').transitionTo(DownloadState.connecting).valueOrNull!;
    final result = await repository.enqueue(active);
    expect(result.isErr, isTrue);
  });

  test('save persists state transitions and progress', () async {
    await repository.enqueue(task('t3'));
    var current = task('t3')
        .transitionTo(DownloadState.connecting)
        .valueOrNull!
        .transitionTo(DownloadState.downloading)
        .valueOrNull!;
    current = current.withProgress(FileSize.ofBytes(400)).valueOrNull!;
    await repository.save(current);

    final loaded = (await repository.findById('t3')).valueOrNull!;
    expect(loaded.state, DownloadState.downloading);
    expect(loaded.bytesDownloaded, FileSize.ofBytes(400));
  });

  test('all orders active first, then by priority', () async {
    await repository.enqueue(task('low', priority: 5));
    await repository.enqueue(task('high', priority: 1));
    final finished = task('done')
        .transitionTo(DownloadState.connecting)
        .valueOrNull!
        .transitionTo(DownloadState.downloading)
        .valueOrNull!
        .transitionTo(DownloadState.completed)
        .valueOrNull!
        .transitionTo(DownloadState.verifying)
        .valueOrNull!
        .transitionTo(DownloadState.done)
        .valueOrNull!;
    await repository.save(finished);

    final ids = (await repository.all()).valueOrNull!.map((t) => t.id).toList();
    expect(ids, ['high', 'low', 'done']);
  });

  test('watchAll emits on changes', () async {
    final emissions = <int>[];
    final subscription =
        repository.watchAll().listen((tasks) => emissions.add(tasks.length));
    await repository.enqueue(task('t4'));
    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(emissions, isNotEmpty);
    expect(emissions.last, 1);
    await subscription.cancel();
  });

  test('clearFinished removes only done tasks', () async {
    await repository.enqueue(task('keep'));
    final finished = task('gone')
        .transitionTo(DownloadState.connecting)
        .valueOrNull!
        .transitionTo(DownloadState.downloading)
        .valueOrNull!
        .transitionTo(DownloadState.completed)
        .valueOrNull!
        .transitionTo(DownloadState.verifying)
        .valueOrNull!
        .transitionTo(DownloadState.done)
        .valueOrNull!;
    await repository.save(finished);

    expect((await repository.clearFinished()).valueOrNull, 1);
    final remaining = (await repository.all()).valueOrNull!;
    expect(remaining.map((t) => t.id), ['keep']);
  });
}
