// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'analyze_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AnalyzePhase {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is AnalyzePhase);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'AnalyzePhase()';
  }
}

/// @nodoc
class $AnalyzePhaseCopyWith<$Res> {
  $AnalyzePhaseCopyWith(AnalyzePhase _, $Res Function(AnalyzePhase) __);
}

/// Adds pattern-matching-related methods to [AnalyzePhase].
extension AnalyzePhasePatterns on AnalyzePhase {
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
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AnalyzeIdle value)? idle,
    TResult Function(AnalyzeValidating value)? validating,
    TResult Function(AnalyzeAnalyzing value)? analyzing,
    TResult Function(AnalyzeResult value)? result,
    TResult Function(AnalyzeIneligible value)? ineligible,
    TResult Function(AnalyzeError value)? error,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case AnalyzeIdle() when idle != null:
        return idle(_that);
      case AnalyzeValidating() when validating != null:
        return validating(_that);
      case AnalyzeAnalyzing() when analyzing != null:
        return analyzing(_that);
      case AnalyzeResult() when result != null:
        return result(_that);
      case AnalyzeIneligible() when ineligible != null:
        return ineligible(_that);
      case AnalyzeError() when error != null:
        return error(_that);
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
  TResult map<TResult extends Object?>({
    required TResult Function(AnalyzeIdle value) idle,
    required TResult Function(AnalyzeValidating value) validating,
    required TResult Function(AnalyzeAnalyzing value) analyzing,
    required TResult Function(AnalyzeResult value) result,
    required TResult Function(AnalyzeIneligible value) ineligible,
    required TResult Function(AnalyzeError value) error,
  }) {
    final _that = this;
    switch (_that) {
      case AnalyzeIdle():
        return idle(_that);
      case AnalyzeValidating():
        return validating(_that);
      case AnalyzeAnalyzing():
        return analyzing(_that);
      case AnalyzeResult():
        return result(_that);
      case AnalyzeIneligible():
        return ineligible(_that);
      case AnalyzeError():
        return error(_that);
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
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AnalyzeIdle value)? idle,
    TResult? Function(AnalyzeValidating value)? validating,
    TResult? Function(AnalyzeAnalyzing value)? analyzing,
    TResult? Function(AnalyzeResult value)? result,
    TResult? Function(AnalyzeIneligible value)? ineligible,
    TResult? Function(AnalyzeError value)? error,
  }) {
    final _that = this;
    switch (_that) {
      case AnalyzeIdle() when idle != null:
        return idle(_that);
      case AnalyzeValidating() when validating != null:
        return validating(_that);
      case AnalyzeAnalyzing() when analyzing != null:
        return analyzing(_that);
      case AnalyzeResult() when result != null:
        return result(_that);
      case AnalyzeIneligible() when ineligible != null:
        return ineligible(_that);
      case AnalyzeError() when error != null:
        return error(_that);
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
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function()? validating,
    TResult Function()? analyzing,
    TResult Function(MediaItem item)? result,
    TResult Function(MediaItem item)? ineligible,
    TResult Function(Failure failure)? error,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case AnalyzeIdle() when idle != null:
        return idle();
      case AnalyzeValidating() when validating != null:
        return validating();
      case AnalyzeAnalyzing() when analyzing != null:
        return analyzing();
      case AnalyzeResult() when result != null:
        return result(_that.item);
      case AnalyzeIneligible() when ineligible != null:
        return ineligible(_that.item);
      case AnalyzeError() when error != null:
        return error(_that.failure);
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
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function() validating,
    required TResult Function() analyzing,
    required TResult Function(MediaItem item) result,
    required TResult Function(MediaItem item) ineligible,
    required TResult Function(Failure failure) error,
  }) {
    final _that = this;
    switch (_that) {
      case AnalyzeIdle():
        return idle();
      case AnalyzeValidating():
        return validating();
      case AnalyzeAnalyzing():
        return analyzing();
      case AnalyzeResult():
        return result(_that.item);
      case AnalyzeIneligible():
        return ineligible(_that.item);
      case AnalyzeError():
        return error(_that.failure);
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
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function()? validating,
    TResult? Function()? analyzing,
    TResult? Function(MediaItem item)? result,
    TResult? Function(MediaItem item)? ineligible,
    TResult? Function(Failure failure)? error,
  }) {
    final _that = this;
    switch (_that) {
      case AnalyzeIdle() when idle != null:
        return idle();
      case AnalyzeValidating() when validating != null:
        return validating();
      case AnalyzeAnalyzing() when analyzing != null:
        return analyzing();
      case AnalyzeResult() when result != null:
        return result(_that.item);
      case AnalyzeIneligible() when ineligible != null:
        return ineligible(_that.item);
      case AnalyzeError() when error != null:
        return error(_that.failure);
      case _:
        return null;
    }
  }
}

