/// Repository contract for library search (section 10).
library;

import '../../../core/error/result.dart';
import '../../library/domain/library_entry.dart';
import 'search_query.dart';

/// One search result: the entry plus why it matched.
final class SearchHit {
  /// Creates a hit.
  const SearchHit({required this.entry, required this.matchedByTypoTolerance});

  /// The matching library entry.
  final LibraryEntry entry;

  /// True when the hit came from the edit-distance fallback rather than an
  /// exact index match, so the UI can say "mostrando resultados para…".
  final bool matchedByTypoTolerance;
}

/// Search gateway over the local FTS5 index.
abstract interface class SearchRepository {
  /// Runs [query], returning hits ordered by relevance.
  Future<Result<List<SearchHit>>> search(SearchQuery query);

  /// Type-ahead suggestions for [prefix] (section 10).
  Future<Result<List<String>>> suggest(String prefix, {int limit = 5});

  /// Every distinct platform slug present in the library, for the filter.
  Future<Result<List<String>>> knownPlatforms();

  /// Every distinct tag present in the library, for the filter.
  Future<Result<List<String>>> knownTags();
}
