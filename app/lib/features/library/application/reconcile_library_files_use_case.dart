/// Detects library files removed outside the app (section 9).
///
/// Responsibility: reconcile what the database believes with what is
/// actually on disk, so the user sees "arquivo não encontrado" with an
/// option to download again instead of a player that fails to open.
library;

import '../../../core/error/result.dart';
import '../../../core/storage/download_file_system.dart';
import '../domain/library_entry.dart';
import '../domain/library_repository.dart';

/// Outcome of one reconciliation pass.
final class ReconcileReport {
  /// Creates a report.
  const ReconcileReport({required this.wentMissing, required this.cameBack});

  /// Entries whose file disappeared since the last check.
  final int wentMissing;

  /// Entries previously flagged missing whose file is back.
  final int cameBack;

  /// Whether anything changed.
  bool get hasChanges => wentMissing > 0 || cameBack > 0;
}

/// Checks every library file and updates its status.
final class ReconcileLibraryFilesUseCase {
  /// Creates the use case.
  const ReconcileLibraryFilesUseCase({
    required LibraryRepository repository,
    required DownloadFileSystem fileSystem,
  })  : _repository = repository,
        _fileSystem = fileSystem;

  final LibraryRepository _repository;
  final DownloadFileSystem _fileSystem;

  /// Runs a full pass over the library.
  Future<Result<ReconcileReport>> call() async {
    final listed = await _repository.list();
    final entries = listed.valueOrNull;
    if (entries == null) return Result.err(listed.failureOrNull!);

    var wentMissing = 0;
    var cameBack = 0;
    for (final entry in entries) {
      // Trashed entries are excluded by `list()`, which is what we want:
      // their file may legitimately be gone already.
      final exists = await _fileSystem.exists(entry.filePath);
      if (!exists && entry.status == LibraryFileStatus.available) {
        await _repository.markMissing(entry.id);
        wentMissing++;
      } else if (exists && entry.status == LibraryFileStatus.missing) {
        await _repository.markAvailable(entry.id);
        cameBack++;
      }
    }
    return Result.ok(
      ReconcileReport(wentMissing: wentMissing, cameBack: cameBack),
    );
  }
}
