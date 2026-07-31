/// In-memory [SettingsRepository] for tests that need to vary a
/// preference without touching drift.
library;

import 'dart:async';

import 'package:vidora/core/error/result.dart';
import 'package:vidora/features/settings/domain/app_settings.dart';
import 'package:vidora/features/settings/domain/settings_repository.dart';

/// Holds one [AppSettings] value in memory.
final class InMemorySettingsRepository implements SettingsRepository {
  /// Creates the repository, optionally seeded with [initial].
  InMemorySettingsRepository([AppSettings initial = const AppSettings()])
      : _settings = initial;

  AppSettings _settings;
  final StreamController<AppSettings> _changes =
      StreamController<AppSettings>.broadcast();

  @override
  Future<Result<AppSettings>> load() async => Result.ok(_settings);

  @override
  Future<Result<AppSettings>> save(AppSettings settings) async {
    _settings = settings;
    if (!_changes.isClosed) _changes.add(settings);
    return Result.ok(settings);
  }

  @override
  Stream<AppSettings> watch() => _changes.stream;

  /// Closes the change stream.
  Future<void> dispose() => _changes.close();
}
