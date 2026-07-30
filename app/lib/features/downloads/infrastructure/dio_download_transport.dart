/// dio implementation of [DownloadTransport].
///
/// Responsibility: issue the ranged GET, interpret the status/headers and
/// hand back a plain byte stream. It deliberately does *not* retry: retry
/// policy belongs to the queue scheduler, which owns the backoff budget.
library;

import 'package:dio/dio.dart';

import 'download_transport.dart';

/// Transfers bytes over HTTP using dio.
final class DioDownloadTransport implements DownloadTransport {
  /// Creates the transport; [dio] is injectable for tests.
  DioDownloadTransport({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  @override
  Future<DownloadStream> open(
    String url, {
    int startByte = 0,
    void Function(TransferHandle handle)? onHandle,
  }) async {
    final cancelToken = CancelToken();
    onHandle?.call(_DioTransferHandle(cancelToken));

    final response = await _dio.get<ResponseBody>(
      url,
      cancelToken: cancelToken,
      options: Options(
        responseType: ResponseType.stream,
        // 416 means the part file is already >= the resource size; the
        // engine treats it as "nothing left to fetch" instead of an error.
        validateStatus: (status) =>
            status != null &&
            (status == 416 || (status >= 200 && status < 300)),
        headers: {
          if (startByte > 0) 'range': 'bytes=$startByte-',
        },
      ),
    );

    final status = response.statusCode ?? 200;
    final headers = response.headers;
    final resumed = status == 206 || status == 416;

    return DownloadStream(
      bytes: status == 416
          ? const Stream<List<int>>.empty()
          : response.data!.stream,
      resumed: resumed,
      totalBytes: _totalBytes(headers, startByte: startByte, resumed: resumed),
      checksumHex: _checksum(headers),
    );
  }

  /// Full resource size: from Content-Range when partial, otherwise
  /// Content-Length (plus the offset already on disk when resuming).
  int? _totalBytes(Headers headers,
      {required int startByte, required bool resumed}) {
    final contentRange = headers.value('content-range');
    if (contentRange != null) {
      final total = RegExp(r'/\s*(\d+)\s*$').firstMatch(contentRange)?.group(1);
      if (total != null) return int.tryParse(total);
    }
    final length = int.tryParse(headers.value('content-length') ?? '');
    if (length == null) return null;
    return resumed ? length + startByte : length;
  }

  /// Reads a published SHA-256 digest from the common header spellings.
  String? _checksum(Headers headers) {
    final direct = headers.value('x-checksum-sha256') ??
        headers.value('x-amz-checksum-sha256');
    if (direct != null && direct.trim().isNotEmpty) return direct.trim();
    // RFC 9530: `Repr-Digest: sha-256=:<base64>:` — base64, not hex, so it
    // is not usable by the hex-based verifier and is intentionally ignored.
    return null;
  }
}

final class _DioTransferHandle implements TransferHandle {
  _DioTransferHandle(this._token);

  final CancelToken _token;

  @override
  void cancel() {
    if (!_token.isCancelled) _token.cancel('download cancelado');
  }
}
