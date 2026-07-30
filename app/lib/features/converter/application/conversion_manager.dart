/// Conversion queue scheduler (section 11).
///
/// Responsibility: run conversions one at a time, independently of the
/// download queue, driving each job through its state machine. FFmpeg
/// saturates the CPU, so the default concurrency is 1 — running several
/// at once would make all of them slower and starve the UI thread.
library;

import 'dart:async';

import '../../../core/error/failures.dart';
import '../../../core/error/result.dart';
import '../domain/conversion_job.dart';
import '../domain/conversion_request.dart';
import '../domain/media_converter.dart';
import '../infrastructure/in_memory_converter_repository.dart';
import 'ffmpeg_command_builder.dart';

/// Schedules and supervises the conversion queue.
final class ConversionManager {
  /// Creates the manager.
  ConversionManager({
    required InMemoryConverterRepository repository,
    required MediaConverter converter,
    int maxConcurrent = 1,
  })  : _repository = repository,
        _converter = converter,
        _maxConcurrent = maxConcurrent < 1 ? 1 : maxConcurrent;

  final InMemoryConverterRepository _repository;
  final MediaConverter _converter;
  final int _maxConcurrent;

  final Set<String> _running = {};
  bool _pumping = false;
  bool _disposed = false;

  /// Ids of conversions currently running.
  Set<String> get runningJobIds => Set.unmodifiable(_running);

  /// Enqueues a conversion of [sourcePath] for the given library entry.
  Future<Result<ConversionJob>> enqueue({
    required String libraryEntryId,
    required String sourcePath,
    required ConversionRequest request,
    Duration? sourceDuration,
  }) async {
    final job = ConversionJob(
      // One queued conversion per (entry, target): re-requesting the same
      // output replaces the pending job instead of duplicating work.
      id: '$libraryEntryId:${request.target.extension}',
      libraryEntryId: libraryEntryId,
      sourcePath: sourcePath,
      request: request,
      sourceDuration: sourceDuration,
    );
    final saved = await _repository.enqueue(job);
    if (saved.isOk) unawaited(_pump());
    return saved;
  }

  /// Cancels a conversion, running or queued.
  Future<Result<ConversionJob>> cancel(String id) async {
    final found = await _repository.findById(id);
    final job = found.valueOrNull;
    if (job == null) {
      return const Result.err(StorageFailure('Conversão não encontrada.'));
    }
    if (_running.contains(id)) {
      _converter.cancel(id);
      return Result.ok(job);
    }
    final canceled = job.transitionTo(ConversionState.canceled);
    final value = canceled.valueOrNull;
    if (value == null) return canceled;
    return _repository.save(value);
  }

  /// Re-queues a failed conversion.
  Future<Result<ConversionJob>> retry(String id) async {
    final found = await _repository.findById(id);
    final job = found.valueOrNull;
    if (job == null) {
      return const Result.err(StorageFailure('Conversão não encontrada.'));
    }
    final requeued = job.transitionTo(ConversionState.queued);
    final value = requeued.valueOrNull;
    if (value == null) return requeued;
    final saved = await _repository.save(value);
    if (saved.isOk) unawaited(_pump());
    return saved;
  }

  /// Removes finished conversions from the queue view.
  Future<Result<int>> clearFinished() => _repository.clearFinished();

  /// Stops scheduling and aborts running conversions.
  void dispose() {
    _disposed = true;
    for (final id in _running.toList()) {
      _converter.cancel(id);
    }
  }

  Future<void> _pump() async {
    if (_pumping || _disposed) return;
    _pumping = true;
    try {
      while (_running.length < _maxConcurrent) {
        final next = await _nextQueued();
        if (next == null) break;
        _running.add(next.id);
        unawaited(_run(next));
      }
    } finally {
      _pumping = false;
    }
  }

  Future<ConversionJob?> _nextQueued() async {
    final all = await _repository.all();
    for (final job in all.valueOrNull ?? const <ConversionJob>[]) {
      if (_running.contains(job.id)) continue;
      if (job.state == ConversionState.queued) return job;
    }
    return null;
  }

  Future<void> _run(ConversionJob queued) async {
    try {
      final started = queued.transitionTo(ConversionState.converting);
      var job = started.valueOrNull;
      if (job == null) return;
      await _repository.save(job);

      final result = await _converter.run(
        jobId: job.id,
        arguments: FfmpegCommandBuilder.build(
          sourcePath: job.sourcePath,
          outputPath: job.outputPath,
          request: job.request,
        ),
        sourceDuration: job.sourceDuration,
        onProgress: (progress) {
          final advanced = job!.withProgress(progress).valueOrNull;
          if (advanced != null) {
            job = advanced;
            unawaited(_repository.save(advanced));
          }
        },
      );

      final finished = switch (result.outcome) {
        ConversionOutcome.success =>
          job!.transitionTo(ConversionState.completed),
        ConversionOutcome.canceled =>
          job!.transitionTo(ConversionState.canceled),
        ConversionOutcome.failure => job!.transitionTo(
            ConversionState.failed,
            failureReason:
                result.errorMessage ?? 'A conversão falhou. Tente novamente.',
          ),
      };
      final value = finished.valueOrNull;
      if (value != null) await _repository.save(value);
    } finally {
      _running.remove(queued.id);
      if (!_disposed) unawaited(_pump());
    }
  }
}
