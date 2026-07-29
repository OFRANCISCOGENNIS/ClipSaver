import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vidora/app/providers.dart';
import 'package:vidora/core/domain/value_objects/file_size.dart';
import 'package:vidora/features/downloads/domain/download_state.dart';
import 'package:vidora/features/downloads/domain/download_task.dart';
import 'package:vidora/features/downloads/presentation/downloads_state.dart';
import 'package:vidora/features/downloads/presentation/downloads_view_model.dart';

import '../support/download_fakes.dart';
import '../support/in_memory_download_repository.dart';

void main() {
  late InMemoryDownloadRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = InMemoryDownloadRepository();
    container = ProviderContainer(
      overrides: [
        downloadRepositoryProvider.overrideWithValue(repository),
        downloadTransportProvider.overrideWithValue(FakeTransport([])),
        downloadFileSystemProvider.overrideWithValue(FakeFileSystem()),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await repository.dispose();
  });

  DownloadsViewModel viewModel() =>
      container.read(downloadsViewModelProvider.notifier);
  DownloadsUiState state() => container.read(downloadsViewModelProvider);

  DownloadTask running({
    String id = 't1',
    int downloaded = 400,
    int? total = 1000,
  }) {
    final base = taskFixture(id: id)
        .transitionTo(DownloadState.connecting)
        .valueOrNull!
        .transitionTo(DownloadState.downloading)
        .valueOrNull!
        .copyWith(
          totalBytes: total == null ? null : FileSize.ofBytes(total),
        );
    return base.withProgress(FileSize.ofBytes(downloaded)).valueOrNull!;
  }

  group('queue projection', () {
    test('starts empty and unloaded', () {
      expect(state().items, isEmpty);
      expect(state().loaded, isFalse);
    });

    test('seeds from the repository and marks itself loaded', () async {
      await repository.save(taskFixture());
      viewModel(); // triggers build
      await Future<void>.delayed(Duration.zero);

      expect(state().loaded, isTrue);
      expect(state().items.single.task.id, 't1');
    });

    test('reacts to queue changes', () async {
      viewModel();
      await repository.save(taskFixture(id: 'a', destination: '/d/a.mp4'));
      await repository.save(taskFixture(id: 'b', destination: '/d/b.mp4'));
      await Future<void>.delayed(Duration.zero);

      expect(state().items.map((item) => item.id), containsAll(['a', 'b']));
    });
  });

  group('per-row affordances', () {
    Future<DownloadItemUiState> rowFor(DownloadTask task) async {
      viewModel();
      await repository.save(task);
      await Future<void>.delayed(Duration.zero);
      return state().items.firstWhere((item) => item.id == task.id);
    }

    test('a running download can be paused and canceled, not resumed',
        () async {
      final row = await rowFor(running());
      expect(row.canPause, isTrue);
      expect(row.canCancel, isTrue);
      expect(row.canResume, isFalse);
      expect(row.canRetry, isFalse);
    });

    test('a paused download can be resumed', () async {
      final row = await rowFor(
        running().transitionTo(DownloadState.paused).valueOrNull!,
      );
      expect(row.canResume, isTrue);
      expect(row.canPause, isFalse);
    });

    test('a failed download offers a retry while budget remains', () async {
      final row = await rowFor(
        running()
            .transitionTo(DownloadState.failed, failureReason: 'Timeout.')
            .valueOrNull!,
      );
      expect(row.canRetry, isTrue);
      expect(row.canCancel, isFalse);
    });

    test('a finished download offers nothing', () async {
      final row = await rowFor(
        running()
            .transitionTo(DownloadState.completed)
            .valueOrNull!
            .transitionTo(DownloadState.verifying)
            .valueOrNull!
            .transitionTo(DownloadState.done)
            .valueOrNull!,
      );
      expect(row.canPause, isFalse);
      expect(row.canResume, isFalse);
      expect(row.canCancel, isFalse);
      expect(row.canRetry, isFalse);
    });
  });

  group('bulk affordances', () {
    test('reports what the toolbar should offer', () async {
      viewModel();
      await repository.save(running(id: 'a'));
      await repository.save(
        running(id: 'b').transitionTo(DownloadState.paused).valueOrNull!,
      );
      await Future<void>.delayed(Duration.zero);

      expect(state().hasPausableWork, isTrue);
      expect(state().hasResumableWork, isTrue);
      expect(state().hasFinishedWork, isFalse);
      expect(state().active, hasLength(2));
    });

    test('offers clearing once something finished', () async {
      viewModel();
      await repository.save(
        running()
            .transitionTo(DownloadState.completed)
            .valueOrNull!
            .transitionTo(DownloadState.verifying)
            .valueOrNull!
            .transitionTo(DownloadState.done)
            .valueOrNull!,
      );
      await Future<void>.delayed(Duration.zero);
      expect(state().hasFinishedWork, isTrue);

      await viewModel().clearFinished();
      await Future<void>.delayed(Duration.zero);
      expect(state().items, isEmpty);
    });
  });

  group('transfer rate', () {
    test('is absent for downloads that are not transferring', () async {
      viewModel();
      await repository.save(taskFixture());
      await Future<void>.delayed(Duration.zero);
      expect(state().items.single.rate, isNull);
    });

    test('appears once a running download reports twice', () async {
      viewModel();
      await repository.save(running(downloaded: 100));
      await Future<void>.delayed(const Duration(milliseconds: 250));
      await repository.save(running(downloaded: 500));
      await Future<void>.delayed(Duration.zero);

      final rate = state().items.single.rate;
      expect(rate, isNotNull);
      expect(rate!.averageBytesPerSecond, greaterThan(0));
    });

    test('is dropped when a running download pauses', () async {
      viewModel();
      await repository.save(running(downloaded: 100));
      await Future<void>.delayed(const Duration(milliseconds: 250));
      await repository.save(running(downloaded: 500));
      await Future<void>.delayed(Duration.zero);
      expect(state().items.single.rate, isNotNull);

      await repository.save(
        running(downloaded: 500)
            .transitionTo(DownloadState.paused)
            .valueOrNull!,
      );
      await Future<void>.delayed(Duration.zero);
      expect(state().items.single.rate, isNull);
    });
  });

  group('state labels', () {
    test('every state has a human label', () {
      for (final downloadState in DownloadState.values) {
        expect(describeDownloadState(downloadState), isNotEmpty);
      }
    });
  });
}
