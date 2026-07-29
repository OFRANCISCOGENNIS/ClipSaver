/// drift-backed [SettingsRepository].
///
/// Responsibility: persist the whole settings object as one JSON row.
/// Using the app database rather than shared_preferences keeps settings
/// on the same storage as everything else — one backup, one encryption
/// story, and unit tests that need no platform channel.
library;

import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/error/failures.dart';
import '../../../core/error/result.dart';
import '../../../core/storage/database.dart';
import '../domain/app_settings.dart';
import '../domain/settings_repository.dart';

/// Key under which the settings JSON is stored.
const String kSettingsKey = 'app_settings';

/// Persists settings in the local database.
final class DriftSettingsRepository implements SettingsRepository {
  /// Creates the repository over [db].
  DriftSettingsRepository(this._db);

  final AppDatabase _db;
  final StreamController<AppSettings> _changes =
      StreamController<AppSettings>.broadcast();

  @override
  Future<Result<AppSettings>> load() async {
    try {
      final row = await (_db.select(_db.preferenceRows)
            ..where((t) => t.key.equals(kSettingsKey)))
          .getSingleOrNull();
      if (row == null) return const Result.ok(AppSettings());
      final decoded = jsonDecode(row.value) as Map<String, dynamic>;
      return Result.ok(AppSettings.fromJson(decoded));
    } on Object {
      // Corrupt or forward-version settings must not brick the app; the
      // defaults are always a safe place to start over from.
      return const Result.ok(AppSettings());
    }
  }

  @override
  Future<Result<AppSettings>> save(AppSettings settings) async {
    try {
      await _db.into(_db.preferenceRows).insertOnConflictUpdate(
            PreferenceRowsCompanion(
              key: const Value(kSettingsKey),
              value: Value(jsonEncode(settings.toJson())),
            ),
          );
      if (!_changes.isClosed) _changes.add(settings);
      return Result.ok(settings);
    } on Exception {
      return const Result.err(
        StorageFailure('Não foi possível salvar as configurações.'),
      );
    }
  }

  @override
  Stream<AppSettings> watch() => _changes.stream;

  /// Closes the change stream.
  Future<void> dispose() => _changes.close();
}
