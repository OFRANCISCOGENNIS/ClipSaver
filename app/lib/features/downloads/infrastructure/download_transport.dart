/// HTTP transport port for byte transfers.
///
/// Responsibility: expose exactly what the download engine needs from the
/// network — a byte stream, the total size and whether the server honored
/// a Range request — without binding the engine to dio, so transfers can
/// be tested deterministically.
library;

/// One open transfer.
final class DownloadStream {
  /// Creates a transfer descriptor.
  const DownloadStream({
    required this.bytes,
    required this.resumed,
    this.totalBytes,
    this.checksumHex,
  });

  /// Chunks of the response body, in order.
  final Stream<List<int>> bytes;

  /// True when the server answered 206 and the stream continues from the
  /// requested offset. False means the stream restarts at byte 0 — the
  /// engine must discard whatever it had.
  final bool resumed;

  /// Full resource size when the origin reports it (Content-Length or
  /// Content-Range). Null for chunked responses of unknown length.
  final int? totalBytes;

  /// Server-published SHA-256 digest, when available (section 8.3).
  final String? checksumHex;
}

/// Cancels an in-flight transfer.
abstract interface class TransferHandle {
  /// Aborts the transfer; the byte stream ends with an error or closes.
  void cancel();
}

/// Port implemented by the dio transport.
abstract interface class DownloadTransport {
  /// Opens [url], requesting bytes from [startByte] when non-zero.
  ///
  /// [handle] receives a cancellation token for the caller to abort.
  Future<DownloadStream> open(
    String url, {
    int startByte = 0,
    void Function(TransferHandle handle)? onHandle,
  });
}
