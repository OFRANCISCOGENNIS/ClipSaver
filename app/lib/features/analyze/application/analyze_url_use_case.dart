/// Use case: analyze a URL the user typed or pasted.
///
/// Responsibility: run the client-side validation of section 7.2 step 1
/// before spending a network round trip, then delegate to the repository.
/// The eligibility decision itself is never made here — it belongs to the
/// backend engine, and the app only renders it.
library;

import '../../../core/domain/value_objects/media_url.dart';
import '../../../core/error/result.dart';
import '../domain/analyze_repository.dart';
import '../domain/media_item.dart';

/// Analyzes one URL.
final class AnalyzeUrlUseCase {
  /// Creates the use case over [repository].
  const AnalyzeUrlUseCase(this._repository);

  final AnalyzeRepository _repository;

  /// Validates [rawUrl] and analyzes it.
  ///
  /// A malformed URL fails locally with a [ValidationFailure] so the user
  /// gets instant feedback instead of a round trip.
  Future<Result<MediaItem>> call(String rawUrl) async {
    final url = MediaUrl.create(rawUrl);
    final value = url.valueOrNull;
    if (value == null) return Result.err(url.failureOrNull!);
    return _repository.analyze(value);
  }
}

/// Use case: list the most recent analyses for the home shortcuts
/// (section 7.1).
final class RecentAnalysesUseCase {
  /// Creates the use case over [repository].
  const RecentAnalysesUseCase(this._repository);

  final AnalyzeRepository _repository;

  /// Newest analyses first, capped at [limit].
  Future<Result<List<MediaItem>>> call({int limit = 5}) =>
      _repository.recentAnalyses(limit: limit);
}
