/// Queue scheduler for downloads (section 8.2).
///
/// Responsibility: decide *what runs when* — concurrency limit, priority
/// ordering, automatic retry with exponential backoff — and persist every
/// state change the engine emits. The engine moves bytes; this class owns
/// the policy.
library;

import 'dart:async';

import '../../../core/error/failures.dart';
import '../../../core/error/result.dart';
import '../domain/download_repository.dart';
import '../domain/download_state.dart';
import '../domain/download_task.dart';
import '../infrastructure/download_engine.dart';

/// Backoff delays between retries (section 8.2: 1s → 2s → 4s → 8s, and a
/// fifth attempt at 16s to use the full [DownloadTask.maxRetries] budget).
const List<Duration> kRetryBackoff = [
  Duration(seconds: 1),
  Duration(seconds: 2),
  Duration(seconds: 4),
  Duration(seconds: 8),
  Duration(seconds: 16),
];

/// Schedules and supervises the download queue.
final class DownloadManager {
  /// Creates the manager. [delay] is injectable so tests do not wait for
  /// real backoff.
  DownloadManager({
    required DownloadRepository repository,
    required DownloadEngine engine,
    int maxConcurrent = 3,
    Future<void> Function(Duration duration) delay = _realDelay,
  })  : _repository = repository,
        _engine = engine,
        _delay = delay,
        _maxConcurrent = _clampConcurrency(maxConcurrent);

  static Future<void> _realDelay(Duration duration) =>
      Future<void>.delayed(duration);

  static int _clampConcurrency(int value) => value.clamp(1, 8);

  final DownloadRepository _repository;
  final DownloadEngine _engine;
  final Future<void> Function(Duration duration) _delay;

  int _maxConcurrent;
  final Set<String> _running = {};

  /// Emits each task that reaches a state the scheduler will not act on
  /// again: `done`, or `failed` with the retry budget spent. A failure that
  /// still has retries is not terminal — it re-queues itself — and
  /// `canceled` is deliberate user action, not news.
  final StreamController<DownloadTask> _terminal =
      StreamController<DownloadTask>.broadcast();

  /// Tasks the user paused or canceled while they were waiting in queue,
  /// so the scheduler must not pick them up.
  final Set<String> _stopRequested = {};

  /// Paused tasks the user asked to resume. A paused task is inert by
  /// definition, so it only becomes schedulable once it is in here.
  final Set<String> _resumeRequested = {};
  bool _pumping = false;
  bool _disposed = false;

  /// Current parallel-download limit (1–8, section 8.2).
  int get maxConcurrent => _maxConcurrent;

  /// Terminal outcomes, for whoever needs to tell the user (notifications).
  Stream<DownloadTask> get terminalUpdates => _terminal.stream;

  /// Ids of downloads currently transferring.
  Set<String> get runningTaskIds => Set.unmodifiable(_running);

  /// Updates the limit and starts more transfers if the new one is higher.
  Future<void> setMaxConcurrent(int value) async {
    _maxConcurrent = _clampConcurrency(value);
    await _pump();
  }

  /// Enqueues [task] and starts it as soon as a slot frees up.
  Future<Result<DownloadTask>> enqueue(DownloadTask task) async {
    final saved = await _repository.enqueue(task);
    if (saved.isOk) {
      _stopRequested.remove(task.id);
      unawaited(_pump());
    }
    return saved;
  }

  /// Picks up work left behind by a previous app session: anything that
  /// was mid-flight when the process died is re-queued so it resumes from
  /// its partial file (Definition of Done: pausado sobrevive a
  /// reinicialização).
  Future<void> restoreQueue() async {
    final all = await _repository.all();
    final tasks = all.valueOrNull;
    if (tasks == null) return;
    for (final task in tasks) {
      // `connecting`/`downloading` are impossible at startup — no transfer
      // is running yet — so they are stale and become `paused`, keeping
      // their bytes for a resume.
      if (task.state == DownloadState.connecting ||
          task.state == DownloadState.downloading) {
        final paused = task.state == DownloadState.connecting
            // connecting has no edge to paused; it must fail first, which
            // also gives the user a visible reason.
            ? task.transitionTo(
                DownloadState.failed,
                failureReason: 'O aplicativo foi encerrado durante o download.',
              )
            : task.transitionTo(DownloadState.paused);
        final value = paused.valueOrNull;
        if (value != null) await _repository.save(value);
      }
    }
    await _pump();
  }

  /// Pauses a transfer, whether it is running or still waiting in queue.
  Future<Result<DownloadTask>> pause(String id) async {
    if (_running.contains(id)) {
      _engine.pause(id);
      return _repository.findById(id).then(_requireTask);
    }
    return _stopQueued(id, DownloadState.paused);
  }

  /// Resumes a paused (or queue-held) transfer.
  Future<Result<DownloadTask>> resume(String id) async {
    final found = await _repository.findById(id);
    final task = found.valueOrNull;
    if (task == null) {
      return const Result.err(StorageFailure('Download não encontrado.'));
    }
    if (task.state != DownloadState.paused &&
        task.state != DownloadState.queued) {
      return Result.err(
        InvalidTransitionFailure(
          'download em ${task.state.name} não pode ser retomado',
        ),
      );
    }
    _stopRequested.remove(id);
    if (task.state == DownloadState.paused) _resumeRequested.add(id);
    unawaited(_pump());
    return Result.ok(task);
  }

