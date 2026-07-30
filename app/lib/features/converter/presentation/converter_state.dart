/// Immutable UI state for the Converter screen (section 11).
library;

import 'package:freezed_annotation/freezed_annotation.dart';

import '../domain/conversion_job.dart';

part 'converter_state.freezed.dart';

/// One row of the conversion queue.
@freezed
abstract class ConversionItemUiState with _$ConversionItemUiState {
  /// Creates a row.
  const factory ConversionItemUiState({required ConversionJob job}) =
      _ConversionItemUiState;

  const ConversionItemUiState._();

  /// Stable identity for list keys.
  String get id => job.id;

  /// Whether the row can still be canceled.
  bool get canCancel =>
      job.state == ConversionState.queued ||
      job.state == ConversionState.converting;

  /// Whether a retry is offered.
  bool get canRetry => job.state == ConversionState.failed;

  /// Whether progress is measurable — without the source duration FFmpeg's
  /// processed-time output cannot become a percentage.
  bool get hasDeterminateProgress =>
      job.sourceDuration != null && job.state == ConversionState.converting;
}

/// Everything the Converter screen renders.
@freezed
abstract class ConverterUiState with _$ConverterUiState {
  /// Creates the state.
  const factory ConverterUiState({
    /// Queue rows, active first.
    @Default(<ConversionItemUiState>[]) List<ConversionItemUiState> items,

    /// False until the first emission arrives.
    @Default(false) bool loaded,
  }) = _ConverterUiState;

  const ConverterUiState._();

  /// Whether "limpar concluídas" should be offered.
  bool get hasFinishedWork =>
      items.any((item) => item.job.state == ConversionState.completed);

  /// Conversions still occupying the queue.
  Iterable<ConversionItemUiState> get active => items.where(
        (item) =>
            item.job.state == ConversionState.queued ||
            item.job.state == ConversionState.converting,
      );
}
