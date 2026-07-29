/// Every user preference (section 16).
///
/// Responsibility: be one immutable, serializable object holding the whole
/// settings surface, so persistence is a single read/write and the UI can
/// diff it without coordinating a dozen keys.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_settings.freezed.dart';
part 'app_settings.g.dart';

/// Interface languages shipped in the MVP (section 16).
enum AppLanguage {
  /// Brazilian Portuguese.
  ptBr('pt-BR', 'Português (Brasil)'),

  /// English.
  en('en', 'English'),

  /// Spanish.
  es('es', 'Español');

  const AppLanguage(this.code, this.label);

  /// BCP-47 tag.
  final String code;

  /// Name shown in the picker, in its own language.
  final String label;
}

/// Theme choice (section 6.3).
enum AppThemeMode {
  /// Always light.
  light('Claro'),

  /// Always dark.
  dark('Escuro'),

  /// Follow the operating system.
  system('Automático');

  const AppThemeMode(this.label);

  /// Name shown in the picker.
  final String label;
}

/// How notifications are delivered (section 16).
enum NotificationStyle {
  /// Sound and vibration.
  sound('Som'),

  /// Vibration only.
  vibrate('Vibrar'),

  /// Neither.
  silent('Silencioso');

  const NotificationStyle(this.label);

  /// Name shown in the picker.
  final String label;
}

/// All user preferences.
@freezed
abstract class AppSettings with _$AppSettings {
  /// Creates a settings snapshot.
  const factory AppSettings({
    // --- Geral ---
    @Default(AppLanguage.ptBr) AppLanguage language,
    @Default(AppThemeMode.system) AppThemeMode themeMode,
    @Default(true) bool clipboardDetection,

    /// False until the compliance onboarding has been seen (section 2.3).
    @Default(false) bool onboardingCompleted,

    // --- Downloads ---
    String? videoDirectory,
    String? audioDirectory,
    @Default(3) int maxConcurrentDownloads,

    /// Speed cap in KB/s; null means unlimited.
    int? speedLimitKbps,
    @Default(false) bool wifiOnly,
    @Default(true) bool resumeOnReconnect,

    // --- Notificações ---
    @Default(true) bool notifyOnStart,
    @Default(true) bool notifyOnComplete,
    @Default(true) bool notifyOnError,
    @Default(NotificationStyle.sound) NotificationStyle notificationStyle,
    @Default(false) bool dailySummary,

    // --- Bateria e dados ---
    @Default(false) bool batterySaver,
    @Default(true) bool pauseOnLowBattery,

    // --- Armazenamento ---
    @Default(200) int thumbnailCacheMb,
    @Default(7) int trashRetentionDays,

    // --- Privacidade ---
    /// Analytics is opt-in, never opt-out (section 13, LGPD/GDPR).
    @Default(false) bool analyticsEnabled,
  }) = _AppSettings;

  /// Parses persisted JSON.
  factory AppSettings.fromJson(Map<String, dynamic> json) =>
      _$AppSettingsFromJson(json);

  const AppSettings._();

  /// Battery percentage below which downloads pause (section 16).
  static const int lowBatteryThreshold = 15;

  /// Effective parallel downloads, respecting battery saver.
  ///
  /// Saver mode halves the limit rather than disabling downloads: the user
  /// asked to spend less power, not to stop working.
  int get effectiveConcurrency {
    if (!batterySaver) return maxConcurrentDownloads;
    final halved = maxConcurrentDownloads ~/ 2;
    return halved < 1 ? 1 : halved;
  }

  /// Whether decorative animation should be suppressed (section 16).
  bool get reduceMotion => batterySaver;
}
