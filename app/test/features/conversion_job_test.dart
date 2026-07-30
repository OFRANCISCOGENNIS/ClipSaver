import 'package:flutter_test/flutter_test.dart';
import 'package:vidora/core/error/failures.dart';
import 'package:vidora/features/converter/domain/conversion_job.dart';
import 'package:vidora/features/converter/domain/conversion_request.dart';

void main() {
  ConversionJob job({
    ConversionState state = ConversionState.queued,
    ConversionTarget target = ConversionTarget.mp3,
  }) =>
      ConversionJob(
        id: 'c1',
        libraryEntryId: 'l1',
        sourcePath: '/library/aula.mp4',
        request: ConversionRequest(target: target),
        state: state,
      );

  group('ConversionJob lifecycle', () {
    test('happy path: queued → converting → completed sets progress to 1', () {
      final done = job()
          .transitionTo(ConversionState.converting)
          .valueOrNull!
          .transitionTo(ConversionState.completed)
          .valueOrNull!;
      expect(done.state, ConversionState.completed);
      expect(done.progress, 1.0);
    });

    test('illegal transitions are refused', () {
      expect(
        job().transitionTo(ConversionState.completed).failureOrNull,
        isA<InvalidTransitionFailure>(),
      );
      expect(
        job(state: ConversionState.completed)
            .transitionTo(ConversionState.converting)
            .failureOrNull,
        isA<InvalidTransitionFailure>(),
      );
    });

    test('failure requires a reason; retry re-enqueues', () {
      final converting = job(state: ConversionState.converting);
      expect(
        converting.transitionTo(ConversionState.failed).failureOrNull,
        isA<InvalidTransitionFailure>(),
      );
      final failed = converting
          .transitionTo(ConversionState.failed, failureReason: 'Codec ausente.')
          .valueOrNull!;
      expect(failed.transitionTo(ConversionState.queued).isOk, isTrue);
    });

    test('progress only advances while converting and stays within 0..1', () {
      final converting = job(state: ConversionState.converting);
      expect(converting.withProgress(0.5).valueOrNull!.progress, 0.5);
      expect(converting.withProgress(1.5).isErr, isTrue);
      expect(job().withProgress(0.5).isErr, isTrue);
    });
  });

  group('ConversionJob output and defaults', () {
    test('output path swaps the extension for the target container', () {
      expect(
        job(target: ConversionTarget.flac).outputPath,
        '/library/aula.flac',
      );
      expect(
        job(target: ConversionTarget.webm).outputPath,
        '/library/aula.webm',
      );
    });

    test('output path handles extensionless sources', () {
      final noExt = ConversionJob(
        id: 'c2',
        libraryEntryId: 'l1',
        sourcePath: '/library/aula',
        request: const ConversionRequest(target: ConversionTarget.mp3),
      );
      expect(noExt.outputPath, '/library/aula.mp3');
    });

    test('original file is preserved by default (section 11)', () {
      expect(job().keepOriginal, isTrue);
    });

    test('audio targets are flagged for the extract-audio flow', () {
      expect(ConversionTarget.mp3.isAudioOnly, isTrue);
      expect(ConversionTarget.mp4.isAudioOnly, isFalse);
    });

    test('constructor validates progress bounds and blank ids', () {
      expect(
        () => ConversionJob(
          id: 'c3',
          libraryEntryId: 'l1',
          sourcePath: '/x.mp4',
          request: const ConversionRequest(target: ConversionTarget.mp3),
          progress: 2,
        ),
        throwsArgumentError,
      );
      expect(
        () => ConversionJob(
          id: '',
          libraryEntryId: 'l1',
          sourcePath: '/x.mp4',
          request: const ConversionRequest(target: ConversionTarget.mp3),
        ),
        throwsArgumentError,
      );
    });
  });
}
