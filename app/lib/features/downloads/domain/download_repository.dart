/// Repository contract for the download queue.
///
/// Responsibility: isolate the application layer from the platform download
/// engines (WorkManager / URLSession / desktop isolates) and from local
/// persistence — infrastructure implements this per platform behind the
/// same interface (section 3, `PlatformService`).
library;

import '../../../core/error/result.dart';
import 'download_state.dart';
import 'download_task.dart';

/// Persistence + scheduling gateway for the download queue.
abstract interface class DownloadRepository {
  /// Persists a new task in [DownloadState.queued] and schedules it.
  Future<Result<DownloadTask>> enqueue(DownloadTask task);

  /// Persists a state change already validated by the entity.
  Future<Result<DownloadTask>> save(DownloadTask task);

  /// Looks a task up by [id]; Ok(null) when absent.
  Future<Result<DownloadTask?>> findById(String id);

  /// All tasks, active first, then by [DownloadTask.priority].
  Future<Result<List<DownloadTask>>> all();

  /// Reactive stream of the queue for the Downloads screen.
  Stream<List<DownloadTask>> watchAll();

  /// Removes terminal tasks in [DownloadState.done] (section 8.2,
  /// "limpar concluídos"). Returns how many were removed.
  Future<Result<int>> clearFinished();
}
