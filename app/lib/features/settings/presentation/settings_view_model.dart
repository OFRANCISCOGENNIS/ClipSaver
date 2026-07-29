/// ViewModel of the Settings screen (section 16).
///
/// Responsibility: load, mutate and persist [AppSettings], and expose the
/// searchable index of every setting so the screen's internal search finds
/// entries the user cannot currently see.
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
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
  static const List<SettingsEntry> searchIndex = [
    SettingsEntry(
      section: 'Geral',
      title: 'Idioma',
      keywords: ['language', 'português', 'english', 'español'],
    ),
    SettingsEntry(
      section: 'Geral',
      title: 'Tema',
      keywords: ['claro', 'escuro', 'automático', 'dark', 'light'],
    ),
    SettingsEntry(
      section: 'Geral',
      title: 'Detectar link na área de transferência',
      keywords: ['clipboard', 'colar'],
    ),
    SettingsEntry(
      section: 'Downloads',
      title: 'Downloads simultâneos',
      keywords: ['paralelo', 'fila', 'concorrência'],
    ),
    SettingsEntry(
      section: 'Downloads',
      title: 'Limite de velocidade',
      keywords: ['banda', 'kb/s', 'throttle'],
    ),
    SettingsEntry(
      section: 'Downloads',
      title: 'Somente Wi-Fi',
      keywords: ['dados móveis', 'celular', '4g', '5g'],
    ),
    SettingsEntry(
      section: 'Downloads',
      title: 'Retomar ao reconectar',
      keywords: ['resume', 'reconexão'],
    ),
    SettingsEntry(
      section: 'Notificações',
      title: 'Avisar ao concluir',
      keywords: ['notificação', 'pronto'],
    ),
    SettingsEntry(
      section: 'Notificações',
      title: 'Avisar em caso de erro',
      keywords: ['falha', 'notificação'],
    ),
    SettingsEntry(
      section: 'Notificações',
      title: 'Estilo das notificações',
      keywords: ['som', 'vibrar', 'silencioso'],
    ),
    SettingsEntry(
      section: 'Notificações',
      title: 'Resumo diário',
      keywords: ['digest'],
    ),
    SettingsEntry(
      section: 'Bateria e dados',
      title: 'Modo economia',
      keywords: ['bateria', 'animações', 'economizar'],
    ),
    SettingsEntry(
      section: 'Bateria e dados',
      title: 'Pausar com bateria baixa',
      keywords: ['15%', 'bateria'],
    ),
    SettingsEntry(
      section: 'Armazenamento',
      title: 'Cache de miniaturas',
      keywords: ['thumbnail', 'limpar', 'espaço'],
    ),
    SettingsEntry(
      section: 'Armazenamento',
      title: 'Retenção da lixeira',
      keywords: ['dias', 'excluir', 'trash'],
    ),
    SettingsEntry(
      section: 'Privacidade',
      title: 'Enviar dados de uso',
      keywords: ['analytics', 'telemetria', 'lgpd', 'gdpr'],
    ),
    SettingsEntry(
      section: 'Privacidade',
      title: 'Política de uso responsável',
      keywords: ['conformidade', 'direitos autorais', 'licença'],
    ),
    SettingsEntry(
      section: 'Sobre',
      title: 'Versão e licenças',
      keywords: ['changelog', 'open source', 'suporte'],
    ),
  ];

  /// Index entries matching [query].
  static List<SettingsEntry> search(String query) =>
      searchIndex.where((entry) => entry.matches(query)).toList();
}
