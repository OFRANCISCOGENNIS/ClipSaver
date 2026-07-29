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

/// Item counts shown on the library tabs (section 9).
final class LibraryCounts {
  /// Creates the counts.
  const LibraryCounts({
    required this.videos,
    required this.audios,
    required this.favorites,
    required this.trashed,
  });

  /// Entries on the Vídeos tab.
  final int videos;

  /// Entries on the Áudios tab.
  final int audios;

  /// Entries marked as favorite.
  final int favorites;

  /// Entries sitting in the trash.
  final int trashed;

  /// Everything visible in the library (excludes the trash).
  int get total => videos + audios;

  @override
  bool operator ==(Object other) =>
      other is LibraryCounts &&
      other.videos == videos &&
      other.audios == audios &&
      other.favorites == favorites &&
      other.trashed == trashed;

  @override
  int get hashCode => Object.hash(videos, audios, favorites, trashed);

  @override
  String toString() => 'LibraryCounts(videos: $videos, audios: $audios, '
      'favorites: $favorites, trashed: $trashed)';
}

/// Persistence gateway for the local library.
abstract interface class LibraryRepository {
  /// Inserts or updates [entry], keeping the search index in step.
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

  /// Entries currently in the trash, newest first.
  Future<Result<List<LibraryEntry>>> listTrashed();

  /// Counts for the tab badges.
  Future<Result<LibraryCounts>> counts();

  /// Reactive stream for tab counters and live grid/list updates.
  Stream<List<LibraryEntry>> watchAll();

  /// Renames an entry (title only; the file on disk keeps its name).
  Future<Result<LibraryEntry>> rename(String id, String title);

  /// Replaces the entry's tags.
  Future<Result<LibraryEntry>> setTags(String id, List<String> tags);

  /// Sets or clears the favorite flag.
  Future<Result<LibraryEntry>> setFavorite(String id, {required bool favorite});

  /// Flags an entry whose file disappeared from disk (section 9).
  Future<Result<LibraryEntry>> markMissing(String id);

  /// Clears the missing flag after the file came back.
  Future<Result<LibraryEntry>> markAvailable(String id);

  /// Soft-delete into the internal trash.
  Future<Result<LibraryEntry>> moveToTrash(String id, DateTime now);

  /// Restore from trash to [LibraryFileStatus.available].
  Future<Result<LibraryEntry>> restoreFromTrash(String id);

  /// Permanently removes entries whose trash retention expired.
  /// Returns how many were purged.
  Future<Result<int>> purgeExpiredTrash(DateTime now);
}
