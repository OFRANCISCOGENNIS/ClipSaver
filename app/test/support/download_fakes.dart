/// Deterministic fakes for the download engine's two ports.
library;

import 'dart:async';

import 'package:vidora/core/domain/value_objects/media_format.dart';
import 'package:vidora/core/storage/download_file_system.dart';
import 'package:vidora/features/downloads/domain/download_task.dart';
import 'package:vidora/features/downloads/infrastructure/download_transport.dart';

/// In-memory filesystem.
final class FakeFileSystem implements DownloadFileSystem {
  /// Current file contents by path.
  final Map<String, List<int>> files = {};

  /// Paths that were renamed, as (from, to) pairs, in order.
  final List<(String, String)> renames = [];

  @override
  Future<int> sizeOf(String path) async => files[path]?.length ?? 0;

  @override
  Future<bool> exists(String path) async => files.containsKey(path);

  @override
  Future<void> delete(String path) async => files.remove(path);

  @override
  Future<void> rename(String from, String to) async {
    renames.add((from, to));
    final bytes = files.remove(from);
    if (bytes != null) files[to] = bytes;
  }

  @override
  Future<ByteSink> openAppend(String path) async {
    files.putIfAbsent(path, () => <int>[]);
    return _FakeSink(files[path]!);
  }

  @override
  Stream<List<int>> readChunks(String path) async* {
    final bytes = files[path];
    if (bytes != null) yield List<int>.of(bytes);
  }
}

final class _FakeSink implements ByteSink {
  _FakeSink(this._target);

  final List<int> _target;
  bool closed = false;

  @override
  void add(List<int> chunk) => _target.addAll(chunk);

  @override
  Future<void> close() async => closed = true;
}

/// Transport returning scripted streams; records what was requested.
final class FakeTransport implements DownloadTransport {
  /// Builds a transport serving one scripted response per call.
  FakeTransport(this.responses);

  /// Factories for each successive `open` call. Throwing a factory
  /// simulates a connection error.
  final List<DownloadStream Function(int startByte)> responses;

  /// Byte offsets requested, in call order.
  final List<int> requestedOffsets = [];

  /// Handle handed to the last caller, for cancellation assertions.
  RecordingHandle? lastHandle;

  @override
  Future<DownloadStream> open(
    String url, {
    int startByte = 0,
    void Function(TransferHandle handle)? onHandle,
  }) async {
    requestedOffsets.add(startByte);
    final handle = RecordingHandle();
    lastHandle = handle;
    onHandle?.call(handle);
    final factory = responses.removeAt(0);
    return factory(startByte);
  }
}

/// Transfer handle that records cancellation and forwards it to a hook.
final class RecordingHandle implements TransferHandle {
  /// Invoked when the engine cancels the transfer.
  void Function()? onCancel;

  /// Whether the engine asked to abort.
  bool canceled = false;

  @override
  void cancel() {
    canceled = true;
    onCancel?.call();
  }
}

/// Builds a completed stream over [chunks].
DownloadStream streamOf(
  List<List<int>> chunks, {
  bool resumed = false,
  int? totalBytes,
  String? checksumHex,
}) =>
    DownloadStream(
      bytes: Stream<List<int>>.fromIterable(chunks),
      resumed: resumed,
      totalBytes: totalBytes,
      checksumHex: checksumHex,
    );

/// A task in the default queued state, pointing at [destination].
DownloadTask taskFixture({
  String id = 't1',
  String destination = '/downloads/file.mp4',
  String sourceUrl = 'https://files.example.com/file.mp4',
  String title = 'Arquivo',
  int? totalBytes,
}) =>
    DownloadTask(
      id: id,
      mediaItemId: 'm1',
      title: title,
      format: const MediaFormat(
        id: 'v720',
        kind: MediaKind.video,
        container: 'mp4',
        height: 720,
      ),
      sourceUrl: sourceUrl,
      destinationPath: destination,
      createdAt: DateTime.utc(2026, 7, 1),
    );
