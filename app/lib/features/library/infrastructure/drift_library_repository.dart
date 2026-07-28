/// drift-backed implementation of [LibraryRepository].
///
/// Responsibility: map [LibraryEntryRows] to the domain entity and back,
/// implement tab queries/sorting and the trash lifecycle (section 9).
library;

import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/domain/value_objects/file_size.dart';
import '../../../core/domain/value_objects/license.dart';
import '../../../core/domain/value_objects/media_format.dart';
import '../../../core/error/failures.dart';
import '../../../core/error/result.dart';
import '../../../core/storage/database.dart';
import '../domain/library_entry.dart';
import '../domain/library_repository.dart';

/// Persists the library in the local database.
final class DriftLibraryRepository implements LibraryRepository {
  /// Creates the repository over [db].
  DriftLibraryRepository(this._db);

  final AppDatabase _db;

  @override
  Future<Result<LibraryEntry>> save(LibraryEntry entry) async {
    try {
      await _db
          .into(_db.libraryEntryRows)
          .insertOnConflictUpdate(_toRow(entry));
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
      query.orderBy([
        (t) {
          final mode = descending ? OrderingMode.desc : OrderingMode.asc;
          return switch (sort) {
            LibrarySort.downloadedAt =>
              OrderingTerm(expression: t.downloadedAt, mode: mode),
            LibrarySort.name => OrderingTerm(expression: t.title, mode: mode),
            LibrarySort.size =>
              OrderingTerm(expression: t.sizeBytes, mode: mode),
            LibrarySort.duration =>
              OrderingTerm(expression: t.durationMs, mode: mode),
            LibrarySort.platform =>
              OrderingTerm(expression: t.platform, mode: mode),
          };
        },
      ]);
      final rows = await query.get();
      return Result.ok(rows.map(_toEntity).toList(growable: false));
    } on Exception {
      return const Result.err(StorageFailure('Falha ao listar a biblioteca.'));
    }
  }

  @override
  Stream<List<LibraryEntry>> watchAll() => _db
      .select(_db.libraryEntryRows)
      .watch()
      .map((rows) => rows.map(_toEntity).toList(growable: false));

  @override
  Future<Result<LibraryEntry>> moveToTrash(String id, DateTime now) =>
      _transition(id, (entry) {
        if (entry.status == LibraryFileStatus.trashed) {
          return const Result.err(
            StorageFailure('O item já está na lixeira.'),
          );
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
            StorageFailure('O item não está na lixeira.'),
          );
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
      final removed = await (_db.delete(_db.libraryEntryRows)
            ..where(
              (t) =>
                  t.status.equals(LibraryFileStatus.trashed.name) &
                  t.trashedAt.isSmallerOrEqualValue(cutoff),
            ))
          .go();
      return Result.ok(removed);
    } on Exception {
      return const Result.err(StorageFailure('Falha ao esvaziar a lixeira.'));
    }
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
        platform: Value(entry.platform),
        licenseSpdxId: Value(entry.license?.spdxId),
        favorite: Value(entry.favorite),
        tagsJson: Value(jsonEncode(entry.tags)),
        status: Value(entry.status.name),
        downloadedAt: Value(entry.downloadedAt),
        trashedAt: Value(entry.trashedAt),
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
      );
}
