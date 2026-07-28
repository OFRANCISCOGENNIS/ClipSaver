/// HTTP client port of the app.
///
/// Responsibility: give repositories a tiny, mockable surface for talking
/// to the Vidora backend, returning [Result] instead of throwing. The dio
/// implementation lives in `dio_api_client.dart`.
library;

import '../error/result.dart';

/// Minimal JSON-over-HTTP port used by infrastructure repositories.
abstract interface class ApiClient {
  /// POSTs [body] as JSON to [path], expecting a JSON object back.
  Future<Result<Map<String, dynamic>>> postJson(
    String path,
    Map<String, dynamic> body,
  );

  /// GETs [path], expecting a JSON object back.
  Future<Result<Map<String, dynamic>>> getJson(String path);
}
