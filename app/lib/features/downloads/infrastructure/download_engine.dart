/// The byte-transfer engine (sections 8.1–8.3).
///
/// Responsibility: perform exactly one download attempt for one task and
/// drive it through the domain state machine — connecting → downloading →
/// completed → verifying → done — persisting nothing itself. Every state
/// change is emitted so the caller (the queue manager) can persist it and
/// the UI can render it.
///
/// Retry policy lives in the manager, not here: an engine that retried on
/// its own would fight the queue's backoff budget.
library;

import 'package:crypto/crypto.dart';

import '../../../core/domain/value_objects/checksum.dart';
import '../../../core/domain/value_objects/file_size.dart';
import '../../../core/error/failures.dart';
import '../../../core/error/result.dart';
import '../../../core/storage/download_file_system.dart';
import '../domain/download_state.dart';
import '../domain/download_task.dart';
import 'download_transport.dart';

/// Why an in-flight transfer was stopped by the user.
enum _StopIntent { pause, cancel }

/// Bookkeeping for one running transfer.
final class _ActiveTransfer {
  _ActiveTransfer();

  TransferHandle? handle;
  _StopIntent? intent;

  void stop(_StopIntent reason) {
    intent = reason;
    handle?.cancel();
  }
}

/// Callback invoked on every state or progress change.
typedef DownloadTaskListener = void Function(DownloadTask task);

/// Runs single download attempts over [DownloadTransport].
final class DownloadEngine {
  /// Creates the engine over its two ports.
  DownloadEngine({
    required DownloadTransport transport,
    required DownloadFileSystem fileSystem,
  })  : _transport = transport,
        _fileSystem = fileSystem;

  final DownloadTransport _transport;
  final DownloadFileSystem _fileSystem;
  final Map<String, _ActiveTransfer> _active = {};

  /// Ids of transfers currently in flight.
  Iterable<String> get activeTaskIds => _active.keys;

  /// Requests a pause: bytes already written are kept for resuming.
  void pause(String taskId) => _active[taskId]?.stop(_StopIntent.pause);

  /// Requests a cancel: the partial file is discarded.
  void cancel(String taskId) => _active[taskId]?.stop(_StopIntent.cancel);

  /// Runs one attempt for [task], which must be resumable (queued or
  /// paused). Emits every intermediate state through [onUpdate] and
  /// returns the final task — `done`, `paused`, `canceled` or `failed`.
  ///
  /// Failures are returned, never thrown: the manager decides whether the
  /// task earns a retry.
  Future<Result<DownloadTask>> run(
    DownloadTask task, {
    required DownloadTaskListener onUpdate,
  }) async {
    if (task.state != DownloadState.queued &&
        task.state != DownloadState.paused) {
      return Result.err(
        InvalidTransitionFailure(
          'download em ${task.state.name} não pode ser iniciado',
        ),
      );
    }

    final transfer = _ActiveTransfer();
    _active[task.id] = transfer;
    try {
      return await _transfer(task, transfer, onUpdate);
    } finally {
      _active.remove(task.id);
    }
  }

