/// In-memory [DownloadRepository] with awaitable state assertions, so
/// scheduler tests never depend on arbitrary delays.
library;

import 'dart:async';

import 'package:vidora/core/error/result.dart';
import 'package:vidora/features/downloads/domain/download_repository.dart';
import 'package:vidora/features/downloads/domain/download_state.dart';
import 'package:vidora/features/downloads/domain/download_task.dart';

final class InMemoryDownloadRepository implements DownloadRepository {
  final Map<String, DownloadTask> _tasks = {};
  final StreamController<List<DownloadTask>> _changes =
      StreamController<List<DownloadTask>>.broadcast();

  /// Every state a given task passed through, in save order.
  final Map<String, List<DownloadState>> history = {};

  List<DownloadTask> get _ordered {
    final tasks = _tasks.values.toList()
      ..sort((a, b) {
        final terminal =
            (a.state.isActive ? 0 : 1) - (b.state.isActive ? 0 : 1);
        if (terminal != 0) return terminal;
        final byPriority = a.priority.compareTo(b.priority);
        return byPriority != 0
            ? byPriority
            : a.createdAt.compareTo(b.createdAt);
      });
    return tasks;
  }

  @override
  Future<Result<DownloadTask>> enqueue(DownloadTask task) => save(task);

  @override
  Future<Result<DownloadTask>> save(DownloadTask task) async {
    _tasks[task.id] = task;
    (history[task.id] ??= []).add(task.state);
    // Transfers canceled by dispose() can save after teardown closed us.
    if (!_changes.isClosed) _changes.add(_ordered);
    return Result.ok(task);
  }

  @override
  Future<Result<DownloadTask?>> findById(String id) async =>
      Result.ok(_tasks[id]);

  @override
  Future<Result<List<DownloadTask>>> all() async => Result.ok(_ordered);

  @override
  Stream<List<DownloadTask>> watchAll() => _changes.stream;

  @override
  Future<Result<int>> clearFinished() async {
    final removed = _tasks.values
        .where((t) => t.state == DownloadState.done)
        .map((t) => t.id)
        .toList();
    for (final id in removed) {
      _tasks.remove(id);
    }
    // Transfers canceled by dispose() can save after teardown closed us.
    if (!_changes.isClosed) _changes.add(_ordered);
    return Result.ok(removed.length);
  }

  /// Completes once [predicate] holds for the current task set.
  Future<void> waitUntil(
    bool Function(List<DownloadTask> tasks) predicate, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    if (predicate(_ordered)) return;
    final completer = Completer<void>();
    final subscription = _changes.stream.listen((tasks) {
      if (!completer.isCompleted && predicate(tasks)) completer.complete();
    });
    try {
      await completer.future.timeout(timeout);
    } finally {
      await subscription.cancel();
    }
  }

  /// Current state of [id], or null when unknown.
  DownloadState? stateOf(String id) => _tasks[id]?.state;

  /// Releases the change stream.
  Future<void> dispose() => _changes.close();
}
