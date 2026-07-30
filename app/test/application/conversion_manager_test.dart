import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:vidora/features/converter/application/conversion_manager.dart';
import 'package:vidora/features/converter/domain/conversion_job.dart';
import 'package:vidora/features/converter/domain/conversion_request.dart';
import 'package:vidora/features/converter/domain/media_converter.dart';
import 'package:vidora/features/converter/infrastructure/in_memory_converter_repository.dart';

/// Converter whose runs the test drives explicitly.
final class FakeConverter implements MediaConverter {
  /// Completers per job, so a test can hold a conversion open.
  final Map<String, Completer<ConversionResult>> pending = {};

  /// Arguments each run received.
  final Map<String, List<String>> receivedArguments = {};

  /// Progress callbacks, to simulate FFmpeg reporting.
  final Map<String, void Function(double)> progressSinks = {};

  /// Ids the manager asked to cancel.
  final List<String> canceled = [];

  @override
  Future<ConversionResult> run({
    required String jobId,
    required List<String> arguments,
    required Duration? sourceDuration,
    required void Function(double progress) onProgress,
  }) {
    receivedArguments[jobId] = arguments;
    progressSinks[jobId] = onProgress;
    final completer = Completer<ConversionResult>();
    pending[jobId] = completer;
    return completer.future;
  }

  @override
  void cancel(String jobId) {
    canceled.add(jobId);
    _complete(jobId, const ConversionResult(ConversionOutcome.canceled));
  }

  /// Finishes [jobId] with [outcome].
  void finish(String jobId, ConversionOutcome outcome, {String? error}) {
    _complete(jobId, ConversionResult(outcome, errorMessage: error));
  }

  /// Completes at most once: teardown disposes the manager, which cancels
  /// jobs a test may already have finished.
  void _complete(String jobId, ConversionResult result) {
    final completer = pending[jobId];
    if (completer != null && !completer.isCompleted) completer.complete(result);
  }
}