  /// Cancels a transfer; the partial file is discarded by the engine.
  Future<Result<DownloadTask>> cancel(String id) async {
    if (_running.contains(id)) {
      _engine.cancel(id);
      return _repository.findById(id).then(_requireTask);
    }
    return _stopQueued(id, DownloadState.canceled);
  }

  /// Re-queues a failed download, consuming one retry from its budget.
  Future<Result<DownloadTask>> retry(String id) async {
    final found = await _repository.findById(id);
    final task = found.valueOrNull;
    if (task == null) {
      return const Result.err(StorageFailure('Download não encontrado.'));
    }
    final requeued = task.transitionTo(DownloadState.queued);
    final value = requeued.valueOrNull;
    if (value == null) return requeued;
    final saved = await _repository.save(value);
    if (saved.isOk) {
      _stopRequested.remove(id);
      unawaited(_pump());
    }
    return saved;
  }

  /// Pauses every active download (section 8.2, ações em massa).
  Future<void> pauseAll() async {
    final all = await _repository.all();
    for (final task in all.valueOrNull ?? const <DownloadTask>[]) {
      if (task.state.isActive && task.state != DownloadState.paused) {
        await pause(task.id);
      }
    }
  }

  /// Resumes every paused download.
  Future<void> resumeAll() async {
    final all = await _repository.all();
    for (final task in all.valueOrNull ?? const <DownloadTask>[]) {
      if (task.state == DownloadState.paused) {
        await resume(task.id);
      }
    }
  }

  /// Removes finished downloads from the queue view.
  Future<Result<int>> clearFinished() => _repository.clearFinished();

  /// Stops scheduling; in-flight transfers are canceled.
  void dispose() {
    _disposed = true;
    for (final id in _running.toList()) {
      _engine.cancel(id);
    }
    unawaited(_terminal.close());
  }

  Future<Result<DownloadTask>> _stopQueued(
    String id,
    DownloadState target,
  ) async {
    final found = await _repository.findById(id);
    final task = found.valueOrNull;
    if (task == null) {
      return const Result.err(StorageFailure('Download não encontrado.'));
    }
    // A queued task has no edge to `paused`; pausing one is really just
    // holding it back from the scheduler, so it stays queued and is
    // flagged instead.
    if (target == DownloadState.paused && task.state == DownloadState.queued) {
      _stopRequested.add(id);
      return Result.ok(task);
    }
    final moved = task.transitionTo(target);
    final value = moved.valueOrNull;
    if (value == null) return moved;
    _stopRequested.add(id);
    return _repository.save(value);
  }

  Result<DownloadTask> _requireTask(Result<DownloadTask?> found) {
    final task = found.valueOrNull;
    return task == null
        ? const Result.err(StorageFailure('Download não encontrado.'))
        : Result.ok(task);
  }

  /// Starts as many queued/paused-resumable tasks as the limit allows.
  /// Serialized by [_pumping] so concurrent triggers cannot double-start.
  Future<void> _pump() async {
    if (_pumping || _disposed) return;
    _pumping = true;
    try {
      while (_running.length < _maxConcurrent) {
        final next = await _nextRunnable();
        if (next == null) break;
        _running.add(next.id);
        unawaited(_run(next));
      }
    } finally {
      _pumping = false;
    }
  }

  Future<DownloadTask?> _nextRunnable() async {
    final all = await _repository.all();
    for (final task in all.valueOrNull ?? const <DownloadTask>[]) {
      if (_running.contains(task.id) || _stopRequested.contains(task.id)) {
        continue;
      }
      if (task.state == DownloadState.queued) return task;
      if (task.state == DownloadState.paused &&
          _resumeRequested.contains(task.id)) {
        return task;
      }
    }
    return null;
  }

  Future<void> _run(DownloadTask task) async {
    try {
      final result = await _engine.run(
        task,
        onUpdate: (updated) => unawaited(_repository.save(updated)),
      );
      final finished = result.valueOrNull;
      if (finished != null && finished.state == DownloadState.done) {
        _emitTerminal(finished);
      }
      if (finished != null && finished.state == DownloadState.failed) {
        // Only a failure the scheduler gave up on is worth announcing;
        // one that will retry in a second would just cry wolf.
        if (!finished.canRetry) _emitTerminal(finished);
        await _scheduleRetry(finished);
      }
    } finally {
      _running.remove(task.id);
      _resumeRequested.remove(task.id);
      if (!_disposed) unawaited(_pump());
    }
  }

  void _emitTerminal(DownloadTask task) {
    if (!_terminal.isClosed) _terminal.add(task);
  }

  /// Re-queues a failed task after its backoff delay, while the retry
  /// budget lasts. A user-visible failure remains on screen meanwhile.
  Future<void> _scheduleRetry(DownloadTask failed) async {
    if (!failed.canRetry) return;
    await _delay(kRetryBackoff[failed.retryCount]);
    if (_disposed || _stopRequested.contains(failed.id)) return;

    // Re-read: the user may have canceled while we were waiting.
    final current = (await _repository.findById(failed.id)).valueOrNull;
    if (current == null || current.state != DownloadState.failed) return;
    final requeued = current.transitionTo(DownloadState.queued).valueOrNull;
    if (requeued == null) return;
    await _repository.save(requeued);
    unawaited(_pump());
  }
}
