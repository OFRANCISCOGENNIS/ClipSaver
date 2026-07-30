/// ViewModel of the Settings screen (section 16).
///
/// Responsibility: load, mutate and persist [AppSettings], and expose the
/// searchable index of every setting so the screen's internal search finds
/// entries the user cannot currently see.
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../l10n/l10n.dart';
import '../domain/app_settings.dart';
import '../domain/settings_repository.dart';

/// Provides the Settings ViewModel.
final settingsViewModelProvider =
    AsyncNotifierProvider<SettingsViewModel, AppSettings>(
  SettingsViewModel.new,
);

/// One searchable setting, for the in-screen search of section 16.
final class SettingsEntry {
  /// Creates an index entry.
  const SettingsEntry({
    required this.section,
    required this.title,
    this.keywords = const [],
  });

  /// Section heading it lives under.
  final String section;

  /// Label shown in the row.
  final String title;

  /// Extra words that should also find it.
  ///
  /// Deliberately multilingual and never displayed: someone running the
  /// app in Portuguese still types "dark", and someone in English still
  /// remembers "escuro". Splitting these per language would make the
  /// search worse in every language.
  final List<String> keywords;

  /// Whether [query] matches this entry.
  bool matches(String query) {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return true;
    return [section, title, ...keywords]
        .any((field) => field.toLowerCase().contains(needle));
  }
}

/// Drives the Settings screen.
final class SettingsViewModel extends AsyncNotifier<AppSettings> {
  late final SettingsRepository _repository;

  @override
  Future<AppSettings> build() async {
    _repository = ref.watch(settingsRepositoryProvider);
    final loaded = await _repository.load();
    return loaded.valueOrNull ?? const AppSettings();
  }

  /// Applies [change] to the current settings and persists the result.
  ///
  /// Named `apply` rather than `update`: `AsyncNotifier` already defines
  /// an `update` with a different contract.
  Future<void> apply(AppSettings Function(AppSettings current) change) async {
    final current = state.valueOrNull;
    if (current == null) return;
    final updated = change(current);
    // Optimistic: the UI reflects the choice immediately, and a failed
    // write surfaces as an error rather than a silently reverted toggle.
    state = AsyncData(updated);
    final saved = await _repository.save(updated);
    final failure = saved.failureOrNull;
    if (failure != null) {
      state = AsyncError(failure, StackTrace.current);
    }
  }

  /// Sets the parallel-download limit, clamped to what the plan allows.
  ///
  /// The clamp lives here rather than in the widget so a stale setting
  /// from a lapsed subscription cannot outlive the subscription.
  Future<void> setMaxConcurrentDownloads(int value) {
    final entitlements = ref.read(entitlementsProvider);
    return apply(
      (current) => current.copyWith(
        maxConcurrentDownloads: entitlements.clampConcurrency(value),
      ),
    );
  }

  /// Marks the compliance onboarding as seen (section 2.3).
  Future<void> completeOnboarding() =>
      apply((current) => current.copyWith(onboardingCompleted: true));

