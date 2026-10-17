/// Timeline operations, and the edits they refuse.
///
/// The refusals carry most of the weight here: an editor that accepts a
/// zero-length clip or a cut outside the clip does not fail loudly, it
/// exports something wrong.
library;

import 'package:flutter_test/flutter_test.dart';
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

  EditProject project({List<EditClip> clips = const []}) =>
      EditProject(id: 'p1', title: 'Projeto', clips: clips);

  group('EditClip', () {
    test('recusa um clipe de duração zero ou negativa', () {
      expect(() => clip(startMs: 5000, endMs: 5000), throwsArgumentError);
      expect(() => clip(startMs: 5000, endMs: 1000), throwsArgumentError);
    });

    test('recusa velocidade fora dos limites utilizáveis', () {
      expect(() => clip(speed: 0.1), throwsArgumentError);
      expect(() => clip(speed: 8), throwsArgumentError);
      expect(clip(speed: kMinSpeed).speed, kMinSpeed);
      expect(clip(speed: kMaxSpeed).speed, kMaxSpeed);
    });

    test('a velocidade encurta a duração na linha do tempo', () {
      // O usuário vê a duração renderizada, não a do arquivo: dobrar a
      // velocidade corta o projeto pela metade.
      expect(clip(endMs: 10000).renderedDuration, const Duration(seconds: 10));
      expect(clip(endMs: 10000, speed: 2).renderedDuration,
          const Duration(seconds: 5));
      expect(clip(endMs: 10000, speed: 0.5).renderedDuration,
          const Duration(seconds: 20));
    });

    test('volume zero é mudo, e continua sendo um clipe válido', () {
      expect(clip(volume: 0).isMuted, isTrue);
      expect(() => clip(volume: -1), throwsArgumentError);
    });
  });

  group('append e remove', () {
    test('acrescenta na ordem e soma a duração', () {
      final p = project()
          .append(clip(id: 'a', endMs: 4000))
          .valueOrNull!
          .append(clip(id: 'b', endMs: 6000))
          .valueOrNull!;

      expect(p.clips.map((c) => c.id), ['a', 'b']);
      expect(p.duration, const Duration(seconds: 10));
    });

    test('recusa dois clipes com o mesmo id', () {
      final p = project(clips: [clip(id: 'a')]);

      expect(p.append(clip(id: 'a')).isOk, isFalse);
    });

    test('remover um clipe que não existe falha em vez de não fazer nada', () {
      expect(project(clips: [clip(id: 'a')]).remove('z').isOk, isFalse);
    });
  });

  group('reorder', () {
    test('move um clipe para outra posição', () {
      final p = project(clips: [clip(id: 'a'), clip(id: 'b'), clip(id: 'c')]);

      final movido = p.reorder(2, 0).valueOrNull!;

      expect(movido.clips.map((c) => c.id), ['c', 'a', 'b']);
    });

    test('recusa posição fora da linha do tempo', () {
      final p = project(clips: [clip(id: 'a')]);

      expect(p.reorder(0, 5).isOk, isFalse);
      expect(p.reorder(-1, 0).isOk, isFalse);
    });
  });

  group('update', () {
    test('uma edição inválida vira Result, não exceção', () {
      // O construtor do clipe é a única fonte de verdade sobre o que é um
      // clipe válido; o erro dele não pode atravessar até a ViewModel.
      final p = project(clips: [clip(id: 'a')]);

      final resultado = p.update('a', (c) => c.copyWith(speed: 99));

      expect(resultado.isOk, isFalse);
      expect(p.clips.single.speed, 1, reason: 'o original não muda');
    });

    test('aplica a mudança e deixa os outros clipes intactos', () {
      final p = project(clips: [clip(id: 'a'), clip(id: 'b')]);

      final mudado = p.update('b', (c) => c.copyWith(volume: 0)).valueOrNull!;

      expect(mudado.clips[0].volume, 1);
      expect(mudado.clips[1].isMuted, isTrue);
    });
  });

  group('splitAt', () {
    test('divide em dois clipes contíguos', () {
      final p = project(clips: [clip(id: 'a', endMs: 10000)]);

      final dividido = p.splitAt('a', const Duration(seconds: 4)).valueOrNull!;

      expect(dividido.clips, hasLength(2));
      expect(dividido.clips[0].sourceEnd, const Duration(seconds: 4));
      expect(dividido.clips[1].sourceStart, const Duration(seconds: 4));
      // Nada de material perdido nem duplicado na emenda.
      expect(dividido.duration, p.duration);
    });

    test('o corte respeita a velocidade do clipe', () {
      // Num clipe a 2x, 2s na régua são 4s de arquivo. Esquecer essa
      // conversão corta no lugar errado sem erro nenhum.
      final p = project(clips: [clip(id: 'a', endMs: 10000, speed: 2)]);

      final dividido = p.splitAt('a', const Duration(seconds: 2)).valueOrNull!;

      expect(dividido.clips[0].sourceEnd, const Duration(seconds: 4));
    });

    test('recusa um corte nas pontas, que não dividiria nada', () {
      final p = project(clips: [clip(id: 'a', endMs: 10000)]);

      expect(p.splitAt('a', Duration.zero).isOk, isFalse);
      expect(p.splitAt('a', const Duration(seconds: 10)).isOk, isFalse);
      expect(p.splitAt('a', const Duration(seconds: 30)).isOk, isFalse);
    });

    test('cada texto segue a metade em que começou, com o tempo rebaseado', () {
      final p = project(clips: [
        clip(id: 'a', endMs: 10000, overlays: [
          TextOverlay(
            text: 'começo',
            start: Duration.zero,
            end: const Duration(seconds: 2),
          ),
          TextOverlay(
            text: 'fim',
            start: const Duration(seconds: 6),
            end: const Duration(seconds: 8),
          ),
        ]),
      ]);

      final dividido = p.splitAt('a', const Duration(seconds: 5)).valueOrNull!;

      expect(dividido.clips[0].overlays.single.text, 'começo');
      expect(dividido.clips[1].overlays.single.text, 'fim');
      // Rebaseado: 6s do clipe original são 1s do clipe da direita.
      expect(
          dividido.clips[1].overlays.single.start, const Duration(seconds: 1));
    });

    test('um texto que cruza o corte é aparado, não duplicado', () {
      final p = project(clips: [
        clip(id: 'a', endMs: 10000, overlays: [
          TextOverlay(
            text: 'atravessa',
            start: const Duration(seconds: 3),
            end: const Duration(seconds: 8),
          ),
        ]),
      ]);

      final dividido = p.splitAt('a', const Duration(seconds: 5)).valueOrNull!;

      expect(dividido.clips[0].overlays.single.end, const Duration(seconds: 5));
      expect(dividido.clips[1].overlays, isEmpty);
    });
  });

  group('TextOverlay', () {
    test('recusa texto vazio e janela invertida', () {
      expect(
        () => TextOverlay(
          text: '',
          start: Duration.zero,
          end: const Duration(seconds: 1),
        ),
        throwsArgumentError,
      );
      expect(
        () => TextOverlay(
          text: 'oi',
          start: const Duration(seconds: 2),
          end: const Duration(seconds: 1),
        ),
        throwsArgumentError,
      );
    });
  });

  group('OutputAspect', () {
    test('original não impõe tamanho; os demais têm resolução definida', () {
      expect(OutputAspect.original.size, isNull);
      expect(OutputAspect.vertical.size, const OutputSize(1080, 1920));
      expect(OutputAspect.square.size, const OutputSize(1080, 1080));
      expect(OutputAspect.wide.size, const OutputSize(1920, 1080));
    });
  });
}
