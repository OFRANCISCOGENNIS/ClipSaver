/// Platform services for the Web (PWA) target.
///
/// The database runs on SQLite compiled to WebAssembly, persisted through
/// OPFS or IndexedDB depending on what the browser supports — drift picks
/// the best available backend. Writing downloaded bytes straight to disk
/// needs the File System Access API, which is not universally available,
/// so that capability is behind a feature flag rather than pretended.
library;

import 'package:drift/wasm.dart';

import '../storage/database.dart';
import '../storage/download_file_system.dart';
import 'platform_services.dart';

/// Names of the runtime assets served alongside the app bundle.
///
/// They are binaries, not source: `tool/fetch_web_assets.sh` downloads
/// them into `web/` at build time.
const String kSqliteWasmAsset = 'sqlite3.wasm';

/// drift's shared web worker.
const String kDriftWorkerAsset = 'drift_worker.js';

/// Opens the WASM-backed database.
Future<PlatformServices> initPlatformServices() async {
  final result = await WasmDatabase.open(
    databaseName: 'vidora',
    sqlite3Uri: Uri.parse(kSqliteWasmAsset),
    driftWorkerUri: Uri.parse(kDriftWorkerAsset),
  );

  return PlatformServices(
    database: AppDatabase(result.resolvedExecutor),
    // The browser owns the download location; the engine hands finished
    // files to the page instead of choosing a path.
    downloadsDirectory: '',
    fileSystem: const UnsupportedDownloadFileSystem(),
    supportsBackgroundDownloads: false,
  );
}

/// Placeholder filesystem for browsers without File System Access.
///
/// It fails loudly rather than silently dropping bytes; the Web download
/// path is delivered with the PWA work in a later phase.
final class UnsupportedDownloadFileSystem implements DownloadFileSystem {
  /// Creates the placeholder.
  const UnsupportedDownloadFileSystem();

  Never _unsupported() => throw UnsupportedError(
        'Downloads diretos ainda não estão disponíveis nesta plataforma.',
      );

  @override
  Future<int> sizeOf(String path) async => _unsupported();

  @override
  Future<bool> exists(String path) async => _unsupported();

  @override
  Future<void> delete(String path) async => _unsupported();

  @override
  Future<void> rename(String from, String to) async => _unsupported();

  @override
  Future<ByteSink> openAppend(String path) async => _unsupported();

  @override
  Stream<List<int>> readChunks(String path) => _unsupported();
}
