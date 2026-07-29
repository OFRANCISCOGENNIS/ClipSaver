import 'package:flutter_test/flutter_test.dart';
import 'package:vidora/core/domain/value_objects/media_format.dart';
import 'package:vidora/core/domain/value_objects/media_url.dart';
import 'package:vidora/core/error/failures.dart';
import 'package:vidora/core/error/result.dart';
import 'package:vidora/features/analyze/domain/authorization_source.dart';
import 'package:vidora/features/analyze/domain/eligibility_result.dart';
import 'package:vidora/features/analyze/domain/media_item.dart';
import 'package:vidora/features/downloads/application/enqueue_download_use_case.dart';
import 'package:vidora/features/downloads/domain/download_task.dart';

void main() {
  const format = MediaFormat(
    id: 'v720',
    kind: MediaKind.video,
    container: 'mp4',
    height: 720,
  );
  const otherFormat = MediaFormat(
    id: 'v1080',
    kind: MediaKind.video,
    container: 'mp4',
    height: 1080,
  );

  MediaItem item({
    bool eligible = true,
    List<MediaFormat> formats = const [format],
    String title = 'Aula aberta',
  }) =>
      MediaItem(
        id: 'm1',
        url: MediaUrl.create('https://cc.example.com/aula').valueOrNull!,
        title: title,
        eligibility: EligibilityResult(
          eligible: eligible,
          source: eligible
              ? AuthorizationSource.openLicense
              : AuthorizationSource.none,
          reason: eligible
              ? 'Conteúdo sob Licença CC-BY.'
              : 'Este conteúdo é protegido por DRM e não pode ser baixado.',
          availableFormats: eligible ? formats : const [],
        ),
      );

  late List<DownloadTask> enqueued;

  EnqueueDownloadUseCase useCase({String directory = '/downloads'}) =>
      EnqueueDownloadUseCase(
        enqueue: (task) async {
          enqueued.add(task);
          return Result.ok(task);
        },
        downloadsDirectory: directory,
      );

  setUp(() => enqueued = []);

  test('enqueues an authorized item with the chosen rendition', () async {
    final result = await useCase()(item(), format);
    final task = result.valueOrNull!;

    expect(enqueued, hasLength(1));
    expect(task.mediaItemId, 'm1');
    expect(task.format, format);
    expect(task.destinationPath, '/downloads/Aula aberta.mp4');
    expect(task.sourceUrl, 'https://cc.example.com/aula');
  });

  test('refuses an unauthorized item and points at the legitimate path',
      () async {
    final result = await useCase()(item(eligible: false), format);
    final failure = result.failureOrNull;

    expect(failure, isA<IneligibleContentFailure>());
    expect(failure!.message, contains('DRM'));
    expect(
      (failure as IneligibleContentFailure).legitimatePath,
      contains('plataforma de origem'),
    );
    expect(enqueued, isEmpty);
  });

  test('refuses a rendition the engine never returned', () async {
    final result = await useCase()(item(), otherFormat);
    expect(result.failureOrNull, isA<ValidationFailure>());
    expect(enqueued, isEmpty);
  });

  test('uses the per-format URL when the origin published one', () async {
    const withUrl = MediaFormat(
      id: 'v720',
      kind: MediaKind.video,
      container: 'mp4',
      height: 720,
      url: 'https://cdn.example.com/aula-720.mp4',
    );
    final result = await useCase()(
      item(formats: const [withUrl]),
      withUrl,
    );
    expect(
        result.valueOrNull!.sourceUrl, 'https://cdn.example.com/aula-720.mp4');
  });

  test('derives a stable id so re-enqueueing does not duplicate', () async {
    final first = await useCase()(item(), format);
    final second = await useCase()(item(), format);
    expect(first.valueOrNull!.id, second.valueOrNull!.id);
  });

  group('buildFileName', () {
    test('strips characters that filesystems reject', () {
      expect(
        buildFileName('a/b\\c:d*e?f"g<h>i|j', format),
        'a b c d e f g h i j.mp4',
      );
    });

    test('collapses whitespace and trims', () {
      expect(buildFileName('  Aula   de   Flutter  ', format),
          'Aula de Flutter.mp4');
    });

    test('caps very long titles, leaving room for the part suffix', () {
      final name = buildFileName('x' * 400, format);
      expect(name.length, lessThanOrEqualTo(130));
    });

    test('falls back to the format id when nothing usable remains', () {
      expect(buildFileName('///', format), 'vidora-v720.mp4');
    });
  });
}
