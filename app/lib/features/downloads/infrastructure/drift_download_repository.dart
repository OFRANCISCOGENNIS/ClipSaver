/// drift-backed implementation of [DownloadRepository].
///
/// Responsibility: map [DownloadTaskRows] to the domain entity and back.
/// State validity is the entity's job — this class persists what the
/// domain already validated and never mutates state on its own.
library;

import 'package:drift/drift.dart';

import '../../../core/domain/value_objects/checksum.dart';
import '../../../core/domain/value_objects/file_size.dart';
import '../../../core/domain/value_objects/media_format.dart';
import '../../../core/error/failures.dart';
import '../../../core/error/result.dart';
import '../../../core/storage/database.dart';
import '../domain/download_repository.dart';
import '../domain/download_state.dart';
import '../domain/download_task.dart';

/// Persists the download queue in the local database.
final class DriftDownloadRepository implements DownloadRepository {
  /// Creates the repository over [db].
  DriftDownloadRepository(this._db);

  final AppDatabase _db;

  @override
  Future<Result<DownloadTask>> enqueue(DownloadTask task) async {
    if (task.state != DownloadState.queued) {
      return const Result.err(
        StorageFailure('Apenas tarefas em fila podem ser enfileiradas.'),
      );
    }
    return save(task);
  }

  @override
  Future<Result<DownloadTask>> save(DownloadTask task) async {
    try {
      await _db.into(_db.downloadTaskRows).insertOnConflictUpdate(_toRow(task));
      return Result.ok(task);
    } on Exception {
      return const Result.err(StorageFailure('Falha ao gravar o download.'));
    }
  }

  @override
  Future<Result<DownloadTask?>> findById(String id) async {
    try {
      final row = await (_db.select(_db.downloadTaskRows)
            ..where((t) => t.id.equals(id)))
          .getSingleOrNull();
      return Result.ok(row == null ? null : _toEntity(row));
    } on Exception {
      return const Result.err(StorageFailure('Falha ao ler o download.'));
    }
  }

  @override
  Future<Result<List<DownloadTask>>> all() async {
    try {
      final rows = await _orderedQuery().get();
      return Result.ok(rows.map(_toEntity).toList(growable: false));
    } on Exception {
      return const Result.err(StorageFailure('Falha ao listar downloads.'));
    }
  }

  @override
  Stream<List<DownloadTask>> watchAll() => _orderedQuery()
      .watch()
      .map((rows) => rows.map(_toEntity).toList(growable: false));

  @override
  Future<Result<int>> clearFinished() async {
    try {
      final removed = await (_db.delete(_db.downloadTaskRows)
            ..where((t) => t.state.equals(DownloadState.done.name)))
          .go();
      return Result.ok(removed);
    } on Exception {
      return const Result.err(StorageFailure('Falha ao limpar concluídos.'));
    }
  }

  /// Active tasks first, then by priority, then FIFO — the order the
  /// Downloads screen renders (section 8.2).
  SimpleSelectStatement<$DownloadTaskRowsTable, DownloadTaskRow>
      _orderedQuery() => _db.select(_db.downloadTaskRows)
        ..orderBy([
          (t) => OrderingTerm.asc(
                t.state.isIn(
                  [DownloadState.done.name, DownloadState.canceled.name],
                ),
              ),
          (t) => OrderingTerm.asc(t.priority),
          (t) => OrderingTerm.asc(t.createdAt),
        ]);

  // Companion with explicit Value(null)s: a plain row data class would
  // treat nulls as "absent" on conflict-update, silently keeping stale
  // values (e.g. failureReason after a successful retry).
  DownloadTaskRowsCompanion _toRow(DownloadTask task) =>
      DownloadTaskRowsCompanion(
        id: Value(task.id),
        mediaItemId: Value(task.mediaItemId),
        title: Value(task.title),
        formatId: Value(task.format.id),
        formatKind: Value(task.format.kind.name),
        formatContainer: Value(task.format.container),
        formatCodec: Value(task.format.codec),
        formatHeight: Value(task.format.height),
        formatBitrateKbps: Value(task.format.bitrateKbps),
        sourceUrl: Value(task.sourceUrl),
        destinationPath: Value(task.destinationPath),
        state: Value(task.state.name),
        bytesDownloaded: Value(task.bytesDownloaded.bytes),
        totalBytes: Value(task.totalBytes?.bytes),
        checksumAlgorithm: Value(task.expectedChecksum?.algorithm.name),
        checksumHex: Value(task.expectedChecksum?.hexDigest),
        priority: Value(task.priority),
        retryCount: Value(task.retryCount),
        failureReason: Value(task.failureReason),
        createdAt: Value(task.createdAt),
      );

  DownloadTask _toEntity(DownloadTaskRow row) {
    Checksum? checksum;
    if (row.checksumAlgorithm != null && row.checksumHex != null) {
      final algorithm = ChecksumAlgorithm.values
          .firstWhere((a) => a.name == row.checksumAlgorithm);
      // Stored digests were validated on the way in; a corrupt row is a
      // storage bug we surface loudly instead of silently dropping.
      checksum = Checksum.create(algorithm, row.checksumHex!).fold(
        (value) => value,
        (failure) => throw StateError('checksum corrompido: $failure'),
      );
    }
    return DownloadTask(
      id: row.id,
      mediaItemId: row.mediaItemId,
      title: row.title,
      format: MediaFormat(
        id: row.formatId,
        kind: MediaKind.values.firstWhere((k) => k.name == row.formatKind),
        container: row.formatContainer,
        codec: row.formatCodec,
        height: row.formatHeight,
        bitrateKbps: row.formatBitrateKbps,
      ),
      sourceUrl: row.sourceUrl,
      destinationPath: row.destinationPath,
      state: DownloadState.values.firstWhere((s) => s.name == row.state),
      bytesDownloaded: FileSize.ofBytes(row.bytesDownloaded),
      totalBytes:
          row.totalBytes == null ? null : FileSize.ofBytes(row.totalBytes!),
      expectedChecksum: checksum,
      priority: row.priority,
      retryCount: row.retryCount,
      failureReason: row.failureReason,
      createdAt: row.createdAt,
    );
  }
}
