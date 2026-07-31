import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:vidora/features/downloads/application/download_manager.dart';
import 'package:vidora/features/downloads/domain/download_state.dart';
import 'package:vidora/features/downloads/domain/download_task.dart';
import 'package:vidora/features/downloads/infrastructure/download_engine.dart';
import 'package:vidora/features/downloads/infrastructure/download_transport.dart';

import '../support/download_fakes.dart';
import '../support/in_memory_download_repository.dart';

void main() {
  late InMemoryDownloadRepository repository;
  late FakeFileSystem fs;
  late List<Duration> backoffs;

  setUp(() {
    repository = InMemoryDownloadRepository();
    fs = FakeFileSystem();
    backoffs = [];
  });

  tearDown(() => repository.dispose());

  DownloadManager managerWith(
    FakeTransport transport, {
    int maxConcurrent = 3,
  }) =>
      DownloadManager(
        repository: repository,
        engine: DownloadEngine(transport: transport, fileSystem: fs),
        maxConcurrent: maxConcurrent,
        delay: (duration) async => backoffs.add(duration),
      );

  DownloadStream Function(int) ok(List<int> bytes) =>
      (_) => streamOf([bytes], totalBytes: bytes.length);

  DownloadStream Function(int) boom() => (_) => throw const FakeNetworkError();

  test('enqueue runs the transfer through to done', () async {
    final manager = managerWith(FakeTransport([
      ok([1, 2, 3])
    ]));
    await manager.enqueue(taskFixture());
    await repository.waitUntil(
      (tasks) => tasks.every((t) => t.state == DownloadState.done),
    );
    expect(repository.stateOf('t1'), DownloadState.done);
    manager.dispose();
  });

  test('honors the concurrency limit', () async {
    final gateA = StreamController<List<int>>();
    final gateB = StreamController<List<int>>();
    final transport = FakeTransport([
      (_) => DownloadStream(bytes: gateA.stream, resumed: false, totalBytes: 1),
      (_) => DownloadStream(bytes: gateB.stream, resumed: false, totalBytes: 1),
    ]);
    final manager = managerWith(transport, maxConcurrent: 1);

    await manager.enqueue(taskFixture(id: 'a', destination: '/d/a.mp4'));
    await manager.enqueue(taskFixture(id: 'b', destination: '/d/b.mp4'));
    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(manager.runningTaskIds, {'a'});
    expect(repository.stateOf('b'), DownloadState.queued);

    gateA.add([1]);
    await gateA.close();
    await repository
        .waitUntil((_) => repository.stateOf('a') == DownloadState.done);
    await Future<void>.delayed(const Duration(milliseconds: 20));

    // Slot freed → the second task starts.
    expect(manager.runningTaskIds, {'b'});
    gateB.add([1]);
    await gateB.close();
    await repository
        .waitUntil((_) => repository.stateOf('b') == DownloadState.done);
    manager.dispose();
  });

  test('clamps the concurrency limit to the documented 1..8 range', () {
    expect(managerWith(FakeTransport([]), maxConcurrent: 0).maxConcurrent, 1);
    expect(managerWith(FakeTransport([]), maxConcurrent: 99).maxConcurrent, 8);
  });

  test('raising the limit starts more transfers', () async {
    final gates = [
      StreamController<List<int>>(),
      StreamController<List<int>>()
    ];
    final transport = FakeTransport([
      for (final gate in gates)
        (_) =>
            DownloadStream(bytes: gate.stream, resumed: false, totalBytes: 1),
    ]);
    final manager = managerWith(transport, maxConcurrent: 1);
    await manager.enqueue(taskFixture(id: 'a', destination: '/d/a.mp4'));
    await manager.enqueue(taskFixture(id: 'b', destination: '/d/b.mp4'));
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(manager.runningTaskIds, hasLength(1));

    await manager.setMaxConcurrent(2);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(manager.runningTaskIds, hasLength(2));

    for (final gate in gates) {
      gate.add([1]);
      await gate.close();
    }
    manager.dispose();
  });

  group('retry with backoff (section 8.2)', () {
    test('retries a failed transfer and succeeds on the second attempt',
        () async {
      final manager = managerWith(FakeTransport([
        boom(),
        ok([1, 2])
      ]));
      await manager.enqueue(taskFixture());
      await repository.waitUntil(
        (_) => repository.stateOf('t1') == DownloadState.done,
      );

      expect(backoffs, [const Duration(seconds: 1)]);
      expect(repository.history['t1'], contains(DownloadState.failed));
      manager.dispose();
    });

    test('follows the documented backoff curve across attempts', () async {
      final manager = managerWith(
        FakeTransport([
          boom(),
          boom(),
          boom(),
          ok([1])
        ]),
      );
      await manager.enqueue(taskFixture());
      await repository.waitUntil(
        (_) => repository.stateOf('t1') == DownloadState.done,
      );

      expect(backoffs, [
        const Duration(seconds: 1),
        const Duration(seconds: 2),
        const Duration(seconds: 4),
      ]);
      manager.dispose();
    });

    test('stops retrying once the budget is exhausted', () async {
      const attempts = DownloadTask.maxRetries + 1;
      final manager = managerWith(
        FakeTransport([for (var i = 0; i < attempts; i++) boom()]),
      );
      await manager.enqueue(taskFixture());
      await repository.waitUntil(
        (_) =>
            repository.stateOf('t1') == DownloadState.failed &&
            backoffs.length == DownloadTask.maxRetries,
      );
      await Future<void>.delayed(const Duration(milliseconds: 30));

      expect(backoffs, hasLength(DownloadTask.maxRetries));
      expect(repository.stateOf('t1'), DownloadState.failed);
      manager.dispose();
    });

    test('manual retry re-queues a failed download', () async {
      final manager = managerWith(
        FakeTransport([
          for (var i = 0; i <= DownloadTask.maxRetries; i++) boom(),
          ok([1]),
        ]),
      );
      await manager.enqueue(taskFixture());
      await repository.waitUntil(
        (_) =>
            repository.stateOf('t1') == DownloadState.failed &&
            backoffs.length == DownloadTask.maxRetries,
      );
      await Future<void>.delayed(const Duration(milliseconds: 30));

      // Budget spent: the domain refuses another retry.
      final refused = await manager.retry('t1');
      expect(refused.isErr, isTrue);
      manager.dispose();
    });
  });

  group('user controls', () {
    test('pauses a running transfer, keeping its bytes', () async {
      final gate = StreamController<List<int>>();
      final manager = managerWith(
        FakeTransport([
          (_) =>
              DownloadStream(bytes: gate.stream, resumed: false, totalBytes: 9),
        ]),
      );
      await manager.enqueue(taskFixture());
      gate.add([1, 2, 3]);
      await repository.waitUntil(
        (tasks) => tasks.single.bytesDownloaded.bytes == 3,
      );

      await manager.pause('t1');
      await gate.close();
      await repository.waitUntil(
        (_) => repository.stateOf('t1') == DownloadState.paused,
      );
      expect(fs.files['/downloads/file.mp4.vidora-part'], [1, 2, 3]);
      manager.dispose();
    });

    test('a queued task held back by pause is not scheduled', () async {
      final gate = StreamController<List<int>>();
      final manager = managerWith(
        FakeTransport([
          (_) =>
              DownloadStream(bytes: gate.stream, resumed: false, totalBytes: 1),
          ok([1]),
        ]),
        maxConcurrent: 1,
      );
      await manager.enqueue(taskFixture(id: 'a', destination: '/d/a.mp4'));
      await manager.enqueue(taskFixture(id: 'b', destination: '/d/b.mp4'));
      await Future<void>.delayed(const Duration(milliseconds: 20));

      await manager.pause('b');
      gate.add([1]);
      await gate.close();
      await repository.waitUntil(
        (_) => repository.stateOf('a') == DownloadState.done,
      );
      await Future<void>.delayed(const Duration(milliseconds: 30));

      expect(manager.runningTaskIds, isEmpty);
      expect(repository.stateOf('b'), DownloadState.queued);

      await manager.resume('b');
      await repository.waitUntil(
        (_) => repository.stateOf('b') == DownloadState.done,
      );
      manager.dispose();
    });

    test('cancels a queued transfer', () async {
      final gate = StreamController<List<int>>();
      final manager = managerWith(
        FakeTransport([
          (_) =>
              DownloadStream(bytes: gate.stream, resumed: false, totalBytes: 1),
        ]),
        maxConcurrent: 1,
      );
      await manager.enqueue(taskFixture(id: 'a', destination: '/d/a.mp4'));
      await manager.enqueue(taskFixture(id: 'b', destination: '/d/b.mp4'));
      await Future<void>.delayed(const Duration(milliseconds: 20));

      await manager.cancel('b');
      expect(repository.stateOf('b'), DownloadState.canceled);

      gate.add([1]);
      await gate.close();
      manager.dispose();
    });

    test('pauseAll and resumeAll act on the whole queue', () async {
      final gates = [
        StreamController<List<int>>(),
        StreamController<List<int>>(),
      ];
      final manager = managerWith(
        FakeTransport([
          for (final gate in gates)
            (_) => DownloadStream(
                  bytes: gate.stream,
                  resumed: false,
                  totalBytes: 4,
                ),
          ok([1, 2, 3, 4]),
          ok([1, 2, 3, 4]),
        ]),
      );
      await manager.enqueue(taskFixture(id: 'a', destination: '/d/a.mp4'));
      await manager.enqueue(taskFixture(id: 'b', destination: '/d/b.mp4'));
      for (final gate in gates) {
        gate.add([1, 2]);
      }
      await repository.waitUntil(
        (tasks) => tasks.every((t) => t.bytesDownloaded.bytes == 2),
      );

      await manager.pauseAll();
      for (final gate in gates) {
        await gate.close();
      }
      await repository.waitUntil(
        (tasks) => tasks.every((t) => t.state == DownloadState.paused),
      );

      await manager.resumeAll();
      await repository.waitUntil(
        (tasks) => tasks.every((t) => t.state == DownloadState.done),
      );
      manager.dispose();
    });

    test('clearFinished removes completed downloads', () async {
      final manager = managerWith(FakeTransport([
        ok([1])
      ]));
      await manager.enqueue(taskFixture());
      await repository.waitUntil(
        (_) => repository.stateOf('t1') == DownloadState.done,
      );
      expect((await manager.clearFinished()).valueOrNull, 1);
      manager.dispose();
    });
  });

  group('restoreQueue after an app restart', () {
    test('a download interrupted mid-transfer becomes paused and resumes',
        () async {
      // Simulates the row left behind by a killed process.
      final interrupted = taskFixture()
          .transitionTo(DownloadState.connecting)
          .valueOrNull!
          .transitionTo(DownloadState.downloading)
          .valueOrNull!;
      await repository.save(interrupted);
      fs.files['/downloads/file.mp4.vidora-part'] = [1, 2];

      final manager = managerWith(
        FakeTransport([
          (_) => streamOf(
                [
                  [3, 4],
                ],
                resumed: true,
                totalBytes: 4,
              ),
        ]),
      );
      await manager.restoreQueue();

      expect(repository.history['t1'], contains(DownloadState.paused));
      manager.dispose();
    });

    test('a download stuck in connecting fails with a visible reason',
        () async {
      final stuck =
          taskFixture().transitionTo(DownloadState.connecting).valueOrNull!;
      await repository.save(stuck);

      final manager = managerWith(FakeTransport([]));
      await manager.restoreQueue();

      expect(repository.stateOf('t1'), DownloadState.failed);
      manager.dispose();
    });

    test('leaves queued and finished downloads untouched', () async {
      await repository.save(taskFixture(id: 'q', destination: '/d/q.mp4'));
      final manager = managerWith(FakeTransport([
        ok([1])
      ]));
      await manager.restoreQueue();
      await repository.waitUntil(
        (_) => repository.stateOf('q') == DownloadState.done,
      );
      manager.dispose();
    });
  });

  group('eventos terminais', () {
    test('um download concluído é anunciado uma vez', () async {
      final manager = managerWith(FakeTransport([
        ok([1, 2, 3])
      ]));
      final vistos = <DownloadTask>[];
      final sub = manager.terminalUpdates.listen(vistos.add);

      await manager.enqueue(taskFixture());
      await repository.waitUntil(
        (tasks) => tasks.every((t) => t.state == DownloadState.done),
      );
      await Future<void>.delayed(Duration.zero);

      expect(vistos, hasLength(1));
      expect(vistos.single.state, DownloadState.done);
      await sub.cancel();
      manager.dispose();
    });

    test('uma falha com retry pela frente não é anunciada', () async {
      // Só a primeira tentativa falha; o agendador re-enfileira sozinho e
      // o download termina. Avisar "falhou" no meio disso seria gritar
      // lobo: quando o usuário olhasse, estaria concluído.
      final manager = managerWith(FakeTransport([
        boom(),
        ok([1, 2, 3]),
      ]));
      final vistos = <DownloadTask>[];
      final sub = manager.terminalUpdates.listen(vistos.add);

      await manager.enqueue(taskFixture());
      await repository.waitUntil(
        (tasks) => tasks.every((t) => t.state == DownloadState.done),
      );
      await Future<void>.delayed(Duration.zero);

      expect(vistos.map((t) => t.state), [DownloadState.done]);
      await sub.cancel();
      manager.dispose();
    });

    test('a falha final, com o orçamento de retry gasto, é anunciada',
        () async {
      const tentativas = DownloadTask.maxRetries + 1;
      final manager = managerWith(
        FakeTransport(List.generate(tentativas, (_) => boom())),
      );
      final vistos = <DownloadTask>[];
      final sub = manager.terminalUpdates.listen(vistos.add);

      await manager.enqueue(taskFixture());
      await repository.waitUntil(
        (tasks) =>
            tasks.every((t) => t.state == DownloadState.failed) &&
            backoffs.length == DownloadTask.maxRetries,
      );
      await Future<void>.delayed(Duration.zero);

      // Uma só: as falhas intermediárias ficaram caladas.
      expect(vistos, hasLength(1));
      expect(vistos.single.state, DownloadState.failed);
      expect(vistos.single.canRetry, isFalse);
      await sub.cancel();
      manager.dispose();
    });
  });
}

/// Stand-in for a transport-level network error.
final class FakeNetworkError implements Exception {
  const FakeNetworkError();
}
