// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SearchUiState {
  /// The active query, rendered as the field plus removable chips.
  SearchQuery get query;

  /// Results for [query].
  List<SearchHit> get hits;

  /// Type-ahead suggestions for what is being typed.
  List<String> get suggestions;

  /// Platform slugs present in the library, for the filter sheet.
  List<String> get platforms;

  /// Tags present in the library, for the filter sheet.
  List<String> get tags;

  /// True while a search is running.
  bool get searching;

  /// False until the first search completes.
  bool get searched;

  /// Create a copy of SearchUiState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SearchUiStateCopyWith<SearchUiState> get copyWith =>
      _$SearchUiStateCopyWithImpl<SearchUiState>(
          this as SearchUiState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SearchUiState &&
            (identical(other.query, query) || other.query == query) &&
            const DeepCollectionEquality().equals(other.hits, hits) &&
            const DeepCollectionEquality()
                .equals(other.suggestions, suggestions) &&
            const DeepCollectionEquality().equals(other.platforms, platforms) &&
            const DeepCollectionEquality().equals(other.tags, tags) &&
            (identical(other.searching, searching) ||
                other.searching == searching) &&
            (identical(other.searched, searched) ||
                other.searched == searched));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      query,
      const DeepCollectionEquality().hash(hits),
      const DeepCollectionEquality().hash(suggestions),
      const DeepCollectionEquality().hash(platforms),
      const DeepCollectionEquality().hash(tags),
      searching,
      searched);

  @override
  String toString() {
    return 'SearchUiState(query: $query, hits: $hits, suggestions: $suggestions, platforms: $platforms, tags: $tags, searching: $searching, searched: $searched)';
  }
}

/// @nodoc
abstract mixin class $SearchUiStateCopyWith<$Res> {
  factory $SearchUiStateCopyWith(
          SearchUiState value, $Res Function(SearchUiState) _then) =
      _$SearchUiStateCopyWithImpl;
  @useResult
  $Res call(
      {SearchQuery query,
      List<SearchHit> hits,
      List<String> suggestions,
      List<String> platforms,
      List<String> tags,
      bool searching,
      bool searched});
}

