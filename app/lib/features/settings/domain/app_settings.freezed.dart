// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AppSettings {
// --- Geral ---
  AppLanguage get language;
  AppThemeMode get themeMode;
  bool get clipboardDetection;

  /// False until the compliance onboarding has been seen (section 2.3).
  bool get onboardingCompleted; // --- Downloads ---
  String? get videoDirectory;
  String? get audioDirectory;
  int get maxConcurrentDownloads;

  /// Speed cap in KB/s; null means unlimited.
  int? get speedLimitKbps;
  bool get wifiOnly;
  bool get resumeOnReconnect; // --- Notificações ---
  bool get notifyOnStart;
  bool get notifyOnComplete;
  bool get notifyOnError;
  NotificationStyle get notificationStyle;
  bool get dailySummary; // --- Bateria e dados ---
  bool get batterySaver;
  bool get pauseOnLowBattery; // --- Armazenamento ---
  int get thumbnailCacheMb;
  int get trashRetentionDays; // --- Privacidade ---
  /// Analytics is opt-in, never opt-out (section 13, LGPD/GDPR).
  bool get analyticsEnabled;

  /// Create a copy of AppSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AppSettingsCopyWith<AppSettings> get copyWith =>
      _$AppSettingsCopyWithImpl<AppSettings>(this as AppSettings, _$identity);

  /// Serializes this AppSettings to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AppSettings &&
            (identical(other.language, language) ||
                other.language == language) &&
            (identical(other.themeMode, themeMode) ||
                other.themeMode == themeMode) &&
            (identical(other.clipboardDetection, clipboardDetection) ||
                other.clipboardDetection == clipboardDetection) &&
            (identical(other.onboardingCompleted, onboardingCompleted) ||
                other.onboardingCompleted == onboardingCompleted) &&
            (identical(other.videoDirectory, videoDirectory) ||
                other.videoDirectory == videoDirectory) &&
            (identical(other.audioDirectory, audioDirectory) ||
                other.audioDirectory == audioDirectory) &&
            (identical(other.maxConcurrentDownloads, maxConcurrentDownloads) ||
                other.maxConcurrentDownloads == maxConcurrentDownloads) &&
            (identical(other.speedLimitKbps, speedLimitKbps) ||
                other.speedLimitKbps == speedLimitKbps) &&
            (identical(other.wifiOnly, wifiOnly) ||
                other.wifiOnly == wifiOnly) &&
            (identical(other.resumeOnReconnect, resumeOnReconnect) ||
                other.resumeOnReconnect == resumeOnReconnect) &&
            (identical(other.notifyOnStart, notifyOnStart) ||
                other.notifyOnStart == notifyOnStart) &&
            (identical(other.notifyOnComplete, notifyOnComplete) ||
                other.notifyOnComplete == notifyOnComplete) &&
            (identical(other.notifyOnError, notifyOnError) ||
                other.notifyOnError == notifyOnError) &&
            (identical(other.notificationStyle, notificationStyle) ||
                other.notificationStyle == notificationStyle) &&
            (identical(other.dailySummary, dailySummary) ||
                other.dailySummary == dailySummary) &&
            (identical(other.batterySaver, batterySaver) ||
                other.batterySaver == batterySaver) &&
            (identical(other.pauseOnLowBattery, pauseOnLowBattery) ||
                other.pauseOnLowBattery == pauseOnLowBattery) &&
            (identical(other.thumbnailCacheMb, thumbnailCacheMb) ||
                other.thumbnailCacheMb == thumbnailCacheMb) &&
            (identical(other.trashRetentionDays, trashRetentionDays) ||
                other.trashRetentionDays == trashRetentionDays) &&
            (identical(other.analyticsEnabled, analyticsEnabled) ||
                other.analyticsEnabled == analyticsEnabled));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        language,
        themeMode,
        clipboardDetection,
        onboardingCompleted,
        videoDirectory,
        audioDirectory,
        maxConcurrentDownloads,
        speedLimitKbps,
        wifiOnly,
        resumeOnReconnect,
        notifyOnStart,
        notifyOnComplete,
        notifyOnError,
        notificationStyle,
        dailySummary,
        batterySaver,
        pauseOnLowBattery,
        thumbnailCacheMb,
        trashRetentionDays,
        analyticsEnabled
      ]);

  @override
  String toString() {
    return 'AppSettings(language: $language, themeMode: $themeMode, clipboardDetection: $clipboardDetection, onboardingCompleted: $onboardingCompleted, videoDirectory: $videoDirectory, audioDirectory: $audioDirectory, maxConcurrentDownloads: $maxConcurrentDownloads, speedLimitKbps: $speedLimitKbps, wifiOnly: $wifiOnly, resumeOnReconnect: $resumeOnReconnect, notifyOnStart: $notifyOnStart, notifyOnComplete: $notifyOnComplete, notifyOnError: $notifyOnError, notificationStyle: $notificationStyle, dailySummary: $dailySummary, batterySaver: $batterySaver, pauseOnLowBattery: $pauseOnLowBattery, thumbnailCacheMb: $thumbnailCacheMb, trashRetentionDays: $trashRetentionDays, analyticsEnabled: $analyticsEnabled)';
  }
}

