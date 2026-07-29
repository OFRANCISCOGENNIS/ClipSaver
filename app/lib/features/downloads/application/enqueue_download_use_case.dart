/// Use case: turn an analyzed item into a queued download.
///
/// Responsibility: this is the last gate before bytes move, so it re-checks
/// authorization locally. The backend already decided, but a UI bug, a
/// stale cached item or a tampered response must not be able to start a
/// download the engine was never authorized to perform (golden rule:
/// compliance wins).
library;

import 'package:path/path.dart' as p;

import '../../../core/domain/value_objects/media_format.dart';
import '../../../core/error/failures.dart';
import '../../../core/error/result.dart';
import '../../analyze/domain/media_item.dart';
import '../domain/download_task.dart';

/// Creates and enqueues download tasks.
final class EnqueueDownloadUseCase {
  /// Creates the use case; [enqueue] is the scheduler entry point.
  const EnqueueDownloadUseCase({
    required Future<Result<DownloadTask>> Function(DownloadTask task) enqueue,
    required String downloadsDirectory,
  })  : _enqueue = enqueue,
        _downloadsDirectory = downloadsDirectory;

  final Future<Result<DownloadTask>> Function(DownloadTask task) _enqueue;
  final String _downloadsDirectory;

  /// Enqueues [format] of [item].
  ///
  /// Refuses when the item is not authorized, or when [format] is not one
  /// of the renditions the eligibility engine actually returned.
  Future<Result<DownloadTask>> call(MediaItem item, MediaFormat format) async {
    if (!item.isDownloadable) {
      return Result.err(
        IneligibleContentFailure(
          item.eligibility.reason,
          legitimatePath:
              'Você pode salvá-lo na sua conta da plataforma de origem.',
        ),
      );
    }
    if (!item.eligibility.availableFormats.contains(format)) {
      return const Result.err(
        ValidationFailure('Esta qualidade não foi liberada para este item.'),
      );
    }

    final task = DownloadTask(
      // Deriving the id from item + format makes re-enqueueing the same
      // rendition idempotent instead of duplicating the queue entry.
      id: '${item.id}:${format.id}',
      mediaItemId: item.id,
      title: item.title,
      format: format,
      // A per-format URL when the origin published one; otherwise the
      // analyzed URL is itself the file (direct-file authorization).
      sourceUrl: format.url ?? item.url.value,
      destinationPath: p.join(
        _downloadsDirectory,
        buildFileName(item.title, format),
      ),
    );
    return _enqueue(task);
  }
}

/// Builds a filesystem-safe file name from [title] and [format].
///
/// Kept deterministic so re-downloading the same rendition overwrites its
/// own partial file instead of leaving orphans behind.
String buildFileName(String title, MediaFormat format) {
  final sanitized = title
      .replaceAll(RegExp(r'[\\/:*?"<>|\x00-\x1F]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  // Leave room for the ".vidora-part" suffix under the common 255-byte
  // file name limit.
  final capped =
      sanitized.length > 120 ? sanitized.substring(0, 120).trim() : sanitized;
  final base = capped.isEmpty ? 'vidora-${format.id}' : capped;
  return '$base.${format.container}';
}
