/// Full-text search index over the library (section 10).
///
/// Responsibility: own the FTS5 virtual table — its DDL, its
/// synchronization with `library_entry_rows` and the raw queries against
/// it.
///
/// The table is declared and queried with plain SQL rather than through
/// drift's `.drift` files: `drift_dev` 2.28 fails to serialize FTS5
/// virtual tables (it never registers them in `allSchemaEntities`, so
/// `createAll()` silently skips them). FTS5 queries need raw SQL anyway,
/// so nothing is lost and the schema stays under our control.
library;

import 'package:drift/drift.dart';

import 'database.dart';

/// Name of the FTS5 virtual table.
const String kSearchTable = 'library_search';

/// DDL for the index.
///
/// `remove_diacritics 2` is what makes "musica" match "música" — not
/// optional for the pt-BR launch locale. `entry_id` is UNINDEXED because
/// it is a join key, never a search term.
const String kSearchTableDdl = '''
CREATE VIRTUAL TABLE IF NOT EXISTS $kSearchTable USING fts5(
  entry_id UNINDEXED,
  title,
  author,
  platform,
  tags,
  tokenize = "unicode61 remove_diacritics 2"
)''';

/// Creates and maintains the FTS5 index.
final class SearchIndex {
  /// Creates the index helper over [db].
  const SearchIndex(this._db);

  final AppDatabase _db;

  /// Creates the virtual table if it does not exist yet.
  Future<void> create() => _db.customStatement(kSearchTableDdl);

  /// Rewrites the index row for one entry.
  ///
  /// FTS5 has no UPSERT, so an update is a delete followed by an insert;
  /// both run in the caller's transaction so the index never diverges
  /// from the library table.
  Future<void> upsert({
    required String entryId,
    required String title,
    String? author,
    String? platform,
    required List<String> tags,
  }) async {
    await remove(entryId);
    await _db.customInsert(
      'INSERT INTO $kSearchTable (entry_id, title, author, platform, tags) '
      'VALUES (?, ?, ?, ?, ?)',
      variables: [
        Variable<String>(entryId),
        Variable<String>(title),
        Variable<String>(author ?? ''),
        Variable<String>(platform ?? ''),
        Variable<String>(tags.join(' ')),
      ],
    );
  }

  /// Drops the index row for [entryId].
  Future<void> remove(String entryId) => _db.customUpdate(
        'DELETE FROM $kSearchTable WHERE entry_id = ?',
        variables: [Variable<String>(entryId)],
        updateKind: UpdateKind.delete,
      );

  /// Entry ids matching [matchExpression], most relevant first.
  ///
  /// [matchExpression] is FTS5 syntax and must already be escaped by
  /// [escapeFtsQuery] — passing user text straight through would let a
  /// stray quote or `NEAR` become a syntax error.
  Future<List<String>> search(String matchExpression) async {
    final rows = await _db.customSelect(
      'SELECT entry_id FROM $kSearchTable '
      "WHERE $kSearchTable MATCH ? ORDER BY rank",
      variables: [Variable<String>(matchExpression)],
    ).get();
    return rows.map((row) => row.read<String>('entry_id')).toList();
  }

  /// Distinct titles matching [matchExpression], for type-ahead.
  Future<List<String>> suggestTitles(
    String matchExpression, {
    int limit = 5,
  }) async {
    final rows = await _db.customSelect(
      'SELECT DISTINCT title FROM $kSearchTable '
      'WHERE $kSearchTable MATCH ? ORDER BY rank LIMIT ?',
      variables: [Variable<String>(matchExpression), Variable<int>(limit)],
    ).get();
    return rows.map((row) => row.read<String>('title')).toList();
  }

  /// Empties the index (used when rebuilding it from scratch).
  Future<void> clear() => _db.customUpdate('DELETE FROM $kSearchTable',
      updateKind: UpdateKind.delete);
}

/// Turns raw user input into a safe FTS5 MATCH expression.
///
/// Every token is wrapped in double quotes (escaping inner quotes), which
/// neutralizes FTS5 operators the user did not mean to type — `AND`,
/// `NEAR`, `*`, `-` and friends. A trailing `*` is appended to the last
/// token so typing continues to match by prefix (section 10).
String escapeFtsQuery(String input, {bool prefix = true}) {
  final tokens = input
      .split(RegExp(r'[\s]+'))
      .map((token) =>
          token.replaceAll(RegExp(r'[^\p{L}\p{N}_]', unicode: true), ''))
      .where((token) => token.isNotEmpty)
      .toList();
  if (tokens.isEmpty) return '';

  final quoted = <String>[];
  for (var i = 0; i < tokens.length; i++) {
    final isLast = i == tokens.length - 1;
    final token = tokens[i].replaceAll('"', '""');
    quoted.add(prefix && isLast ? '"$token"*' : '"$token"');
  }
  return quoted.join(' ');
}
