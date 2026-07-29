/// FFmpeg execution port (section 11).
///
/// Responsibility: keep the conversion queue independent of *how* FFmpeg
/// runs — a bundled binary in a separate process on desktop, a platform
/// channel on mobile, FFmpeg.wasm on the Web. The queue only needs
/// "start these arguments, tell me the progress, let me cancel".
///
/// No concrete implementation ships in this phase on purpose: the
/// `ffmpeg_kit_flutter` package named in the original tech table was
/// retired by its maintainer and its prebuilt binaries were withdrawn, so
/// picking a replacement is a decision to make deliberately rather than
/// by default. Everything above this port is finished and tested.
library;

/// Outcome of one FFmpeg run.
enum ConversionOutcome {
  /// Output written successfully.
  success,

  /// The caller canceled the run.
  canceled,

  /// FFmpeg exited with an error.
  failure,
}

/// Result of a finished run, with the reason when it failed.
final class ConversionResult {
  /// Creates a result.
  const ConversionResult(this.outcome, {this.errorMessage});

  /// What happened.
  final ConversionOutcome outcome;

  /// User-facing explanation, present when [outcome] is failure.
  final String? errorMessage;
}

/// Runs FFmpeg.
abstract interface class MediaConverter {
  /// Executes [arguments], reporting progress in 0..1 through [onProgress].
  ///
  /// [sourceDuration] is what turns FFmpeg's processed-time output into a
  /// percentage; null means progress cannot be computed and the UI shows
  /// an indeterminate bar.
  Future<ConversionResult> run({
    required String jobId,
    required List<String> arguments,
    required Duration? sourceDuration,
    required void Function(double progress) onProgress,
  });

  /// Aborts the run for [jobId], if it is still going.
  void cancel(String jobId);
}
