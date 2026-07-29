/// drift-backed implementation of [LibraryRepository].
///
/// Responsibility: map [LibraryEntryRows] to the domain entity and back,
/// implement tab queries/sorting and the trash lifecycle (section 9), and
/// keep the FTS5 index in step with every write — index maintenance is
/// deliberately here, in the same transaction as the row, rather than in
/// a trigger the Dart side cannot see.
library;

import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/domain/value_objects/file_size.dart';
import '../../../core/domain/value_objects/license.dart';
import '../../../core/domain/value_objects/media_format.dart';
import '../../../core/error/failures.dart';
import '../../../core/error/result.dart';
import '../../../core/storage/database.dart';
import '../../../core/storage/search_index.dart';
import '../domain/library_entry.dart';
import '../domain/library_repository.dart';

/// Persists the library in the local database.
final class DriftLibraryRepository implements LibraryRepository {
  /// Creates the repository over [db].
  DriftLibraryRepository(this._db) : _index = SearchIndex(_db);

  final AppDatabase _db;
  final SearchIndex _index;

  @override
  Future<Result<LibraryEntry>> save(LibraryEntry entry) async {
    try {
      await _db.transaction(() async {
        await _db
            .into(_db.libraryEntryRows)
            .insertOnConflictUpdate(_toRow(entry));
        // Trashed entries leave the index: they must not surface in search
        // until the user restores them.
        if (entry.status == LibraryFileStatus.trashed) {
          await _index.remove(entry.id);
        } else {
          await _index.upsert(
            entryId: entry.id,
            title: entry.title,
            author: entry.author,
            platform: entry.platform,
            tags: entry.tags,
          );
        }
      });
      return Result.ok(entry);
    } on Exception {
      return const Result.err(StorageFailure('Falha ao gravar o item.'));
    }
  }

  @override
  Future<Result<LibraryEntry?>> findById(String id) async {
    try {
      final row = await (_db.select(_db.libraryEntryRows)
            ..where((t) => t.id.equals(id)))
          .getSingleOrNull();
      return Result.ok(row == null ? null : _toEntity(row));
    } on Exception {
      return const Result.err(StorageFailure('Falha ao ler o item.'));
    }
  }

  @override
  Future<Result<List<LibraryEntry>>> list({
    MediaKind? kind,
    bool favoritesOnly = false,
    LibrarySort sort = LibrarySort.downloadedAt,
    bool descending = true,
  }) async {
    try {
      final query = _db.select(_db.libraryEntryRows)
        ..where((t) => t.status.equals(LibraryFileStatus.trashed.name).not());
      if (kind != null) {
        query.where((t) => t.kind.equals(kind.name));
      }
      if (favoritesOnly) {
        query.where((t) => t.favorite.equals(true));
      }
      query.orderBy([(t) => _orderingFor(t, sort, descending)]);
      final rows = await query.get();
      return Result.ok(rows.map(_toEntity).toList(growable: false));
    } on Exception {
      return const Result.err(StorageFailure('Falha ao listar a biblioteca.'));
    }
  }

  @override
  Future<Result<List<LibraryEntry>>> listTrashed() async {
    try {
      final rows = await (_db.select(_db.libraryEntryRows)
            ..where((t) => t.status.equals(LibraryFileStatus.trashed.name))
            ..orderBy([(t) => OrderingTerm.desc(t.trashedAt)]))
          .get();
      return Result.ok(rows.map(_toEntity).toList(growable: false));
    } on Exception {
      return const Result.err(StorageFailure('Falha ao listar a lixeira.'));
    }
  }

  @override
  Future<Result<LibraryCounts>> counts() async {
    try {
      final rows = await _db.select(_db.libraryEntryRows).get();
      var videos = 0;
      var audios = 0;
      var favorites = 0;
      var trashed = 0;
      for (final row in rows) {
        if (row.status == LibraryFileStatus.trashed.name) {
          trashed++;
          continue;
        }
        if (row.kind == MediaKind.video.name) {
          videos++;
        } else {
          audios++;
        }
        if (row.favorite) favorites++;
      }
      return Result.ok(
        LibraryCounts(
          videos: videos,
          audios: audios,
          favorites: favorites,
          trashed: trashed,
        ),
      );
    } on Exception {
      return const Result.err(StorageFailure('Falha ao contar os itens.'));
    }
  }

  @override
  Stream<List<LibraryEntry>> watchAll() => _db
      .select(_db.libraryEntryRows)
      .watch()
      .map((rows) => rows.map(_toEntity).toList(growable: false));

  @override
  Future<Result<LibraryEntry>> rename(String id, String title) =>
      _transition(id, (entry) {
        if (title.trim().isEmpty) {
          return const Result.err(
            ValidationFailure('O nome não pode ficar vazio.'),
          );
        }
        return Result.ok(entry.copyWith(title: title.trim()));
      });

  @override
  Future<Result<LibraryEntry>> setTags(String id, List<String> tags) =>
      _transition(id, (entry) {
        // Normalize here so the search index and the chips agree on what a
        // tag is: trimmed, lowercase, no blanks, no duplicates.
        final normalized = <String>{
          for (final tag in tags)
            if (tag.trim().isNotEmpty) tag.trim().toLowerCase(),
        }.toList()
          ..sort();
        return Result.ok(entry.copyWith(tags: normalized));
      });

  @override
  Future<Result<LibraryEntry>> setFavorite(
    String id, {
    required bool favorite,
  }) =>
      _transition(id, (entry) => Result.ok(entry.copyWith(favorite: favorite)));