/// @nodoc

class AnalyzeIdle implements AnalyzePhase {
  const AnalyzeIdle();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is AnalyzeIdle);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'AnalyzePhase.idle()';
  }
}

/// @nodoc

class AnalyzeValidating implements AnalyzePhase {
  const AnalyzeValidating();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is AnalyzeValidating);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'AnalyzePhase.validating()';
  }
}

/// @nodoc

class AnalyzeAnalyzing implements AnalyzePhase {
  const AnalyzeAnalyzing();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is AnalyzeAnalyzing);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'AnalyzePhase.analyzing()';
  }
}

/// @nodoc

class AnalyzeResult implements AnalyzePhase {
  const AnalyzeResult(this.item);

  final MediaItem item;

  /// Create a copy of AnalyzePhase
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AnalyzeResultCopyWith<AnalyzeResult> get copyWith =>
      _$AnalyzeResultCopyWithImpl<AnalyzeResult>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AnalyzeResult &&
            (identical(other.item, item) || other.item == item));
  }

  @override
  int get hashCode => Object.hash(runtimeType, item);

  @override
  String toString() {
    return 'AnalyzePhase.result(item: $item)';
  }
}

/// @nodoc
abstract mixin class $AnalyzeResultCopyWith<$Res>
    implements $AnalyzePhaseCopyWith<$Res> {
  factory $AnalyzeResultCopyWith(
          AnalyzeResult value, $Res Function(AnalyzeResult) _then) =
      _$AnalyzeResultCopyWithImpl;
  @useResult
  $Res call({MediaItem item});
}

/// @nodoc
class _$AnalyzeResultCopyWithImpl<$Res>
    implements $AnalyzeResultCopyWith<$Res> {
  _$AnalyzeResultCopyWithImpl(this._self, this._then);

  final AnalyzeResult _self;
  final $Res Function(AnalyzeResult) _then;

  /// Create a copy of AnalyzePhase
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? item = null,
  }) {
    return _then(AnalyzeResult(
      null == item
          ? _self.item
          : item // ignore: cast_nullable_to_non_nullable
              as MediaItem,
    ));
  }
}

/// @nodoc

class AnalyzeIneligible implements AnalyzePhase {
  const AnalyzeIneligible(this.item);

  final MediaItem item;

  /// Create a copy of AnalyzePhase
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AnalyzeIneligibleCopyWith<AnalyzeIneligible> get copyWith =>
      _$AnalyzeIneligibleCopyWithImpl<AnalyzeIneligible>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AnalyzeIneligible &&
            (identical(other.item, item) || other.item == item));
  }

  @override
  int get hashCode => Object.hash(runtimeType, item);

  @override
  String toString() {
    return 'AnalyzePhase.ineligible(item: $item)';
  }
}

/// @nodoc
abstract mixin class $AnalyzeIneligibleCopyWith<$Res>
    implements $AnalyzePhaseCopyWith<$Res> {
  factory $AnalyzeIneligibleCopyWith(
          AnalyzeIneligible value, $Res Function(AnalyzeIneligible) _then) =
      _$AnalyzeIneligibleCopyWithImpl;
  @useResult
  $Res call({MediaItem item});
}

/// @nodoc
class _$AnalyzeIneligibleCopyWithImpl<$Res>
    implements $AnalyzeIneligibleCopyWith<$Res> {
  _$AnalyzeIneligibleCopyWithImpl(this._self, this._then);

  final AnalyzeIneligible _self;
  final $Res Function(AnalyzeIneligible) _then;

  /// Create a copy of AnalyzePhase
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? item = null,
  }) {
    return _then(AnalyzeIneligible(
      null == item
          ? _self.item
          : item // ignore: cast_nullable_to_non_nullable
              as MediaItem,
    ));
  }
}

/// @nodoc

class AnalyzeError implements AnalyzePhase {
  const AnalyzeError(this.failure);

  final Failure failure;

  /// Create a copy of AnalyzePhase
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AnalyzeErrorCopyWith<AnalyzeError> get copyWith =>
      _$AnalyzeErrorCopyWithImpl<AnalyzeError>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AnalyzeError &&
            (identical(other.failure, failure) || other.failure == failure));
  }

  @override
  int get hashCode => Object.hash(runtimeType, failure);

  @override
  String toString() {
    return 'AnalyzePhase.error(failure: $failure)';
  }
}

/// @nodoc
abstract mixin class $AnalyzeErrorCopyWith<$Res>
    implements $AnalyzePhaseCopyWith<$Res> {
  factory $AnalyzeErrorCopyWith(
          AnalyzeError value, $Res Function(AnalyzeError) _then) =
      _$AnalyzeErrorCopyWithImpl;
  @useResult
  $Res call({Failure failure});
}

