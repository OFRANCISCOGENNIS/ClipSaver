/// Repository contract for the local library (section 9).
///
/// Responsibility: keep library queries (tabs, sorting, trash) behind an
/// interface so the drift/FTS5 implementation stays in infrastructure.
library;

import '../../../core/domain/value_objects/media_format.dart';
import '../../../core/error/result.dart';
import 'library_entry.dart';

/// Sort keys offered by the library screen (section 9).
enum LibrarySort {
  /// By download completion date.
  downloadedAt,

  /// Alphabetically by title.
  name,

  /// By file size on disk.
  size,

  /// By media duration.
  duration,

  /// By origin platform slug.
  platform,
}

/// Persistence gateway for the local library.
abstract interface class LibraryRepository {
  /// Inserts or updates [entry].
  Future<Result<LibraryEntry>> save(LibraryEntry entry);

  /// Looks an entry up by [id]; Ok(null) when absent.
  Future<Result<LibraryEntry?>> findById(String id);

  /// Entries for one tab, excluding trashed items.
  Future<Result<List<LibraryEntry>>> list({
    MediaKind? kind,
    bool favoritesOnly = false,
    LibrarySort sort = LibrarySort.downloadedAt,
    bool descending = true,
  });

  /// Reactive stream for tab counters and live grid/list updates.
  Stream<List<LibraryEntry>> watchAll();

  /// Soft-delete into the internal trash.
  Future<Result<LibraryEntry>> moveToTrash(String id, DateTime now);

  /// Restore from trash to [LibraryFileStatus.available].
  Future<Result<LibraryEntry>> restoreFromTrash(String id);

  /// Permanently removes entries whose trash retention expired.
  /// Returns how many were purged.
  Future<Result<int>> purgeExpiredTrash(DateTime now);
}
