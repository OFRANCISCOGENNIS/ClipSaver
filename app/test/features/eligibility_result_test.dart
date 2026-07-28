import 'package:test/test.dart';
import 'package:vidora/core/domain/value_objects/media_format.dart';
import 'package:vidora/features/analyze/domain/authorization_source.dart';
import 'package:vidora/features/analyze/domain/eligibility_result.dart';

void main() {
  const format = MediaFormat(
    id: 'f1',
    kind: MediaKind.video,
    container: 'mp4',
    codec: 'h264',
    height: 1080,
  );

  group('EligibilityResult invariants', () {
    test('valid eligible result holds source, reason and formats', () {
      final result = EligibilityResult(
        eligible: true,
        source: AuthorizationSource.openLicense,
        reason: 'Conteúdo sob licença CC-BY-4.0.',
        availableFormats: const [format],
        restrictions: const ['atribuição obrigatória'],
      );
      expect(result.availableFormats, hasLength(1));
      expect(result.source.badgeLabel, 'Licença aberta');
    });

    test('eligible without a named source is rejected', () {
      expect(
        () => EligibilityResult(
          eligible: true,
          source: AuthorizationSource.none,
          reason: 'x',
          availableFormats: const [format],
        ),
        throwsArgumentError,
      );
    });

    test('ineligible claiming a source is rejected', () {
      expect(
        () => EligibilityResult(
          eligible: false,
          source: AuthorizationSource.directFile,
          reason: 'x',
        ),
        throwsArgumentError,
      );
    });

    test('ineligible offering formats is rejected', () {
      expect(
        () => EligibilityResult(
          eligible: false,
          source: AuthorizationSource.none,
          reason: 'x',
          availableFormats: const [format],
        ),
        throwsArgumentError,
      );
    });

    test('eligible with zero formats is rejected', () {
      expect(
        () => EligibilityResult(
          eligible: true,
          source: AuthorizationSource.directFile,
          reason: 'x',
        ),
        throwsArgumentError,
      );
    });

    test('empty reason is rejected — the reason is user-facing', () {
      expect(
        () => EligibilityResult(
          eligible: true,
          source: AuthorizationSource.directFile,
          reason: '  ',
          availableFormats: const [format],
        ),
        throwsArgumentError,
      );
    });

    test('format list is immutable to callers', () {
      final result = EligibilityResult(
        eligible: true,
        source: AuthorizationSource.directFile,
        reason: 'Arquivo de mídia servido publicamente.',
        availableFormats: const [format],
      );
      expect(() => result.availableFormats.clear(), throwsUnsupportedError);
    });
  });

  group('AuthorizationSource wire mapping', () {
    test('round-trips every wire value', () {
      for (final source in AuthorizationSource.values) {
        expect(AuthorizationSource.fromWire(source.wireValue), source);
      }
    });

    test('unknown wire values fail closed to none', () {
      expect(AuthorizationSource.fromWire('hacked'), AuthorizationSource.none);
    });
  });
}
