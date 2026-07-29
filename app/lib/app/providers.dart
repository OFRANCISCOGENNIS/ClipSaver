/// Global dependency injection (section 4.1: DI via Riverpod).
///
/// Responsibility: build the infrastructure graph once and expose it as
/// providers. Everything here is overridable, which is what lets tests
/// swap the network, the database and the filesystem for fakes without
/// touching a single ViewModel.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/api_client.dart';
import '../core/network/dio_api_client.dart';
import '../core/platform/clipboard_reader.dart';
import '../core/storage/database.dart';
import '../core/storage/download_file_system.dart';
import '../features/analyze/domain/analyze_repository.dart';
import '../features/analyze/infrastructure/analyze_repository_impl.dart';
import '../features/converter/application/conversion_manager.dart';
import '../features/converter/domain/media_converter.dart';
import '../features/converter/infrastructure/in_memory_converter_repository.dart';
import '../features/downloads/application/download_manager.dart';
import '../features/downloads/domain/download_repository.dart';
import '../features/downloads/infrastructure/dio_download_transport.dart';
import '../features/downloads/infrastructure/download_engine.dart';
import '../features/downloads/infrastructure/download_transport.dart';
import '../features/downloads/infrastructure/drift_download_repository.dart';
import '../features/library/domain/library_repository.dart';
import '../features/library/infrastructure/drift_library_repository.dart';
import '../features/premium/domain/entitlements.dart';
import '../features/search/domain/search_repository.dart';
import '../features/search/infrastructure/drift_search_repository.dart';
import '../features/settings/domain/settings_repository.dart';
import '../features/settings/infrastructure/drift_settings_repository.dart';

/// Base URL of the Vidora API.
///
/// Overridden per flavor at bootstrap; the default points at the local
/// docker-compose stack so a fresh checkout runs without configuration.
final apiBaseUrlProvider = Provider<String>(
  (ref) => const String.fromEnvironment(
    'VIDORA_API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  ),
);

/// The local database. Overridden in tests with an in-memory executor.
final databaseProvider = Provider<AppDatabase>(
  (ref) => throw UnimplementedError(
    'databaseProvider must be overridden at bootstrap with the opened '
    'AppDatabase — opening it requires an async platform path lookup.',
  ),
);

/// Directory where finished downloads are written.
///
/// Overridden at bootstrap with the platform's Downloads/Documents path;
/// resolving it needs an async platform call, so it cannot be a default.
final downloadsDirectoryProvider = Provider<String>(
  (ref) => throw UnimplementedError(
    'downloadsDirectoryProvider must be overridden at bootstrap with the '
    'platform downloads directory.',
  ),
);

/// HTTP client for the Vidora API.
final apiClientProvider = Provider<ApiClient>(
  (ref) => DioApiClient(baseUrl: ref.watch(apiBaseUrlProvider)),
);

/// Platform clipboard access.
final clipboardReaderProvider =
    Provider<ClipboardReader>((ref) => const SystemClipboardReader());

/// Filesystem used by the download engine.
///
/// Overridden at bootstrap with the platform implementation — it cannot
/// default here, because importing the `dart:io` one unconditionally
/// would break the Web build.
final downloadFileSystemProvider = Provider<DownloadFileSystem>(
  (ref) => throw UnimplementedError(
    'downloadFileSystemProvider must be overridden at bootstrap with the '
    'platform filesystem.',
  ),
);

/// Byte transport used by the download engine.
final downloadTransportProvider =
    Provider<DownloadTransport>((ref) => DioDownloadTransport());

/// Analysis + eligibility gateway.
final analyzeRepositoryProvider = Provider<AnalyzeRepository>(
  (ref) => AnalyzeRepositoryImpl(
    client: ref.watch(apiClientProvider),
    db: ref.watch(databaseProvider),
  ),
);

/// Download queue persistence.
final downloadRepositoryProvider = Provider<DownloadRepository>(
  (ref) => DriftDownloadRepository(ref.watch(databaseProvider)),
);

/// Library persistence.
final libraryRepositoryProvider = Provider<LibraryRepository>(
  (ref) => DriftLibraryRepository(ref.watch(databaseProvider)),
);

/// The byte-transfer engine.
final downloadEngineProvider = Provider<DownloadEngine>(
  (ref) => DownloadEngine(
    transport: ref.watch(downloadTransportProvider),
    fileSystem: ref.watch(downloadFileSystemProvider),
  ),
);

/// User preferences.
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final repository = DriftSettingsRepository(ref.watch(databaseProvider));
  ref.onDispose(() => repository.dispose());
  return repository;
});

/// The active plan (section 14).
///
/// Overridden by the billing layer once store receipts are wired; free is
/// the safe default — never grant paid features on a failed lookup.
final entitlementsProvider = Provider<Entitlements>((ref) => Entitlements.free);

/// The queue scheduler. Disposed with the container so in-flight
/// transfers are canceled instead of leaking.
final downloadManagerProvider = Provider<DownloadManager>((ref) {
  final manager = DownloadManager(
    repository: ref.watch(downloadRepositoryProvider),
    engine: ref.watch(downloadEngineProvider),
    // The plan is the ceiling, the setting is the request: a stale
    // setting from a lapsed subscription can never exceed the free limit.
    maxConcurrent: ref.watch(entitlementsProvider).clampConcurrency(
          ref.watch(requestedConcurrencyProvider),
        ),
  );
  ref.onDispose(manager.dispose);
  return manager;
});

/// Library search over the FTS5 index.
final searchRepositoryProvider = Provider<SearchRepository>(
  (ref) => DriftSearchRepository(
    db: ref.watch(databaseProvider),
    library: ref.watch(libraryRepositoryProvider),
  ),
);

/// Session-scoped conversion queue (section 11: independent of downloads).
final converterRepositoryProvider =
    Provider<InMemoryConverterRepository>((ref) {
  final repository = InMemoryConverterRepository();
  ref.onDispose(() => repository.dispose());
  return repository;
});

/// FFmpeg execution backend.
///
/// Overridden at bootstrap with the platform converter. There is no
/// default: `ffmpeg_kit_flutter` was retired upstream, so the replacement
/// is a deliberate choice rather than something to fall into.
final mediaConverterProvider = Provider<MediaConverter>(
  (ref) => throw UnimplementedError(
    'mediaConverterProvider must be overridden with a MediaConverter '
    'implementation for this platform.',
  ),
);

/// The conversion scheduler.
final conversionManagerProvider = Provider<ConversionManager>((ref) {
  final manager = ConversionManager(
    repository: ref.watch(converterRepositoryProvider),
    converter: ref.watch(mediaConverterProvider),
  );
  ref.onDispose(manager.dispose);
  return manager;
});

/// Concurrency the user asked for in Settings, before the plan clamp.
///
/// Overridden at bootstrap from the persisted settings; the default
/// matches section 8.2.
final requestedConcurrencyProvider = Provider<int>((ref) => 3);
