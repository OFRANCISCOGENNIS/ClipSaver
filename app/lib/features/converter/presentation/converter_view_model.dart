/// ViewModel of the Converter screen (MVVM, section 4.1).
///
/// Responsibility: project the conversion queue into rows and forward
/// intents to the manager. The queue is independent of the download
/// queue, exactly as section 11 requires.
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/error/result.dart';
import '../../library/domain/library_entry.dart';
import '../application/conversion_manager.dart';
import '../domain/conversion_job.dart';
import '../domain/conversion_request.dart';
import 'converter_state.dart';

/// Provides the Converter ViewModel.
final converterViewModelProvider =
    NotifierProvider<ConverterViewModel, ConverterUiState>(
  ConverterViewModel.new,
);

/// Drives the Converter screen.
final class ConverterViewModel extends Notifier<ConverterUiState> {
  late final ConversionManager _manager;
  StreamSubscription<List<ConversionJob>>? _subscription;

  @override
  ConverterUiState build() {
    _manager = ref.watch(conversionManagerProvider);
    final repository = ref.watch(converterRepositoryProvider);

    _subscription = repository.watchAll().listen(_onJobs);
    ref.onDispose(() => unawaited(_subscription?.cancel()));
    unawaited(repository.all().then((result) {
      final jobs = result.valueOrNull;
      if (jobs != null) _onJobs(jobs);
    }));

    return const ConverterUiState();
  }

  void _onJobs(List<ConversionJob> jobs) {
    state = ConverterUiState(
      loaded: true,
      items: [for (final job in jobs) ConversionItemUiState(job: job)],
    );
  }

  /// Queues a conversion of [entry] with [request].
  Future<Result<ConversionJob>> convert(
    LibraryEntry entry,
    ConversionRequest request,
  ) =>
      _manager.enqueue(
        libraryEntryId: entry.id,
        sourcePath: entry.filePath,
        request: request,
        sourceDuration: entry.duration,
      );

  /// Queues a conversion using a ready-made preset (section 11).
  Future<Result<ConversionJob>> convertWithPreset(
    LibraryEntry entry,
    ConversionPreset preset,
  ) =>
      convert(entry, preset.toRequest());

  /// Cancels a conversion.
  Future<Result<ConversionJob>> cancel(String id) => _manager.cancel(id);

  /// Retries a failed conversion.
  Future<Result<ConversionJob>> retry(String id) => _manager.retry(id);

  /// Removes finished rows.
  Future<void> clearFinished() async {
    await _manager.clearFinished();
  }
}

