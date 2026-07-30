/// Fakes for the Analyze feature's collaborators.
library;

import 'package:vidora/core/domain/value_objects/license.dart';
import 'package:vidora/core/domain/value_objects/media_format.dart';
import 'package:vidora/core/domain/value_objects/media_url.dart';
import 'package:vidora/core/error/failures.dart';
import 'package:vidora/core/error/result.dart';
import 'package:vidora/core/platform/clipboard_reader.dart';
import 'package:vidora/features/analyze/domain/analyze_repository.dart';
import 'package:vidora/features/analyze/domain/authorization_source.dart';
import 'package:vidora/features/analyze/domain/eligibility_result.dart';
import 'package:vidora/features/analyze/domain/media_item.dart';

/// A rendition used across the Analyze tests.
const MediaFormat kFormat720 = MediaFormat(
  id: 'v720',
  kind: MediaKind.video,
  container: 'mp4',
  height: 720,
);

/// Builds an analyzed item, eligible by default.
MediaItem mediaItemFixture({
  String id = 'm1',
  String url = 'https://cc.example.com/aula',
  String title = 'Aula aberta',
  bool eligible = true,
  List<MediaFormat> formats = const [kFormat720],
  List<String> restrictions = const ['atribuição obrigatória'],
}) =>
    MediaItem(
      id: id,
      url: MediaUrl.create(url).valueOrNull!,
      title: title,
      author: 'Prof. Silva',
      eligibility: EligibilityResult(
        eligible: eligible,
        source: eligible
            ? AuthorizationSource.openLicense
            : AuthorizationSource.none,
        // An open-license verdict always names the license it relies on.
        license: eligible ? License.ccBy : null,
        reason: eligible
            ? 'Conteúdo sob Licença CC-BY — o download é permitido.'
            : 'Este conteúdo é protegido por DRM e não pode ser baixado.',
        availableFormats: eligible ? formats : const [],
        restrictions: eligible ? restrictions : const [],
      ),
    );

/// Repository returning scripted results and recording calls.
final class FakeAnalyzeRepository implements AnalyzeRepository {
  /// Result returned by the next [analyze] call.
  Result<MediaItem> nextResult =
      const Result.err(NetworkFailure('não configurado'));

  /// Items returned by [recentAnalyses].
  List<MediaItem> recents = [];

  /// URLs passed to [analyze], in order.
  final List<String> analyzed = [];

  @override
  Future<Result<MediaItem>> analyze(MediaUrl url) async {
    analyzed.add(url.value);
    return nextResult;
  }

  @override
  Future<Result<List<MediaItem>>> recentAnalyses({int limit = 5}) async =>
      Result.ok(recents.take(limit).toList());
}

/// Clipboard returning a fixed value.
final class FakeClipboardReader implements ClipboardReader {
  /// Creates the fake with [text] as its content.
  FakeClipboardReader([this.text]);

  /// Current clipboard content.
  String? text;

  @override
  Future<String?> readText() async => text;
}