/// @nodoc
class _$AnalyzeErrorCopyWithImpl<$Res> implements $AnalyzeErrorCopyWith<$Res> {
  _$AnalyzeErrorCopyWithImpl(this._self, this._then);

  final AnalyzeError _self;
  final $Res Function(AnalyzeError) _then;

  /// Create a copy of AnalyzePhase
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? failure = null,
  }) {
    return _then(AnalyzeError(
      null == failure
          ? _self.failure
          : failure // ignore: cast_nullable_to_non_nullable
              as Failure,
    ));
  }
}

/// @nodoc
mixin _$AnalyzeUiState {
  /// Current text of the URL field.
  String get url;

  /// Inline validation message shown under the field, when any.
  String? get urlError;

  /// Current node of the state machine.
  AnalyzePhase get phase;

  /// Last five analyses, for the "Recentes" shortcuts (section 7.1).
  List<MediaItem> get recents;

  /// URL found in the clipboard, offered as a paste chip.
  String? get clipboardSuggestion;

  /// Create a copy of AnalyzeUiState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AnalyzeUiStateCopyWith<AnalyzeUiState> get copyWith =>
      _$AnalyzeUiStateCopyWithImpl<AnalyzeUiState>(
          this as AnalyzeUiState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AnalyzeUiState &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.urlError, urlError) ||
                other.urlError == urlError) &&
            (identical(other.phase, phase) || other.phase == phase) &&
            const DeepCollectionEquality().equals(other.recents, recents) &&
            (identical(other.clipboardSuggestion, clipboardSuggestion) ||
                other.clipboardSuggestion == clipboardSuggestion));
  }

  @override
  int get hashCode => Object.hash(runtimeType, url, urlError, phase,
      const DeepCollectionEquality().hash(recents), clipboardSuggestion);

  @override
  String toString() {
    return 'AnalyzeUiState(url: $url, urlError: $urlError, phase: $phase, recents: $recents, clipboardSuggestion: $clipboardSuggestion)';
  }
}

/// @nodoc
abstract mixin class $AnalyzeUiStateCopyWith<$Res> {
  factory $AnalyzeUiStateCopyWith(
          AnalyzeUiState value, $Res Function(AnalyzeUiState) _then) =
      _$AnalyzeUiStateCopyWithImpl;
  @useResult
  $Res call(
      {String url,
      String? urlError,
      AnalyzePhase phase,
      List<MediaItem> recents,
      String? clipboardSuggestion});

  $AnalyzePhaseCopyWith<$Res> get phase;
}