  /// The full searchable index of settings (section 16).
  ///
  /// Built against [l10n] rather than held as a `const`: the section and
  /// title are exactly the strings the screen renders, so a query that
  /// matches what the user can see always matches the index too.
  static List<SettingsEntry> searchIndexFor(AppLocalizations l10n) => [
        SettingsEntry(
          section: l10n.settingsSectionGeneral,
          title: l10n.settingsLanguage,
          keywords: const [
            'idioma',
            'language',
            'português',
            'english',
            'español',
          ],
        ),
        SettingsEntry(
          section: l10n.settingsSectionGeneral,
          title: l10n.settingsTheme,
          keywords: const [
            'tema',
            'theme',
            'claro',
            'escuro',
            'automático',
            'dark',
            'light',
            'oscuro',
          ],
        ),
        SettingsEntry(
          section: l10n.settingsSectionGeneral,
          title: l10n.settingsClipboardDetection,
          keywords: const [
            'clipboard',
            'colar',
            'área de transferência',
            'portapapeles',
            'paste',
          ],
        ),
        SettingsEntry(
          section: l10n.settingsSectionDownloads,
          title: l10n.settingsConcurrency,
          keywords: const [
            'paralelo',
            'fila',
            'concorrência',
            'parallel',
            'queue',
            'simultáneas',
          ],
        ),
        SettingsEntry(
          section: l10n.settingsSectionDownloads,
          title: l10n.settingsSpeedLimit,
          keywords: const ['banda', 'kb/s', 'throttle', 'velocidad', 'speed'],
        ),
        SettingsEntry(
          section: l10n.settingsSectionDownloads,
          title: l10n.settingsWifiOnly,
          keywords: const [
            'dados móveis',
            'celular',
            '4g',
            '5g',
            'mobile data',
            'datos',
          ],
        ),
        SettingsEntry(
          section: l10n.settingsSectionDownloads,
          title: l10n.settingsResumeOnReconnect,
          keywords: const ['resume', 'reconexão', 'retomar', 'reanudar'],
        ),
        SettingsEntry(
          section: l10n.settingsSectionNotifications,
          title: l10n.settingsNotifyOnComplete,
          keywords: const ['notificação', 'pronto', 'notification', 'done'],
        ),
        SettingsEntry(
          section: l10n.settingsSectionNotifications,
          title: l10n.settingsNotifyOnError,
          keywords: const ['falha', 'notificação', 'error', 'failure'],
        ),
        SettingsEntry(
          section: l10n.settingsSectionNotifications,
          title: l10n.settingsNotificationStyle,
          keywords: const [
            'som',
            'vibrar',
            'silencioso',
            'sound',
            'silent',
            'sonido',
          ],
        ),
        SettingsEntry(
          section: l10n.settingsSectionNotifications,
          title: l10n.settingsDailySummary,
          keywords: const ['digest', 'resumo', 'resumen', 'summary'],
        ),
        SettingsEntry(
          section: l10n.settingsSectionBattery,
          title: l10n.settingsBatterySaver,
          keywords: const [
            'bateria',
            'animações',
            'economizar',
            'battery',
            'saver',
            'ahorro',
          ],
        ),
        SettingsEntry(
          section: l10n.settingsSectionBattery,
          title: l10n.settingsPauseOnLowBattery,
          keywords: const ['15%', 'bateria', 'battery', 'batería'],
        ),
        SettingsEntry(
          section: l10n.settingsSectionStorage,
          title: l10n.settingsThumbnailCache,
          keywords: const [
            'thumbnail',
            'limpar',
            'espaço',
            'miniatura',
            'cache',
          ],
        ),
        SettingsEntry(
          section: l10n.settingsSectionStorage,
          title: l10n.settingsTrashRetention,
          keywords: const ['dias', 'excluir', 'trash', 'lixeira', 'papelera'],
        ),
        SettingsEntry(
          section: l10n.settingsSectionPrivacy,
          title: l10n.settingsAnalytics,
          keywords: const [
            'analytics',
            'telemetria',
            'lgpd',
            'gdpr',
            'privacidade',
          ],
        ),
        SettingsEntry(
          section: l10n.settingsSectionPrivacy,
          title: l10n.settingsPolicy,
          keywords: const [
            'conformidade',
            'direitos autorais',
            'licença',
            'copyright',
            'compliance',
          ],
        ),
        SettingsEntry(
          section: l10n.settingsSectionAbout,
          title: l10n.settingsAbout,
          keywords: const [
            'changelog',
            'open source',
            'suporte',
            'version',
            'licenses',
          ],
        ),
      ];

  /// Index entries matching [query].
  static List<SettingsEntry> search(String query, AppLocalizations l10n) =>
      searchIndexFor(l10n).where((entry) => entry.matches(query)).toList();
}
