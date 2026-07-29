// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'converter_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ConversionItemUiState {
  ConversionJob get job;

  /// Create a copy of ConversionItemUiState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ConversionItemUiStateCopyWith<ConversionItemUiState> get copyWith =>
      _$ConversionItemUiStateCopyWithImpl<ConversionItemUiState>(
          this as ConversionItemUiState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ConversionItemUiState &&
            (identical(other.job, job) || other.job == job));
  }

  @override
  int get hashCode => Object.hash(runtimeType, job);

  @override
  String toString() {
    return 'ConversionItemUiState(job: $job)';
  }
}

/// @nodoc
abstract mixin class $ConversionItemUiStateCopyWith<$Res> {
  factory $ConversionItemUiStateCopyWith(ConversionItemUiState value,
          $Res Function(ConversionItemUiState) _then) =
      _$ConversionItemUiStateCopyWithImpl;
  @useResult
  $Res call({ConversionJob job});
}

/// @nodoc
class _$ConversionItemUiStateCopyWithImpl<$Res>
    implements $ConversionItemUiStateCopyWith<$Res> {
  _$ConversionItemUiStateCopyWithImpl(this._self, this._then);

  final ConversionItemUiState _self;
  final $Res Function(ConversionItemUiState) _then;

  /// Create a copy of ConversionItemUiState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? job = null,
  }) {
    return _then(_self.copyWith(
      job: null == job
          ? _self.job
          : job // ignore: cast_nullable_to_non_nullable
              as ConversionJob,
    ));
  }
}

/// Adds pattern-matching-related methods to [ConversionItemUiState].
extension ConversionItemUiStatePatterns on ConversionItemUiState {
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
    TResult Function(_ConversionItemUiState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ConversionItemUiState() when $default != null:
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
    TResult Function(_ConversionItemUiState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ConversionItemUiState():
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
    TResult? Function(_ConversionItemUiState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ConversionItemUiState() when $default != null:
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
    TResult Function(ConversionJob job)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ConversionItemUiState() when $default != null:
        return $default(_that.job);
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
    TResult Function(ConversionJob job) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ConversionItemUiState():
        return $default(_that.job);
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
    TResult? Function(ConversionJob job)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ConversionItemUiState() when $default != null:
        return $default(_that.job);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _ConversionItemUiState extends ConversionItemUiState {
  const _ConversionItemUiState({required this.job}) : super._();

  @override
  final ConversionJob job;

  /// Create a copy of ConversionItemUiState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ConversionItemUiStateCopyWith<_ConversionItemUiState> get copyWith =>
      __$ConversionItemUiStateCopyWithImpl<_ConversionItemUiState>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ConversionItemUiState &&
            (identical(other.job, job) || other.job == job));
  }

  @override
  int get hashCode => Object.hash(runtimeType, job);

  @override
  String toString() {
    return 'ConversionItemUiState(job: $job)';
  }
}

/// @nodoc
abstract mixin class _$ConversionItemUiStateCopyWith<$Res>
    implements $ConversionItemUiStateCopyWith<$Res> {
  factory _$ConversionItemUiStateCopyWith(_ConversionItemUiState value,
          $Res Function(_ConversionItemUiState) _then) =
      __$ConversionItemUiStateCopyWithImpl;
  @override
  @useResult
  $Res call({ConversionJob job});
}

/// @nodoc
class __$ConversionItemUiStateCopyWithImpl<$Res>
    implements _$ConversionItemUiStateCopyWith<$Res> {
  __$ConversionItemUiStateCopyWithImpl(this._self, this._then);

  final _ConversionItemUiState _self;
  final $Res Function(_ConversionItemUiState) _then;

  /// Create a copy of ConversionItemUiState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? job = null,
  }) {
    return _then(_ConversionItemUiState(
      job: null == job
          ? _self.job
          : job // ignore: cast_nullable_to_non_nullable
              as ConversionJob,
    ));
  }
}

