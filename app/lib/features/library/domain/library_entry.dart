/// A finished media file as it appears in the Library (section 9).
///
/// Responsibility: represent the on-disk file plus its provenance
/// (origin platform, license badge) and library metadata (favorites,
/// tags, trash), independent of how it was obtained.
library;

import '../../../core/domain/value_objects/file_size.dart';
import '../../../core/domain/value_objects/license.dart';
import '../../../core/domain/value_objects/media_format.dart';

/// Where the entry's file currently is, from the app's point of view.
enum LibraryFileStatus {
  /// File exists at [LibraryEntry.filePath].
  available,

  /// File was removed outside the app (section 9, "arquivo não encontrado").
  missing,

  /// Soft-deleted: kept in the internal trash for 7 days before purge.
  trashed,
}

/// One finished media file with provenance and library metadata.
final class LibraryEntry {
  /// Builds an entry, validating blanks and the trash invariant.
  LibraryEntry({
    required this.id,
    required this.title,
    required this.filePath,
    required this.kind,
    required this.size,
    required this.downloadedAt,
    this.duration,
    this.platform,
    this.license,
    this.favorite = false,
    List<String> tags = const [],
    this.status = LibraryFileStatus.available,
    this.trashedAt,
  }) : tags = List.unmodifiable(tags) {
    if (id.trim().isEmpty) throw ArgumentError('id must not be empty');
    if (title.trim().isEmpty) throw ArgumentError('title must not be empty');
    if (filePath.trim().isEmpty) {
      throw ArgumentError('filePath must not be empty');
    }
    if ((status == LibraryFileStatus.trashed) != (trashedAt != null)) {
      throw ArgumentError('trashedAt must be set iff status is trashed');
    }
  }

  /// Days an item stays in the internal trash before permanent deletion.
  static const int trashRetentionDays = 7;

  /// Unique entry identifier.
  final String id;

  /// Display title (renameable by the user).
  final String title;

  /// Absolute path of the media file on disk.
  final String filePath;

  /// Video or audio, for the library tabs.
  final MediaKind kind;

  /// File size on disk.
  final FileSize size;

  /// Media duration, when known.
  final Duration? duration;

  /// Origin platform slug for the platform badge.
  final String? platform;

  /// License badge (section 9); null for user-owned/official downloads.
  final License? license;

  /// Whether the user marked this entry as favorite.
  final bool favorite;

  /// User tags. Free tier caps at 3 distinct tags across the library —
  /// enforced by the application layer, not here.
  final List<String> tags;

  /// Current file status (available/missing/trashed).
  final LibraryFileStatus status;

  /// When the download finished.
  final DateTime downloadedAt;

  /// When the entry entered the trash; set iff [status] is trashed.
  final DateTime? trashedAt;

  /// Whether the internal player can open this entry.
  bool get isPlayable => status == LibraryFileStatus.available;

  /// Whether the trash retention window has elapsed at [now].
  bool isTrashExpired(DateTime now) =>
      status == LibraryFileStatus.trashed &&
      now.difference(trashedAt!).inDays >= trashRetentionDays;

  /// Copies the entry overriding the given mutable fields.
  LibraryEntry copyWith({
    String? title,
    String? filePath,
    bool? favorite,
    List<String>? tags,
    LibraryFileStatus? status,
    DateTime? trashedAt,
    bool clearTrashedAt = false,
  }) =>
      LibraryEntry(
        id: id,
        title: title ?? this.title,
        filePath: filePath ?? this.filePath,
        kind: kind,
        size: size,
        downloadedAt: downloadedAt,
        duration: duration,
        platform: platform,
        license: license,
        favorite: favorite ?? this.favorite,
        tags: tags ?? this.tags,
        status: status ?? this.status,
        trashedAt: clearTrashedAt ? null : (trashedAt ?? this.trashedAt),
      );

  @override
  bool operator ==(Object other) => other is LibraryEntry && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'LibraryEntry($id, "$title", ${status.name})';
}
