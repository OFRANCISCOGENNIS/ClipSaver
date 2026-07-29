/// dart:io implementation of [DownloadFileSystem] for mobile and desktop.
library;

import 'dart:io';

import 'package:path/path.dart' as p;

import 'download_file_system.dart';

/// Filesystem backed by `dart:io`.
final class IoDownloadFileSystem implements DownloadFileSystem {
  /// Creates the filesystem adapter.
  const IoDownloadFileSystem();

  @override
  Future<int> sizeOf(String path) async {
    final file = File(path);
    return await file.exists() ? file.length() : 0;
  }

  @override
  Future<bool> exists(String path) => File(path).exists();

  @override
  Future<void> delete(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  @override
  Future<void> rename(String from, String to) async {
    await Directory(p.dirname(to)).create(recursive: true);
    await File(from).rename(to);
  }

  @override
  Future<ByteSink> openAppend(String path) async {
    await Directory(p.dirname(path)).create(recursive: true);
    return _IoByteSink(File(path).openWrite(mode: FileMode.writeOnlyAppend));
  }

  @override
  Stream<List<int>> readChunks(String path) => File(path).openRead();
}

final class _IoByteSink implements ByteSink {
  _IoByteSink(this._sink);

  final IOSink _sink;

  @override
  void add(List<int> chunk) => _sink.add(chunk);

  @override
  Future<void> close() async {
    await _sink.flush();
    await _sink.close();
  }
}
