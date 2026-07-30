/// Repository contract for the conversion queue (section 11), independent
/// from the download queue.
///
/// Responsibility: hide the FFmpeg execution backend (ffmpeg_kit on
/// mobile/desktop, FFmpeg.wasm on Web) behind one interface.
library;

import '../../../core/error/result.dart';
import 'conversion_job.dart';

/// Persistence + execution gateway for the conversion queue.
abstract interface class ConverterRepository {
  /// Persists a new job in [ConversionState.queued] and schedules it.
  Future<Result<ConversionJob>> enqueue(ConversionJob job);

  /// Persists a state change already validated by the entity.
  Future<Result<ConversionJob>> save(ConversionJob job);

  /// Looks a job up by [id]; Ok(null) when absent.
  Future<Result<ConversionJob?>> findById(String id);

  /// Reactive stream of the conversion queue.
  Stream<List<ConversionJob>> watchAll();
}
