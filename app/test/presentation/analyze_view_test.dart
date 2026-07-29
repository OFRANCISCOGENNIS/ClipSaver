import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vidora/app/providers.dart';
import 'package:vidora/app/theme/app_theme.dart';
import 'package:vidora/core/error/failures.dart';
import 'package:vidora/core/error/result.dart';
import 'package:vidora/features/analyze/presentation/analyze_view.dart';

import '../support/analyze_fakes.dart';

void main() {
  late FakeAnalyzeRepository repository;
  late FakeClipboardReader clipboard;

  setUp(() {
    repository = FakeAnalyzeRepository();
    clipboard = FakeClipboardReader();
  });

  Future<void> pumpScreen(WidgetTester tester, {String? sharedUrl}) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          analyzeRepositoryProvider.overrideWithValue(repository),
          clipboardReaderProvider.overrideWithValue(clipboard),
          downloadsDirectoryProvider.overrideWithValue('/downloads'),
        ],
        child: MaterialApp(
          theme: buildVidoraTheme(Brightness.light),
          home: AnalyzeView(sharedUrl: sharedUrl),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows the compliance-first empty state', (tester) async {
    await pumpScreen(tester);
    expect(find.text('Baixe apenas o que é permitido'), findsOneWidget);
    expect(find.text('Analisar'), findsOneWidget);
  });

  testWidgets('the primary button stays disabled until the URL is valid',
      (tester) async {
    await pumpScreen(tester);

    FilledButton button() =>
        tester.widget<FilledButton>(find.byType(FilledButton).first);
    expect(button().onPressed, isNull);

    await tester.enterText(find.byType(TextField), 'não é um link');
    await tester.pump();
    expect(button().onPressed, isNull);
    expect(find.textContaining('link válido'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'https://cc.example.com/a');
    await tester.pump();
    expect(button().onPressed, isNotNull);
  });

  testWidgets(
      'renders the authorization badge and real formats for an '
      'eligible result', (tester) async {
    repository.nextResult = Result.ok(mediaItemFixture());
    await pumpScreen(tester);

    await tester.enterText(
      find.byType(TextField),
      'https://cc.example.com/aula',
    );
    await tester.pump();
    await tester.tap(find.text('Analisar'));
    await tester.pumpAndSettle();

    expect(find.text('Aula aberta'), findsOneWidget);
    expect(find.text('Licença CC-BY'), findsOneWidget);
    expect(find.text('720p · MP4'), findsOneWidget);
    expect(
      find.textContaining('atribuição obrigatória'),
      findsOneWidget,
    );
    expect(find.text('Baixar 720p'), findsOneWidget);
  });

  testWidgets(
      'renders the educational card, and no download button, for a '
      'refused result', (tester) async {
    repository.nextResult = Result.ok(mediaItemFixture(eligible: false));
    await pumpScreen(tester);

    await tester.enterText(
      find.byType(TextField),
      'https://drm.example.com/filme',
    );
    await tester.pump();
    await tester.tap(find.text('Analisar'));
    await tester.pumpAndSettle();

    expect(find.text('Download não autorizado'), findsOneWidget);
    expect(find.textContaining('protegido por DRM'), findsOneWidget);
    expect(find.textContaining('Baixar'), findsNothing);
    expect(find.text('Detalhes técnicos'), findsOneWidget);
  });

  testWidgets('shows a specific error with a retry action', (tester) async {
    repository.nextResult = const Result.err(NetworkFailure('Sem conexão.'));
    await pumpScreen(tester);

    await tester.enterText(find.byType(TextField), 'https://cc.example.com/a');
    await tester.pump();
    await tester.tap(find.text('Analisar'));
    await tester.pumpAndSettle();

    expect(find.text('Sem conexão.'), findsOneWidget);
    expect(find.text('Tentar novamente'), findsOneWidget);

    repository.nextResult = Result.ok(mediaItemFixture());
    await tester.tap(find.text('Tentar novamente'));
    await tester.pumpAndSettle();
    expect(find.text('Aula aberta'), findsOneWidget);
  });

  testWidgets('offers the clipboard link and fills the field when accepted',
      (tester) async {
    clipboard.text = 'https://cc.example.com/copiado';
    await pumpScreen(tester);

    expect(find.textContaining('Colar link copiado?'), findsOneWidget);
    await tester.tap(find.byType(InputChip));
    await tester.pumpAndSettle();

    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'https://cc.example.com/copiado',
    );
    expect(find.byType(InputChip), findsNothing);
  });

  testWidgets('a shared deep-link URL is analyzed on open', (tester) async {
    repository.nextResult = Result.ok(mediaItemFixture());
    await pumpScreen(tester, sharedUrl: 'https://cc.example.com/aula');

    expect(repository.analyzed, ['https://cc.example.com/aula']);
    expect(find.text('Aula aberta'), findsOneWidget);
  });

  testWidgets('lists recent analyses with their authorization badge',
      (tester) async {
    repository.recents = [
      mediaItemFixture(id: 'r1', title: 'Primeira'),
      mediaItemFixture(id: 'r2', title: 'Segunda', eligible: false),
    ];
    await pumpScreen(tester);

    expect(find.text('Recentes'), findsOneWidget);
    expect(find.text('Primeira'), findsOneWidget);
    expect(find.text('Não autorizado'), findsOneWidget);
  });

  testWidgets('tapping a recent item restores its verdict without a request',
      (tester) async {
    repository.recents = [mediaItemFixture(id: 'r1', title: 'Primeira')];
    await pumpScreen(tester);

    await tester.tap(find.text('Primeira'));
    await tester.pumpAndSettle();

    expect(find.text('Baixar 720p'), findsOneWidget);
    expect(repository.analyzed, isEmpty);
  });
}
