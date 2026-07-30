/// In-memory conversion queue.
///
/// Responsibility: hold the conversion queue for the current session.
/// Unlike downloads — which section 18 requires to survive an app
/// restart — a conversion has no partial output worth resuming: FFmpeg
/// writes to a temporary file that is discarded on abort. Persisting the
/// queue would only resurrect jobs whose work was already thrown away.
library;

import 'dart:async';

import '../../../core/error/result.dart';
import '../domain/conversion_job.dart';
import '../domain/converter_repository.dart';

/// Session-scoped conversion queue.
final class InMemoryConverterRepository implements ConverterRepository {
  final Map<String, ConversionJob> _jobs = {};
  final StreamController<List<ConversionJob>> _changes =
      StreamController<List<ConversionJob>>.broadcast();

  List<ConversionJob> get _ordered {
    // Active jobs first, then by insertion order (Map preserves it).
    final jobs = _jobs.values.toList();
    jobs.sort((a, b) {
      int rank(ConversionJob job) => switch (job.state) {
            ConversionState.converting => 0,
            ConversionState.queued => 1,
            _ => 2,
          };
      return rank(a).compareTo(rank(b));
    });
    return jobs;
  }

  @override
  Future<Result<ConversionJob>> enqueue(ConversionJob job) => save(job);

  @override
  Future<Result<ConversionJob>> save(ConversionJob job) async {
    _jobs[job.id] = job;
    if (!_changes.isClosed) _changes.add(_ordered);
    return Result.ok(job);
  }

  @override
  Future<Result<ConversionJob?>> findById(String id) async =>
      Result.ok(_jobs[id]);

  @override
  Stream<List<ConversionJob>> watchAll() => _changes.stream;

  /// All jobs in display order.
  Future<Result<List<ConversionJob>>> all() async => Result.ok(_ordered);

  /// Drops finished jobs from the queue view.
  Future<Result<int>> clearFinished() async {
    final removed = _jobs.values
        .where((job) => job.state == ConversionState.completed)
        .map((job) => job.id)
        .toList();
    for (final id in removed) {
      _jobs.remove(id);
    }
    if (!_changes.isClosed) _changes.add(_ordered);
    return Result.ok(removed.length);
  }

  /// Closes the change stream.
  Future<void> dispose() => _changes.close();
}
