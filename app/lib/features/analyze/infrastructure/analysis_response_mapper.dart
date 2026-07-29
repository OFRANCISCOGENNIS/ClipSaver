/// Mapper from the backend's `POST /analysis` JSON to domain entities.
///
/// Responsibility: parse defensively — the wire is untrusted input.
/// Anything structurally invalid (including a response that violates the
/// eligibility invariants) becomes a [ServerFailure] instead of a crash
/// or, worse, a permissive verdict.
library;

import '../../../core/domain/value_objects/file_size.dart';
import '../../../core/domain/value_objects/license.dart';
import '../../../core/domain/value_objects/media_format.dart';
import '../../../core/domain/value_objects/media_url.dart';
import '../../../core/error/failures.dart';
import '../../../core/error/result.dart';
import '../domain/authorization_source.dart';
import '../domain/eligibility_result.dart';
import '../domain/media_item.dart';

/// Parses one analysis response object into a [MediaItem].
Result<MediaItem> mapAnalysisResponse(Map<String, dynamic> json) {
  try {
    final urlRaw = json['url'];
    final id = json['id'];
    final eligibilityRaw = json['eligibility'];
    if (urlRaw is! String ||
        id is! String ||
        eligibilityRaw is! Map<String, dynamic>) {
      return const Result.err(ServerFailure('Resposta de análise malformada.'));
    }
    final urlResult = MediaUrl.create(urlRaw);
    if (urlResult.isErr) {
      return const Result.err(ServerFailure('Resposta de análise malformada.'));
    }

    final eligible = eligibilityRaw['eligible'] == true;
    final source = AuthorizationSource.fromWire(
      eligibilityRaw['source'] as String? ?? 'none',
    );
    final reason = eligibilityRaw['reason'] as String? ?? '';
    final formats = mapWireFormats(eligibilityRaw['availableFormats']);
    final restrictions =
        ((eligibilityRaw['restrictions'] as List<dynamic>?) ?? const [])
            .whereType<String>()
            .toList(growable: false);
    final licenseRaw = eligibilityRaw['license'] as String?;

    // The entity constructor enforces the compliance invariants; an
    // inconsistent payload (eligible without formats, etc.) throws and is
    // converted to a ServerFailure below — fail closed, never permissive.
    final eligibility = EligibilityResult(
      eligible: eligible,
      source: eligible ? source : AuthorizationSource.none,
      license: licenseRaw == null ? null : License.fromMetadata(licenseRaw),
      reason: reason,
      availableFormats: formats,
      restrictions: restrictions,
    );

    final title = json['title'] as String?;
    return Result.ok(
      MediaItem(
        id: id,
        url: urlResult.valueOrNull!,
        title: (title == null || title.trim().isEmpty)
            ? urlResult.valueOrNull!.value
            : title,
        author: json['author'] as String?,
        thumbnailUrl: json['thumbnailUrl'] as String?,
        eligibility: eligibility,
      ),
    );
  } on Object {
    return const Result.err(ServerFailure('Resposta de análise malformada.'));
  }
}

/// Parses a wire-format list of renditions. Throws [FormatException] on
/// structurally invalid entries (callers convert to [ServerFailure]).
List<MediaFormat> mapWireFormats(Object? raw) {
  if (raw is! List) return const [];
  return raw.whereType<Map<String, dynamic>>().map((format) {
    final id = format['id'];
    final kind = format['kind'];
    final container = format['container'];
    if (id is! String || kind is! String || container is! String) {
      throw const FormatException('formato inválido');
    }
    return MediaFormat(
      id: id,
      kind: MediaKind.values.firstWhere((k) => k.name == kind),
      container: container,
      codec: format['codec'] as String?,
      height: (format['height'] as num?)?.toInt(),
      bitrateKbps: (format['bitrateKbps'] as num?)?.toInt(),
      estimatedSize: format['estimatedSizeBytes'] == null
          ? null
          : FileSize.ofBytes((format['estimatedSizeBytes'] as num).toInt()),
      url: format['url'] as String?,
    );
  }).toList(growable: false);
}
