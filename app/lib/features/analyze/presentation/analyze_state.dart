/// Immutable UI state for the Analyze screen (section 7.2).
///
/// Responsibility: model the explicit state machine
/// `idle → validating → analyzing → result | ineligible | error`
/// as a sealed union, so the View cannot render a combination the
/// ViewModel never produced.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/error/failures.dart';
import '../domain/media_item.dart';

part 'analyze_state.freezed.dart';

/// One node of the Analyze state machine.
@freezed
sealed class AnalyzePhase with _$AnalyzePhase {
  /// Nothing typed yet, or the field was cleared.
  const factory AnalyzePhase.idle() = AnalyzeIdle;

  /// The URL is being validated locally (format check).
  const factory AnalyzePhase.validating() = AnalyzeValidating;

  /// Waiting on the backend analysis.
  const factory AnalyzePhase.analyzing() = AnalyzeAnalyzing;

  /// The URL is eligible; [item] carries the formats and the badge.
  const factory AnalyzePhase.result(MediaItem item) = AnalyzeResult;

  /// The URL was analyzed and refused; [item] carries the reason.
  const factory AnalyzePhase.ineligible(MediaItem item) = AnalyzeIneligible;

  /// The analysis could not be completed (network, server, validation).
  const factory AnalyzePhase.error(Failure failure) = AnalyzeError;
}

/// Everything the Analyze screen renders.
@freezed
abstract class AnalyzeUiState with _$AnalyzeUiState {
  /// Creates the state.
  const factory AnalyzeUiState({
    /// Current text of the URL field.
    @Default('') String url,

    /// Inline validation message shown under the field, when any.
    String? urlError,

    /// Current node of the state machine.
    @Default(AnalyzeIdle()) AnalyzePhase phase,

    /// Last five analyses, for the "Recentes" shortcuts (section 7.1).
    @Default(<MediaItem>[]) List<MediaItem> recents,

    /// URL found in the clipboard, offered as a paste chip.
    String? clipboardSuggestion,
  }) = _AnalyzeUiState;

  const AnalyzeUiState._();

  /// Whether the primary button is enabled (section 7.1).
  bool get canAnalyze => url.trim().isNotEmpty && urlError == null && !isBusy;

  /// Whether an asynchronous analysis is in flight.
  ///
  /// Validation is synchronous, so [AnalyzeValidating] is a resting node
  /// meaning "the field holds a checked URL" — it must not disable the
  /// button, or a valid link could never be analyzed.
  bool get isBusy => phase is AnalyzeAnalyzing;
}
