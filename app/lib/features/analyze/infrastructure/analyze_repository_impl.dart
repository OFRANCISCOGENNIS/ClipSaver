/// Backend-facing implementation of [AnalyzeRepository].
///
/// Responsibility: call `POST /analysis`, map the response to the domain
/// and keep the local analysis history that powers the "Recentes"
/// shortcuts (section 7.1) and the History screen (section 9).
library;

import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/domain/value_objects/license.dart';
import '../../../core/domain/value_objects/media_url.dart';
import '../../../core/error/result.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/database.dart';
import '../domain/analyze_repository.dart';
import '../domain/authorization_source.dart';
import '../domain/eligibility_result.dart';
import '../domain/media_item.dart';
import 'analysis_response_mapper.dart';

/// Analyzes URLs via the Vidora API, recording local history.
final class AnalyzeRepositoryImpl implements AnalyzeRepository {
  /// Creates the repository over the HTTP [client] and local [db].
  AnalyzeRepositoryImpl({
    required ApiClient client,
    required AppDatabase db,
    DateTime Function() clock = DateTime.now,
  })  : _client = client,
        _db = db,
        _clock = clock;

  final ApiClient _client;
  final AppDatabase _db;
  final DateTime Function() _clock;

  @override
  Future<Result<MediaItem>> analyze(MediaUrl url) async {
    final response = await _client.postJson('/analysis', {'url': url.value});
    final mapped = response.flatMap(mapAnalysisResponse);
    // History records every completed analysis, eligible or not; network
    // failures are not analyses and stay out.
    final item = mapped.valueOrNull;
    if (item != null) {
      await _recordHistory(item);
    }
    return mapped;
  }

  @override
  Future<Result<List<MediaItem>>> recentAnalyses({int limit = 5}) async {
    try {
      final rows = await (_db.select(_db.analysisHistoryRows)
            ..orderBy([(t) => OrderingTerm.desc(t.analyzedAt)])
            ..limit(limit))
          .get();
      return Result.ok(rows.map(_historyToItem).toList(growable: false));
    } on Exception {
      return const Result.ok([]);
    }
  }

  Future<void> _recordHistory(MediaItem item) async {
    final e = item.eligibility;
    // Companion with explicit Value(null)s so re-analyses can clear
    // fields (author/thumbnail) that disappeared from the origin.
    await _db.into(_db.analysisHistoryRows).insertOnConflictUpdate(
          AnalysisHistoryRowsCompanion(
            id: Value(item.id),
            url: Value(item.url.value),
            title: Value(item.title),
            author: Value(item.author),
            thumbnailUrl: Value(item.thumbnailUrl),
            eligible: Value(e.eligible),
            source: Value(e.source.wireValue),
            licenseSpdxId: Value(e.license?.spdxId),
            reason: Value(e.reason),
            restrictionsJson: Value(jsonEncode(e.restrictions)),
            formatsJson: Value(
              jsonEncode([
                for (final f in e.availableFormats)
                  {
                    'id': f.id,
                    'kind': f.kind.name,
                    'container': f.container,
                    if (f.codec != null) 'codec': f.codec,
                    if (f.height != null) 'height': f.height,
                    if (f.bitrateKbps != null) 'bitrateKbps': f.bitrateKbps,
                    if (f.estimatedSize != null)
                      'estimatedSizeBytes': f.estimatedSize!.bytes,
                    if (f.url != null) 'url': f.url,
                  },
              ]),
            ),
            analyzedAt: Value(_clock()),
          ),
        );
  }

  MediaItem _historyToItem(AnalysisHistoryRow row) {
    final formats = mapWireFormats(jsonDecode(row.formatsJson));
    return MediaItem(
      id: row.id,
      url: MediaUrl.create(row.url).fold(
        (value) => value,
        (failure) => throw StateError('URL corrompida no histórico'),
      ),
      title: row.title,
      author: row.author,
      thumbnailUrl: row.thumbnailUrl,
      eligibility: EligibilityResult(
        eligible: row.eligible,
        source: AuthorizationSource.fromWire(row.source),
        license: row.licenseSpdxId == null
            ? null
            : License.fromMetadata(row.licenseSpdxId),
        reason: row.reason,
        availableFormats: formats,
        restrictions:
            (jsonDecode(row.restrictionsJson) as List<dynamic>).cast<String>(),
      ),
    );
  }
}
