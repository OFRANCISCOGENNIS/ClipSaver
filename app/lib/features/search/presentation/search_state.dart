/// Immutable UI state for the Search screen (section 10).
library;

import 'package:freezed_annotation/freezed_annotation.dart';

import '../domain/search_query.dart';
import '../domain/search_repository.dart';

part 'search_state.freezed.dart';

/// Everything the Search screen renders.
@freezed
abstract class SearchUiState with _$SearchUiState {
  /// Creates the state.
  const factory SearchUiState({
    /// The active query, rendered as the field plus removable chips.
    required SearchQuery query,

    /// Results for [query].
    @Default(<SearchHit>[]) List<SearchHit> hits,

    /// Type-ahead suggestions for what is being typed.
    @Default(<String>[]) List<String> suggestions,

    /// Platform slugs present in the library, for the filter sheet.
    @Default(<String>[]) List<String> platforms,

    /// Tags present in the library, for the filter sheet.
    @Default(<String>[]) List<String> tags,

    /// True while a search is running.
    @Default(false) bool searching,

    /// False until the first search completes.
    @Default(false) bool searched,
  }) = _SearchUiState;

  /// The initial, empty state.
  factory SearchUiState.initial() => SearchUiState(query: SearchQuery());

  const SearchUiState._();

  /// Whether to render the "nothing found" state.
  bool get isEmpty => searched && !searching && hits.isEmpty;

  /// True when every hit came from the typo-tolerant fallback, so the UI
  /// can explain why these results look approximate.
  bool get showingApproximateResults =>
      hits.isNotEmpty && hits.every((hit) => hit.matchedByTypoTolerance);
}
