/// ViewModel of the Analyze screen (MVVM, section 4.1).
///
/// Responsibility: own the state machine transitions and nothing else —
/// no widgets, no BuildContext, no direct HTTP. Every path through
/// section 7.2 is reachable from here and testable without a widget tree.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/domain/value_objects/media_url.dart';
import '../../../core/error/failures.dart';
import '../../../core/platform/clipboard_reader.dart';
import '../application/analyze_url_use_case.dart';
import '../domain/media_item.dart';
import 'analyze_state.dart';

/// Provides the Analyze ViewModel.
final analyzeViewModelProvider =
    NotifierProvider<AnalyzeViewModel, AnalyzeUiState>(AnalyzeViewModel.new);

/// Drives the Analyze screen.
final class AnalyzeViewModel extends Notifier<AnalyzeUiState> {
  late final AnalyzeUrlUseCase _analyzeUrl;
  late final RecentAnalysesUseCase _recentAnalyses;
  late final ClipboardReader _clipboard;

  @override
  AnalyzeUiState build() {
    final repository = ref.watch(analyzeRepositoryProvider);
    _analyzeUrl = AnalyzeUrlUseCase(repository);
    _recentAnalyses = RecentAnalysesUseCase(repository);
    _clipboard = ref.watch(clipboardReaderProvider);
    return const AnalyzeUiState();
  }

  /// Loads the "Recentes" shortcuts and the clipboard suggestion.
  Future<void> initialize({bool detectClipboard = true}) async {
    await refreshRecents();
    if (detectClipboard) await checkClipboard();
  }

  /// Reloads the recent-analyses shortcuts.
  Future<void> refreshRecents() async {
    final recents = await _recentAnalyses();
    state = state.copyWith(recents: recents.valueOrNull ?? const []);
  }

  /// Offers the clipboard content as a paste chip when it is a valid URL
  /// and is not already in the field (section 7.1).
  Future<void> checkClipboard() async {
    final text = await _clipboard.readText();
    if (text == null || text.trim().isEmpty) return;
    final candidate = text.trim();
    if (candidate == state.url.trim()) return;
    if (MediaUrl.create(candidate).isErr) return;
    state = state.copyWith(clipboardSuggestion: candidate);
  }

  /// Dismisses the paste suggestion.
  void dismissClipboardSuggestion() =>
      state = state.copyWith(clipboardSuggestion: null);

  /// Accepts the paste suggestion, filling the field.
  void acceptClipboardSuggestion() {
    final suggestion = state.clipboardSuggestion;
    if (suggestion == null) return;
    state = state.copyWith(clipboardSuggestion: null);
    urlChanged(suggestion);
  }

  /// Handles typing: validates in real time and drops any previous
  /// verdict, which no longer describes what is in the field.
  void urlChanged(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      state = state.copyWith(
        url: value,
        urlError: null,
        phase: const AnalyzePhase.idle(),
      );
      return;
    }
    final validation = MediaUrl.create(trimmed);
    state = state.copyWith(
      url: value,
      urlError: validation.failureOrNull?.message,
      phase: const AnalyzePhase.validating(),
    );
  }

  /// Clears the field and returns to `idle`, keeping the shortcuts.
  void clear() => state = AnalyzeUiState(recents: state.recents);

  /// Runs the analysis for the current field content.
  Future<void> analyze() async {
    if (!state.canAnalyze) return;
    state = state.copyWith(phase: const AnalyzePhase.analyzing());

    final result = await _analyzeUrl(state.url);
    final item = result.valueOrNull;
    if (item == null) {
      state = state.copyWith(phase: AnalyzePhase.error(result.failureOrNull!));
      return;
    }
    state = state.copyWith(
      phase: item.isDownloadable
          ? AnalyzePhase.result(item)
          : AnalyzePhase.ineligible(item),
    );
    await refreshRecents();
  }

  /// Re-runs the last analysis after an error (section 7.2 item 6).
  Future<void> retry() async {
    if (state.phase is! AnalyzeError) return;
    state = state.copyWith(phase: const AnalyzePhase.validating());
    await analyze();
  }

  /// Re-opens a previous analysis from the shortcuts without hitting the
  /// network — the stored verdict is what was decided then.
  void openRecent(MediaItem item) => state = state.copyWith(
        url: item.url.value,
        urlError: null,
        phase: item.isDownloadable
            ? AnalyzePhase.result(item)
            : AnalyzePhase.ineligible(item),
      );
}

/// Message for a [Failure], specific per type (section 7.2 item 6).
String describeFailure(Failure failure) => switch (failure) {
      NetworkFailure() ||
      ValidationFailure() ||
      ServerFailure() =>
        failure.message,
      _ => 'Não foi possível analisar este link.',
    };
