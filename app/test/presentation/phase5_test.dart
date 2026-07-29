/// Settings persistence, the settings ViewModel and the process-backed
/// FFmpeg converter.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vidora/app/providers.dart';
import 'package:vidora/core/storage/database.dart';
import 'package:vidora/features/converter/domain/media_converter.dart';
import 'package:vidora/features/converter/infrastructure/process_media_converter.dart';
import 'package:vidora/features/premium/domain/entitlements.dart';
import 'package:vidora/features/settings/domain/app_settings.dart';
import 'package:vidora/features/settings/infrastructure/drift_settings_repository.dart';
import 'package:vidora/features/settings/presentation/settings_view_model.dart';

void main() {
  group('DriftSettingsRepository', () {
    late AppDatabase db;
    late DriftSettingsRepository repository;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      repository = DriftSettingsRepository(db);
    });

    tearDown(() async {
      await repository.dispose();
      await db.close();
    });

    test('returns defaults on first run', () async {
      final settings = (await repository.load()).valueOrNull!;
      expect(settings, const AppSettings());
      expect(settings.analyticsEnabled, isFalse);
      expect(settings.onboardingCompleted, isFalse);
    });

    test('round-trips every field', () async {
      const settings = AppSettings(
        language: AppLanguage.es,
        themeMode: AppThemeMode.dark,
        clipboardDetection: false,
        onboardingCompleted: true,
        maxConcurrentDownloads: 6,
        speedLimitKbps: 512,
        wifiOnly: true,
        resumeOnReconnect: false,
        notificationStyle: NotificationStyle.silent,
        dailySummary: true,
        batterySaver: true,
        thumbnailCacheMb: 350,
        trashRetentionDays: 14,
        analyticsEnabled: true,
      );
      await repository.save(settings);

      expect((await repository.load()).valueOrNull, settings);
    });

    test('emits on every save so other screens stay in step', () async {
      final seen = <AppSettings>[];
      final subscription = repository.watch().listen(seen.add);

      await repository.save(const AppSettings(wifiOnly: true));
      await Future<void>.delayed(Duration.zero);

      expect(seen.single.wifiOnly, isTrue);
      await subscription.cancel();
    });

    test('falls back to defaults rather than crashing on corrupt data',
        () async {
      // A forward-version or truncated blob must not brick the app.
      await db.customStatement(
        "INSERT OR REPLACE INTO preference_rows (key, value) "
        "VALUES ('$kSettingsKey', 'não é json')",
      );
      expect((await repository.load()).valueOrNull, const AppSettings());
    });
  });

  group('AppSettings behavior', () {
    test('battery saver halves concurrency but never stops downloads', () {
      const normal = AppSettings(maxConcurrentDownloads: 6);
      expect(normal.effectiveConcurrency, 6);

      const saving = AppSettings(maxConcurrentDownloads: 6, batterySaver: true);
      expect(saving.effectiveConcurrency, 3);

      const minimal =
          AppSettings(maxConcurrentDownloads: 1, batterySaver: true);
      expect(minimal.effectiveConcurrency, 1);
    });

    test('battery saver also reduces motion', () {
      expect(const AppSettings().reduceMotion, isFalse);
      expect(const AppSettings(batterySaver: true).reduceMotion, isTrue);
    });
  });

  group('SettingsViewModel', () {
    late AppDatabase db;
    late ProviderContainer container;

    ProviderContainer buildContainer(Entitlements entitlements) =>
        ProviderContainer(
          overrides: [
            databaseProvider.overrideWithValue(db),
            entitlementsProvider.overrideWithValue(entitlements),
          ],
        );

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      container = buildContainer(Entitlements.premium);
    });

    tearDown(() async {
      container.dispose();
      await Future<void>.delayed(Duration.zero);
      await db.close();
    });

    test('loads and persists a change', () async {
      final viewModel = container.read(settingsViewModelProvider.notifier);
      await container.read(settingsViewModelProvider.future);

      await viewModel.apply((current) => current.copyWith(wifiOnly: true));
      expect(
        container.read(settingsViewModelProvider).valueOrNull!.wifiOnly,
        isTrue,
      );

      // A fresh repository sees the persisted value.
      final reloaded = DriftSettingsRepository(db);
      expect((await reloaded.load()).valueOrNull!.wifiOnly, isTrue);
      await reloaded.dispose();
    });

    test('completing onboarding is persisted', () async {
      final viewModel = container.read(settingsViewModelProvider.notifier);
      await container.read(settingsViewModelProvider.future);

      await viewModel.completeOnboarding();
      expect(
        container
            .read(settingsViewModelProvider)
            .valueOrNull!
            .onboardingCompleted,
        isTrue,
      );
    });

    test('concurrency is clamped to the plan, not to what was asked', () async {
      container.dispose();
      container = buildContainer(Entitlements.free);

      final viewModel = container.read(settingsViewModelProvider.notifier);
      await container.read(settingsViewModelProvider.future);

      await viewModel.setMaxConcurrentDownloads(8);
      expect(
        container
            .read(settingsViewModelProvider)
            .valueOrNull!
            .maxConcurrentDownloads,
        2,
      );
    });

    group('internal search (section 16)', () {
      test('an empty query returns everything', () {
        expect(
          SettingsViewModel.search('').length,
          SettingsViewModel.searchIndex.length,
        );
      });

      test('finds by label', () {
        final results = SettingsViewModel.search('lixeira');
        expect(results, hasLength(1));
        expect(results.single.section, 'Armazenamento');
      });

      test('finds by synonym the label does not contain', () {
        expect(SettingsViewModel.search('lgpd').single.title,
            'Enviar dados de uso');
        expect(SettingsViewModel.search('clipboard').single.section, 'Geral');
        expect(SettingsViewModel.search('4g').single.title, 'Somente Wi-Fi');
      });

      test('finds by section name', () {
        expect(SettingsViewModel.search('Notificações'), hasLength(4));
      });

      test('is case- and whitespace-insensitive', () {
        expect(SettingsViewModel.search('  TEMA  '), isNotEmpty);
      });

      test('returns nothing for an unrelated query', () {
        expect(SettingsViewModel.search('zzzzz'), isEmpty);
      });
    });
  });

  group('ProcessMediaConverter', () {
    /// Builds a converter whose process is scripted by the test.
    (ProcessMediaConverter, _FakeProcess) converterWith({
      int exitCode = 0,
      List<String> stdoutLines = const [],
      List<String> stderrLines = const [],
    }) {
      final process = _FakeProcess(
        exitCode: exitCode,
        stdoutLines: stdoutLines,
        stderrLines: stderrLines,
      );
      final converter = ProcessMediaConverter(
        startProcess: (executable, arguments) async {
          process.startedWith = (executable, arguments);
          return process;
        },
      );
      return (converter, process);
    }

    test('reports success on exit code 0', () async {
      final (converter, _) = converterWith();
      final result = await converter.run(
        jobId: 'j1',
        arguments: const ['-i', 'a.mp4', 'a.mp3'],
        sourceDuration: const Duration(seconds: 100),
        onProgress: (_) {},
      );
      expect(result.outcome, ConversionOutcome.success);
    });

    test('passes the arguments through untouched', () async {
      final (converter, process) = converterWith();
      await converter.run(
        jobId: 'j1',
        arguments: const ['-i', 'a.mp4', 'a.mp3'],
        sourceDuration: null,
        onProgress: (_) {},
      );
      expect(process.startedWith!.$2, ['-i', 'a.mp4', 'a.mp3']);
    });

    test('turns FFmpeg progress lines into a fraction', () async {
      final (converter, _) = converterWith(
        stdoutLines: ['frame=10', 'out_time_us=25000000', 'progress=continue'],
      );
      final progress = <double>[];
      await converter.run(
        jobId: 'j1',
        arguments: const [],
        sourceDuration: const Duration(seconds: 100),
        onProgress: progress.add,
      );
      expect(progress, [0.25]);
    });

    test('reports no progress when the source duration is unknown', () async {
      final (converter, _) = converterWith(
        stdoutLines: ['out_time_us=25000000'],
      );
      final progress = <double>[];
      await converter.run(
        jobId: 'j1',
        arguments: const [],
        sourceDuration: null,
        onProgress: progress.add,
      );
      expect(progress, isEmpty);
    });

    test('translates known FFmpeg errors into actionable messages', () async {
      final cases = {
        'a.mp4: No such file or directory': 'origem não foi encontrado',
        'Error opening output: Permission denied': 'Sem permissão',
        'Unknown encoder libfoo': 'não é suportado',
        'Error writing: No space left on device': 'Espaço insuficiente',
        'moov atom not found': 'corrompido',
      };
      for (final entry in cases.entries) {
        final (converter, _) =
            converterWith(exitCode: 1, stderrLines: [entry.key]);
        final result = await converter.run(
          jobId: 'j1',
          arguments: const [],
          sourceDuration: null,
          onProgress: (_) {},
        );
        expect(result.outcome, ConversionOutcome.failure);
        expect(result.errorMessage, contains(entry.value), reason: entry.key);
      }
    });

    test('shows FFmpeg own words when the error is unrecognized', () async {
      final (converter, _) = converterWith(
        exitCode: 1,
        stderrLines: ['algo muito específico deu errado'],
      );
      final result = await converter.run(
        jobId: 'j1',
        arguments: const [],
        sourceDuration: null,
        onProgress: (_) {},
      );
      expect(result.errorMessage, contains('algo muito específico'));
    });

    test('a cancel kills the process and reports canceled', () async {
      final process = _FakeProcess(exitCode: 255, holdUntilKilled: true);
      final converter = ProcessMediaConverter(
        startProcess: (_, __) async => process,
      );

      final run = converter.run(
        jobId: 'j1',
        arguments: const [],
        sourceDuration: null,
        onProgress: (_) {},
      );
      await Future<void>.delayed(Duration.zero);
      converter.cancel('j1');

      expect((await run).outcome, ConversionOutcome.canceled);
      expect(process.killed, isTrue);
    });

    test('a cancel arriving during startup still aborts the run', () async {
      final process = _FakeProcess(exitCode: 255, holdUntilKilled: true);
      late ProcessMediaConverter converter;
      converter = ProcessMediaConverter(
        startProcess: (_, __) async {
          // The user hit cancel while the binary was still launching.
          converter.cancel('j1');
          return process;
        },
      );

      final result = await converter.run(
        jobId: 'j1',
        arguments: const [],
        sourceDuration: null,
        onProgress: (_) {},
      );
      expect(result.outcome, ConversionOutcome.canceled);
      expect(process.killed, isTrue);
    });

    test('a binary that cannot start fails with a readable message', () async {
      final converter = ProcessMediaConverter(
        startProcess: (_, __) async => throw const ProcessException('x', []),
      );
      final result = await converter.run(
        jobId: 'j1',
        arguments: const [],
        sourceDuration: null,
        onProgress: (_) {},
      );
      expect(result.outcome, ConversionOutcome.failure);
      expect(result.errorMessage, contains('iniciar'));
    });
  });
}

