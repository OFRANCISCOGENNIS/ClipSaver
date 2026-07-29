/// FTS5-backed implementation of [SearchRepository] (section 10).
///
/// Responsibility: translate a [SearchQuery] into an index lookup plus
/// filter predicates, and fall back to edit-distance matching when the
/// index finds nothing — a typo should return results, not an empty
/// screen.
library;

import 'package:path/path.dart' as p;

import '../../../core/error/failures.dart';
import '../../../core/error/result.dart';
import '../../../core/storage/database.dart';
import '../../../core/storage/search_index.dart';
import '../../../core/utils/edit_distance.dart';
import '../../library/domain/library_entry.dart';
import '../../library/domain/library_repository.dart';
import '../domain/search_query.dart';
import '../domain/search_repository.dart';

/// Searches the library through the FTS5 index.
final class DriftSearchRepository implements SearchRepository {
  /// Creates the repository over [db] and the library [library].
  DriftSearchRepository({
    required AppDatabase db,
    required LibraryRepository library,
  })  : _index = SearchIndex(db),
        _library = library;

  final SearchIndex _index;
  final LibraryRepository _library;

  @override
  Future<Result<List<SearchHit>>> search(SearchQuery query) async {
    try {
      final all = await _library.list();
      final entries = all.valueOrNull;
      if (entries == null) return Result.err(all.failureOrNull!);

      final text = query.text.trim();
      if (text.isEmpty) {
        // Filters only: no index lookup needed.
        return Result.ok(
          _applyFilters(entries, query)
              .map((entry) =>
                  SearchHit(entry: entry, matchedByTypoTolerance: false))
              .toList(growable: false),
        );
      }

      final byId = {for (final entry in entries) entry.id: entry};
      final matchExpression = escapeFtsQuery(text);
      final rankedIds = matchExpression.isEmpty
          ? <String>[]
          : await _index.search(matchExpression);

      // FTS5 returns ids in relevance order; preserve it.
      final matched = <LibraryEntry>[
        for (final id in rankedIds)
          if (byId[id] != null) byId[id]!,
      ];
      final filtered = _applyFilters(matched, query);
      if (filtered.isNotEmpty) {
        return Result.ok(
          filtered
              .map((entry) =>
                  SearchHit(entry: entry, matchedByTypoTolerance: false))
              .toList(growable: false),
        );
      }

      // Nothing matched exactly — try one edit away before giving up.
      final fuzzy = _applyFilters(_fuzzyMatches(entries, text), query);
      return Result.ok(
        fuzzy
            .map((entry) =>
                SearchHit(entry: entry, matchedByTypoTolerance: true))
            .toList(growable: false),
      );
    } on Exception {
      return const Result.err(StorageFailure('Falha ao buscar na biblioteca.'));
    }
  }

  @override
  Future<Result<List<String>>> suggest(String prefix, {int limit = 5}) async {
    final trimmed = prefix.trim();
    if (trimmed.isEmpty) return const Result.ok([]);
    try {
      final matchExpression = escapeFtsQuery(trimmed);
      if (matchExpression.isEmpty) return const Result.ok([]);
      return Result.ok(
          await _index.suggestTitles(matchExpression, limit: limit));
    } on Exception {
      return const Result.ok([]);
    }
  }

  @override
  Future<Result<List<String>>> knownPlatforms() async {
    final all = await _library.list();
    final entries = all.valueOrNull;
    if (entries == null) return Result.err(all.failureOrNull!);
    final platforms = <String>{
      for (final entry in entries)
        if (entry.platform != null) entry.platform!,
    }.toList()
      ..sort();
    return Result.ok(platforms);
  }

  @override
  Future<Result<List<String>>> knownTags() async {
    final all = await _library.list();
    final entries = all.valueOrNull;
    if (entries == null) return Result.err(all.failureOrNull!);
    final tags = <String>{for (final entry in entries) ...entry.tags}.toList()
      ..sort();
    return Result.ok(tags);
  }

  /// Entries with any searchable word within one edit of a query term.
  List<LibraryEntry> _fuzzyMatches(List<LibraryEntry> entries, String text) {
    final terms = text
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((term) => term.isNotEmpty)
        .toList();
    if (terms.isEmpty) return const [];

    return entries.where((entry) {
      final haystack = [
        entry.title,
        entry.author ?? '',
        entry.platform ?? '',
        ...entry.tags,
      ].join(' ');
      // Every term must land somewhere, so "aula flutr" does not match an
      // entry that only satisfies "aula".
      return terms.every((term) => anyWordWithinOneEdit(haystack, term));
    }).toList(growable: false);
  }

  List<LibraryEntry> _applyFilters(
    List<LibraryEntry> entries,
    SearchQuery query,
  ) =>
      entries.where((entry) {
        if (query.kind != null && entry.kind != query.kind) return false;
        if (query.platform != null && entry.platform != query.platform) {
          return false;
        }
        if (query.durationBucket != null &&
            !query.durationBucket!.contains(entry.duration)) {
          return false;
        }
        if (query.dateRange != null &&
            !query.dateRange!.contains(entry.downloadedAt)) {
          return false;
        }
        if (query.minSize != null && entry.size.compareTo(query.minSize!) < 0) {
          return false;
        }
        if (query.maxSize != null && entry.size.compareTo(query.maxSize!) > 0) {
          return false;
        }
        if (query.containers.isNotEmpty &&
            !query.containers.contains(containerOf(entry.filePath))) {
          return false;
        }
        if (query.tags.isNotEmpty &&
            !entry.tags.toSet().containsAll(query.tags)) {
          return false;
        }
        return true;
      }).toList(growable: false);
}

/// File container of [filePath]: lowercase extension without the dot.
String containerOf(String filePath) {
  final extension = p.extension(filePath);
  return extension.isEmpty ? '' : extension.substring(1).toLowerCase();
}
