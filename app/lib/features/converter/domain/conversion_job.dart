/// A media conversion job (section 11): one source file from the user's
/// library, one target spec, executed by FFmpeg off the UI thread.
///
/// Responsibility: validate the conversion request at construction and
/// track its lifecycle with the same refuse-illegal-transitions approach
/// as [DownloadTask].
library;

import 'package:path/path.dart' as p;

import '../../../core/error/failures.dart';
import '../../../core/error/result.dart';
import 'conversion_request.dart';

/// Lifecycle states of a conversion job.
enum ConversionState {
  /// Waiting for a converter slot.
  queued,

  /// FFmpeg is processing the file.
  converting,

  /// Output written successfully. Terminal.
  completed,

  /// Failed with a reason; may be retried.
  failed,

  /// Canceled by the user. Terminal.
  canceled,
}

/// Target containers the converter supports (section 11).
enum ConversionTarget {
  /// MP4 container (H.264/H.265) — maximum compatibility.
  mp4('mp4', isAudioOnly: false),

  /// WebM container (VP9).
  webm('webm', isAudioOnly: false),

  /// Matroska container.
  mkv('mkv', isAudioOnly: false),

  /// MP3 audio.
  mp3('mp3', isAudioOnly: true),

  /// AAC audio.
  aac('aac', isAudioOnly: true),

  /// Uncompressed WAV audio.
  wav('wav', isAudioOnly: true),

  /// Lossless FLAC audio.
  flac('flac', isAudioOnly: true),

  /// Ogg Vorbis audio.
  ogg('ogg', isAudioOnly: true),

  /// Opus audio.
  opus('opus', isAudioOnly: true);

  const ConversionTarget(this.extension, {required this.isAudioOnly});

  /// File extension of the output container, without the dot.
  final String extension;

  /// True for audio containers — converting video into one of these is the
  /// "extract audio" flow and must preserve metadata (section 11).
  final bool isAudioOnly;
}

/// One conversion of a library file to a target container.
final class ConversionJob {
  /// Builds a job, validating identifiers and progress bounds.
  ConversionJob({
    required this.id,
    required this.libraryEntryId,
    required this.sourcePath,
    required this.request,
    this.sourceDuration,
    this.state = ConversionState.queued,
    this.progress = 0,
    this.failureReason,
  }) {
    if (id.trim().isEmpty) throw ArgumentError('id must not be empty');
    if (libraryEntryId.trim().isEmpty) {
      throw ArgumentError('libraryEntryId must not be empty');
    }
    if (sourcePath.trim().isEmpty) {
      throw ArgumentError('sourcePath must not be empty');
    }
    if (progress < 0 || progress > 1) {
      throw ArgumentError.value(progress, 'progress', 'must be within 0..1');
    }
  }

  /// Unique job identifier.
  final String id;

  /// Conversions only apply to files already in the user's library
  /// (section 11: "arquivos do próprio usuário").
  final String libraryEntryId;

  /// Absolute path of the source file.
  final String sourcePath;

  /// The full conversion spec — codecs, quality, trim, target container.
  final ConversionRequest request;

  /// Source media duration, needed to turn FFmpeg's processed-time output
  /// into a percentage. Null makes progress indeterminate.
  final Duration? sourceDuration;

  /// Current lifecycle state.
  final ConversionState state;

  /// Fraction of media time processed, 0..1 (FFmpeg reports time, not
  /// bytes).
  final double progress;

  /// Populated when [state] is [ConversionState.failed].
  final String? failureReason;

  /// Requested output container.
  ConversionTarget get target => request.target;

  /// Section 11: original preserved by default; replacement is opt-in.
  bool get keepOriginal => request.keepOriginal;

  /// Output path: the source path with the target extension.
  ///
  /// When the target extension matches the source, a suffix is added so a
  /// conversion never overwrites its own input mid-run.
  String get outputPath {
    final directory = p.dirname(sourcePath);
    final base = p.basenameWithoutExtension(sourcePath);
    final sameContainer =
        p.extension(sourcePath).toLowerCase() == '.${target.extension}';
    final name = sameContainer ? '$base (convertido)' : base;
    return p.join(directory, '$name.${target.extension}');
  }

  static const Map<ConversionState, Set<ConversionState>> _transitions = {
    ConversionState.queued: {
      ConversionState.converting,
      ConversionState.canceled,
    },
    ConversionState.converting: {
      ConversionState.completed,
      ConversionState.failed,
      ConversionState.canceled,
    },
    ConversionState.completed: {},
    ConversionState.failed: {ConversionState.queued}, // retry
    ConversionState.canceled: {},
  };

  /// Attempts a lifecycle transition, refusing illegal moves.
  Result<ConversionJob> transitionTo(
    ConversionState next, {
    String? failureReason,
  }) {
    if (!_transitions[state]!.contains(next)) {
      return Result.err(
        InvalidTransitionFailure(
          'transição ${state.name} → ${next.name} não é permitida',
        ),
      );
    }
    if (next == ConversionState.failed &&
        (failureReason == null || failureReason.trim().isEmpty)) {
      return const Result.err(
        InvalidTransitionFailure(
          'falha requer um motivo para exibição ao usuário',
        ),
      );
    }
    return Result.ok(
      _copyWith(
        state: next,
        failureReason: next == ConversionState.failed ? failureReason : null,
        progress: next == ConversionState.completed ? 1.0 : progress,
      ),
    );
  }

  /// Updates time-based progress; only valid while converting.
  Result<ConversionJob> withProgress(double value) {
    if (state != ConversionState.converting) {
      return Result.err(
        InvalidTransitionFailure(
          'progresso só é aceito em converting (estado atual: ${state.name})',
        ),
      );
    }
    if (value < 0 || value > 1) {
      return const Result.err(
        InvalidTransitionFailure('progresso deve estar entre 0 e 1'),
      );
    }
    return Result.ok(_copyWith(progress: value));
  }

  ConversionJob _copyWith({
    ConversionState? state,
    double? progress,
    String? failureReason,
  }) =>
      ConversionJob(
        id: id,
        libraryEntryId: libraryEntryId,
        sourcePath: sourcePath,
        request: request,
        sourceDuration: sourceDuration,
        state: state ?? this.state,
        progress: progress ?? this.progress,
        failureReason: failureReason,
      );

  @override
  bool operator ==(Object other) => other is ConversionJob && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'ConversionJob($id → ${target.extension}, ${state.name})';
}
