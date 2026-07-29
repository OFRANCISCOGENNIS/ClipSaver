/// Immutable UI state for the Downloads screen (section 8.2).
library;

import 'package:freezed_annotation/freezed_annotation.dart';

import '../application/transfer_rate.dart';
import '../domain/download_state.dart';
import '../domain/download_task.dart';

part 'downloads_state.freezed.dart';

/// One row of the queue: the task plus its live speed reading.
@freezed
abstract class DownloadItemUiState with _$DownloadItemUiState {
  /// Creates a row.
  const factory DownloadItemUiState({
    required DownloadTask task,

    /// Live rate; null until two measurements exist or when not running.
    TransferRate? rate,
  }) = _DownloadItemUiState;

  const DownloadItemUiState._();

  /// Stable identity for list keys and actions.
  String get id => task.id;

  /// Whether pausing is offered for this row.
  bool get canPause =>
      task.state == DownloadState.downloading ||
      task.state == DownloadState.connecting ||
      task.state == DownloadState.queued;

  /// Whether resuming is offered.
  bool get canResume => task.state == DownloadState.paused;

  /// Whether the row can still be canceled.
  bool get canCancel => task.state.isActive;

  /// Whether a manual retry is offered.
  bool get canRetry => task.canRetry;
}

/// The whole Downloads screen.
@freezed
abstract class DownloadsUiState with _$DownloadsUiState {
  /// Creates the state.
  const factory DownloadsUiState({
    /// Queue rows, ordered by the repository (active first, then priority).
    @Default(<DownloadItemUiState>[]) List<DownloadItemUiState> items,

    /// False until the first emission from the database arrives.
    @Default(false) bool loaded,
  }) = _DownloadsUiState;

  const DownloadsUiState._();

  /// Rows still occupying the queue.
  Iterable<DownloadItemUiState> get active =>
      items.where((item) => item.task.state.isActive);

  /// Whether "pausar tudo" should be offered.
  bool get hasPausableWork => items.any((item) => item.canPause);

  /// Whether "retomar tudo" should be offered.
  bool get hasResumableWork => items.any((item) => item.canResume);

  /// Whether "limpar concluídos" should be offered.
  bool get hasFinishedWork =>
      items.any((item) => item.task.state == DownloadState.done);
}
