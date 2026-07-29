/// ViewModel of the Search screen (MVVM, section 4.1).
///
/// Responsibility: own the query, debounce typing and expose one method
/// per filter chip. Every mutation goes through [_apply], so the results
/// can never describe a query the user has already changed.
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/domain/value_objects/file_size.dart';
import '../../../core/domain/value_objects/media_format.dart';
import '../domain/search_query.dart';
import '../domain/search_repository.dart';
import 'search_state.dart';

/// Provides the Search ViewModel.
final searchViewModelProvider =
    NotifierProvider<SearchViewModel, SearchUiState>(SearchViewModel.new);

/// Drives the Search screen.
final class SearchViewModel extends Notifier<SearchUiState> {
  late final SearchRepository _repository;
  Timer? _debounce;

  /// Set when the provider is torn down. Async loads started before that
  /// must not write to a disposed notifier — or query a closed database.
  bool _disposed = false;

  /// How long to wait after a keystroke before querying. Short enough to
  /// feel instant, long enough that a fast typist runs one query, not ten.
  static const Duration debounceDelay = Duration(milliseconds: 180);

  @override
  SearchUiState build() {
    _repository = ref.watch(searchRepositoryProvider);
    ref.onDispose(() {
      _disposed = true;
      _debounce?.cancel();
    });
    // Deferred: `state` does not exist until build() returns, and
    // loadFacets() writes to it.
    unawaited(Future.microtask(loadFacets));
    return SearchUiState.initial();
  }

  /// Loads the platform and tag lists shown in the filter sheet.
  Future<void> loadFacets() async {
    if (_disposed) return;
    final platforms = await _repository.knownPlatforms();
    if (_disposed) return;
    final tags = await _repository.knownTags();
    if (_disposed) return;
    state = state.copyWith(
      platforms: platforms.valueOrNull ?? const [],
      tags: tags.valueOrNull ?? const [],
    );
  }

  /// Handles typing: updates suggestions immediately, searches debounced.
  void textChanged(String text) {
    state = state.copyWith(query: state.query.copyWith(text: text));
    unawaited(_refreshSuggestions(text));
    _debounce?.cancel();
    _debounce = Timer(debounceDelay, () => unawaited(search()));
  }

  /// Runs the search for the current query immediately.
  Future<void> search() async {
    _debounce?.cancel();
    if (_disposed) return;
    final query = state.query;
    state = state.copyWith(searching: true);
    final result = await _repository.search(query);

    // A slower earlier search must not overwrite a newer query's results.
    if (_disposed || state.query != query) return;
    state = state.copyWith(
      hits: result.valueOrNull ?? const [],
      searching: false,
      searched: true,
      suggestions: const [],
    );
  }

  /// Accepts a type-ahead suggestion.
  Future<void> acceptSuggestion(String suggestion) async {
    state = state.copyWith(
      query: state.query.copyWith(text: suggestion),
      suggestions: const [],
    );
    await search();
  }

  /// Filters by media kind; passing the active value clears it.
  Future<void> toggleKind(MediaKind kind) => _apply(
        state.query.kind == kind
            ? state.query.copyWith(clearKind: true)
            : state.query.copyWith(kind: kind),
      );

  /// Filters by platform; passing the active value clears it.
  Future<void> togglePlatform(String platform) => _apply(
        state.query.platform == platform
            ? state.query.copyWith(clearPlatform: true)
            : state.query.copyWith(platform: platform),
      );

  /// Filters by duration bucket; passing the active value clears it.
  Future<void> toggleDuration(DurationBucket bucket) => _apply(
        state.query.durationBucket == bucket
            ? state.query.copyWith(clearDurationBucket: true)
            : state.query.copyWith(durationBucket: bucket),
      );

  /// Adds or removes a tag from the filter set.
  Future<void> toggleTag(String tag) {
    final tags = state.query.tags.toSet();
    if (!tags.remove(tag)) tags.add(tag);
    return _apply(state.query.copyWith(tags: tags));
  }

  /// Adds or removes a container from the filter set.
  Future<void> toggleContainer(String container) {
    final containers = state.query.containers.toSet();
    if (!containers.remove(container)) containers.add(container);
    return _apply(state.query.copyWith(containers: containers));
  }

  /// Restricts results to a download date interval.
  Future<void> setDateRange(DateRange? range) => _apply(
        range == null
            ? state.query.copyWith(clearDateRange: true)
            : state.query.copyWith(dateRange: range),
      );

  /// Restricts results by file size.
  Future<void> setSizeRange({FileSize? min, FileSize? max}) => _apply(
        min == null && max == null
            ? state.query.copyWith(clearSizes: true)
            : state.query.copyWith(minSize: min, maxSize: max),
      );

  /// Drops every filter, keeping the text.
  Future<void> clearFilters() => _apply(SearchQuery(text: state.query.text));

  /// Resets the screen.
  void reset() {
    _debounce?.cancel();
    state = SearchUiState.initial().copyWith(
      platforms: state.platforms,
      tags: state.tags,
    );
  }

  Future<void> _apply(SearchQuery query) async {
    state = state.copyWith(query: query);
    await search();
  }

  Future<void> _refreshSuggestions(String text) async {
    if (text.trim().isEmpty) {
      state = state.copyWith(suggestions: const []);
      return;
    }
    final suggestions = await _repository.suggest(text);
    // Discard suggestions for text the user has already moved past.
    if (_disposed || state.query.text != text) return;
    state = state.copyWith(suggestions: suggestions.valueOrNull ?? const []);
  }
}