  Future<Result<DownloadTask>> _transfer(
    DownloadTask initial,
    _ActiveTransfer transfer,
    DownloadTaskListener onUpdate,
  ) async {
    var task = initial;

    // The two entry paths differ by design (section 8.1): a fresh task
    // goes queued → connecting, while a paused one resumes straight into
    // downloading — `paused` has no edge to `connecting`. Moving first
    // also means a failure while reconnecting has a legal edge to `failed`
    // from either state.
    task = _emit(
      task,
      task.state == DownloadState.paused
          ? DownloadState.downloading
          : DownloadState.connecting,
      onUpdate,
    );

    final partPath = task.partFilePath;
    var received = await _fileSystem.sizeOf(partPath);

    final DownloadStream stream;
    try {
      stream = await _transport.open(
        task.sourceUrl,
        startByte: received,
        onHandle: (handle) {
          transfer.handle = handle;
          // The user may have hit pause/cancel while we were connecting.
          if (transfer.intent != null) handle.cancel();
        },
      );
    } on Object catch (error) {
      return _fail(
          task, 'Não foi possível conectar à origem.', error, onUpdate);
    }

    // The server ignored our Range header and is restarting from byte 0;
    // appending would corrupt the file, so the partial bytes are dropped.
    if (received > 0 && !stream.resumed) {
      await _fileSystem.delete(partPath);
      received = 0;
    }

    // A part file larger than the resource means the origin changed under
    // us (or the file is stale). Start over rather than carry bytes that
    // would violate the entity's downloaded <= total invariant.
    if (stream.totalBytes != null && received > stream.totalBytes!) {
      await _fileSystem.delete(partPath);
      received = 0;
    }
    task = task.copyWith(
      bytesDownloaded: FileSize.ofBytes(received),
      totalBytes: stream.totalBytes == null
          ? null
          : FileSize.ofBytes(stream.totalBytes!),
    );
    if (task.state == DownloadState.connecting) {
      task = _emit(task, DownloadState.downloading, onUpdate);
    } else {
      onUpdate(task);
    }

    final sink = await _fileSystem.openAppend(partPath);
    try {
      await for (final chunk in stream.bytes) {
        if (transfer.intent != null) break;
        sink.add(chunk);
        received += chunk.length;
        final progressed = task.withProgress(FileSize.ofBytes(received));
        // A chunk overshooting the announced size means the origin lied
        // about Content-Length; treat it as a corrupt transfer.
        if (progressed.isErr) {
          await sink.close();
          return _fail(
            task,
            'A origem enviou mais dados do que o esperado.',
            null,
            onUpdate,
          );
        }
        task = progressed.valueOrNull!;
        onUpdate(task);
      }
    } on Object catch (error) {
      await sink.close();
      if (transfer.intent != null) {
        return _stopped(task, transfer.intent!, partPath, onUpdate);
      }
      return _fail(task, 'A transferência foi interrompida.', error, onUpdate);
    }
    await sink.close();

    if (transfer.intent != null) {
      return _stopped(task, transfer.intent!, partPath, onUpdate);
    }

    final total = task.totalBytes;
    if (total != null && received < total.bytes) {
      return _fail(
        task,
        'A conexão caiu antes do fim do arquivo.',
        null,
        onUpdate,
      );
    }

    task = _emit(task, DownloadState.completed, onUpdate);
    task = _emit(task, DownloadState.verifying, onUpdate);

    final integrity = await _verify(task, stream.checksumHex, partPath);
    if (integrity != null) {
      // Corrupt bytes are worthless and would break resuming; drop them so
      // a retry starts clean.
      await _fileSystem.delete(partPath);
      return _fail(task, integrity.message, null, onUpdate);
    }

    await _fileSystem.rename(partPath, task.destinationPath);
    return Result.ok(_emit(task, DownloadState.done, onUpdate));
  }

  /// Returns a failure when integrity checking fails, or null when the
  /// file passes (section 8.3: checksum when published, size otherwise).
  Future<IntegrityFailure?> _verify(
    DownloadTask task,
    String? publishedChecksum,
    String partPath,
  ) async {
    final expected = task.expectedChecksum ??
        (publishedChecksum == null
            ? null
            : Checksum.create(ChecksumAlgorithm.sha256, publishedChecksum)
                .valueOrNull);

    if (expected == null) {
      final size = await _fileSystem.sizeOf(partPath);
      if (size == 0) {
        return const IntegrityFailure('O arquivo baixado está vazio.');
      }
      final total = task.totalBytes;
      if (total != null && size != total.bytes) {
        return const IntegrityFailure(
          'O tamanho do arquivo não confere com o informado pela origem.',
        );
      }
      return null;
    }

    final digest = await sha256.bind(_fileSystem.readChunks(partPath)).first;
    final actual = Checksum.create(ChecksumAlgorithm.sha256, digest.toString())
        .valueOrNull!;
    return actual.matches(expected)
        ? null
        : const IntegrityFailure(
            'A verificação de integridade falhou: o arquivo está corrompido.',
          );
  }

  Future<Result<DownloadTask>> _stopped(
    DownloadTask task,
    _StopIntent intent,
    String partPath,
    DownloadTaskListener onUpdate,
  ) async {
    if (intent == _StopIntent.cancel) {
      await _fileSystem.delete(partPath);
      return Result.ok(_emit(task, DownloadState.canceled, onUpdate));
    }
    return Result.ok(_emit(task, DownloadState.paused, onUpdate));
  }

  Result<DownloadTask> _fail(
    DownloadTask task,
    String reason,
    Object? error,
    DownloadTaskListener onUpdate,
  ) {
    final failed = task.transitionTo(
      DownloadState.failed,
      failureReason: reason,
    );
    final value = failed.valueOrNull;
    if (value != null) onUpdate(value);
    return failed;
  }

  /// Applies a transition that the flow guarantees is legal, emitting it.
  DownloadTask _emit(
    DownloadTask task,
    DownloadState next,
    DownloadTaskListener onUpdate,
  ) {
    final moved = task.transitionTo(next).valueOrNull!;
    onUpdate(moved);
    return moved;
  }
}