/// @nodoc
class _$AnalyzeUiStateCopyWithImpl<$Res>
    implements $AnalyzeUiStateCopyWith<$Res> {
  _$AnalyzeUiStateCopyWithImpl(this._self, this._then);

  final AnalyzeUiState _self;
  final $Res Function(AnalyzeUiState) _then;

  /// Create a copy of AnalyzeUiState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? url = null,
    Object? urlError = freezed,
    Object? phase = null,
    Object? recents = null,
    Object? clipboardSuggestion = freezed,
  }) {
    return _then(_self.copyWith(
      url: null == url
          ? _self.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      urlError: freezed == urlError
          ? _self.urlError
          : urlError // ignore: cast_nullable_to_non_nullable
              as String?,
      phase: null == phase
          ? _self.phase
          : phase // ignore: cast_nullable_to_non_nullable
              as AnalyzePhase,
      recents: null == recents
          ? _self.recents
          : recents // ignore: cast_nullable_to_non_nullable
              as List<MediaItem>,
      clipboardSuggestion: freezed == clipboardSuggestion
          ? _self.clipboardSuggestion
          : clipboardSuggestion // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }

  /// Create a copy of AnalyzeUiState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AnalyzePhaseCopyWith<$Res> get phase {
    return $AnalyzePhaseCopyWith<$Res>(_self.phase, (value) {
      return _then(_self.copyWith(phase: value));
    });
  }
}

/// Adds pattern-matching-related methods to [AnalyzeUiState].
extension AnalyzeUiStatePatterns on AnalyzeUiState {
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
    TResult Function(_AnalyzeUiState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AnalyzeUiState() when $default != null:
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
    TResult Function(_AnalyzeUiState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AnalyzeUiState():
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
    TResult? Function(_AnalyzeUiState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AnalyzeUiState() when $default != null:
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
    TResult Function(String url, String? urlError, AnalyzePhase phase,
            List<MediaItem> recents, String? clipboardSuggestion)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AnalyzeUiState() when $default != null:
        return $default(_that.url, _that.urlError, _that.phase, _that.recents,
            _that.clipboardSuggestion);
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
    TResult Function(String url, String? urlError, AnalyzePhase phase,
            List<MediaItem> recents, String? clipboardSuggestion)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AnalyzeUiState():
        return $default(_that.url, _that.urlError, _that.phase, _that.recents,
            _that.clipboardSuggestion);
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
    TResult? Function(String url, String? urlError, AnalyzePhase phase,
            List<MediaItem> recents, String? clipboardSuggestion)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AnalyzeUiState() when $default != null:
        return $default(_that.url, _that.urlError, _that.phase, _that.recents,
            _that.clipboardSuggestion);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _AnalyzeUiState extends AnalyzeUiState {
  const _AnalyzeUiState(
      {this.url = '',
      this.urlError,
      this.phase = const AnalyzeIdle(),
      final List<MediaItem> recents = const <MediaItem>[],
      this.clipboardSuggestion})
      : _recents = recents,
        super._();

  /// Current text of the URL field.
  @override
  @JsonKey()
  final String url;

  /// Inline validation message shown under the field, when any.
  @override
  final String? urlError;

  /// Current node of the state machine.
  @override
  @JsonKey()
  final AnalyzePhase phase;

  /// Last five analyses, for the "Recentes" shortcuts (section 7.1).
  final List<MediaItem> _recents;

  /// Last five analyses, for the "Recentes" shortcuts (section 7.1).
  @override
  @JsonKey()
  List<MediaItem> get recents {
    if (_recents is EqualUnmodifiableListView) return _recents;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recents);
  }

  /// URL found in the clipboard, offered as a paste chip.
  @override
  final String? clipboardSuggestion;

  /// Create a copy of AnalyzeUiState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AnalyzeUiStateCopyWith<_AnalyzeUiState> get copyWith =>
      __$AnalyzeUiStateCopyWithImpl<_AnalyzeUiState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AnalyzeUiState &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.urlError, urlError) ||
                other.urlError == urlError) &&
            (identical(other.phase, phase) || other.phase == phase) &&
            const DeepCollectionEquality().equals(other._recents, _recents) &&
            (identical(other.clipboardSuggestion, clipboardSuggestion) ||
                other.clipboardSuggestion == clipboardSuggestion));
  }

  @override
  int get hashCode => Object.hash(runtimeType, url, urlError, phase,
      const DeepCollectionEquality().hash(_recents), clipboardSuggestion);

  @override
  String toString() {
    return 'AnalyzeUiState(url: $url, urlError: $urlError, phase: $phase, recents: $recents, clipboardSuggestion: $clipboardSuggestion)';
  }
}

/// @nodoc
abstract mixin class _$AnalyzeUiStateCopyWith<$Res>
    implements $AnalyzeUiStateCopyWith<$Res> {
  factory _$AnalyzeUiStateCopyWith(
          _AnalyzeUiState value, $Res Function(_AnalyzeUiState) _then) =
      __$AnalyzeUiStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String url,
      String? urlError,
      AnalyzePhase phase,
      List<MediaItem> recents,
      String? clipboardSuggestion});

  @override
  $AnalyzePhaseCopyWith<$Res> get phase;
}

/// @nodoc
class __$AnalyzeUiStateCopyWithImpl<$Res>
    implements _$AnalyzeUiStateCopyWith<$Res> {
  __$AnalyzeUiStateCopyWithImpl(this._self, this._then);

  final _AnalyzeUiState _self;
  final $Res Function(_AnalyzeUiState) _then;

  /// Create a copy of AnalyzeUiState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? url = null,
    Object? urlError = freezed,
    Object? phase = null,
    Object? recents = null,
    Object? clipboardSuggestion = freezed,
  }) {
    return _then(_AnalyzeUiState(
      url: null == url
          ? _self.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      urlError: freezed == urlError
          ? _self.urlError
          : urlError // ignore: cast_nullable_to_non_nullable
              as String?,
      phase: null == phase
          ? _self.phase
          : phase // ignore: cast_nullable_to_non_nullable
              as AnalyzePhase,
      recents: null == recents
          ? _self._recents
          : recents // ignore: cast_nullable_to_non_nullable
              as List<MediaItem>,
      clipboardSuggestion: freezed == clipboardSuggestion
          ? _self.clipboardSuggestion
          : clipboardSuggestion // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }

  /// Create a copy of AnalyzeUiState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AnalyzePhaseCopyWith<$Res> get phase {
    return $AnalyzePhaseCopyWith<$Res>(_self.phase, (value) {
      return _then(_self.copyWith(phase: value));
    });
  }
}

// dart format on