/// @nodoc
abstract mixin class $AppSettingsCopyWith<$Res> {
  factory $AppSettingsCopyWith(
          AppSettings value, $Res Function(AppSettings) _then) =
      _$AppSettingsCopyWithImpl;
  @useResult
  $Res call(
      {AppLanguage language,
      AppThemeMode themeMode,
      bool clipboardDetection,
      bool onboardingCompleted,
      String? videoDirectory,
      String? audioDirectory,
      int maxConcurrentDownloads,
      int? speedLimitKbps,
      bool wifiOnly,
      bool resumeOnReconnect,
      bool notifyOnStart,
      bool notifyOnComplete,
      bool notifyOnError,
      NotificationStyle notificationStyle,
      bool dailySummary,
      bool batterySaver,
      bool pauseOnLowBattery,
      int thumbnailCacheMb,
      int trashRetentionDays,
      bool analyticsEnabled});
}

/// @nodoc
class _$AppSettingsCopyWithImpl<$Res> implements $AppSettingsCopyWith<$Res> {
  _$AppSettingsCopyWithImpl(this._self, this._then);

  final AppSettings _self;
  final $Res Function(AppSettings) _then;

  /// Create a copy of AppSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? language = null,
    Object? themeMode = null,
    Object? clipboardDetection = null,
    Object? onboardingCompleted = null,
    Object? videoDirectory = freezed,
    Object? audioDirectory = freezed,
    Object? maxConcurrentDownloads = null,
    Object? speedLimitKbps = freezed,
    Object? wifiOnly = null,
    Object? resumeOnReconnect = null,
    Object? notifyOnStart = null,
    Object? notifyOnComplete = null,
    Object? notifyOnError = null,
    Object? notificationStyle = null,
    Object? dailySummary = null,
    Object? batterySaver = null,
    Object? pauseOnLowBattery = null,
    Object? thumbnailCacheMb = null,
    Object? trashRetentionDays = null,
    Object? analyticsEnabled = null,
  }) {
    return _then(_self.copyWith(
      language: null == language
          ? _self.language
          : language // ignore: cast_nullable_to_non_nullable
              as AppLanguage,
      themeMode: null == themeMode
          ? _self.themeMode
          : themeMode // ignore: cast_nullable_to_non_nullable
              as AppThemeMode,
      clipboardDetection: null == clipboardDetection
          ? _self.clipboardDetection
          : clipboardDetection // ignore: cast_nullable_to_non_nullable
              as bool,
      onboardingCompleted: null == onboardingCompleted
          ? _self.onboardingCompleted
          : onboardingCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      videoDirectory: freezed == videoDirectory
          ? _self.videoDirectory
          : videoDirectory // ignore: cast_nullable_to_non_nullable
              as String?,
      audioDirectory: freezed == audioDirectory
          ? _self.audioDirectory
          : audioDirectory // ignore: cast_nullable_to_non_nullable
              as String?,
      maxConcurrentDownloads: null == maxConcurrentDownloads
          ? _self.maxConcurrentDownloads
          : maxConcurrentDownloads // ignore: cast_nullable_to_non_nullable
              as int,
      speedLimitKbps: freezed == speedLimitKbps
          ? _self.speedLimitKbps
          : speedLimitKbps // ignore: cast_nullable_to_non_nullable
              as int?,
      wifiOnly: null == wifiOnly
          ? _self.wifiOnly
          : wifiOnly // ignore: cast_nullable_to_non_nullable
              as bool,
      resumeOnReconnect: null == resumeOnReconnect
          ? _self.resumeOnReconnect
          : resumeOnReconnect // ignore: cast_nullable_to_non_nullable
              as bool,
      notifyOnStart: null == notifyOnStart
          ? _self.notifyOnStart
          : notifyOnStart // ignore: cast_nullable_to_non_nullable
              as bool,
      notifyOnComplete: null == notifyOnComplete
          ? _self.notifyOnComplete
          : notifyOnComplete // ignore: cast_nullable_to_non_nullable
              as bool,
      notifyOnError: null == notifyOnError
          ? _self.notifyOnError
          : notifyOnError // ignore: cast_nullable_to_non_nullable
              as bool,
      notificationStyle: null == notificationStyle
          ? _self.notificationStyle
          : notificationStyle // ignore: cast_nullable_to_non_nullable
              as NotificationStyle,
      dailySummary: null == dailySummary
          ? _self.dailySummary
          : dailySummary // ignore: cast_nullable_to_non_nullable
              as bool,
      batterySaver: null == batterySaver
          ? _self.batterySaver
          : batterySaver // ignore: cast_nullable_to_non_nullable
              as bool,
      pauseOnLowBattery: null == pauseOnLowBattery
          ? _self.pauseOnLowBattery
          : pauseOnLowBattery // ignore: cast_nullable_to_non_nullable
              as bool,
      thumbnailCacheMb: null == thumbnailCacheMb
          ? _self.thumbnailCacheMb
          : thumbnailCacheMb // ignore: cast_nullable_to_non_nullable
              as int,
      trashRetentionDays: null == trashRetentionDays
          ? _self.trashRetentionDays
          : trashRetentionDays // ignore: cast_nullable_to_non_nullable
              as int,
      analyticsEnabled: null == analyticsEnabled
          ? _self.analyticsEnabled
          : analyticsEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// Adds pattern-matching-related methods to [AppSettings].
extension AppSettingsPatterns on AppSettings {
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
    TResult Function(_AppSettings value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AppSettings() when $default != null:
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
    TResult Function(_AppSettings value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AppSettings():
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
    TResult? Function(_AppSettings value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AppSettings() when $default != null:
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
            AppLanguage language,
            AppThemeMode themeMode,
            bool clipboardDetection,
            bool onboardingCompleted,
            String? videoDirectory,
            String? audioDirectory,
            int maxConcurrentDownloads,
            int? speedLimitKbps,
            bool wifiOnly,
            bool resumeOnReconnect,
            bool notifyOnStart,
            bool notifyOnComplete,
            bool notifyOnError,
            NotificationStyle notificationStyle,
            bool dailySummary,
            bool batterySaver,
            bool pauseOnLowBattery,
            int thumbnailCacheMb,
            int trashRetentionDays,
            bool analyticsEnabled)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AppSettings() when $default != null:
        return $default(
            _that.language,
            _that.themeMode,
            _that.clipboardDetection,
            _that.onboardingCompleted,
            _that.videoDirectory,
            _that.audioDirectory,
            _that.maxConcurrentDownloads,
            _that.speedLimitKbps,
            _that.wifiOnly,
            _that.resumeOnReconnect,
            _that.notifyOnStart,
            _that.notifyOnComplete,
            _that.notifyOnError,
            _that.notificationStyle,
            _that.dailySummary,
            _that.batterySaver,
            _that.pauseOnLowBattery,
            _that.thumbnailCacheMb,
            _that.trashRetentionDays,
            _that.analyticsEnabled);
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
            AppLanguage language,
            AppThemeMode themeMode,
            bool clipboardDetection,
            bool onboardingCompleted,
            String? videoDirectory,
            String? audioDirectory,
            int maxConcurrentDownloads,
            int? speedLimitKbps,
            bool wifiOnly,
            bool resumeOnReconnect,
            bool notifyOnStart,
            bool notifyOnComplete,
            bool notifyOnError,
            NotificationStyle notificationStyle,
            bool dailySummary,
            bool batterySaver,
            bool pauseOnLowBattery,
            int thumbnailCacheMb,
            int trashRetentionDays,
            bool analyticsEnabled)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AppSettings():
        return $default(
            _that.language,
            _that.themeMode,
            _that.clipboardDetection,
            _that.onboardingCompleted,
            _that.videoDirectory,
            _that.audioDirectory,
            _that.maxConcurrentDownloads,
            _that.speedLimitKbps,
            _that.wifiOnly,
            _that.resumeOnReconnect,
            _that.notifyOnStart,
            _that.notifyOnComplete,
            _that.notifyOnError,
            _that.notificationStyle,
            _that.dailySummary,
            _that.batterySaver,
            _that.pauseOnLowBattery,
            _that.thumbnailCacheMb,
            _that.trashRetentionDays,
            _that.analyticsEnabled);
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
            AppLanguage language,
            AppThemeMode themeMode,
            bool clipboardDetection,
            bool onboardingCompleted,
            String? videoDirectory,
            String? audioDirectory,
            int maxConcurrentDownloads,
            int? speedLimitKbps,
            bool wifiOnly,
            bool resumeOnReconnect,
            bool notifyOnStart,
            bool notifyOnComplete,
            bool notifyOnError,
            NotificationStyle notificationStyle,
            bool dailySummary,
            bool batterySaver,
            bool pauseOnLowBattery,
            int thumbnailCacheMb,
            int trashRetentionDays,
            bool analyticsEnabled)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AppSettings() when $default != null:
        return $default(
            _that.language,
            _that.themeMode,
            _that.clipboardDetection,
            _that.onboardingCompleted,
            _that.videoDirectory,
            _that.audioDirectory,
            _that.maxConcurrentDownloads,
            _that.speedLimitKbps,
            _that.wifiOnly,
            _that.resumeOnReconnect,
            _that.notifyOnStart,
            _that.notifyOnComplete,
            _that.notifyOnError,
            _that.notificationStyle,
            _that.dailySummary,
            _that.batterySaver,
            _that.pauseOnLowBattery,
            _that.thumbnailCacheMb,
            _that.trashRetentionDays,
            _that.analyticsEnabled);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _AppSettings extends AppSettings {
  const _AppSettings(
      {this.language = AppLanguage.ptBr,
      this.themeMode = AppThemeMode.system,
      this.clipboardDetection = true,
      this.onboardingCompleted = false,
      this.videoDirectory,
      this.audioDirectory,
      this.maxConcurrentDownloads = 3,
      this.speedLimitKbps,
      this.wifiOnly = false,
      this.resumeOnReconnect = true,
      this.notifyOnStart = true,
      this.notifyOnComplete = true,
      this.notifyOnError = true,
      this.notificationStyle = NotificationStyle.sound,
      this.dailySummary = false,
      this.batterySaver = false,
      this.pauseOnLowBattery = true,
      this.thumbnailCacheMb = 200,
      this.trashRetentionDays = 7,
      this.analyticsEnabled = false})
      : super._();
  factory _AppSettings.fromJson(Map<String, dynamic> json) =>
      _$AppSettingsFromJson(json);

// --- Geral ---
  @override
  @JsonKey()
  final AppLanguage language;
  @override
  @JsonKey()
  final AppThemeMode themeMode;
  @override
  @JsonKey()
  final bool clipboardDetection;

  /// False until the compliance onboarding has been seen (section 2.3).
  @override
  @JsonKey()
  final bool onboardingCompleted;
// --- Downloads ---
  @override
  final String? videoDirectory;
  @override
  final String? audioDirectory;
  @override
  @JsonKey()
  final int maxConcurrentDownloads;

  /// Speed cap in KB/s; null means unlimited.
  @override
  final int? speedLimitKbps;
  @override
  @JsonKey()
  final bool wifiOnly;
  @override
  @JsonKey()
  final bool resumeOnReconnect;
// --- Notificações ---
  @override
  @JsonKey()
  final bool notifyOnStart;
  @override
  @JsonKey()
  final bool notifyOnComplete;
  @override
  @JsonKey()
  final bool notifyOnError;
  @override
  @JsonKey()
  final NotificationStyle notificationStyle;
  @override
  @JsonKey()
  final bool dailySummary;
// --- Bateria e dados ---
  @override
  @JsonKey()
  final bool batterySaver;
  @override
  @JsonKey()
  final bool pauseOnLowBattery;
// --- Armazenamento ---
  @override
  @JsonKey()
  final int thumbnailCacheMb;
  @override
  @JsonKey()
  final int trashRetentionDays;
// --- Privacidade ---
  /// Analytics is opt-in, never opt-out (section 13, LGPD/GDPR).
  @override
  @JsonKey()
  final bool analyticsEnabled;

  /// Create a copy of AppSettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AppSettingsCopyWith<_AppSettings> get copyWith =>
      __$AppSettingsCopyWithImpl<_AppSettings>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$AppSettingsToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AppSettings &&
            (identical(other.language, language) ||
                other.language == language) &&
            (identical(other.themeMode, themeMode) ||
                other.themeMode == themeMode) &&
            (identical(other.clipboardDetection, clipboardDetection) ||
                other.clipboardDetection == clipboardDetection) &&
            (identical(other.onboardingCompleted, onboardingCompleted) ||
                other.onboardingCompleted == onboardingCompleted) &&
            (identical(other.videoDirectory, videoDirectory) ||
                other.videoDirectory == videoDirectory) &&
            (identical(other.audioDirectory, audioDirectory) ||
                other.audioDirectory == audioDirectory) &&
            (identical(other.maxConcurrentDownloads, maxConcurrentDownloads) ||
                other.maxConcurrentDownloads == maxConcurrentDownloads) &&
            (identical(other.speedLimitKbps, speedLimitKbps) ||
                other.speedLimitKbps == speedLimitKbps) &&
            (identical(other.wifiOnly, wifiOnly) ||
                other.wifiOnly == wifiOnly) &&
            (identical(other.resumeOnReconnect, resumeOnReconnect) ||
                other.resumeOnReconnect == resumeOnReconnect) &&
            (identical(other.notifyOnStart, notifyOnStart) ||
                other.notifyOnStart == notifyOnStart) &&
            (identical(other.notifyOnComplete, notifyOnComplete) ||
                other.notifyOnComplete == notifyOnComplete) &&
            (identical(other.notifyOnError, notifyOnError) ||
                other.notifyOnError == notifyOnError) &&
            (identical(other.notificationStyle, notificationStyle) ||
                other.notificationStyle == notificationStyle) &&
            (identical(other.dailySummary, dailySummary) ||
                other.dailySummary == dailySummary) &&
            (identical(other.batterySaver, batterySaver) ||
                other.batterySaver == batterySaver) &&
            (identical(other.pauseOnLowBattery, pauseOnLowBattery) ||
                other.pauseOnLowBattery == pauseOnLowBattery) &&
            (identical(other.thumbnailCacheMb, thumbnailCacheMb) ||
                other.thumbnailCacheMb == thumbnailCacheMb) &&
            (identical(other.trashRetentionDays, trashRetentionDays) ||
                other.trashRetentionDays == trashRetentionDays) &&
            (identical(other.analyticsEnabled, analyticsEnabled) ||
                other.analyticsEnabled == analyticsEnabled));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        language,
        themeMode,
        clipboardDetection,
        onboardingCompleted,
        videoDirectory,
        audioDirectory,
        maxConcurrentDownloads,
        speedLimitKbps,
        wifiOnly,
        resumeOnReconnect,
        notifyOnStart,
        notifyOnComplete,
        notifyOnError,
        notificationStyle,
        dailySummary,
        batterySaver,
        pauseOnLowBattery,
        thumbnailCacheMb,
        trashRetentionDays,
        analyticsEnabled
      ]);

  @override
  String toString() {
    return 'AppSettings(language: $language, themeMode: $themeMode, clipboardDetection: $clipboardDetection, onboardingCompleted: $onboardingCompleted, videoDirectory: $videoDirectory, audioDirectory: $audioDirectory, maxConcurrentDownloads: $maxConcurrentDownloads, speedLimitKbps: $speedLimitKbps, wifiOnly: $wifiOnly, resumeOnReconnect: $resumeOnReconnect, notifyOnStart: $notifyOnStart, notifyOnComplete: $notifyOnComplete, notifyOnError: $notifyOnError, notificationStyle: $notificationStyle, dailySummary: $dailySummary, batterySaver: $batterySaver, pauseOnLowBattery: $pauseOnLowBattery, thumbnailCacheMb: $thumbnailCacheMb, trashRetentionDays: $trashRetentionDays, analyticsEnabled: $analyticsEnabled)';
  }
}

/// @nodoc
abstract mixin class _$AppSettingsCopyWith<$Res>
    implements $AppSettingsCopyWith<$Res> {
  factory _$AppSettingsCopyWith(
          _AppSettings value, $Res Function(_AppSettings) _then) =
      __$AppSettingsCopyWithImpl;
  @override
  @useResult
  $Res call(
      {AppLanguage language,
      AppThemeMode themeMode,
      bool clipboardDetection,
      bool onboardingCompleted,
      String? videoDirectory,
      String? audioDirectory,
      int maxConcurrentDownloads,
      int? speedLimitKbps,
      bool wifiOnly,
      bool resumeOnReconnect,
      bool notifyOnStart,
      bool notifyOnComplete,
      bool notifyOnError,
      NotificationStyle notificationStyle,
      bool dailySummary,
      bool batterySaver,
      bool pauseOnLowBattery,
      int thumbnailCacheMb,
      int trashRetentionDays,
      bool analyticsEnabled});
}

/// @nodoc
class __$AppSettingsCopyWithImpl<$Res> implements _$AppSettingsCopyWith<$Res> {
  __$AppSettingsCopyWithImpl(this._self, this._then);

  final _AppSettings _self;
  final $Res Function(_AppSettings) _then;

  /// Create a copy of AppSettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? language = null,
    Object? themeMode = null,
    Object? clipboardDetection = null,
    Object? onboardingCompleted = null,
    Object? videoDirectory = freezed,
    Object? audioDirectory = freezed,
    Object? maxConcurrentDownloads = null,
    Object? speedLimitKbps = freezed,
    Object? wifiOnly = null,
    Object? resumeOnReconnect = null,
    Object? notifyOnStart = null,
    Object? notifyOnComplete = null,
    Object? notifyOnError = null,
    Object? notificationStyle = null,
    Object? dailySummary = null,
    Object? batterySaver = null,
    Object? pauseOnLowBattery = null,
    Object? thumbnailCacheMb = null,
    Object? trashRetentionDays = null,
    Object? analyticsEnabled = null,
  }) {
    return _then(_AppSettings(
      language: null == language
          ? _self.language
          : language // ignore: cast_nullable_to_non_nullable
              as AppLanguage,
      themeMode: null == themeMode
          ? _self.themeMode
          : themeMode // ignore: cast_nullable_to_non_nullable
              as AppThemeMode,
      clipboardDetection: null == clipboardDetection
          ? _self.clipboardDetection
          : clipboardDetection // ignore: cast_nullable_to_non_nullable
              as bool,
      onboardingCompleted: null == onboardingCompleted
          ? _self.onboardingCompleted
          : onboardingCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      videoDirectory: freezed == videoDirectory
          ? _self.videoDirectory
          : videoDirectory // ignore: cast_nullable_to_non_nullable
              as String?,
      audioDirectory: freezed == audioDirectory
          ? _self.audioDirectory
          : audioDirectory // ignore: cast_nullable_to_non_nullable
              as String?,
      maxConcurrentDownloads: null == maxConcurrentDownloads
          ? _self.maxConcurrentDownloads
          : maxConcurrentDownloads // ignore: cast_nullable_to_non_nullable
              as int,
      speedLimitKbps: freezed == speedLimitKbps
          ? _self.speedLimitKbps
          : speedLimitKbps // ignore: cast_nullable_to_non_nullable
              as int?,
      wifiOnly: null == wifiOnly
          ? _self.wifiOnly
          : wifiOnly // ignore: cast_nullable_to_non_nullable
              as bool,
      resumeOnReconnect: null == resumeOnReconnect
          ? _self.resumeOnReconnect
          : resumeOnReconnect // ignore: cast_nullable_to_non_nullable
              as bool,
      notifyOnStart: null == notifyOnStart
          ? _self.notifyOnStart
          : notifyOnStart // ignore: cast_nullable_to_non_nullable
              as bool,
      notifyOnComplete: null == notifyOnComplete
          ? _self.notifyOnComplete
          : notifyOnComplete // ignore: cast_nullable_to_non_nullable
              as bool,
      notifyOnError: null == notifyOnError
          ? _self.notifyOnError
          : notifyOnError // ignore: cast_nullable_to_non_nullable
              as bool,
      notificationStyle: null == notificationStyle
          ? _self.notificationStyle
          : notificationStyle // ignore: cast_nullable_to_non_nullable
              as NotificationStyle,
      dailySummary: null == dailySummary
          ? _self.dailySummary
          : dailySummary // ignore: cast_nullable_to_non_nullable
              as bool,
      batterySaver: null == batterySaver
          ? _self.batterySaver
          : batterySaver // ignore: cast_nullable_to_non_nullable
              as bool,
      pauseOnLowBattery: null == pauseOnLowBattery
          ? _self.pauseOnLowBattery
          : pauseOnLowBattery // ignore: cast_nullable_to_non_nullable
              as bool,
      thumbnailCacheMb: null == thumbnailCacheMb
          ? _self.thumbnailCacheMb
          : thumbnailCacheMb // ignore: cast_nullable_to_non_nullable
              as int,
      trashRetentionDays: null == trashRetentionDays
          ? _self.trashRetentionDays
          : trashRetentionDays // ignore: cast_nullable_to_non_nullable
              as int,
      analyticsEnabled: null == analyticsEnabled
          ? _self.analyticsEnabled
          : analyticsEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

// dart format on
