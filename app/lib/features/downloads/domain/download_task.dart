/// Immutable download task entity.
///
/// Responsibility: hold everything the download manager needs to render
/// and control one item (section 8.2) and enforce the state machine of
/// section 8.1 — every state change goes through [transitionTo], which
/// returns a typed failure for illegal moves instead of corrupting state.
library;

import '../../../core/domain/value_objects/checksum.dart';
import '../../../core/domain/value_objects/file_size.dart';
import '../../../core/domain/value_objects/media_format.dart';
import '../../../core/error/failures.dart';
import '../../../core/error/result.dart';
import 'download_state.dart';

/// One item of the download queue, with validated state transitions.
final class DownloadTask {
  /// Builds a task, validating identifiers, retry bounds and byte counts.
  DownloadTask({
    required this.id,
    required this.mediaItemId,
    required this.title,
    required this.format,
    required this.destinationPath,
    this.state = DownloadState.queued,
    this.bytesDownloaded = FileSize.zero,
    this.totalBytes,
    this.expectedChecksum,
    this.priority = 0,
    this.retryCount = 0,
    this.failureReason,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now() {
    if (id.trim().isEmpty) throw ArgumentError('id must not be empty');
    if (mediaItemId.trim().isEmpty) {
      throw ArgumentError('mediaItemId must not be empty');
    }
    if (destinationPath.trim().isEmpty) {
      throw ArgumentError('destinationPath must not be empty');
    }
    if (priority < 0) throw ArgumentError('priority must be >= 0');
    if (retryCount < 0 || retryCount > maxRetries) {
      throw ArgumentError('retryCount must be within 0..$maxRetries');
    }
    final total = totalBytes;
    if (total != null && bytesDownloaded.compareTo(total) > 0) {
      throw ArgumentError('bytesDownloaded cannot exceed totalBytes');
    }
  }

  /// Retry ceiling from section 8.2 (backoff 1s → 2s → 4s → 8s, max 5).
  static const int maxRetries = 5;

  /// Unique task identifier.
  final String id;

  /// The analyzed [MediaItem] this download materializes. The eligibility
  /// decision lives there; a task can only be created for eligible items
  /// (enforced by the enqueue use case in the application layer).
  final String mediaItemId;

  /// Denormalized title so the queue renders without joining entities.
  final String title;

  /// The exact rendition being downloaded.
  final MediaFormat format;

  /// Final path. While active, bytes live in `<path>.vidora-part` and are
  /// moved atomically on completion (section 8.3).
  final String destinationPath;

  /// Current lifecycle state.
  final DownloadState state;

  /// Bytes received so far.
  final FileSize bytesDownloaded;

  /// Null while the server hasn't reported Content-Length.
  final FileSize? totalBytes;

  /// Server-provided checksum for the verifying step, when available.
  final Checksum? expectedChecksum;

  /// Queue priority; lower runs first. Reordering (section 8.2) rewrites it.
  final int priority;

  /// Retries already consumed (max [maxRetries]).
  final int retryCount;

  /// Populated when [state] is [DownloadState.failed].
  final String? failureReason;

  /// Enqueue timestamp.
  final DateTime createdAt;

  /// Path of the temporary partial file (section 8.3).
  String get partFilePath => '$destinationPath.vidora-part';

  /// Progress in [0, 1]; 0 while total size is unknown.
  double get progress =>
      totalBytes == null ? 0 : bytesDownloaded.fractionOf(totalBytes!);

  /// Whether the failed task still has retry budget.
  bool get canRetry => state == DownloadState.failed && retryCount < maxRetries;

  /// Attempts the transition to [next], returning the updated task or an
  /// [InvalidTransitionFailure]. Retry bookkeeping happens here so callers
  /// can't forget it: failed → queued increments [retryCount] and is
  /// refused beyond [maxRetries].
  Result<DownloadTask> transitionTo(
    DownloadState next, {
    String? failureReason,
  }) {
    if (!state.canTransitionTo(next)) {
      return Result.err(
        InvalidTransitionFailure(
          'transição ${state.name} → ${next.name} não é permitida',
        ),
      );
    }
    final isRetry =
        state == DownloadState.failed && next == DownloadState.queued;
    if (isRetry && retryCount >= maxRetries) {
      return const Result.err(
        InvalidTransitionFailure(
          'limite de $maxRetries tentativas atingido',
        ),
      );
    }
    if (next == DownloadState.failed &&
        (failureReason == null || failureReason.trim().isEmpty)) {
      return const Result.err(
        InvalidTransitionFailure(
          'falha requer um motivo para exibição ao usuário',
        ),
      );
    }
    return Result.ok(
      copyWith(
        state: next,
        retryCount: isRetry ? retryCount + 1 : retryCount,
        failureReason: next == DownloadState.failed ? failureReason : null,
        clearFailureReason: next != DownloadState.failed,
      ),
    );
  }

  /// Records received bytes. Only meaningful while downloading; other
  /// states refuse so a late progress event can't resurrect a canceled task.
  Result<DownloadTask> withProgress(FileSize downloaded) {
    if (state != DownloadState.downloading) {
      return Result.err(
        InvalidTransitionFailure(
          'progresso só é aceito em downloading (estado atual: ${state.name})',
        ),
      );
    }
    final total = totalBytes;
    if (total != null && downloaded.compareTo(total) > 0) {
      return const Result.err(
        InvalidTransitionFailure('bytes recebidos excedem o total'),
      );
    }
    return Result.ok(copyWith(bytesDownloaded: downloaded));
  }

  /// Copies the task overriding the given mutable fields.
  DownloadTask copyWith({
    DownloadState? state,
    FileSize? bytesDownloaded,
    FileSize? totalBytes,
    int? priority,
    int? retryCount,
    String? failureReason,
    bool clearFailureReason = false,
  }) =>
      DownloadTask(
        id: id,
        mediaItemId: mediaItemId,
        title: title,
        format: format,
        destinationPath: destinationPath,
        state: state ?? this.state,
        bytesDownloaded: bytesDownloaded ?? this.bytesDownloaded,
        totalBytes: totalBytes ?? this.totalBytes,
        expectedChecksum: expectedChecksum,
        priority: priority ?? this.priority,
        retryCount: retryCount ?? this.retryCount,
        failureReason:
            clearFailureReason ? null : (failureReason ?? this.failureReason),
        createdAt: createdAt,
      );

  @override
  bool operator ==(Object other) => other is DownloadTask && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'DownloadTask($id, ${state.name}, ${(progress * 100).toStringAsFixed(0)}%)';
}
