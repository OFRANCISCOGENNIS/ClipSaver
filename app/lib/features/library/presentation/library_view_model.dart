/// ViewModel of the Library screen (MVVM, section 4.1).
///
/// Responsibility: translate tab/sort/view choices into repository
/// queries and expose the per-item actions. It holds no widgets and no
/// filesystem knowledge beyond the reconciliation use case.
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/domain/value_objects/media_format.dart';
import '../../../core/error/result.dart';
import '../application/reconcile_library_files_use_case.dart';
import '../domain/library_entry.dart';
import '../domain/library_repository.dart';
import 'library_state.dart';

/// Provides the Library ViewModel.
final libraryViewModelProvider =
    NotifierProvider<LibraryViewModel, LibraryUiState>(LibraryViewModel.new);

/// Drives the Library screen.
final class LibraryViewModel extends Notifier<LibraryUiState> {
  late final LibraryRepository _repository;
  StreamSubscription<List<LibraryEntry>>? _subscription;

  /// Set when the provider is torn down. Async loads started before that
  /// must not write to a disposed notifier — or query a closed database.
  bool _disposed = false;

  @override
  LibraryUiState build() {
    _repository = ref.watch(libraryRepositoryProvider);
    // Any write to the library re-runs the current query, so counts and
    // the visible list can never drift apart.
    _subscription = _repository.watchAll().listen((_) => unawaited(refresh()));
    ref.onDispose(() {
      _disposed = true;
      unawaited(_subscription?.cancel());
    });
    // Deferred: `state` does not exist until build() returns, and refresh()
    // reads it to know which tab to query.
    unawaited(Future.microtask(refresh));
    return const LibraryUiState();
  }

  /// Re-runs the query for the current tab, sort and direction.
  Future<void> refresh() async {
    if (_disposed) return;
    final listed = await _repository.list(
      kind: switch (state.tab) {
        LibraryTab.videos => MediaKind.video,
        LibraryTab.audios => MediaKind.audio,
        LibraryTab.favorites || LibraryTab.recents => null,
      },
      favoritesOnly: state.tab == LibraryTab.favorites,
      sort: state.tab == LibraryTab.recents
          ? LibrarySort.downloadedAt
          : state.sort,
      descending: state.tab == LibraryTab.recents ? true : state.descending,
    );
    final counted = await _repository.counts();
    if (_disposed) return;

    state = state.copyWith(
      entries: listed.valueOrNull ?? const [],
      counts: counted.valueOrNull ?? state.counts,
      loaded: true,
    );
  }

  /// Switches tab and reloads.
  Future<void> selectTab(LibraryTab tab) async {
    if (tab == state.tab) return;
    state = state.copyWith(tab: tab);
    await refresh();
  }

  /// Toggles between grid and list.
  void toggleViewMode() => state = state.copyWith(
        viewMode: state.viewMode == LibraryViewMode.grid
            ? LibraryViewMode.list
            : LibraryViewMode.grid,
      );

  /// Applies a sort key; repeating the current key flips the direction.
  Future<void> sortBy(LibrarySort sort) async {
    state = sort == state.sort
        ? state.copyWith(descending: !state.descending)
        : state.copyWith(sort: sort, descending: true);
    await refresh();
  }

  /// Toggles the favorite flag of [id].
  Future<Result<LibraryEntry>> toggleFavorite(String id) async {
    final entry = state.entries.where((e) => e.id == id).firstOrNull;
    if (entry == null) {
      return _repository.setFavorite(id, favorite: true);
    }
    return _repository.setFavorite(id, favorite: !entry.favorite);
  }

  /// Renames [id].
  Future<Result<LibraryEntry>> rename(String id, String title) =>
      _repository.rename(id, title);

  /// Replaces the tags of [id].
  Future<Result<LibraryEntry>> setTags(String id, List<String> tags) =>
      _repository.setTags(id, tags);

  /// Moves [id] to the trash.
  Future<Result<LibraryEntry>> moveToTrash(String id) =>
      _repository.moveToTrash(id, DateTime.now());

  /// Restores [id] from the trash.
  Future<Result<LibraryEntry>> restore(String id) =>
      _repository.restoreFromTrash(id);

  /// Empties expired trash entries (older than the retention window).
  Future<Result<int>> purgeExpiredTrash() =>
      _repository.purgeExpiredTrash(DateTime.now());

  /// Checks the filesystem and flags entries whose file disappeared.
  Future<Result<ReconcileReport>> reconcileFiles() async {
    final useCase = ReconcileLibraryFilesUseCase(
      repository: _repository,
      fileSystem: ref.read(downloadFileSystemProvider),
    );
    final report = await useCase();
    if (report.valueOrNull?.hasChanges ?? false) await refresh();
    return report;
  }
}
