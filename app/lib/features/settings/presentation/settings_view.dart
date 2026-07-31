/// The Settings screen (section 16).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/shell.dart';
import '../../../app/theme/tokens.dart';
import '../../../l10n/l10n.dart';
import '../domain/app_settings.dart';
import 'settings_view_model.dart';

/// Preferences, grouped in sections with an internal search.
class SettingsView extends ConsumerStatefulWidget {
  /// Creates the screen.
  const SettingsView({super.key});

  @override
  ConsumerState<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends ConsumerState<SettingsView> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(settingsViewModelProvider);
    final viewModel = ref.read(settingsViewModelProvider.notifier);
    final entitlements = ref.watch(entitlementsProvider);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: SafeArea(
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Padding(
              padding: kPagePadding,
              child: Text('$error'),
            ),
          ),
          data: (settings) => ListView(
            padding: kPagePadding,
            children: [
              TextField(
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(
                  hintText: l10n.settingsSearchHint,
                  prefixIcon: const Icon(Icons.search),
                ),
              ),
              const SizedBox(height: VidoraSpacing.lg),
              ..._sections(
                settings,
                viewModel,
                entitlements.maxConcurrentDownloads,
                l10n,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _sections(
    AppSettings settings,
    SettingsViewModel viewModel,
    int concurrencyCeiling,
    AppLocalizations l10n,
  ) {
    final rows = <String, List<Widget>>{
      l10n.settingsSectionGeneral: [
        _choice<AppThemeMode>(
          l10n.settingsTheme,
          settings.themeMode,
          AppThemeMode.values,
          (value) => value.label(l10n),
          (value) => viewModel.apply((c) => c.copyWith(themeMode: value)),
        ),
        _choice<AppLanguage>(
          l10n.settingsLanguage,
          settings.language,
          AppLanguage.values,
          // Language names stay in their own language: someone looking for
          // English scans the list for "English", not for "Inglês".
          (value) => value.label,
          (value) => viewModel.apply((c) => c.copyWith(language: value)),
        ),
        _toggle(
          l10n.settingsClipboardDetection,
          settings.clipboardDetection,
          (value) =>
              viewModel.apply((c) => c.copyWith(clipboardDetection: value)),
        ),
      ],
      l10n.settingsSectionDownloads: [
        _slider(
          l10n.settingsConcurrency,
          settings.maxConcurrentDownloads.toDouble(),
          min: 1,
          max: concurrencyCeiling.toDouble(),
          label: '${settings.maxConcurrentDownloads}',
          onChanged: (value) =>
              viewModel.setMaxConcurrentDownloads(value.round()),
        ),
        _toggle(
          l10n.settingsWifiOnly,
          settings.wifiOnly,
          (value) => viewModel.apply((c) => c.copyWith(wifiOnly: value)),
        ),
        _toggle(
          l10n.settingsResumeOnReconnect,
          settings.resumeOnReconnect,
          (value) =>
              viewModel.apply((c) => c.copyWith(resumeOnReconnect: value)),
        ),
      ],
      l10n.settingsSectionNotifications: [
        _toggle(
          l10n.settingsNotifyOnComplete,
          settings.notifyOnComplete,
          (value) =>
              viewModel.apply((c) => c.copyWith(notifyOnComplete: value)),
        ),
        _toggle(
          l10n.settingsNotifyOnError,
          settings.notifyOnError,
          (value) => viewModel.apply((c) => c.copyWith(notifyOnError: value)),
        ),
        _choice<NotificationStyle>(
          l10n.settingsNotificationStyle,
          settings.notificationStyle,
          NotificationStyle.values,
          (value) => value.label(l10n),
          (value) =>
              viewModel.apply((c) => c.copyWith(notificationStyle: value)),
        ),
        _toggle(
          l10n.settingsDailySummary,
          settings.dailySummary,
          (value) => viewModel.apply((c) => c.copyWith(dailySummary: value)),
        ),
      ],
      l10n.settingsSectionBattery: [
        _toggle(
          l10n.settingsBatterySaver,
          settings.batterySaver,
          (value) => viewModel.apply((c) => c.copyWith(batterySaver: value)),
          subtitle: l10n.settingsBatterySaverBody,
        ),
        _toggle(
          l10n.settingsPauseOnLowBattery,
          settings.pauseOnLowBattery,
          (value) =>
              viewModel.apply((c) => c.copyWith(pauseOnLowBattery: value)),
          subtitle: l10n.settingsPauseOnLowBatteryBody(
            AppSettings.lowBatteryThreshold,
          ),
        ),
      ],
      l10n.settingsSectionStorage: [
        _slider(
          l10n.settingsThumbnailCache,
          settings.thumbnailCacheMb.toDouble(),
          min: 50,
          max: 500,
          label: l10n.settingsMegabytes(settings.thumbnailCacheMb),
          onChanged: (value) => viewModel
              .apply((c) => c.copyWith(thumbnailCacheMb: value.round())),
        ),
        _slider(
          l10n.settingsTrashRetention,
          settings.trashRetentionDays.toDouble(),
          min: 1,
          max: 30,
          label: l10n.settingsDays(settings.trashRetentionDays),
          onChanged: (value) => viewModel
              .apply((c) => c.copyWith(trashRetentionDays: value.round())),
        ),
      ],
      l10n.settingsSectionPrivacy: [
        _toggle(
          l10n.settingsAnalytics,
          settings.analyticsEnabled,
          (value) =>
              viewModel.apply((c) => c.copyWith(analyticsEnabled: value)),
          // Opt-in, never opt-out: LGPD/GDPR consent must be affirmative.
          subtitle: l10n.settingsAnalyticsBody,
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.settingsPolicy),
          subtitle: Text(l10n.settingsPolicyBody),
          trailing: const Icon(Icons.open_in_new, size: 18),
        ),
      ],
    };

    final index = SettingsViewModel.searchIndexFor(l10n);
    final widgets = <Widget>[];
    for (final section in rows.entries) {
      final matching = <Widget>[];
      for (var i = 0; i < section.value.length; i++) {
        final entry = index.where(
          (candidate) => candidate.section == section.key,
        );
        // A row is shown when its section still has any match for the
        // query — the index carries the synonyms the labels do not.
        if (_query.trim().isEmpty ||
            entry.any((candidate) => candidate.matches(_query))) {
          matching.add(section.value[i]);
        }
      }
      if (matching.isEmpty) continue;
      widgets
        ..add(_header(section.key))
        ..addAll(matching)
        ..add(const SizedBox(height: VidoraSpacing.lg));
    }
    if (widgets.isEmpty) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(top: VidoraSpacing.xl),
          child: Text(
            l10n.settingsNoResults,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return widgets;
  }

  Widget _header(String title) => Padding(
        padding: const EdgeInsets.only(bottom: VidoraSpacing.sm),
        child: Text(title, style: Theme.of(context).textTheme.labelLarge),
      );

  Widget _toggle(
    String title,
    bool value,
    ValueChanged<bool> onChanged, {
    String? subtitle,
  }) =>
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(title),
        subtitle: subtitle == null ? null : Text(subtitle),
        value: value,
        onChanged: onChanged,
      );

  // Não é um ListTile de propósito. Com a fonte do sistema em 2x, o
  // dropdown no trailing fica mais largo do que o tile inteiro e o ListTile
  // lança "Trailing widget consumes the entire tile width" — e as outras 15
  // exceções da tela eram cascata dessa. O Wrap mantém título e controle na
  // mesma linha enquanto cabem, e desce o controle para a linha de baixo
  // quando a fonte cresce, em vez de estourar.
  Widget _choice<T>(
    String title,
    T current,
    List<T> options,
    String Function(T value) label,
    ValueChanged<T> onSelected,
  ) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: VidoraSpacing.sm),
        child: Row(
          children: [
            Expanded(child: Text(title)),
            const SizedBox(width: VidoraSpacing.md),
            // isExpanded dentro de um Flexible: sem isso o dropdown se
            // dimensiona pelo item mais largo — "Português (Brasil)" em 2x
            // pede 235px a mais do que a tela tem — e a Row interna dele
            // estoura sem nem consultar o layout de fora. Expandido, ele
            // aceita a largura que recebe e o rótulo ganha reticências.
            Flexible(
              child: DropdownButton<T>(
                value: current,
                underline: const SizedBox.shrink(),
                isExpanded: true,
                alignment: AlignmentDirectional.centerEnd,
                // itemHeight fixo (48 por padrão) não acompanha a fonte do
                // sistema; nulo dimensiona cada item pelo próprio texto.
                itemHeight: null,
                onChanged: (value) {
                  if (value != null) onSelected(value);
                },
                items: [
                  for (final option in options)
                    DropdownMenuItem(
                      value: option,
                      child: Text(
                        label(option),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _slider(
    String title,
    double value, {
    required double min,
    required double max,
    required String label,
    required ValueChanged<double> onChanged,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(title)),
              Text(label),
            ],
          ),
          Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: (max - min).round().clamp(1, 100),
            label: label,
            onChanged: onChanged,
          ),
        ],
      );
}
