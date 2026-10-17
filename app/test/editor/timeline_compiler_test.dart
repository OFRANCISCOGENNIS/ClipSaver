/// What the renderer actually tells FFmpeg to do.
///
/// Each case here is a defect that produces a *playable but wrong* file —
/// stretched faces, silent audio, the wrong clip's sound — which is the
/// class of bug an export never reports and a user discovers after
/// posting the video.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:vidora/features/editor/application/timeline_compiler.dart';
import 'package:vidora/features/editor/domain/edit_project.dart';

void main() {
  EditClip clip({
    String id = 'c1',
    String path = '/media/a.mp4',
    int startMs = 0,
    int endMs = 10000,
    double speed = 1,
    double volume = 1,
    List<TextOverlay> overlays = const [],
  }) =>
      EditClip(
        id: id,
        sourcePath: path,
        sourceStart: Duration(milliseconds: startMs),
        sourceEnd: Duration(milliseconds: endMs),
        speed: speed,
        volume: volume,
        overlays: overlays,
      );

  List<String> compile(
    List<EditClip> clips, {
    OutputAspect aspect = OutputAspect.original,
  }) =>
      TimelineCompiler.build(
        project: EditProject(
          id: 'p1',
          title: 'Projeto',
          clips: clips,
          aspect: aspect,
        ),
        outputPath: '/out/final.mp4',
      );

  /// The filter graph, which is where every interesting decision lands.
  String graphOf(List<String> args) =>
      args[args.indexOf('-filter_complex') + 1];

  group('estrutura', () {
    test('cada clipe vira uma entrada, mesmo vindo do mesmo arquivo', () {
      // Reaproveitar a entrada faria dois trechos lerem o mesmo decoder, e
      // o segundo sairia como cópia do primeiro.
      final args = compile([
        clip(id: 'a', path: '/media/x.mp4', startMs: 0, endMs: 2000),
        clip(id: 'b', path: '/media/x.mp4', startMs: 5000, endMs: 7000),
      ]);

      final entradas = <String>[];
      for (var i = 0; i < args.length - 1; i++) {
        if (args[i] == '-i') entradas.add(args[i + 1]);
      }
      expect(entradas, ['/media/x.mp4', '/media/x.mp4']);
    });

    test('concat junta vídeo e áudio de todos os clipes', () {
      final graph = graphOf(compile([clip(id: 'a'), clip(id: 'b')]));

      expect(graph, contains('[v0][a0][v1][a1]concat=n=2:v=1:a=1[outv][outa]'));
    });

    test('recusa renderizar uma linha do tempo vazia', () {
      expect(
        () => TimelineCompiler.build(
          project: EditProject(id: 'p1', title: 'Vazio'),
          outputPath: '/out/x.mp4',
        ),
        throwsArgumentError,
      );
    });

    test('reencoda de propósito: não há o que copiar depois do filtro', () {
      final args = compile([clip()]);

      expect(args, containsAllInOrder(['-c:v', 'libx264']));
      expect(args, containsAllInOrder(['-c:a', 'aac']));
      expect(args, containsAllInOrder(['-pix_fmt', 'yuv420p']));
    });
  });

  group('corte', () {
    test('apara pelos pontos de entrada e saída e zera o relógio', () {
      final graph = graphOf(compile([clip(startMs: 2500, endMs: 7000)]));

      expect(graph, contains('trim=start=2.500:end=7.000'));
      // Sem isto o concat deixaria um congelamento do tamanho do ponto de
      // entrada no lugar do corte.
      expect(graph, contains('setpts=PTS-STARTPTS'));
      expect(graph, contains('asetpts=PTS-STARTPTS'));
    });
  });

  group('velocidade', () {
    test('vídeo acelera dividindo o timestamp', () {
      expect(graphOf(compile([clip(speed: 2)])), contains('setpts=PTS/2'));
    });

    test('1x não emite filtro de velocidade nenhum', () {
      final graph = graphOf(compile([clip()]));

      expect(graph, isNot(contains('atempo')));
      expect(graph, isNot(contains('PTS/')));
    });

    test('atempo é encadeado acima de 2x, que é o limite do filtro', () {
      // Passar atempo=4 direto deixa o vídeo rápido e o áudio errado, sem
      // nenhum aviso do FFmpeg.
      expect(TimelineCompiler.atempoChain(4), [2.0, 2.0]);
      expect(TimelineCompiler.atempoChain(3), [2.0, 1.5]);
      expect(graphOf(compile([clip(speed: 4)])), contains('atempo=2,atempo=2'));
    });

    test('atempo é encadeado abaixo de 0,5x pelo mesmo motivo', () {
      expect(TimelineCompiler.atempoChain(0.25), [0.5, 0.5]);
      expect(graphOf(compile([clip(speed: 0.25)])),
          contains('atempo=0.5,atempo=0.5'));
    });

    test('os fatores encadeados multiplicam de volta na velocidade pedida', () {
      for (final speed in [0.25, 0.4, 0.5, 1.5, 2.0, 3.0, 4.0]) {
        final produto = TimelineCompiler.atempoChain(speed)
            .fold<double>(1, (total, factor) => total * factor);
        expect(produto, closeTo(speed, 0.0001), reason: 'velocidade $speed');
        for (final factor in TimelineCompiler.atempoChain(speed)) {
          expect(factor, inInclusiveRange(0.5, 2.0));
        }
      }
    });
  });

  group('áudio', () {
    test('um clipe mudo mantém a faixa silenciada, não a remove', () {
      // Remover deixaria o concat com menos faixas de áudio que de vídeo,
      // e cada clipe seguinte tocaria o som do anterior.
      final graph = graphOf(compile([clip(volume: 0)]));

      expect(graph, contains('volume=0'));
      expect(graph, contains('[a0]'));
    });

    test('normaliza o formato para o concat aceitar fontes diferentes', () {
      expect(graphOf(compile([clip()])), contains('channel_layouts=stereo'));
    });
  });

  group('proporção', () {
    test('original não mexe na imagem', () {
      final graph = graphOf(compile([clip()]));

      expect(graph, isNot(contains('scale=')));
      expect(graph, isNot(contains('pad=')));
    });

    test('vertical encaixa e preenche, em vez de esticar', () {
      final graph = graphOf(compile([clip()], aspect: OutputAspect.vertical));

      expect(graph,
          contains('scale=1080:1920:force_original_aspect_ratio=decrease'));
      expect(graph, contains('pad=1080:1920:(ow-iw)/2:(oh-ih)/2'));
      expect(graph, contains('setsar=1'));
    });

    test('quadrado e largo usam suas resoluções', () {
      expect(graphOf(compile([clip()], aspect: OutputAspect.square)),
          contains('scale=1080:1080'));
      expect(graphOf(compile([clip()], aspect: OutputAspect.wide)),
          contains('scale=1920:1080'));
    });
  });

  group('texto', () {
    TextOverlay texto(String conteudo) => TextOverlay(
          text: conteudo,
          start: const Duration(seconds: 1),
          end: const Duration(seconds: 3),
        );

    test('desenha com janela de exibição', () {
      final graph = graphOf(compile([
        clip(overlays: [texto('Olá')])
      ]));

      expect(graph, contains("text='Olá'"));
      expect(graph, contains("enable='between(t,1,3)'"));
    });

    test('a janela acompanha a velocidade do clipe', () {
      final graph = graphOf(compile([
        clip(speed: 2, overlays: [texto('Olá')])
      ]));

      // 1s na régua são 2s de arquivo num clipe a 2x.
      expect(graph, contains("enable='between(t,2,6)'"));
    });

    test('escapa aspas e dois-pontos, que encerrariam o argumento', () {
      expect(TimelineCompiler.escapeDrawText("d'água"), r"d\'água");
      expect(TimelineCompiler.escapeDrawText('10:30'), r'10\:30');
      expect(TimelineCompiler.escapeDrawText('100%'), r'100\%');
    });

    test('escapa a barra invertida antes de tudo', () {
      // Escapar depois escaparia as próprias escapas.
      expect(TimelineCompiler.escapeDrawText(r'a\b'), r'a\\b');
      expect(TimelineCompiler.escapeDrawText(r"\'"), r"\\\'");
    });

    test('um texto hostil não vira opção de filtro', () {
      final graph = graphOf(compile([
        clip(overlays: [texto("x':fontcolor=red:enable='1")]),
      ]));

      // Tudo entre aspas continua sendo texto: nenhuma opção nova nasceu.
      expect(graph, isNot(contains(':fontcolor=red:')));
      expect(graph, contains(r"\'"));
    });

    test('quebra de linha vira espaço em vez de quebrar o filtro', () {
      expect(TimelineCompiler.escapeDrawText('a\nb'), 'a b');
    });
  });
}