/// @nodoc
class _$SearchUiStateCopyWithImpl<$Res>
    implements $SearchUiStateCopyWith<$Res> {
  _$SearchUiStateCopyWithImpl(this._self, this._then);

  final SearchUiState _self;
  final $Res Function(SearchUiState) _then;

  /// Create a copy of SearchUiState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? query = null,
    Object? hits = null,
    Object? suggestions = null,
    Object? platforms = null,
    Object? tags = null,
    Object? searching = null,
    Object? searched = null,
  }) {
    return _then(_self.copyWith(
      query: null == query
          ? _self.query
          : query // ignore: cast_nullable_to_non_nullable
              as SearchQuery,
      hits: null == hits
          ? _self.hits
          : hits // ignore: cast_nullable_to_non_nullable
              as List<SearchHit>,
      suggestions: null == suggestions
          ? _self.suggestions
          : suggestions // ignore: cast_nullable_to_non_nullable
              as List<String>,
      platforms: null == platforms
          ? _self.platforms
          : platforms // ignore: cast_nullable_to_non_nullable
              as List<String>,
      tags: null == tags
          ? _self.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      searching: null == searching
          ? _self.searching
          : searching // ignore: cast_nullable_to_non_nullable
              as bool,
      searched: null == searched
          ? _self.searched
          : searched // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// Adds pattern-matching-related methods to [SearchUiState].
extension SearchUiStatePatterns on SearchUiState {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_SearchUiState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SearchUiState() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_SearchUiState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SearchUiState():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_SearchUiState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SearchUiState() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            SearchQuery query,
            List<SearchHit> hits,
            List<String> suggestions,
            List<String> platforms,
            List<String> tags,
            bool searching,
            bool searched)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SearchUiState() when $default != null:
        return $default(_that.query, _that.hits, _that.suggestions,
            _that.platforms, _that.tags, _that.searching, _that.searched);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            SearchQuery query,
            List<SearchHit> hits,
            List<String> suggestions,
            List<String> platforms,
            List<String> tags,
            bool searching,
            bool searched)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SearchUiState():
        return $default(_that.query, _that.hits, _that.suggestions,
            _that.platforms, _that.tags, _that.searching, _that.searched);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            SearchQuery query,
            List<SearchHit> hits,
            List<String> suggestions,
            List<String> platforms,
            List<String> tags,
            bool searching,
            bool searched)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SearchUiState() when $default != null:
        return $default(_that.query, _that.hits, _that.suggestions,
            _that.platforms, _that.tags, _that.searching, _that.searched);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _SearchUiState extends SearchUiState {
  const _SearchUiState(
      {required this.query,
      final List<SearchHit> hits = const <SearchHit>[],
      final List<String> suggestions = const <String>[],
      final List<String> platforms = const <String>[],
      final List<String> tags = const <String>[],
      this.searching = false,
      this.searched = false})
      : _hits = hits,
        _suggestions = suggestions,
        _platforms = platforms,
        _tags = tags,
        super._();

  /// The active query, rendered as the field plus removable chips.
  @override
  final SearchQuery query;

  /// Results for [query].
  final List<SearchHit> _hits;

  /// Results for [query].
  @override
  @JsonKey()
  List<SearchHit> get hits {
    if (_hits is EqualUnmodifiableListView) return _hits;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_hits);
  }

  /// Type-ahead suggestions for what is being typed.
  final List<String> _suggestions;

  /// Type-ahead suggestions for what is being typed.
  @override
  @JsonKey()
  List<String> get suggestions {
    if (_suggestions is EqualUnmodifiableListView) return _suggestions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_suggestions);
  }

  /// Platform slugs present in the library, for the filter sheet.
  final List<String> _platforms;

  /// Platform slugs present in the library, for the filter sheet.
  @override
  @JsonKey()
  List<String> get platforms {
    if (_platforms is EqualUnmodifiableListView) return _platforms;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_platforms);
  }

  /// Tags present in the library, for the filter sheet.
  final List<String> _tags;

  /// Tags present in the library, for the filter sheet.
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  /// True while a search is running.
  @override
  @JsonKey()
  final bool searching;

  /// False until the first search completes.
  @override
  @JsonKey()
  final bool searched;

  /// Create a copy of SearchUiState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SearchUiStateCopyWith<_SearchUiState> get copyWith =>
      __$SearchUiStateCopyWithImpl<_SearchUiState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SearchUiState &&
            (identical(other.query, query) || other.query == query) &&
            const DeepCollectionEquality().equals(other._hits, _hits) &&
            const DeepCollectionEquality()
                .equals(other._suggestions, _suggestions) &&
            const DeepCollectionEquality()
                .equals(other._platforms, _platforms) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.searching, searching) ||
                other.searching == searching) &&
            (identical(other.searched, searched) ||
                other.searched == searched));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      query,
      const DeepCollectionEquality().hash(_hits),
      const DeepCollectionEquality().hash(_suggestions),
      const DeepCollectionEquality().hash(_platforms),
      const DeepCollectionEquality().hash(_tags),
      searching,
      searched);

  @override
  String toString() {
    return 'SearchUiState(query: $query, hits: $hits, suggestions: $suggestions, platforms: $platforms, tags: $tags, searching: $searching, searched: $searched)';
  }
}

/// @nodoc
abstract mixin class _$SearchUiStateCopyWith<$Res>
    implements $SearchUiStateCopyWith<$Res> {
  factory _$SearchUiStateCopyWith(
          _SearchUiState value, $Res Function(_SearchUiState) _then) =
      __$SearchUiStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {SearchQuery query,
      List<SearchHit> hits,
      List<String> suggestions,
      List<String> platforms,
      List<String> tags,
      bool searching,
      bool searched});
}

/// @nodoc
class __$SearchUiStateCopyWithImpl<$Res>
    implements _$SearchUiStateCopyWith<$Res> {
  __$SearchUiStateCopyWithImpl(this._self, this._then);

  final _SearchUiState _self;
  final $Res Function(_SearchUiState) _then;

  /// Create a copy of SearchUiState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? query = null,
    Object? hits = null,
    Object? suggestions = null,
    Object? platforms = null,
    Object? tags = null,
    Object? searching = null,
    Object? searched = null,
  }) {
    return _then(_SearchUiState(
      query: null == query
          ? _self.query
          : query // ignore: cast_nullable_to_non_nullable
              as SearchQuery,
      hits: null == hits
          ? _self._hits
          : hits // ignore: cast_nullable_to_non_nullable
              as List<SearchHit>,
      suggestions: null == suggestions
          ? _self._suggestions
          : suggestions // ignore: cast_nullable_to_non_nullable
              as List<String>,
      platforms: null == platforms
          ? _self._platforms
          : platforms // ignore: cast_nullable_to_non_nullable
              as List<String>,
      tags: null == tags
          ? _self._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      searching: null == searching
          ? _self.searching
          : searching // ignore: cast_nullable_to_non_nullable
              as bool,
      searched: null == searched
          ? _self.searched
          : searched // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

// dart format on
