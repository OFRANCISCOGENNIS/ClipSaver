/// Platform service abstraction (section 3: "camadas específicas por
/// plataforma isoladas via abstrações").
///
/// Responsibility: resolve everything that differs across the six target
/// platforms — where the database lives, where files are written, how
/// bytes hit the disk — behind one conditional import. Without this, a
/// single `dart:io` import in the bootstrap would break the Web build,
/// and a `dart:ffi` one would break it at compile time.
library;

import '../storage/database.dart';
import '../storage/download_file_system.dart';
import 'platform_services_io.dart'
    if (dart.library.js_interop) 'platform_services_web.dart' as impl;

/// Everything the app needs from the host platform.
final class PlatformServices {
  /// Creates the bundle.
  const PlatformServices({
    required this.database,
    required this.downloadsDirectory,
    required this.fileSystem,
    required this.supportsBackgroundDownloads,
  });

  /// Opened local database.
  final AppDatabase database;

  /// Directory finished downloads are written to.
  final String downloadsDirectory;

  /// Filesystem the download engine writes through.
  final DownloadFileSystem fileSystem;

  /// Feature flag (section 3): false on platforms where transfers cannot
  /// continue with the app closed, so the UI can say so instead of
  /// promising something it cannot deliver.
  final bool supportsBackgroundDownloads;
}

/// Initializes the platform services for the current target.
Future<PlatformServices> initPlatformServices() => impl.initPlatformServices();
