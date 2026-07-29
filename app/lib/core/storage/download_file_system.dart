/// Filesystem port used by the download engine.
///
/// Responsibility: abstract the platform filesystem (dart:io on
/// mobile/desktop, File System Access API on Web) so the transfer logic —
/// partial files, appends, atomic moves — is testable in memory and
/// portable across the six target platforms (section 3).
library;

/// A byte sink appending to an open file.
abstract interface class ByteSink {
  /// Appends [chunk] to the file.
  void add(List<int> chunk);

  /// Flushes and closes the underlying handle.
  Future<void> close();
}

/// Filesystem operations the download engine needs.
abstract interface class DownloadFileSystem {
  /// Size of [path] in bytes; 0 when the file does not exist.
  Future<int> sizeOf(String path);

  /// Whether [path] exists.
  Future<bool> exists(String path);

  /// Deletes [path]; a missing file is not an error.
  Future<void> delete(String path);

  /// Renames [from] to [to], replacing an existing [to].
  ///
  /// Must be atomic within the same volume — this is what makes a
  /// finished download appear whole or not at all (section 8.3).
  Future<void> rename(String from, String to);

  /// Opens [path] for appending, creating parent directories as needed.
  Future<ByteSink> openAppend(String path);

  /// Reads [path] in chunks, for checksum verification without loading
  /// the whole file into memory.
  Stream<List<int>> readChunks(String path);
}
