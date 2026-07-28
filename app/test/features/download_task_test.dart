import 'package:test/test.dart';
import 'package:vidora/core/domain/value_objects/file_size.dart';
import 'package:vidora/core/domain/value_objects/media_format.dart';
import 'package:vidora/core/error/failures.dart';
import 'package:vidora/features/downloads/domain/download_state.dart';
import 'package:vidora/features/downloads/domain/download_task.dart';

void main() {
  const format = MediaFormat(
    id: 'f1',
    kind: MediaKind.audio,
    container: 'mp3',
    bitrateKbps: 128,
  );

  DownloadTask task({DownloadState state = DownloadState.queued}) =>
      DownloadTask(
        id: 't1',
        mediaItemId: 'm1',
        title: 'Episódio 12',
        format: format,
        destinationPath: '/downloads/ep12.mp3',
        state: state,
        totalBytes: FileSize.ofBytes(1000),
      );

  group('DownloadState transition matrix (section 8.1)', () {
    const allowed = {
      DownloadState.queued: {DownloadState.connecting, DownloadState.canceled},
      DownloadState.connecting: {
        DownloadState.downloading,
        DownloadState.failed,
        DownloadState.canceled,
      },
      DownloadState.downloading: {
        DownloadState.paused,
        DownloadState.completed,
        DownloadState.failed,
        DownloadState.canceled,
      },
      DownloadState.paused: {DownloadState.downloading, DownloadState.canceled},
      DownloadState.completed: {
        DownloadState.verifying,
        DownloadState.canceled,
      },
      DownloadState.verifying: {
        DownloadState.done,
        DownloadState.failed,
        DownloadState.canceled,
      },
      DownloadState.failed: {DownloadState.queued},
      DownloadState.done: <DownloadState>{},
      DownloadState.canceled: <DownloadState>{},
    };

    test('exactly the documented transitions are allowed — full matrix', () {
      for (final from in DownloadState.values) {
        for (final to in DownloadState.values) {
          expect(
            from.canTransitionTo(to),
            allowed[from]!.contains(to),
            reason: '${from.name} → ${to.name}',
          );
        }
      }
    });

    test('active and terminal flags are consistent', () {
      expect(DownloadState.downloading.isActive, isTrue);
      expect(DownloadState.paused.isActive, isTrue);
      expect(DownloadState.done.isActive, isFalse);
      expect(DownloadState.done.isTerminal, isTrue);
      expect(DownloadState.failed.isTerminal, isTrue);
      expect(DownloadState.verifying.isTerminal, isFalse);
    });
  });

  group('DownloadTask.transitionTo', () {
    test('happy path: queued → … → done', () {
      var current = task();
      for (final next in [
        DownloadState.connecting,
        DownloadState.downloading,
        DownloadState.completed,
        DownloadState.verifying,
        DownloadState.done,
      ]) {
        final result = current.transitionTo(next);
        expect(result.isOk, isTrue, reason: '→ ${next.name}');
        current = result.valueOrNull!;
      }
      expect(current.state, DownloadState.done);
    });

    test('pause and resume round-trip preserves progress', () {
      var current = task(state: DownloadState.downloading);
      current = current.withProgress(FileSize.ofBytes(400)).valueOrNull!;
      current = current.transitionTo(DownloadState.paused).valueOrNull!;
      current = current.transitionTo(DownloadState.downloading).valueOrNull!;
      expect(current.bytesDownloaded, FileSize.ofBytes(400));
      expect(current.progress, 0.4);
    });

    test('illegal transition returns InvalidTransitionFailure', () {
      final result = task().transitionTo(DownloadState.done);
      expect(result.failureOrNull, isA<InvalidTransitionFailure>());
    });

    test('canceled is reachable from every active state', () {
      for (final state in DownloadState.values.where((s) => s.isActive)) {
        expect(
          task(state: state).transitionTo(DownloadState.canceled).isOk,
          isTrue,
          reason: 'cancel from ${state.name}',
        );
      }
    });

    test('failing requires a user-facing reason', () {
      final noReason = task(state: DownloadState.connecting)
          .transitionTo(DownloadState.failed);
      expect(noReason.failureOrNull, isA<InvalidTransitionFailure>());

      final withReason = task(state: DownloadState.connecting)
          .transitionTo(DownloadState.failed, failureReason: 'Sem conexão.');
      expect(withReason.valueOrNull!.failureReason, 'Sem conexão.');
    });

    test('retry re-enqueues, increments retryCount and clears the reason', () {
      final failed = task(state: DownloadState.connecting)
          .transitionTo(DownloadState.failed, failureReason: 'Timeout.')
          .valueOrNull!;
      final retried = failed.transitionTo(DownloadState.queued).valueOrNull!;
      expect(retried.state, DownloadState.queued);
      expect(retried.retryCount, 1);
      expect(retried.failureReason, isNull);
    });

    test('retry is refused after maxRetries attempts', () {
      var current = task(state: DownloadState.connecting)
          .transitionTo(DownloadState.failed, failureReason: 'x')
          .valueOrNull!;
      for (var i = 0; i < DownloadTask.maxRetries; i++) {
        current = current
            .transitionTo(DownloadState.queued)
            .valueOrNull!
            .transitionTo(DownloadState.connecting)
            .valueOrNull!
            .transitionTo(DownloadState.failed, failureReason: 'x')
            .valueOrNull!;
      }
      expect(current.retryCount, DownloadTask.maxRetries);
      expect(current.canRetry, isFalse);
      expect(
        current.transitionTo(DownloadState.queued).failureOrNull,
        isA<InvalidTransitionFailure>(),
      );
    });
  });

  group('DownloadTask.withProgress', () {
    test('rejects progress outside downloading state', () {
      final result = task().withProgress(FileSize.ofBytes(10));
      expect(result.failureOrNull, isA<InvalidTransitionFailure>());
    });

    test('rejects progress beyond total size', () {
      final result = task(state: DownloadState.downloading)
          .withProgress(FileSize.ofBytes(2000));
      expect(result.failureOrNull, isA<InvalidTransitionFailure>());
    });

    test('progress is 0 while total size is unknown', () {
      final unknownTotal = DownloadTask(
        id: 't2',
        mediaItemId: 'm1',
        title: 'x',
        format: format,
        destinationPath: '/d/x.mp3',
        state: DownloadState.downloading,
        bytesDownloaded: FileSize.ofBytes(500),
      );
      expect(unknownTotal.progress, 0);
    });
  });

  group('DownloadTask invariants', () {
    test('part file uses the .vidora-part extension (section 8.3)', () {
      expect(task().partFilePath, '/downloads/ep12.mp3.vidora-part');
    });

    test('constructor rejects downloaded > total', () {
      expect(
        () => DownloadTask(
          id: 't3',
          mediaItemId: 'm1',
          title: 'x',
          format: format,
          destinationPath: '/d/x.mp3',
          bytesDownloaded: FileSize.ofBytes(11),
          totalBytes: FileSize.ofBytes(10),
        ),
        throwsArgumentError,
      );
    });

    test('constructor rejects blank identifiers', () {
      expect(
        () => DownloadTask(
          id: ' ',
          mediaItemId: 'm1',
          title: 'x',
          format: format,
          destinationPath: '/d/x.mp3',
        ),
        throwsArgumentError,
      );
    });
  });
}
