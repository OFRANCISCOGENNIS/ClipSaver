// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'downloads_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DownloadItemUiState {
  DownloadTask get task;

  /// Live rate; null until two measurements exist or when not running.
  TransferRate? get rate;

  /// Create a copy of DownloadItemUiState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $DownloadItemUiStateCopyWith<DownloadItemUiState> get copyWith =>
      _$DownloadItemUiStateCopyWithImpl<DownloadItemUiState>(
          this as DownloadItemUiState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is DownloadItemUiState &&
            (identical(other.task, task) || other.task == task) &&
            (identical(other.rate, rate) || other.rate == rate));
  }

  @override
  int get hashCode => Object.hash(runtimeType, task, rate);

  @override
  String toString() {
    return 'DownloadItemUiState(task: $task, rate: $rate)';
  }
}

/// @nodoc
abstract mixin class $DownloadItemUiStateCopyWith<$Res> {
  factory $DownloadItemUiStateCopyWith(
          DownloadItemUiState value, $Res Function(DownloadItemUiState) _then) =
      _$DownloadItemUiStateCopyWithImpl;
  @useResult
  $Res call({DownloadTask task, TransferRate? rate});
}

/// @nodoc
class _$DownloadItemUiStateCopyWithImpl<$Res>
    implements $DownloadItemUiStateCopyWith<$Res> {
  _$DownloadItemUiStateCopyWithImpl(this._self, this._then);

  final DownloadItemUiState _self;
  final $Res Function(DownloadItemUiState) _then;

  /// Create a copy of DownloadItemUiState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? task = null,
    Object? rate = freezed,
  }) {
    return _then(_self.copyWith(
      task: null == task
          ? _self.task
          : task // ignore: cast_nullable_to_non_nullable
              as DownloadTask,
      rate: freezed == rate
          ? _self.rate
          : rate // ignore: cast_nullable_to_non_nullable
              as TransferRate?,
    ));
  }
}

/// Adds pattern-matching-related methods to [DownloadItemUiState].
extension DownloadItemUiStatePatterns on DownloadItemUiState {
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
    TResult Function(_DownloadItemUiState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DownloadItemUiState() when $default != null:
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
    TResult Function(_DownloadItemUiState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DownloadItemUiState():
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
    TResult? Function(_DownloadItemUiState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DownloadItemUiState() when $default != null:
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
    TResult Function(DownloadTask task, TransferRate? rate)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DownloadItemUiState() when $default != null:
        return $default(_that.task, _that.rate);
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
    TResult Function(DownloadTask task, TransferRate? rate) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DownloadItemUiState():
        return $default(_that.task, _that.rate);
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
    TResult? Function(DownloadTask task, TransferRate? rate)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DownloadItemUiState() when $default != null:
        return $default(_that.task, _that.rate);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _DownloadItemUiState extends DownloadItemUiState {
  const _DownloadItemUiState({required this.task, this.rate}) : super._();

  @override
  final DownloadTask task;

  /// Live rate; null until two measurements exist or when not running.
  @override
  final TransferRate? rate;

  /// Create a copy of DownloadItemUiState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$DownloadItemUiStateCopyWith<_DownloadItemUiState> get copyWith =>
      __$DownloadItemUiStateCopyWithImpl<_DownloadItemUiState>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _DownloadItemUiState &&
            (identical(other.task, task) || other.task == task) &&
            (identical(other.rate, rate) || other.rate == rate));
  }

  @override
  int get hashCode => Object.hash(runtimeType, task, rate);

  @override
  String toString() {
    return 'DownloadItemUiState(task: $task, rate: $rate)';
  }
}

/// @nodoc
abstract mixin class _$DownloadItemUiStateCopyWith<$Res>
    implements $DownloadItemUiStateCopyWith<$Res> {
  factory _$DownloadItemUiStateCopyWith(_DownloadItemUiState value,
          $Res Function(_DownloadItemUiState) _then) =
      __$DownloadItemUiStateCopyWithImpl;
  @override
  @useResult
  $Res call({DownloadTask task, TransferRate? rate});
}

/// @nodoc
class __$DownloadItemUiStateCopyWithImpl<$Res>
    implements _$DownloadItemUiStateCopyWith<$Res> {
  __$DownloadItemUiStateCopyWithImpl(this._self, this._then);

  final _DownloadItemUiState _self;
  final $Res Function(_DownloadItemUiState) _then;

  /// Create a copy of DownloadItemUiState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? task = null,
    Object? rate = freezed,
  }) {
    return _then(_DownloadItemUiState(
      task: null == task
          ? _self.task
          : task // ignore: cast_nullable_to_non_nullable
              as DownloadTask,
      rate: freezed == rate
          ? _self.rate
          : rate // ignore: cast_nullable_to_non_nullable
              as TransferRate?,
    ));
  }
}

