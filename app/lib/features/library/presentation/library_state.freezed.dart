// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'library_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LibraryUiState {
  /// Entries for the selected tab, already sorted.
  List<LibraryEntry> get entries;

  /// Counts for the tab badges.
  LibraryCounts get counts;

  /// Selected tab.
  LibraryTab get tab;

  /// Grid or list.
  LibraryViewMode get viewMode;

  /// Active sort key.
  LibrarySort get sort;

  /// Sort direction.
  bool get descending;

  /// False until the first load finishes.
  bool get loaded;

  /// Create a copy of LibraryUiState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $LibraryUiStateCopyWith<LibraryUiState> get copyWith =>
      _$LibraryUiStateCopyWithImpl<LibraryUiState>(
          this as LibraryUiState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is LibraryUiState &&
            const DeepCollectionEquality().equals(other.entries, entries) &&
            (identical(other.counts, counts) || other.counts == counts) &&
            (identical(other.tab, tab) || other.tab == tab) &&
            (identical(other.viewMode, viewMode) ||
                other.viewMode == viewMode) &&
            (identical(other.sort, sort) || other.sort == sort) &&
            (identical(other.descending, descending) ||
                other.descending == descending) &&
            (identical(other.loaded, loaded) || other.loaded == loaded));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(entries),
      counts,
      tab,
      viewMode,
      sort,
      descending,
      loaded);

  @override
  String toString() {
    return 'LibraryUiState(entries: $entries, counts: $counts, tab: $tab, viewMode: $viewMode, sort: $sort, descending: $descending, loaded: $loaded)';
  }
}

/// @nodoc
abstract mixin class $LibraryUiStateCopyWith<$Res> {
  factory $LibraryUiStateCopyWith(
          LibraryUiState value, $Res Function(LibraryUiState) _then) =
      _$LibraryUiStateCopyWithImpl;
  @useResult
  $Res call(
      {List<LibraryEntry> entries,
      LibraryCounts counts,
      LibraryTab tab,
      LibraryViewMode viewMode,
      LibrarySort sort,
      bool descending,
      bool loaded});
}