/// Scripted stand-in for an FFmpeg process.
final class _FakeProcess implements Process {
  _FakeProcess({
    required int exitCode,
    this.stdoutLines = const [],
    this.stderrLines = const [],
    this.holdUntilKilled = false,
  }) : _exitCode = exitCode {
    if (!holdUntilKilled) _exit.complete(_exitCode);
  }

  final int _exitCode;
  final List<String> stdoutLines;
  final List<String> stderrLines;

  /// When true the process only exits once killed.
  final bool holdUntilKilled;

  final Completer<int> _exit = Completer<int>();

  /// Whether [kill] was called.
  bool killed = false;

  /// Executable and arguments the converter launched with.
  (String, List<String>)? startedWith;

  @override
  Future<int> get exitCode => _exit.future;

  @override
  Stream<List<int>> get stdout => Stream.fromIterable(
        stdoutLines.map((line) => utf8.encode('$line\n')),
      );

  @override
  Stream<List<int>> get stderr => Stream.fromIterable(
        stderrLines.map((line) => utf8.encode('$line\n')),
      );

  @override
  IOSink get stdin => throw UnimplementedError();

  @override
  int get pid => 1234;

  @override
  bool kill([ProcessSignal signal = ProcessSignal.sigterm]) {
    killed = true;
    if (!_exit.isCompleted) _exit.complete(_exitCode);
    return true;
  }
}
