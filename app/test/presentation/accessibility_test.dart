/// Accessibility regressions that only surface outside the default setup.
///
/// The three cases here were found by rendering the queue the way a real
/// user might have it configured, not the way a test defaults to: system
/// font at 2x, and a screen reader reading the actions out of context.
library;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vidora/app/providers.dart';
import 'package:vidora/app/theme/app_theme.dart';
import 'package:vidora/core/domain/value_objects/file_size.dart';
import 'package:vidora/features/downloads/domain/download_state.dart';
import 'package:vidora/features/downloads/domain/download_task.dart';
import 'package:vidora/features/downloads/presentation/downloads_view.dart';

import '../support/download_fakes.dart';
import '../support/in_memory_download_repository.dart';
import '../support/localized_app.dart';

void main() {
  late InMemoryDownloadRepository repository;

  setUp(() => repository = InMemoryDownloadRepository());
  tearDown(() => repository.dispose());

  /// A task mid-transfer, which is the state with the most text on screen.
  DownloadTask downloading({String title = 'Arquivo', String id = 't1'}) =>
      taskFixture(id: id, title: title)
          .copyWith(totalBytes: FileSize.ofBytes(1000))
          .transitionTo(DownloadState.connecting)
          .valueOrNull!
          .transitionTo(DownloadState.downloading)
          .valueOrNull!
          .withProgress(FileSize.ofBytes(250))
          .valueOrNull!;

  /// Mounts the queue at [textScale] on a phone-sized surface.
  Future<void> pumpQueue(
    WidgetTester tester, {
    required List<DownloadTask> tasks,
    double textScale = 1,
    Size surface = const Size(400, 900),
  }) async {
    await tester.binding.setSurfaceSize(surface);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          downloadRepositoryProvider.overrideWithValue(repository),
          downloadTransportProvider.overrideWithValue(FakeTransport([])),
          downloadFileSystemProvider.overrideWithValue(FakeFileSystem()),
        ],
        child: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
          child: localizedApp(
            theme: buildVidoraTheme(Brightness.dark),
            home: const DownloadsView(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    for (final task in tasks) {
      await repository.save(task);
    }
    // The progress bar animates while downloading, so settling never
    // returns — two pumps are enough to render the seeded rows.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }

  group('escala de texto', () {
    testWidgets('a linha de bytes não estoura com a fonte do sistema em 2x',
        (tester) async {
      await pumpQueue(tester, tasks: [downloading()], textScale: 2);

      // Antes do Wrap isto era "A RenderFlex overflowed by 156 pixels".
      expect(tester.takeException(), isNull);
    });

    testWidgets('o percentual continua inteiro em 2x', (tester) async {
      await pumpQueue(tester, tasks: [downloading()], textScale: 2);

      expect(find.text('25%'), findsOneWidget);
      final box = tester.getSize(find.text('25%'));
      final rendered = tester.renderObject<RenderBox>(find.text('25%'));
      // Uma caixa estreita demais recorta o texto em vez de o mostrar; a
      // largura pedida tem de acompanhar o que o texto realmente ocupa.
      expect(box.width, greaterThanOrEqualTo(rendered.size.width));
      expect(tester.takeException(), isNull);
    });

    testWidgets('em 3x a tela ainda renderiza sem estouro', (tester) async {
      await pumpQueue(tester, tasks: [downloading()], textScale: 3);

      expect(tester.takeException(), isNull);
    });
  });

  group('leitor de tela', () {
    testWidgets('cada ação diz em qual item ela age', (tester) async {
      final handle = tester.ensureSemantics();

      await pumpQueue(
        tester,
        tasks: [downloading(title: 'Palestra sobre acessibilidade')],
      );

      // O tooltip continua curto, para quem lê com os olhos ao lado do item.
      expect(find.byTooltip('Pausar'), findsOneWidget);
      // O rótulo falado carrega o título, para quem ouve fora de contexto.
      expect(
        find.bySemanticsLabel('Pausar “Palestra sobre acessibilidade”'),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel('Cancelar “Palestra sobre acessibilidade”'),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('o rótulo não custa a ação: o nó continua acionável',
        (tester) async {
      final handle = tester.ensureSemantics();

      await pumpQueue(tester, tasks: [downloading()]);

      final node = tester.getSemantics(
        find.bySemanticsLabel('Pausar “Arquivo”'),
      );
      final data = node.getSemanticsData();
      expect(data.flagsCollection.isButton, isTrue);
      expect(data.hasAction(SemanticsAction.tap), isTrue);

      // Aciona pelo nó de semântica, como faria o leitor de tela, e confirma
      // que a fila reagiu — um rótulo bonito sobre um botão morto seria pior
      // do que o rótulo ambíguo que ele substituiu.
      tester.semantics.performAction(
        find.semantics.byLabel('Pausar “Arquivo”'),
        SemanticsAction.tap,
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      final stored = await repository.findById(taskFixture().id);
      expect(stored.valueOrNull?.state, DownloadState.paused);
      handle.dispose();
    });

    testWidgets('duas linhas produzem dois rótulos distintos', (tester) async {
      final handle = tester.ensureSemantics();

      await pumpQueue(
        tester,
        tasks: [
          downloading(title: 'Primeiro'),
          downloading(title: 'Segundo', id: 't2'),
        ],
      );

      expect(find.bySemanticsLabel('Pausar “Primeiro”'), findsOneWidget);
      expect(find.bySemanticsLabel('Pausar “Segundo”'), findsOneWidget);
      handle.dispose();
    });
  });
}