/// @nodoc
class _$LibraryUiStateCopyWithImpl<$Res>
    implements $LibraryUiStateCopyWith<$Res> {
  _$LibraryUiStateCopyWithImpl(this._self, this._then);

  final LibraryUiState _self;
  final $Res Function(LibraryUiState) _then;

  /// Create a copy of LibraryUiState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? entries = null,
    Object? counts = null,
    Object? tab = null,
    Object? viewMode = null,
    Object? sort = null,
    Object? descending = null,
    Object? loaded = null,
  }) {
    return _then(_self.copyWith(
      entries: null == entries
          ? _self.entries
          : entries // ignore: cast_nullable_to_non_nullable
              as List<LibraryEntry>,
      counts: null == counts
          ? _self.counts
          : counts // ignore: cast_nullable_to_non_nullable
              as LibraryCounts,
      tab: null == tab
          ? _self.tab
          : tab // ignore: cast_nullable_to_non_nullable
              as LibraryTab,
      viewMode: null == viewMode
          ? _self.viewMode
          : viewMode // ignore: cast_nullable_to_non_nullable
              as LibraryViewMode,
      sort: null == sort
          ? _self.sort
          : sort // ignore: cast_nullable_to_non_nullable
              as LibrarySort,
      descending: null == descending
          ? _self.descending
          : descending // ignore: cast_nullable_to_non_nullable
              as bool,
      loaded: null == loaded
          ? _self.loaded
          : loaded // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// Adds pattern-matching-related methods to [LibraryUiState].
extension LibraryUiStatePatterns on LibraryUiState {
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
    TResult Function(_LibraryUiState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _LibraryUiState() when $default != null:
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
    TResult Function(_LibraryUiState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LibraryUiState():
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
    TResult? Function(_LibraryUiState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LibraryUiState() when $default != null:
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
            List<LibraryEntry> entries,
            LibraryCounts counts,
            LibraryTab tab,
            LibraryViewMode viewMode,
            LibrarySort sort,
            bool descending,
            bool loaded)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _LibraryUiState() when $default != null:
        return $default(_that.entries, _that.counts, _that.tab, _that.viewMode,
            _that.sort, _that.descending, _that.loaded);
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
            List<LibraryEntry> entries,
            LibraryCounts counts,
            LibraryTab tab,
            LibraryViewMode viewMode,
            LibrarySort sort,
            bool descending,
            bool loaded)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LibraryUiState():
        return $default(_that.entries, _that.counts, _that.tab, _that.viewMode,
            _that.sort, _that.descending, _that.loaded);
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
            List<LibraryEntry> entries,
            LibraryCounts counts,
            LibraryTab tab,
            LibraryViewMode viewMode,
            LibrarySort sort,
            bool descending,
            bool loaded)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LibraryUiState() when $default != null:
        return $default(_that.entries, _that.counts, _that.tab, _that.viewMode,
            _that.sort, _that.descending, _that.loaded);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _LibraryUiState extends LibraryUiState {
  const _LibraryUiState(
      {final List<LibraryEntry> entries = const <LibraryEntry>[],
      this.counts =
          const LibraryCounts(videos: 0, audios: 0, favorites: 0, trashed: 0),
      this.tab = LibraryTab.videos,
      this.viewMode = LibraryViewMode.grid,
      this.sort = LibrarySort.downloadedAt,
      this.descending = true,
      this.loaded = false})
      : _entries = entries,
        super._();

  /// Entries for the selected tab, already sorted.
  final List<LibraryEntry> _entries;

  /// Entries for the selected tab, already sorted.
  @override
  @JsonKey()
  List<LibraryEntry> get entries {
    if (_entries is EqualUnmodifiableListView) return _entries;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_entries);
  }

  /// Counts for the tab badges.
  @override
  @JsonKey()
  final LibraryCounts counts;

  /// Selected tab.
  @override
  @JsonKey()
  final LibraryTab tab;

  /// Grid or list.
  @override
  @JsonKey()
  final LibraryViewMode viewMode;

  /// Active sort key.
  @override
  @JsonKey()
  final LibrarySort sort;

  /// Sort direction.
  @override
  @JsonKey()
  final bool descending;

  /// False until the first load finishes.
  @override
  @JsonKey()
  final bool loaded;

  /// Create a copy of LibraryUiState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$LibraryUiStateCopyWith<_LibraryUiState> get copyWith =>
      __$LibraryUiStateCopyWithImpl<_LibraryUiState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _LibraryUiState &&
            const DeepCollectionEquality().equals(other._entries, _entries) &&
            (identical(other.counts, counts) || other.counts == counts) &&
            (identical(other.tab, tab) || other.tab == tab) &&
            (identical(other.viewMode, viewMode) ||
                other.viewMode == viewMode) &&
            (identical(other.sort, sort) || other.sort == sort) &&
            (identical(other.descending, descending) ||
                other.descending == descending) &&
            (identical(other.loaded, loaded) || other.loaded == loaded));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_entries),
      counts,
      tab,
      viewMode,
      sort,
      descending,
      loaded);

  @override
  String toString() {
    return 'LibraryUiState(entries: $entries, counts: $counts, tab: $tab, viewMode: $viewMode, sort: $sort, descending: $descending, loaded: $loaded)';
  }
}

/// @nodoc
abstract mixin class _$LibraryUiStateCopyWith<$Res>
    implements $LibraryUiStateCopyWith<$Res> {
  factory _$LibraryUiStateCopyWith(
          _LibraryUiState value, $Res Function(_LibraryUiState) _then) =
      __$LibraryUiStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {List<LibraryEntry> entries,
      LibraryCounts counts,
      LibraryTab tab,
      LibraryViewMode viewMode,
      LibrarySort sort,
      bool descending,
      bool loaded});
}

/// @nodoc
class __$LibraryUiStateCopyWithImpl<$Res>
    implements _$LibraryUiStateCopyWith<$Res> {
  __$LibraryUiStateCopyWithImpl(this._self, this._then);

  final _LibraryUiState _self;
  final $Res Function(_LibraryUiState) _then;

  /// Create a copy of LibraryUiState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? entries = null,
    Object? counts = null,
    Object? tab = null,
    Object? viewMode = null,
    Object? sort = null,
    Object? descending = null,
    Object? loaded = null,
  }) {
    return _then(_LibraryUiState(
      entries: null == entries
          ? _self._entries
          : entries // ignore: cast_nullable_to_non_nullable
              as List<LibraryEntry>,
      counts: null == counts
          ? _self.counts
          : counts // ignore: cast_nullable_to_non_nullable
              as LibraryCounts,
      tab: null == tab
          ? _self.tab
          : tab // ignore: cast_nullable_to_non_nullable
              as LibraryTab,
      viewMode: null == viewMode
          ? _self.viewMode
          : viewMode // ignore: cast_nullable_to_non_nullable
              as LibraryViewMode,
      sort: null == sort
          ? _self.sort
          : sort // ignore: cast_nullable_to_non_nullable
              as LibrarySort,
      descending: null == descending
          ? _self.descending
          : descending // ignore: cast_nullable_to_non_nullable
              as bool,
      loaded: null == loaded
          ? _self.loaded
          : loaded // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

// dart format on
