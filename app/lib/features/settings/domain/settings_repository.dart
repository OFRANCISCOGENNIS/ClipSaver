/// Persistence contract for [AppSettings] (section 16).
library;

import '../../../core/error/result.dart';
import 'app_settings.dart';

/// Reads and writes user preferences.
abstract interface class SettingsRepository {
  /// Loads the stored settings, or the defaults on first run.
  Future<Result<AppSettings>> load();

  /// Persists [settings] in full.
  Future<Result<AppSettings>> save(AppSettings settings);

  /// Emits whenever settings change, so every screen stays in step.
  Stream<AppSettings> watch();
}