/// @nodoc
mixin _$ConverterUiState {
  /// Queue rows, active first.
  List<ConversionItemUiState> get items;

  /// False until the first emission arrives.
  bool get loaded;

  /// Create a copy of ConverterUiState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ConverterUiStateCopyWith<ConverterUiState> get copyWith =>
      _$ConverterUiStateCopyWithImpl<ConverterUiState>(
          this as ConverterUiState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ConverterUiState &&
            const DeepCollectionEquality().equals(other.items, items) &&
            (identical(other.loaded, loaded) || other.loaded == loaded));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(items), loaded);

  @override
  String toString() {
    return 'ConverterUiState(items: $items, loaded: $loaded)';
  }
}

/// @nodoc
abstract mixin class $ConverterUiStateCopyWith<$Res> {
  factory $ConverterUiStateCopyWith(
          ConverterUiState value, $Res Function(ConverterUiState) _then) =
      _$ConverterUiStateCopyWithImpl;
  @useResult
  $Res call({List<ConversionItemUiState> items, bool loaded});
}

/// @nodoc
class _$ConverterUiStateCopyWithImpl<$Res>
    implements $ConverterUiStateCopyWith<$Res> {
  _$ConverterUiStateCopyWithImpl(this._self, this._then);

  final ConverterUiState _self;
  final $Res Function(ConverterUiState) _then;

  /// Create a copy of ConverterUiState
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
              as List<ConversionItemUiState>,
      loaded: null == loaded
          ? _self.loaded
          : loaded // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// Adds pattern-matching-related methods to [ConverterUiState].
extension ConverterUiStatePatterns on ConverterUiState {
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
    TResult Function(_ConverterUiState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ConverterUiState() when $default != null:
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
    TResult Function(_ConverterUiState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ConverterUiState():
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
    TResult? Function(_ConverterUiState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ConverterUiState() when $default != null:
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
    TResult Function(List<ConversionItemUiState> items, bool loaded)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ConverterUiState() when $default != null:
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
    TResult Function(List<ConversionItemUiState> items, bool loaded) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ConverterUiState():
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
    TResult? Function(List<ConversionItemUiState> items, bool loaded)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ConverterUiState() when $default != null:
        return $default(_that.items, _that.loaded);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _ConverterUiState extends ConverterUiState {
  const _ConverterUiState(
      {final List<ConversionItemUiState> items =
          const <ConversionItemUiState>[],
      this.loaded = false})
      : _items = items,
        super._();

  /// Queue rows, active first.
  final List<ConversionItemUiState> _items;

  /// Queue rows, active first.
  @override
  @JsonKey()
  List<ConversionItemUiState> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  /// False until the first emission arrives.
  @override
  @JsonKey()
  final bool loaded;

  /// Create a copy of ConverterUiState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ConverterUiStateCopyWith<_ConverterUiState> get copyWith =>
      __$ConverterUiStateCopyWithImpl<_ConverterUiState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ConverterUiState &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.loaded, loaded) || other.loaded == loaded));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_items), loaded);

  @override
  String toString() {
    return 'ConverterUiState(items: $items, loaded: $loaded)';
  }
}

/// @nodoc
abstract mixin class _$ConverterUiStateCopyWith<$Res>
    implements $ConverterUiStateCopyWith<$Res> {
  factory _$ConverterUiStateCopyWith(
          _ConverterUiState value, $Res Function(_ConverterUiState) _then) =
      __$ConverterUiStateCopyWithImpl;
  @override
  @useResult
  $Res call({List<ConversionItemUiState> items, bool loaded});
}

/// @nodoc
class __$ConverterUiStateCopyWithImpl<$Res>
    implements _$ConverterUiStateCopyWith<$Res> {
  __$ConverterUiStateCopyWithImpl(this._self, this._then);

  final _ConverterUiState _self;
  final $Res Function(_ConverterUiState) _then;

  /// Create a copy of ConverterUiState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? items = null,
    Object? loaded = null,
  }) {
    return _then(_ConverterUiState(
      items: null == items
          ? _self._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<ConversionItemUiState>,
      loaded: null == loaded
          ? _self.loaded
          : loaded // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

// dart format on
