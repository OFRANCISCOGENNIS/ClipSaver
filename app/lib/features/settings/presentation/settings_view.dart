/// The Settings screen (section 16).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/shell.dart';
import '../../../app/theme/tokens.dart';
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

    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
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
                decoration: const InputDecoration(
                  hintText: 'Buscar nas configurações',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              const SizedBox(height: VidoraSpacing.lg),
              ..._sections(
                  settings, viewModel, entitlements.maxConcurrentDownloads),
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
  ) {
    final rows = <String, List<Widget>>{
      'Geral': [
        _choice<AppThemeMode>(
          'Tema',
          settings.themeMode,
          AppThemeMode.values,
          (value) => value.label,
          (value) => viewModel.apply((c) => c.copyWith(themeMode: value)),
        ),
        _choice<AppLanguage>(
          'Idioma',
          settings.language,
          AppLanguage.values,
          (value) => value.label,
          (value) => viewModel.apply((c) => c.copyWith(language: value)),
        ),
        _toggle(
          'Detectar link na área de transferência',
          settings.clipboardDetection,
          (value) =>
              viewModel.apply((c) => c.copyWith(clipboardDetection: value)),
        ),
      ],
      'Downloads': [
        _slider(
          'Downloads simultâneos',
          settings.maxConcurrentDownloads.toDouble(),
          min: 1,
          max: concurrencyCeiling.toDouble(),
          label: '${settings.maxConcurrentDownloads}',
          onChanged: (value) =>
              viewModel.setMaxConcurrentDownloads(value.round()),
        ),
        _toggle(
          'Somente Wi-Fi',
          settings.wifiOnly,
          (value) => viewModel.apply((c) => c.copyWith(wifiOnly: value)),
        ),
        _toggle(
          'Retomar ao reconectar',
          settings.resumeOnReconnect,
          (value) =>
              viewModel.apply((c) => c.copyWith(resumeOnReconnect: value)),
        ),
      ],
      'Notificações': [
        _toggle(
          'Avisar ao concluir',
          settings.notifyOnComplete,
          (value) =>
              viewModel.apply((c) => c.copyWith(notifyOnComplete: value)),
        ),
        _toggle(
          'Avisar em caso de erro',
          settings.notifyOnError,
          (value) => viewModel.apply((c) => c.copyWith(notifyOnError: value)),
        ),
        _choice<NotificationStyle>(
          'Estilo das notificações',
          settings.notificationStyle,
          NotificationStyle.values,
          (value) => value.label,
          (value) =>
              viewModel.apply((c) => c.copyWith(notificationStyle: value)),
        ),
        _toggle(
          'Resumo diário',
          settings.dailySummary,
          (value) => viewModel.apply((c) => c.copyWith(dailySummary: value)),
        ),
      ],
      'Bateria e dados': [
        _toggle(
          'Modo economia',
          settings.batterySaver,
          (value) => viewModel.apply((c) => c.copyWith(batterySaver: value)),
          subtitle: 'Reduz downloads simultâneos e desliga animações.',
        ),
        _toggle(
          'Pausar com bateria baixa',
          settings.pauseOnLowBattery,
          (value) =>
              viewModel.apply((c) => c.copyWith(pauseOnLowBattery: value)),
          subtitle: 'Abaixo de ${AppSettings.lowBatteryThreshold}%.',
        ),
      ],
      'Armazenamento': [
        _slider(
          'Cache de miniaturas',
          settings.thumbnailCacheMb.toDouble(),
          min: 50,
          max: 500,
          label: '${settings.thumbnailCacheMb} MB',
          onChanged: (value) => viewModel
              .apply((c) => c.copyWith(thumbnailCacheMb: value.round())),
        ),
        _slider(
          'Retenção da lixeira',
          settings.trashRetentionDays.toDouble(),
          min: 1,
          max: 30,
          label: '${settings.trashRetentionDays} dias',
          onChanged: (value) => viewModel
              .apply((c) => c.copyWith(trashRetentionDays: value.round())),
        ),
      ],
      'Privacidade': [
        _toggle(
          'Enviar dados de uso',
          settings.analyticsEnabled,
          (value) =>
              viewModel.apply((c) => c.copyWith(analyticsEnabled: value)),
          // Opt-in, never opt-out: LGPD/GDPR consent must be affirmative.
          subtitle: 'Desligado por padrão. Nada é enviado sem sua permissão.',
        ),
        const ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text('Política de uso responsável'),
          subtitle: Text(
            'O Vidora só baixa conteúdo autorizado pela plataforma de '
            'origem ou pelo titular dos direitos.',
          ),
          trailing: Icon(Icons.open_in_new, size: 18),
        ),
      ],
    };

    final widgets = <Widget>[];
    for (final section in rows.entries) {
      final matching = <Widget>[];
      for (var i = 0; i < section.value.length; i++) {
        final entry = SettingsViewModel.searchIndex.where(
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
            'Nenhuma configuração encontrada.',
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

  Widget _choice<T>(
    String title,
    T current,
    List<T> options,
    String Function(T value) label,
    ValueChanged<T> onSelected,
  ) =>
      ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(title),
        trailing: DropdownButton<T>(
          value: current,
          underline: const SizedBox.shrink(),
          onChanged: (value) {
            if (value != null) onSelected(value);
          },
          items: [
            for (final option in options)
              DropdownMenuItem(value: option, child: Text(label(option))),
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
