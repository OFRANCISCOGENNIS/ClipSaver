// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppSettings _$AppSettingsFromJson(Map<String, dynamic> json) => _AppSettings(
      language: $enumDecodeNullable(_$AppLanguageEnumMap, json['language']) ??
          AppLanguage.ptBr,
      themeMode:
          $enumDecodeNullable(_$AppThemeModeEnumMap, json['themeMode']) ??
              AppThemeMode.system,
      clipboardDetection: json['clipboardDetection'] as bool? ?? true,
      onboardingCompleted: json['onboardingCompleted'] as bool? ?? false,
      videoDirectory: json['videoDirectory'] as String?,
      audioDirectory: json['audioDirectory'] as String?,
      maxConcurrentDownloads:
          (json['maxConcurrentDownloads'] as num?)?.toInt() ?? 3,
      speedLimitKbps: (json['speedLimitKbps'] as num?)?.toInt(),
      wifiOnly: json['wifiOnly'] as bool? ?? false,
      resumeOnReconnect: json['resumeOnReconnect'] as bool? ?? true,
      notifyOnStart: json['notifyOnStart'] as bool? ?? true,
      notifyOnComplete: json['notifyOnComplete'] as bool? ?? true,
      notifyOnError: json['notifyOnError'] as bool? ?? true,
      notificationStyle: $enumDecodeNullable(
              _$NotificationStyleEnumMap, json['notificationStyle']) ??
          NotificationStyle.sound,
      dailySummary: json['dailySummary'] as bool? ?? false,
      batterySaver: json['batterySaver'] as bool? ?? false,
      pauseOnLowBattery: json['pauseOnLowBattery'] as bool? ?? true,
      thumbnailCacheMb: (json['thumbnailCacheMb'] as num?)?.toInt() ?? 200,
      trashRetentionDays: (json['trashRetentionDays'] as num?)?.toInt() ?? 7,
      analyticsEnabled: json['analyticsEnabled'] as bool? ?? false,
    );

Map<String, dynamic> _$AppSettingsToJson(_AppSettings instance) =>
    <String, dynamic>{
      'language': _$AppLanguageEnumMap[instance.language]!,
      'themeMode': _$AppThemeModeEnumMap[instance.themeMode]!,
      'clipboardDetection': instance.clipboardDetection,
      'onboardingCompleted': instance.onboardingCompleted,
      'videoDirectory': instance.videoDirectory,
      'audioDirectory': instance.audioDirectory,
      'maxConcurrentDownloads': instance.maxConcurrentDownloads,
      'speedLimitKbps': instance.speedLimitKbps,
      'wifiOnly': instance.wifiOnly,
      'resumeOnReconnect': instance.resumeOnReconnect,
      'notifyOnStart': instance.notifyOnStart,
      'notifyOnComplete': instance.notifyOnComplete,
      'notifyOnError': instance.notifyOnError,
      'notificationStyle':
          _$NotificationStyleEnumMap[instance.notificationStyle]!,
      'dailySummary': instance.dailySummary,
      'batterySaver': instance.batterySaver,
      'pauseOnLowBattery': instance.pauseOnLowBattery,
      'thumbnailCacheMb': instance.thumbnailCacheMb,
      'trashRetentionDays': instance.trashRetentionDays,
      'analyticsEnabled': instance.analyticsEnabled,
    };

const _$AppLanguageEnumMap = {
  AppLanguage.ptBr: 'ptBr',
  AppLanguage.en: 'en',
  AppLanguage.es: 'es',
};

const _$AppThemeModeEnumMap = {
  AppThemeMode.light: 'light',
  AppThemeMode.dark: 'dark',
  AppThemeMode.system: 'system',
};

const _$NotificationStyleEnumMap = {
  NotificationStyle.sound: 'sound',
  NotificationStyle.vibrate: 'vibrate',
  NotificationStyle.silent: 'silent',
};
