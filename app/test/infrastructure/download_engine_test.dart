import 'dart:async';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vidora/core/domain/value_objects/checksum.dart';
import 'package:vidora/core/domain/value_objects/file_size.dart';
import 'package:vidora/core/error/failures.dart';
import 'package:vidora/features/downloads/domain/download_state.dart';
import 'package:vidora/features/downloads/domain/download_task.dart';
import 'package:vidora/features/downloads/infrastructure/download_engine.dart';
import 'package:vidora/features/downloads/infrastructure/download_transport.dart';

import '../support/download_fakes.dart';

void main() {
  late FakeFileSystem fs;
  late List<DownloadState> emitted;

  setUp(() {
    fs = FakeFileSystem();
    emitted = [];
  });

  DownloadEngine engineWith(FakeTransport transport) =>
      DownloadEngine(transport: transport, fileSystem: fs);

  void record(DownloadTask task) => emitted.add(task.state);

  const part = '/downloads/file.mp4.vidora-part';
  const destination = '/downloads/file.mp4';

  group('happy path', () {
    test('drives queued → done and moves the part file atomically', () async {
      final transport = FakeTransport([
        (_) => streamOf(
              [
                [1, 2, 3],
                [4, 5],
              ],
              totalBytes: 5,
            ),
      ]);

      final result =
          await engineWith(transport).run(taskFixture(), onUpdate: record);

      final task = result.valueOrNull!;
      expect(task.state, DownloadState.done);
      expect(task.bytesDownloaded, FileSize.ofBytes(5));
      expect(task.totalBytes, FileSize.ofBytes(5));
      expect(
        emitted,
        containsAllInOrder([
          DownloadState.connecting,
          DownloadState.downloading,
          DownloadState.completed,
          DownloadState.verifying,
          DownloadState.done,
        ]),
      );
      expect(fs.renames, [(part, destination)]);
      expect(fs.files[destination], [1, 2, 3, 4, 5]);
      expect(fs.files.containsKey(part), isFalse);
    });

    test('reports progress on every chunk', () async {
      final progress = <int>[];
      final transport = FakeTransport([
        (_) => streamOf(
              [
                [1, 2],
                [3, 4],
                [5],
              ],
              totalBytes: 5,
            ),
      ]);

      await engineWith(transport).run(
        taskFixture(),
        onUpdate: (task) {
          if (task.state == DownloadState.downloading) {
            progress.add(task.bytesDownloaded.bytes);
          }
        },
      );

      expect(progress, [0, 2, 4, 5]);
    });
  });

  group('resuming', () {
    test('requests the byte offset already on disk and appends', () async {
      fs.files[part] = [1, 2, 3];
      final transport = FakeTransport([
        (_) => streamOf(
              [
                [4, 5],
              ],
              resumed: true,
              totalBytes: 5,
            ),
      ]);

      final result =
          await engineWith(transport).run(taskFixture(), onUpdate: record);

      expect(transport.requestedOffsets, [3]);
      expect(result.valueOrNull!.state, DownloadState.done);
      expect(fs.files[destination], [1, 2, 3, 4, 5]);
    });

    test('discards partial bytes when the server ignores the Range header',
        () async {
      fs.files[part] = [9, 9, 9];
      final transport = FakeTransport([
        // resumed: false — a 200 response restarting from byte 0.
        (_) => streamOf(
              [
                [1, 2, 3, 4, 5],
              ],
              totalBytes: 5,
            ),
      ]);

      final result =
          await engineWith(transport).run(taskFixture(), onUpdate: record);

      expect(result.valueOrNull!.state, DownloadState.done);
      expect(fs.files[destination], [1, 2, 3, 4, 5]);
    });

    test('restarts when the partial file is larger than the resource',
        () async {
      fs.files[part] = [1, 2, 3, 4, 5, 6, 7, 8];
      final transport = FakeTransport([
        (_) => streamOf(
              [
                [1, 2, 3],
              ],
              resumed: true,
              totalBytes: 3,
            ),
      ]);

      final result =
          await engineWith(transport).run(taskFixture(), onUpdate: record);

      expect(result.valueOrNull!.state, DownloadState.done);
      expect(fs.files[destination], [1, 2, 3]);
    });

    test('a paused task resumes without passing through connecting', () async {
      final paused = taskFixture()
          .transitionTo(DownloadState.connecting)
          .valueOrNull!
          .transitionTo(DownloadState.downloading)
          .valueOrNull!
          .transitionTo(DownloadState.paused)
          .valueOrNull!;
      final transport = FakeTransport([
        (_) => streamOf(
              [
                [1],
              ],
              resumed: true,
              totalBytes: 1,
            ),
      ]);

      final result = await engineWith(transport).run(paused, onUpdate: record);

      expect(result.valueOrNull!.state, DownloadState.done);
      expect(emitted, isNot(contains(DownloadState.connecting)));
      expect(emitted.first, DownloadState.downloading);
    });
  });

  group('pause and cancel', () {
    /// Builds a transport whose stream stays open until the test closes it.
    (FakeTransport, StreamController<List<int>>) openEndedTransport() {
      // The controller is returned for the caller to close — that is the
      // whole point of this helper, so the analyzer's local check misses it.
      // ignore: close_sinks
      final controller = StreamController<List<int>>();
      final transport = FakeTransport([
        (_) => DownloadStream(
              bytes: controller.stream,
              resumed: false,
              totalBytes: 10,
            ),
      ]);
      return (transport, controller);
    }

    test('pause keeps the partial bytes for a later resume', () async {
      final (transport, controller) = openEndedTransport();
      final engine = engineWith(transport);
      final task = taskFixture();

      final run = engine.run(task, onUpdate: record);
      controller.add([1, 2, 3]);
      await Future<void>.delayed(Duration.zero);
      engine.pause(task.id);
      await controller.close();

      final result = await run;
      expect(result.valueOrNull!.state, DownloadState.paused);
      expect(fs.files[part], [1, 2, 3]);
      expect(fs.files.containsKey(destination), isFalse);
      expect(transport.lastHandle!.canceled, isTrue);
    });

    test('cancel discards the partial file', () async {
      final (transport, controller) = openEndedTransport();
      final engine = engineWith(transport);
      final task = taskFixture();

      final run = engine.run(task, onUpdate: record);
      controller.add([1, 2, 3]);
      await Future<void>.delayed(Duration.zero);
      engine.cancel(task.id);
      await controller.close();

      final result = await run;
      expect(result.valueOrNull!.state, DownloadState.canceled);
      expect(fs.files.containsKey(part), isFalse);
    });

    test('a stop requested while connecting aborts the transfer', () async {
      final controller = StreamController<List<int>>();
      late DownloadEngine engine;
      final task = taskFixture();
      final transport = FakeTransport([
        (_) => DownloadStream(bytes: controller.stream, resumed: false),
      ]);
      engine = engineWith(transport);

      // Cancel arrives between `open` being called and its stream flowing.
      final run = engine.run(
        task,
        onUpdate: (updated) {
          record(updated);
          if (updated.state == DownloadState.connecting) engine.cancel(task.id);
        },
      );
      await Future<void>.delayed(Duration.zero);
      await controller.close();

      expect((await run).valueOrNull!.state, DownloadState.canceled);
    });

    test('exposes the ids of in-flight transfers', () async {
      final (transport, controller) = openEndedTransport();
      final engine = engineWith(transport);
      final task = taskFixture();

      final run = engine.run(task, onUpdate: record);
      await Future<void>.delayed(Duration.zero);
      expect(engine.activeTaskIds, contains(task.id));

      engine.cancel(task.id);
      await controller.close();
      await run;
      expect(engine.activeTaskIds, isEmpty);
    });
  });

  group('integrity (section 8.3)', () {
    Checksum checksumOf(List<int> bytes) => Checksum.create(
          ChecksumAlgorithm.sha256,
          sha256.convert(bytes).toString(),
        ).valueOrNull!;

    test('accepts a file matching the task checksum', () async {
      const bytes = [1, 2, 3, 4];
      final task = DownloadTask(
        id: 't1',
        mediaItemId: 'm1',
        title: 'x',
        format: taskFixture().format,
        sourceUrl: 'https://files.example.com/file.mp4',
        destinationPath: destination,
        expectedChecksum: checksumOf(bytes),
      );
      final transport = FakeTransport([
        (_) => streamOf([bytes], totalBytes: 4),
      ]);

      final result = await engineWith(transport).run(task, onUpdate: record);
      expect(result.valueOrNull!.state, DownloadState.done);
    });

    test('fails and discards the file on checksum mismatch', () async {
      final task = DownloadTask(
        id: 't1',
        mediaItemId: 'm1',
        title: 'x',
        format: taskFixture().format,
        sourceUrl: 'https://files.example.com/file.mp4',
        destinationPath: destination,
        expectedChecksum: checksumOf(const [9, 9, 9, 9]),
      );
      final transport = FakeTransport([
        (_) => streamOf(
              [
                [1, 2, 3, 4],
              ],
              totalBytes: 4,
            ),
      ]);

      final result = await engineWith(transport).run(task, onUpdate: record);
      final failed = result.valueOrNull!;
      expect(failed.state, DownloadState.failed);
      expect(failed.failureReason, contains('integridade'));
      expect(fs.files.containsKey(part), isFalse);
      expect(fs.files.containsKey(destination), isFalse);
    });

    test('uses the checksum published by the server when the task has none',
        () async {
      const bytes = [7, 7, 7];
      final transport = FakeTransport([
        (_) => streamOf(
              [bytes],
              totalBytes: 3,
              checksumHex: sha256.convert(bytes).toString(),
            ),
      ]);

      final result =
          await engineWith(transport).run(taskFixture(), onUpdate: record);
      expect(result.valueOrNull!.state, DownloadState.done);
    });

    test('falls back to a size check when no checksum is available', () async {
      final transport = FakeTransport([
        (_) => streamOf(
              [
                [1, 2, 3],
              ],
              totalBytes: 3,
            ),
      ]);
      final result =
          await engineWith(transport).run(taskFixture(), onUpdate: record);
      expect(result.valueOrNull!.state, DownloadState.done);
    });

    test('rejects an empty download', () async {
      final transport = FakeTransport([(_) => streamOf([])]);
      final result =
          await engineWith(transport).run(taskFixture(), onUpdate: record);
      final failed = result.valueOrNull!;
      expect(failed.state, DownloadState.failed);
      expect(failed.failureReason, contains('vazio'));
    });
  });

  group('failures', () {
    test('a connection error fails the task with a readable reason', () async {
      final transport = FakeTransport([
        (_) => throw const SocketExceptionStub(),
      ]);
      final result =
          await engineWith(transport).run(taskFixture(), onUpdate: record);
      final failed = result.valueOrNull!;
      expect(failed.state, DownloadState.failed);
      expect(failed.failureReason, contains('conectar'));
    });

    test('a stream that ends early fails instead of publishing the file',
        () async {
      final transport = FakeTransport([
        (_) => streamOf(
              [
                [1, 2],
              ],
              totalBytes: 10,
            ),
      ]);
      final result =
          await engineWith(transport).run(taskFixture(), onUpdate: record);
      final failed = result.valueOrNull!;
      expect(failed.state, DownloadState.failed);
      expect(failed.failureReason, contains('caiu'));
      expect(fs.files.containsKey(destination), isFalse);
      // Bytes are kept: a retry resumes from where it stopped.
      expect(fs.files[part], [1, 2]);
    });

    test('a mid-stream error fails the task', () async {
      final transport = FakeTransport([
        (_) => DownloadStream(
              bytes: Stream<List<int>>.error(const SocketExceptionStub()),
              resumed: false,
              totalBytes: 10,
            ),
      ]);
      final result =
          await engineWith(transport).run(taskFixture(), onUpdate: record);
      expect(result.valueOrNull!.state, DownloadState.failed);
    });

    test('an origin sending more bytes than announced fails the transfer',
        () async {
      final transport = FakeTransport([
        (_) => streamOf(
              [
                [1, 2, 3, 4, 5],
              ],
              totalBytes: 2,
            ),
      ]);
      final result =
          await engineWith(transport).run(taskFixture(), onUpdate: record);
      final failed = result.valueOrNull!;
      expect(failed.state, DownloadState.failed);
      expect(failed.failureReason, contains('mais dados'));
    });

    test('refuses to start a task that is not queued or paused', () async {
      final done =
          taskFixture().transitionTo(DownloadState.canceled).valueOrNull!;
      final result =
          await engineWith(FakeTransport([])).run(done, onUpdate: record);
      expect(result.failureOrNull, isA<InvalidTransitionFailure>());
    });
  });
}

/// Stand-in for a transport-level network error.
final class SocketExceptionStub implements Exception {
  const SocketExceptionStub();
}
