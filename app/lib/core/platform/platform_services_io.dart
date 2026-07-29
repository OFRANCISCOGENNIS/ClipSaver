/// Platform services for Android, iOS, Windows, macOS and Linux.
library;

import 'dart:io';

import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../storage/database.dart';
import '../storage/io_download_file_system.dart';
import 'platform_services.dart';

/// Opens the native database and resolves the platform directories.
Future<PlatformServices> initPlatformServices() async {
  final supportDir = await getApplicationSupportDirectory();
  return PlatformServices(
    database: AppDatabase(
      // Runs SQLite on a background isolate so queries never compete with
      // the UI thread for frame budget (section 12).
      NativeDatabase.createInBackground(
        File(p.join(supportDir.path, 'vidora.sqlite')),
      ),
    ),
    downloadsDirectory: await _resolveDownloadsDirectory(),
    fileSystem: const IoDownloadFileSystem(),
    supportsBackgroundDownloads: true,
  );
}

/// Shared Downloads folder when the platform has one, otherwise the app's
/// documents directory (iOS and sandboxed macOS have no shared Downloads).
Future<String> _resolveDownloadsDirectory() async {
  final downloads = await getDownloadsDirectory();
  if (downloads != null) return p.join(downloads.path, 'Vidora');
  final documents = await getApplicationDocumentsDirectory();
  return p.join(documents.path, 'Vidora');
}