  @override
  Future<Result<LibraryEntry>> markMissing(String id) =>
      _transition(id, (entry) {
        if (entry.status == LibraryFileStatus.trashed) {
          return const Result.err(
            StorageFailure('Itens na lixeira não são verificados.'),
          );
        }
        return Result.ok(entry.copyWith(status: LibraryFileStatus.missing));
      });

  @override
  Future<Result<LibraryEntry>> markAvailable(String id) =>
      _transition(id, (entry) {
        if (entry.status == LibraryFileStatus.trashed) {
          return const Result.err(
            StorageFailure('Restaure o item antes de reativá-lo.'),
          );
        }
        return Result.ok(entry.copyWith(status: LibraryFileStatus.available));
      });

  @override
  Future<Result<LibraryEntry>> moveToTrash(String id, DateTime now) =>
      _transition(id, (entry) {
        if (entry.status == LibraryFileStatus.trashed) {
          return const Result.err(StorageFailure('O item já está na lixeira.'));
        }
        return Result.ok(
          entry.copyWith(status: LibraryFileStatus.trashed, trashedAt: now),
        );
      });

  @override
  Future<Result<LibraryEntry>> restoreFromTrash(String id) =>
      _transition(id, (entry) {
        if (entry.status != LibraryFileStatus.trashed) {
          return const Result.err(
              StorageFailure('O item não está na lixeira.'));
        }
        return Result.ok(
          entry.copyWith(
            status: LibraryFileStatus.available,
            clearTrashedAt: true,
          ),
        );
      });

  @override
  Future<Result<int>> purgeExpiredTrash(DateTime now) async {
    try {
      final cutoff = now.subtract(
        const Duration(days: LibraryEntry.trashRetentionDays),
      );
      final expired = await (_db.select(_db.libraryEntryRows)
            ..where(
              (t) =>
                  t.status.equals(LibraryFileStatus.trashed.name) &
                  t.trashedAt.isSmallerOrEqualValue(cutoff),
            ))
          .get();
      await _db.transaction(() async {
        for (final row in expired) {
          await (_db.delete(_db.libraryEntryRows)
                ..where((t) => t.id.equals(row.id)))
              .go();
          await _index.remove(row.id);
        }
      });
      return Result.ok(expired.length);
    } on Exception {
      return const Result.err(StorageFailure('Falha ao esvaziar a lixeira.'));
    }
  }

  OrderingTerm _orderingFor(
    $LibraryEntryRowsTable t,
    LibrarySort sort,
    bool descending,
  ) {
    final mode = descending ? OrderingMode.desc : OrderingMode.asc;
    return switch (sort) {
      LibrarySort.downloadedAt =>
        OrderingTerm(expression: t.downloadedAt, mode: mode),
      LibrarySort.name => OrderingTerm(expression: t.title, mode: mode),
      LibrarySort.size => OrderingTerm(expression: t.sizeBytes, mode: mode),
      LibrarySort.duration =>
        OrderingTerm(expression: t.durationMs, mode: mode),
      LibrarySort.platform => OrderingTerm(expression: t.platform, mode: mode),
    };
  }

  Future<Result<LibraryEntry>> _transition(
    String id,
    Result<LibraryEntry> Function(LibraryEntry entry) change,
  ) async {
    final found = await findById(id);
    final failure = found.failureOrNull;
    if (failure != null) return Result.err(failure);
    final entry = found.valueOrNull;
    if (entry == null) {
      return const Result.err(StorageFailure('Item não encontrado.'));
    }
    final changed = change(entry);
    final changeFailure = changed.failureOrNull;
    if (changeFailure != null) return Result.err(changeFailure);
    return save(changed.valueOrNull!);
  }

  // Companion with explicit Value(null)s: a plain row data class would
  // treat nulls as "absent" on conflict-update, silently keeping stale
  // values (e.g. trashedAt after a restore).
  LibraryEntryRowsCompanion _toRow(LibraryEntry entry) =>
      LibraryEntryRowsCompanion(
        id: Value(entry.id),
        title: Value(entry.title),
        filePath: Value(entry.filePath),
        kind: Value(entry.kind.name),
        sizeBytes: Value(entry.size.bytes),
        durationMs: Value(entry.duration?.inMilliseconds),
        author: Value(entry.author),
        platform: Value(entry.platform),
        licenseSpdxId: Value(entry.license?.spdxId),
        favorite: Value(entry.favorite),
        tagsJson: Value(jsonEncode(entry.tags)),
        status: Value(entry.status.name),
        downloadedAt: Value(entry.downloadedAt),
        trashedAt: Value(entry.trashedAt),
        lastPlayedAt: Value(entry.lastPlayedAt),
      );

  LibraryEntry _toEntity(LibraryEntryRow row) => LibraryEntry(
        id: row.id,
        title: row.title,
        filePath: row.filePath,
        kind: MediaKind.values.firstWhere((k) => k.name == row.kind),
        size: FileSize.ofBytes(row.sizeBytes),
        duration: row.durationMs == null
            ? null
            : Duration(milliseconds: row.durationMs!),
        author: row.author,
        platform: row.platform,
        license: row.licenseSpdxId == null
            ? null
            : License.fromMetadata(row.licenseSpdxId),
        favorite: row.favorite,
        tags: (jsonDecode(row.tagsJson) as List<dynamic>).cast<String>(),
        status:
            LibraryFileStatus.values.firstWhere((s) => s.name == row.status),
        downloadedAt: row.downloadedAt,
        trashedAt: row.trashedAt,
        lastPlayedAt: row.lastPlayedAt,
      );
}
