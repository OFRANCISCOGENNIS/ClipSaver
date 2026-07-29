import 'package:flutter/material.dart';
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

void main() {
  late InMemoryDownloadRepository repository;

  setUp(() => repository = InMemoryDownloadRepository());
  tearDown(() => repository.dispose());

  /// Mounts the screen, then seeds [tasks].
  ///
  /// Order matters: on mount the screen calls `restoreQueue()`, which
  /// (correctly) demotes any persisted `downloading` row to `paused` —
  /// such a row can only be leftover from a killed process. Seeding after
  /// mount reproduces what really happens when a transfer starts.
  ///
  /// Pass `settle: false` when the screen shows an indeterminate progress
  /// bar — it animates forever, so `pumpAndSettle` would never return.
  Future<void> pumpScreen(
    WidgetTester tester, {
    List<DownloadTask> tasks = const [],
    bool settle = true,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          downloadRepositoryProvider.overrideWithValue(repository),
          downloadTransportProvider.overrideWithValue(FakeTransport([])),
          downloadFileSystemProvider.overrideWithValue(FakeFileSystem()),
        ],
        child: MaterialApp(
          theme: buildVidoraTheme(Brightness.dark),
          home: const DownloadsView(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    for (final task in tasks) {
      await repository.save(task);
    }
    if (settle) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump();
      await tester.pump();
    }
  }

  DownloadTask downloading({int downloaded = 250, int? total = 1000}) {
    final base = taskFixture()
        .transitionTo(DownloadState.connecting)
        .valueOrNull!
        .transitionTo(DownloadState.downloading)
        .valueOrNull!
        .copyWith(totalBytes: total == null ? null : FileSize.ofBytes(total));
    return base.withProgress(FileSize.ofBytes(downloaded)).valueOrNull!;
  }

  testWidgets('shows the empty state when nothing is queued', (tester) async {
    await pumpScreen(tester);
    expect(find.text('Nenhum download na fila'), findsOneWidget);
  });

  testWidgets('renders progress, state and byte counters', (tester) async {
    await pumpScreen(tester, tasks: [downloading()]);

    expect(find.text('Arquivo'), findsOneWidget);
    expect(find.text('Baixando'), findsOneWidget);
    expect(find.text('25%'), findsOneWidget);
    expect(find.text('250 B / 1000 B'), findsOneWidget);
  });

  testWidgets(
      'an unknown total size shows an indeterminate bar, not a fake '
      'percentage', (tester) async {
    await pumpScreen(
      tester,
      tasks: [downloading(total: null)],
      settle: false,
    );

    final indicator = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    );
    expect(indicator.value, isNull);
    // No percentage at all — inventing "0%" would misreport real progress.
    expect(find.textContaining('%'), findsNothing);
    expect(find.text('—'), findsWidgets);
  });

  testWidgets('offers pause and cancel for a running download', (tester) async {
    await pumpScreen(tester, tasks: [downloading()]);

    expect(find.byTooltip('Pausar'), findsOneWidget);
    expect(find.byTooltip('Cancelar'), findsOneWidget);
    expect(find.byTooltip('Continuar'), findsNothing);
  });

  testWidgets('offers resume for a paused download', (tester) async {
    await pumpScreen(tester, tasks: [
      downloading().transitionTo(DownloadState.paused).valueOrNull!,
    ]);

    expect(find.byTooltip('Continuar'), findsOneWidget);
    expect(find.text('Pausado'), findsOneWidget);
  });

  testWidgets('shows the failure reason and a retry action', (tester) async {
    await pumpScreen(tester, tasks: [
      downloading()
          .transitionTo(
            DownloadState.failed,
            failureReason: 'A conexão caiu antes do fim do arquivo.',
          )
          .valueOrNull!,
    ]);

    expect(find.text('Falhou'), findsOneWidget);
    expect(
      find.text('A conexão caiu antes do fim do arquivo.'),
      findsOneWidget,
    );
    expect(find.text('Tentar de novo'), findsOneWidget);
  });

  testWidgets('cancelling asks for confirmation and can be declined',
      (tester) async {
    await pumpScreen(tester, tasks: [downloading()]);

    await tester.tap(find.byTooltip('Cancelar'));
    await tester.pumpAndSettle();
    expect(find.text('Cancelar download?'), findsOneWidget);

    await tester.tap(find.text('Manter'));
    await tester.pumpAndSettle();
    expect(repository.stateOf('t1'), DownloadState.downloading);
  });

  testWidgets('confirming the cancel dialog cancels the download',
      (tester) async {
    // Queued (not running) so the manager cancels it without an engine.
    await pumpScreen(tester, tasks: [taskFixture()]);

    await tester.tap(find.byTooltip('Cancelar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancelar download'));
    await tester.pumpAndSettle();

    expect(repository.stateOf('t1'), DownloadState.canceled);
  });

  testWidgets('bulk actions appear only when they apply', (tester) async {
    await pumpScreen(tester);
    expect(find.byTooltip('Pausar tudo'), findsNothing);
    expect(find.byTooltip('Limpar concluídos'), findsNothing);

    await repository.save(downloading());
    await tester.pumpAndSettle();
    expect(find.byTooltip('Pausar tudo'), findsOneWidget);

    await repository.save(
      downloading()
          .transitionTo(DownloadState.completed)
          .valueOrNull!
          .transitionTo(DownloadState.verifying)
          .valueOrNull!
          .transitionTo(DownloadState.done)
          .valueOrNull!,
    );
    await tester.pumpAndSettle();
    expect(find.byTooltip('Limpar concluídos'), findsOneWidget);
  });

  testWidgets('clearing finished downloads empties the queue', (tester) async {
    await pumpScreen(tester, tasks: [
      downloading()
          .transitionTo(DownloadState.completed)
          .valueOrNull!
          .transitionTo(DownloadState.verifying)
          .valueOrNull!
          .transitionTo(DownloadState.done)
          .valueOrNull!,
    ]);
    expect(find.text('Concluído'), findsOneWidget);

    await tester.tap(find.byTooltip('Limpar concluídos'));
    await tester.pumpAndSettle();
    expect(find.text('Nenhum download na fila'), findsOneWidget);
  });

  testWidgets('the progress bar is announced to screen readers',
      (tester) async {
    final handle = tester.ensureSemantics();
    await pumpScreen(tester, tasks: [downloading()]);

    expect(
      find.bySemanticsLabel(RegExp('Baixando, 25 por cento')),
      findsOneWidget,
    );
    handle.dispose();
  });
}
