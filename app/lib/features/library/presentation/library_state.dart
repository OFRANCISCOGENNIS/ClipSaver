/// Immutable UI state for the Library screen (section 9).
library;

import 'package:freezed_annotation/freezed_annotation.dart';

import '../domain/library_entry.dart';
import '../domain/library_repository.dart';

part 'library_state.freezed.dart';

/// The four library tabs (section 9).
enum LibraryTab {
  /// Video entries.
  videos,

  /// Audio entries.
  audios,

  /// Favorited entries of any kind.
  favorites,

  /// Everything, newest first.
  recents,
}

/// Grid or list presentation; the choice is persisted (section 9).
enum LibraryViewMode {
  /// Large thumbnails.
  grid,

  /// Dense rows.
  list,
}

/// Everything the Library screen renders.
@freezed
abstract class LibraryUiState with _$LibraryUiState {
  /// Creates the state.
  const factory LibraryUiState({
    /// Entries for the selected tab, already sorted.
    @Default(<LibraryEntry>[]) List<LibraryEntry> entries,

    /// Counts for the tab badges.
    @Default(LibraryCounts(videos: 0, audios: 0, favorites: 0, trashed: 0))
    LibraryCounts counts,

    /// Selected tab.
    @Default(LibraryTab.videos) LibraryTab tab,

    /// Grid or list.
    @Default(LibraryViewMode.grid) LibraryViewMode viewMode,

    /// Active sort key.
    @Default(LibrarySort.downloadedAt) LibrarySort sort,

    /// Sort direction.
    @Default(true) bool descending,

    /// False until the first load finishes.
    @Default(false) bool loaded,
  }) = _LibraryUiState;

  const LibraryUiState._();

  /// Whether the current tab has nothing to show.
  bool get isEmpty => loaded && entries.isEmpty;

  /// Entries whose file vanished from disk (section 9).
  Iterable<LibraryEntry> get missing =>
      entries.where((entry) => entry.status == LibraryFileStatus.missing);
}
