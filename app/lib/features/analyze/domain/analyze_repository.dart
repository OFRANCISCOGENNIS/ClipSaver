/// Repository contract for URL analysis.
///
/// Responsibility: keep the application layer independent of HTTP/cache
/// details — the infrastructure layer implements this against the backend
/// `analysis` module (with its 24h idempotent cache, section 4.3).
library;

import '../../../core/domain/value_objects/media_url.dart';
import '../../../core/error/result.dart';
import 'media_item.dart';

/// Gateway to the backend analysis + eligibility service.
abstract interface class AnalyzeRepository {
  /// Analyzes [url] on the backend: eligibility + metadata extraction.
  ///
  /// Returns [MediaItem] on success (eligible or not — both are valid
  /// analysis outcomes); failures cover network, server and validation
  /// errors only.
  Future<Result<MediaItem>> analyze(MediaUrl url);

  /// Most recent analyses for the home shortcuts (section 7.1),
  /// newest first, capped at [limit].
  Future<Result<List<MediaItem>>> recentAnalyses({int limit = 5});
}
