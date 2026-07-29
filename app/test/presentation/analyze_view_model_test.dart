import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vidora/app/providers.dart';
import 'package:vidora/core/error/failures.dart';
import 'package:vidora/core/error/result.dart';
import 'package:vidora/features/analyze/presentation/analyze_state.dart';
import 'package:vidora/features/analyze/presentation/analyze_view_model.dart';

import '../support/analyze_fakes.dart';

void main() {
  late FakeAnalyzeRepository repository;
  late FakeClipboardReader clipboard;
  late ProviderContainer container;

  setUp(() {
    repository = FakeAnalyzeRepository();
    clipboard = FakeClipboardReader();
    container = ProviderContainer(
      overrides: [
        analyzeRepositoryProvider.overrideWithValue(repository),
        clipboardReaderProvider.overrideWithValue(clipboard),
      ],
    );
  });

  tearDown(() => container.dispose());

  AnalyzeViewModel viewModel() =>
      container.read(analyzeViewModelProvider.notifier);
  AnalyzeUiState state() => container.read(analyzeViewModelProvider);

  group('initial state', () {
    test('starts idle with an empty field', () {
      expect(state().phase, isA<AnalyzeIdle>());
      expect(state().url, isEmpty);
      expect(state().canAnalyze, isFalse);
      expect(state().isBusy, isFalse);
    });
  });

  group('real-time URL validation (section 7.2 step 1)', () {
    test('a valid URL enables the button and clears the error', () {
      viewModel().urlChanged('https://cc.example.com/aula');
      expect(state().phase, isA<AnalyzeValidating>());
      expect(state().urlError, isNull);
      expect(state().canAnalyze, isTrue);
    });

    test('an invalid URL surfaces an inline error and blocks the button', () {
      viewModel().urlChanged('não é um link');
      expect(state().urlError, isNotNull);
      expect(state().canAnalyze, isFalse);
    });

    test('a private-network URL is refused before any request', () {
      viewModel().urlChanged('http://192.168.0.10/video.mp4');
      expect(state().urlError, isNotNull);
      expect(repository.analyzed, isEmpty);
    });

    test('clearing the field returns to idle', () {
      viewModel().urlChanged('https://cc.example.com/aula');
      viewModel().urlChanged('');
      expect(state().phase, isA<AnalyzeIdle>());
      expect(state().urlError, isNull);
    });
  });

  group('analysis', () {
    test('an eligible verdict lands in the result node', () async {
      final item = mediaItemFixture();
      repository.nextResult = Result.ok(item);

      viewModel().urlChanged(item.url.value);
      await viewModel().analyze();

      final phase = state().phase;
      expect(phase, isA<AnalyzeResult>());
      expect((phase as AnalyzeResult).item.id, item.id);
      expect(repository.analyzed, [item.url.value]);
    });

    test('an ineligible verdict lands in the ineligible node, not error',
        () async {
      final item = mediaItemFixture(eligible: false);
      repository.nextResult = Result.ok(item);

      viewModel().urlChanged(item.url.value);
      await viewModel().analyze();

      // A refusal is a successful analysis with a "no" — the UI must show
      // the educational card, never a generic failure.
      expect(state().phase, isA<AnalyzeIneligible>());
    });

    test('a network failure lands in the error node', () async {
      repository.nextResult = const Result.err(NetworkFailure('Sem conexão.'));
      viewModel().urlChanged('https://cc.example.com/aula');
      await viewModel().analyze();

      final phase = state().phase;
      expect(phase, isA<AnalyzeError>());
      expect(describeFailure((phase as AnalyzeError).failure), 'Sem conexão.');
    });

    test('refuses to run while the field is invalid', () async {
      viewModel().urlChanged('inválido');
      await viewModel().analyze();
      expect(repository.analyzed, isEmpty);
    });

    test('reloads the recent shortcuts after a successful analysis', () async {
      repository.nextResult = Result.ok(mediaItemFixture());
      repository.recents = [mediaItemFixture(id: 'old')];

      viewModel().urlChanged('https://cc.example.com/aula');
      await viewModel().analyze();

      expect(state().recents.single.id, 'old');
    });

    test('retry re-runs only from the error node', () async {
      repository.nextResult = const Result.err(NetworkFailure('Sem conexão.'));
      viewModel().urlChanged('https://cc.example.com/aula');
      await viewModel().analyze();

      repository.nextResult = Result.ok(mediaItemFixture());
      await viewModel().retry();
      expect(state().phase, isA<AnalyzeResult>());

      // From a result node, retry is a no-op.
      repository.analyzed.clear();
      await viewModel().retry();
      expect(repository.analyzed, isEmpty);
    });

    test('typing again drops a stale verdict', () async {
      repository.nextResult = Result.ok(mediaItemFixture());
      viewModel().urlChanged('https://cc.example.com/aula');
      await viewModel().analyze();
      expect(state().phase, isA<AnalyzeResult>());

      viewModel().urlChanged('https://cc.example.com/outra');
      expect(state().phase, isA<AnalyzeValidating>());
    });
  });

  group('clipboard suggestion (section 7.1)', () {
    test('offers a valid URL found in the clipboard', () async {
      clipboard.text = 'https://cc.example.com/copiado';
      await viewModel().checkClipboard();
      expect(state().clipboardSuggestion, 'https://cc.example.com/copiado');
    });

    test('ignores non-URL and empty clipboard content', () async {
      clipboard.text = 'apenas um texto';
      await viewModel().checkClipboard();
      expect(state().clipboardSuggestion, isNull);

      clipboard.text = '   ';
      await viewModel().checkClipboard();
      expect(state().clipboardSuggestion, isNull);
    });

    test('does not offer what is already in the field', () async {
      const url = 'https://cc.example.com/aula';
      viewModel().urlChanged(url);
      clipboard.text = url;
      await viewModel().checkClipboard();
      expect(state().clipboardSuggestion, isNull);
    });

    test('accepting fills the field and validates it', () async {
      clipboard.text = 'https://cc.example.com/copiado';
      await viewModel().checkClipboard();
      viewModel().acceptClipboardSuggestion();

      expect(state().url, 'https://cc.example.com/copiado');
      expect(state().clipboardSuggestion, isNull);
      expect(state().canAnalyze, isTrue);
    });

    test('dismissing removes the chip', () async {
      clipboard.text = 'https://cc.example.com/copiado';
      await viewModel().checkClipboard();
      viewModel().dismissClipboardSuggestion();
      expect(state().clipboardSuggestion, isNull);
    });

    test('initialize can skip clipboard detection when disabled', () async {
      clipboard.text = 'https://cc.example.com/copiado';
      await viewModel().initialize(detectClipboard: false);
      expect(state().clipboardSuggestion, isNull);
    });
  });

  group('recent shortcuts', () {
    test('opening a recent item restores its verdict without a request',
        () async {
      final item = mediaItemFixture(id: 'r1');
      viewModel().openRecent(item);

      expect(state().url, item.url.value);
      expect(state().phase, isA<AnalyzeResult>());
      expect(repository.analyzed, isEmpty);
    });

    test('opening a refused recent item restores the ineligible node', () {
      viewModel().openRecent(mediaItemFixture(id: 'r2', eligible: false));
      expect(state().phase, isA<AnalyzeIneligible>());
    });

    test('clear keeps the shortcuts but resets the field', () async {
      repository.recents = [mediaItemFixture()];
      await viewModel().refreshRecents();
      viewModel().urlChanged('https://cc.example.com/aula');

      viewModel().clear();
      expect(state().url, isEmpty);
      expect(state().phase, isA<AnalyzeIdle>());
      expect(state().recents, hasLength(1));
    });
  });
}
