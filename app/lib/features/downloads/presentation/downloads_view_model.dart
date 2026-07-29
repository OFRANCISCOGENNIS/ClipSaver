/// ViewModel of the Downloads screen (MVVM, section 4.1).
///
/// Responsibility: project the repository's reactive queue into UI rows,
/// enriching each with a smoothed transfer rate, and forward user intents
/// to the scheduler. It owns no transfer logic of its own.
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/error/result.dart';
import '../application/download_manager.dart';
import '../application/transfer_rate.dart';
import '../domain/download_state.dart';
import '../domain/download_task.dart';
import 'downloads_state.dart';

/// Provides the Downloads ViewModel.
final downloadsViewModelProvider =
    NotifierProvider<DownloadsViewModel, DownloadsUiState>(
  DownloadsViewModel.new,
);

/// Drives the Downloads screen.
final class DownloadsViewModel extends Notifier<DownloadsUiState> {
  late final DownloadManager _manager;
  final TransferRateTracker _rates = TransferRateTracker();
  StreamSubscription<List<DownloadTask>>? _subscription;

  @override
  DownloadsUiState build() {
    _manager = ref.watch(downloadManagerProvider);
    final repository = ref.watch(downloadRepositoryProvider);

    _subscription = repository.watchAll().listen(_onTasks);
    ref.onDispose(() => unawaited(_subscription?.cancel()));

    // Seed from the current queue so the screen is populated before the
    // first stream event lands.
    unawaited(
      repository.all().then((result) {
        final tasks = result.valueOrNull;
        if (tasks != null) _onTasks(tasks);
      }),
    );

    return const DownloadsUiState();
  }

  void _onTasks(List<DownloadTask> tasks) {
    _rates.retainOnly(tasks.map((task) => task.id).toSet());
    state = DownloadsUiState(
      loaded: true,
      items: [
        for (final task in tasks)
          DownloadItemUiState(task: task, rate: _rateFor(task)),
      ],
    );
  }

  TransferRate? _rateFor(DownloadTask task) {
    if (task.state != DownloadState.downloading) {
      // A stopped transfer has no meaningful speed, and keeping the last
      // sample would make a resumed download start with a stale ETA.
      _rates.forget(task.id);
      return null;
    }
    return _rates.update(
      task.id,
      task.bytesDownloaded.bytes,
      totalBytes: task.totalBytes?.bytes,
    );
  }

  /// Re-queues work left behind by a previous session.
  Future<void> restore() => _manager.restoreQueue();

  /// Pauses one download.
  Future<Result<DownloadTask>> pause(String id) => _manager.pause(id);

  /// Resumes one download.
  Future<Result<DownloadTask>> resume(String id) => _manager.resume(id);

  /// Cancels one download.
  Future<Result<DownloadTask>> cancel(String id) => _manager.cancel(id);

  /// Retries a failed download.
  Future<Result<DownloadTask>> retry(String id) => _manager.retry(id);

  /// Pauses every active download.
  Future<void> pauseAll() => _manager.pauseAll();

  /// Resumes every paused download.
  Future<void> resumeAll() => _manager.resumeAll();

  /// Removes finished rows from the queue.
  Future<void> clearFinished() async {
    await _manager.clearFinished();
  }
}

/// Human label for a queue state (section 8.1).
String describeDownloadState(DownloadState state) => switch (state) {
      DownloadState.queued => 'Na fila',
      DownloadState.connecting => 'Conectando',
      DownloadState.downloading => 'Baixando',
      DownloadState.paused => 'Pausado',
      DownloadState.completed => 'Concluindo',
      DownloadState.verifying => 'Verificando integridade',
      DownloadState.done => 'Concluído',
      DownloadState.failed => 'Falhou',
      DownloadState.canceled => 'Cancelado',
    };