/// @nodoc
mixin _$DownloadsUiState {
  /// Queue rows, ordered by the repository (active first, then priority).
  List<DownloadItemUiState> get items;

  /// False until the first emission from the database arrives.
  bool get loaded;

  /// Create a copy of DownloadsUiState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $DownloadsUiStateCopyWith<DownloadsUiState> get copyWith =>
      _$DownloadsUiStateCopyWithImpl<DownloadsUiState>(
          this as DownloadsUiState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is DownloadsUiState &&
            const DeepCollectionEquality().equals(other.items, items) &&
            (identical(other.loaded, loaded) || other.loaded == loaded));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(items), loaded);

  @override
  String toString() {
    return 'DownloadsUiState(items: $items, loaded: $loaded)';
  }
}

/// @nodoc
abstract mixin class $DownloadsUiStateCopyWith<$Res> {
  factory $DownloadsUiStateCopyWith(
          DownloadsUiState value, $Res Function(DownloadsUiState) _then) =
      _$DownloadsUiStateCopyWithImpl;
  @useResult
  $Res call({List<DownloadItemUiState> items, bool loaded});
}

/// @nodoc
class _$DownloadsUiStateCopyWithImpl<$Res>
    implements $DownloadsUiStateCopyWith<$Res> {
  _$DownloadsUiStateCopyWithImpl(this._self, this._then);

  final DownloadsUiState _self;
  final $Res Function(DownloadsUiState) _then;

  /// Create a copy of DownloadsUiState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? loaded = null,
  }) {
    return _then(_self.copyWith(
      items: null == items
          ? _self.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<DownloadItemUiState>,
      loaded: null == loaded
          ? _self.loaded
          : loaded // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// Adds pattern-matching-related methods to [DownloadsUiState].
extension DownloadsUiStatePatterns on DownloadsUiState {
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
    TResult Function(_DownloadsUiState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DownloadsUiState() when $default != null:
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
    TResult Function(_DownloadsUiState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DownloadsUiState():
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
    TResult? Function(_DownloadsUiState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DownloadsUiState() when $default != null:
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
    TResult Function(List<DownloadItemUiState> items, bool loaded)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DownloadsUiState() when $default != null:
        return $default(_that.items, _that.loaded);
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
    TResult Function(List<DownloadItemUiState> items, bool loaded) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DownloadsUiState():
        return $default(_that.items, _that.loaded);
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
    TResult? Function(List<DownloadItemUiState> items, bool loaded)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DownloadsUiState() when $default != null:
        return $default(_that.items, _that.loaded);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _DownloadsUiState extends DownloadsUiState {
  const _DownloadsUiState(
      {final List<DownloadItemUiState> items = const <DownloadItemUiState>[],
      this.loaded = false})
      : _items = items,
        super._();

  /// Queue rows, ordered by the repository (active first, then priority).
  final List<DownloadItemUiState> _items;

  /// Queue rows, ordered by the repository (active first, then priority).
  @override
  @JsonKey()
  List<DownloadItemUiState> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  /// False until the first emission from the database arrives.
  @override
  @JsonKey()
  final bool loaded;

  /// Create a copy of DownloadsUiState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$DownloadsUiStateCopyWith<_DownloadsUiState> get copyWith =>
      __$DownloadsUiStateCopyWithImpl<_DownloadsUiState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _DownloadsUiState &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.loaded, loaded) || other.loaded == loaded));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_items), loaded);

  @override
  String toString() {
    return 'DownloadsUiState(items: $items, loaded: $loaded)';
  }
}

/// @nodoc
abstract mixin class _$DownloadsUiStateCopyWith<$Res>
    implements $DownloadsUiStateCopyWith<$Res> {
  factory _$DownloadsUiStateCopyWith(
          _DownloadsUiState value, $Res Function(_DownloadsUiState) _then) =
      __$DownloadsUiStateCopyWithImpl;
  @override
  @useResult
  $Res call({List<DownloadItemUiState> items, bool loaded});
}

/// @nodoc
class __$DownloadsUiStateCopyWithImpl<$Res>
    implements _$DownloadsUiStateCopyWith<$Res> {
  __$DownloadsUiStateCopyWithImpl(this._self, this._then);

  final _DownloadsUiState _self;
  final $Res Function(_DownloadsUiState) _then;

  /// Create a copy of DownloadsUiState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? items = null,
    Object? loaded = null,
  }) {
    return _then(_DownloadsUiState(
      items: null == items
          ? _self._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<DownloadItemUiState>,
      loaded: null == loaded
          ? _self.loaded
          : loaded // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

// dart format on