void main() {
  late InMemoryConverterRepository repository;
  late FakeConverter converter;
  late ConversionManager manager;

  setUp(() {
    repository = InMemoryConverterRepository();
    converter = FakeConverter();
    manager = ConversionManager(repository: repository, converter: converter);
  });

  tearDown(() async {
    manager.dispose();
    await repository.dispose();
  });

  Future<ConversionJob> enqueue({
    String entryId = 'l1',
    ConversionTarget target = ConversionTarget.mp3,
    Duration? sourceDuration = const Duration(minutes: 2),
  }) async {
    final result = await manager.enqueue(
      libraryEntryId: entryId,
      sourcePath: '/library/aula.mp4',
      request: ConversionRequest(target: target),
      sourceDuration: sourceDuration,
    );
    await Future<void>.delayed(Duration.zero);
    return result.valueOrNull!;
  }

  Future<ConversionState?> stateOf(String id) async =>
      (await repository.findById(id)).valueOrNull?.state;

  test('enqueueing starts the conversion and passes FFmpeg arguments',
      () async {
    final job = await enqueue();

    expect(await stateOf(job.id), ConversionState.converting);
    expect(converter.receivedArguments[job.id], contains('-i'));
    expect(converter.receivedArguments[job.id]!.last, endsWith('.mp3'));
  });

  test('a successful run completes the job at 100%', () async {
    final job = await enqueue();
    converter.finish(job.id, ConversionOutcome.success);
    await Future<void>.delayed(Duration.zero);

    final finished = (await repository.findById(job.id)).valueOrNull!;
    expect(finished.state, ConversionState.completed);
    expect(finished.progress, 1.0);
  });

  test('progress reported by FFmpeg reaches the queue', () async {
    final job = await enqueue();
    converter.progressSinks[job.id]!(0.42);
    await Future<void>.delayed(Duration.zero);

    expect((await repository.findById(job.id)).valueOrNull!.progress, 0.42);
    converter.finish(job.id, ConversionOutcome.success);
  });

  test('a failed run keeps the reason for the user', () async {
    final job = await enqueue();
    converter.finish(
      job.id,
      ConversionOutcome.failure,
      error: 'Codec não suportado.',
    );
    await Future<void>.delayed(Duration.zero);

    final failed = (await repository.findById(job.id)).valueOrNull!;
    expect(failed.state, ConversionState.failed);
    expect(failed.failureReason, 'Codec não suportado.');
  });

  test('a failure without a message still gets a readable reason', () async {
    final job = await enqueue();
    converter.finish(job.id, ConversionOutcome.failure);
    await Future<void>.delayed(Duration.zero);

    final failed = (await repository.findById(job.id)).valueOrNull!;
    expect(failed.failureReason, isNotEmpty);
  });

  test('runs one conversion at a time — FFmpeg saturates the CPU', () async {
    final first = await enqueue(entryId: 'a');
    final second = await enqueue(entryId: 'b');

    expect(manager.runningJobIds, {first.id});
    expect(await stateOf(second.id), ConversionState.queued);

    converter.finish(first.id, ConversionOutcome.success);
    await Future<void>.delayed(Duration.zero);
    expect(manager.runningJobIds, {second.id});
    converter.finish(second.id, ConversionOutcome.success);
  });

  test('cancelling a running conversion aborts FFmpeg', () async {
    final job = await enqueue();
    await manager.cancel(job.id);
    await Future<void>.delayed(Duration.zero);

    expect(converter.canceled, [job.id]);
    expect(await stateOf(job.id), ConversionState.canceled);
  });

  test('cancelling a queued conversion never starts it', () async {
    final first = await enqueue(entryId: 'a');
    final second = await enqueue(entryId: 'b');

    await manager.cancel(second.id);
    expect(await stateOf(second.id), ConversionState.canceled);
    expect(converter.receivedArguments.containsKey(second.id), isFalse);

    converter.finish(first.id, ConversionOutcome.success);
  });

  test('retry re-queues a failed conversion', () async {
    final job = await enqueue();
    converter.finish(job.id, ConversionOutcome.failure, error: 'x');
    await Future<void>.delayed(Duration.zero);

    await manager.retry(job.id);
    await Future<void>.delayed(Duration.zero);
    expect(await stateOf(job.id), ConversionState.converting);
    converter.finish(job.id, ConversionOutcome.success);
  });

  test('retrying an unknown job reports it rather than crashing', () async {
    expect((await manager.retry('nope')).isErr, isTrue);
    expect((await manager.cancel('nope')).isErr, isTrue);
  });

  test('re-requesting the same output replaces the pending job', () async {
    final first = await enqueue(entryId: 'l1', target: ConversionTarget.mp3);
    final second = await enqueue(entryId: 'l1', target: ConversionTarget.mp3);

    expect(second.id, first.id);
    expect((await repository.all()).valueOrNull, hasLength(1));
    converter.finish(first.id, ConversionOutcome.success);
  });

  test('different targets for the same entry are separate jobs', () async {
    final mp3 = await enqueue(entryId: 'l1', target: ConversionTarget.mp3);
    final flac = await enqueue(entryId: 'l1', target: ConversionTarget.flac);

    expect(flac.id, isNot(mp3.id));
    expect((await repository.all()).valueOrNull, hasLength(2));
    converter.finish(mp3.id, ConversionOutcome.success);
  });

  test('clearFinished drops completed conversions', () async {
    final job = await enqueue();
    converter.finish(job.id, ConversionOutcome.success);
    await Future<void>.delayed(Duration.zero);

    expect((await manager.clearFinished()).valueOrNull, 1);
    expect((await repository.all()).valueOrNull, isEmpty);
  });

  test('dispose aborts everything in flight', () async {
    final job = await enqueue();
    manager.dispose();
    expect(converter.canceled, contains(job.id));
  });

  group('output path', () {
    test('swaps the extension for the target container', () {
      final job = ConversionJob(
        id: 'c1',
        libraryEntryId: 'l1',
        sourcePath: '/library/aula.mp4',
        request: const ConversionRequest(target: ConversionTarget.mp3),
      );
      expect(job.outputPath, '/library/aula.mp3');
    });

    test('never overwrites its own input when the container matches', () {
      final job = ConversionJob(
        id: 'c1',
        libraryEntryId: 'l1',
        sourcePath: '/library/aula.mp4',
        request: const ConversionRequest(target: ConversionTarget.mp4),
      );
      expect(job.outputPath, '/library/aula (convertido).mp4');
    });

    test('handles sources without an extension', () {
      final job = ConversionJob(
        id: 'c1',
        libraryEntryId: 'l1',
        sourcePath: '/library/aula',
        request: const ConversionRequest(target: ConversionTarget.mp3),
      );
      expect(job.outputPath, '/library/aula.mp3');
    });
  });
}
