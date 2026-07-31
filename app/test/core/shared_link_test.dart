/// Extracting and routing a link that arrived from another app's share.
///
/// Share sheets hand over text, not URLs: a title, the link, a couple of
/// hashtags and a "shared via" footer. Every case here came from what a
/// real share actually looks like — and each one, mishandled, ends with
/// the app rejecting a link the user legitimately owns.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:vidora/app/router.dart';
import 'package:vidora/app/shared_link_routing.dart';
import 'package:vidora/core/platform/shared_link_port.dart';

void main() {
  group('extractSharedUrl', () {
    test('um link puro passa intacto', () {
      expect(
        extractSharedUrl('https://arquivo.org/aula.mp4'),
        'https://arquivo.org/aula.mp4',
      );
    });

    test('acha o link no meio do texto que o app de origem anexou', () {
      expect(
        extractSharedUrl(
          'Aula aberta de tipografia\nhttps://arquivo.org/aula.mp4\n'
          'Compartilhado via ExemploApp',
        ),
        'https://arquivo.org/aula.mp4',
      );
    });

    test('preserva a query inteira, que é onde mora o identificador', () {
      expect(
        extractSharedUrl('veja https://exemplo.org/w?v=abc123&t=42s'),
        'https://exemplo.org/w?v=abc123&t=42s',
      );
    });

    test('a pontuação da frase não vira parte do link', () {
      // "veja https://exemplo.org/aula." é um link e um ponto final.
      expect(
        extractSharedUrl('veja https://exemplo.org/aula.'),
        'https://exemplo.org/aula',
      );
      expect(
        extractSharedUrl('(https://exemplo.org/aula)'),
        'https://exemplo.org/aula',
      );
    });

    test('texto sem link nenhum devolve nulo em vez de lixo', () {
      expect(extractSharedUrl('olha isso aqui'), isNull);
      expect(extractSharedUrl(''), isNull);
      expect(extractSharedUrl(null), isNull);
    });

    test('um esquema que não é http não é promovido a link', () {
      // Recusar aqui é barato; deixar passar empurra um `file://` para
      // dentro do fluxo de análise.
      expect(extractSharedUrl('file:///etc/passwd'), isNull);
      expect(extractSharedUrl('javascript:alert(1)'), isNull);
    });
  });

  group('analyzeLocationFor', () {
    test('a rota abre Analyze com o link no parâmetro esperado', () {
      final location = analyzeLocationFor('https://arquivo.org/aula.mp4');

      expect(location, startsWith(Routes.analyze));
      expect(
        Uri.parse(location).queryParameters[kSharedUrlParam],
        'https://arquivo.org/aula.mp4',
      );
    });

    test('um link com & sobrevive ao encoding', () {
      // Sem percent-encoding, "&t=42s" viraria um segundo parâmetro da
      // nossa rota e o app analisaria um link truncado.
      final location = analyzeLocationFor('https://exemplo.org/w?v=abc&t=42s');

      expect(
        Uri.parse(location).queryParameters[kSharedUrlParam],
        'https://exemplo.org/w?v=abc&t=42s',
      );
    });
  });

  group('NoopSharedLinkPort', () {
    test('não inventa link nenhum nas plataformas sem compartilhamento',
        () async {
      const port = NoopSharedLinkPort();

      expect(await port.initialLink(), isNull);
      expect(await port.links().toList(), isEmpty);
    });
  });
}
