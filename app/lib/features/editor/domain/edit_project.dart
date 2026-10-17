/// Timeline model for the editor (section 11, extensão da fase 8).
///
/// Responsibility: hold what the user assembled — which pieces of which
/// files, in what order, at what speed and volume, with what text on top —
/// and refuse every edit that would produce a timeline FFmpeg cannot
/// render. Rendering itself lives in `TimelineCompiler`; this file never
/// builds a command.
///
/// Every operation returns a new project rather than mutating one. Undo
/// then costs nothing (keep the previous value) and a half-applied edit
/// cannot exist, which is the failure mode that makes editors lose work.
library;

import '../../../core/error/failures.dart';
import '../../../core/error/result.dart';

/// Output framing. The editor never stretches an image to fit: a ratio
/// change pads, so a vertical export of a wide clip has bars rather than
/// distorted faces.
enum OutputAspect {
  /// Keep whatever the first clip has.
  original,

  /// 9:16 — full-screen phone.
  vertical,

  /// 1:1 — square.
  square,

  /// 16:9 — widescreen.
  wide;

  /// Target pixel size, or null for [OutputAspect.original].
  OutputSize? get size => switch (this) {
        OutputAspect.original => null,
        OutputAspect.vertical => const OutputSize(1080, 1920),
        OutputAspect.square => const OutputSize(1080, 1080),
        OutputAspect.wide => const OutputSize(1920, 1080),
      };
}

/// Pixel dimensions of a framed export.
final class OutputSize {
  /// Creates the size.
  const OutputSize(this.width, this.height);

  /// Width in pixels.
  final int width;

  /// Height in pixels.
  final int height;

  @override
  bool operator ==(Object other) =>
      other is OutputSize && other.width == width && other.height == height;

  @override
  int get hashCode => Object.hash(width, height);

  @override
  String toString() => '${width}x$height';
}

/// Where a text overlay sits in the frame.
enum TextAnchor {
  /// Near the top edge.
  top,

  /// Vertically centred.
  center,

  /// Near the bottom edge, the default for captions.
  bottom,
}

/// Playback speed bounds. Beyond 4x the audio is unintelligible and the
/// frame drop looks like a bug; below 0.25x a short clip becomes minutes.
const double kMinSpeed = 0.25;

/// Upper playback-speed bound.
const double kMaxSpeed = 4;

/// One line of text drawn over a clip.
final class TextOverlay {
  /// Creates the overlay, validating its window.
  TextOverlay({
    required this.text,
    required this.start,
    required this.end,
    this.anchor = TextAnchor.bottom,
    this.fontSizePx = 48,
  }) {
    if (text.isEmpty) throw ArgumentError('text must not be empty');
    if (end <= start) throw ArgumentError('end must be after start');
    if (fontSizePx <= 0) throw ArgumentError('fontSizePx must be positive');
  }

  /// The literal text. Escaping for FFmpeg is the compiler's job — the
  /// model keeps exactly what the user typed, so an edit round-trip never
  /// accumulates backslashes.
  final String text;

  /// Start, relative to the clip it belongs to.
  final Duration start;

  /// End, relative to the clip it belongs to.
  final Duration end;

  /// Vertical placement.
  final TextAnchor anchor;

  /// Size in pixels at the output resolution.
  final int fontSizePx;

  /// How long the text stays on screen.
  Duration get duration => end - start;
}

/// One piece of one source file, placed on the timeline.
final class EditClip {
  /// Creates the clip, validating its range and its multipliers.
  EditClip({
    required this.id,
    required this.sourcePath,
    required this.sourceStart,
    required this.sourceEnd,
    this.speed = 1,
    this.volume = 1,
    this.overlays = const [],
  }) {
    if (id.trim().isEmpty) throw ArgumentError('id must not be empty');
    if (sourcePath.trim().isEmpty) {
      throw ArgumentError('sourcePath must not be empty');
    }
    if (sourceStart.isNegative) {
      throw ArgumentError('sourceStart must not be negative');
    }
    if (sourceEnd <= sourceStart) {
      throw ArgumentError('sourceEnd must be after sourceStart');
    }
    if (speed < kMinSpeed || speed > kMaxSpeed) {
      throw ArgumentError('speed must be within $kMinSpeed..$kMaxSpeed');
    }
    if (volume < 0 || volume > 2) {
      throw ArgumentError('volume must be within 0..2');
    }
  }

  /// Stable identity, used as the list key and by every operation.
  final String id;

  /// Absolute path of the file this clip reads from.
  final String sourcePath;

  /// In point within the source.
  final Duration sourceStart;

  /// Out point within the source.
  final Duration sourceEnd;

  /// Playback multiplier; 1 is untouched.
  final double speed;

  /// Audio multiplier; 0 is muted, 1 is untouched.
  final double volume;

  /// Text drawn over this clip, in no particular order.
  final List<TextOverlay> overlays;

  /// Length of the source material used.
  Duration get sourceDuration => sourceEnd - sourceStart;

  /// Length on the finished timeline, after speed is applied.
  ///
  /// This is the number the user sees, and it is why speed cannot be a
  /// render-time flag: doubling the speed halves the project.
  Duration get renderedDuration => Duration(
        microseconds: (sourceDuration.inMicroseconds / speed).round(),
      );

  /// Whether this clip contributes no audio.
  bool get isMuted => volume == 0;

  /// Copies the clip, overriding the given fields.
  EditClip copyWith({
    Duration? sourceStart,
    Duration? sourceEnd,
    double? speed,
    double? volume,
    List<TextOverlay>? overlays,
    String? id,
  }) =>
      EditClip(
        id: id ?? this.id,
        sourcePath: sourcePath,
        sourceStart: sourceStart ?? this.sourceStart,
        sourceEnd: sourceEnd ?? this.sourceEnd,
        speed: speed ?? this.speed,
        volume: volume ?? this.volume,
        overlays: overlays ?? this.overlays,
      );
}

/// An edit in progress: the clips, in order, plus the output framing.
final class EditProject {
  /// Creates the project.
  EditProject({
    required this.id,
    required this.title,
    this.clips = const [],
    this.aspect = OutputAspect.original,
  }) {
    if (id.trim().isEmpty) throw ArgumentError('id must not be empty');
  }

  /// Stable identity.
  final String id;

  /// User-facing name.
  final String title;

  /// Clips in playback order.
  final List<EditClip> clips;

  /// Output framing.
  final OutputAspect aspect;

  /// Total length of the finished video.
  Duration get duration => clips.fold(
        Duration.zero,
        (total, clip) => total + clip.renderedDuration,
      );

  /// Whether there is anything to render.
  bool get isEmpty => clips.isEmpty;

  EditProject _withClips(List<EditClip> next) => EditProject(
        id: id,
        title: title,
        clips: List.unmodifiable(next),
        aspect: aspect,
      );

  int _indexOf(String clipId) => clips.indexWhere((clip) => clip.id == clipId);

  /// Appends [clip] to the end of the timeline.
  Result<EditProject> append(EditClip clip) {
    if (_indexOf(clip.id) != -1) {
      return Result.err(
        ValidationFailure('já existe um clipe com o id "${clip.id}".'),
      );
    }
    return Result.ok(_withClips([...clips, clip]));
  }

  /// Removes the clip with [clipId].
  Result<EditProject> remove(String clipId) {
    final index = _indexOf(clipId);
    if (index == -1) return _notFound(clipId);
    return Result.ok(_withClips([...clips]..removeAt(index)));
  }

  /// Moves the clip at [from] to position [to].
  Result<EditProject> reorder(int from, int to) {
    if (from < 0 || from >= clips.length || to < 0 || to >= clips.length) {
      return const Result.err(
        ValidationFailure('posição fora da linha do tempo.'),
      );
    }
    final next = [...clips];
    next.insert(to, next.removeAt(from));
    return Result.ok(_withClips(next));
  }

  /// Replaces the clip with [clipId] by applying [change] to it.
  Result<EditProject> update(
    String clipId,
    EditClip Function(EditClip clip) change,
  ) {
    final index = _indexOf(clipId);
    if (index == -1) return _notFound(clipId);
    final next = [...clips];
    try {
      next[index] = change(next[index]);
    } on ArgumentError catch (error) {
      // The clip constructor is the single source of truth for what is a
      // valid clip; an invalid edit becomes a Result here instead of an
      // exception crossing into the ViewModel.
      return Result.err(ValidationFailure(error.message.toString()));
    }
    return Result.ok(_withClips(next));
  }

  /// Splits the clip with [clipId] at [at], measured from the clip's own
  /// start on the finished timeline.
  ///
  /// The offset is in *rendered* time because that is what the playhead
  /// shows. Converting it back through the speed multiplier is exactly
  /// the step that is easy to forget and silently cuts in the wrong place
  /// on any clip that is not at 1x.
  Result<EditProject> splitAt(String clipId, Duration at) {
    final index = _indexOf(clipId);
    if (index == -1) return _notFound(clipId);
    final clip = clips[index];

    if (at <= Duration.zero || at >= clip.renderedDuration) {
      return const Result.err(
        ValidationFailure(
          'o corte precisa cair dentro do clipe; nas pontas ele não '
          'dividiria nada.',
        ),
      );
    }

    final offsetInSource = Duration(
      microseconds: (at.inMicroseconds * clip.speed).round(),
    );
    final cut = clip.sourceStart + offsetInSource;

    final left = clip.copyWith(sourceEnd: cut, overlays: const []);
    final right = clip.copyWith(
      id: '${clip.id}_b',
      sourceStart: cut,
      overlays: const [],
    );

    // Overlays follow the half they started in, with the right-hand ones
    // rebased so their timings stay relative to their new clip.
    final leftOverlays = <TextOverlay>[];
    final rightOverlays = <TextOverlay>[];
    for (final overlay in clip.overlays) {
      if (overlay.start < at) {
        leftOverlays.add(
          TextOverlay(
            text: overlay.text,
            start: overlay.start,
            end: overlay.end < at ? overlay.end : at,
            anchor: overlay.anchor,
            fontSizePx: overlay.fontSizePx,
          ),
        );
      } else {
        rightOverlays.add(
          TextOverlay(
            text: overlay.text,
            start: overlay.start - at,
            end: overlay.end - at,
            anchor: overlay.anchor,
            fontSizePx: overlay.fontSizePx,
          ),
        );
      }
    }

    final next = [...clips]
      ..[index] = left.copyWith(overlays: leftOverlays)
      ..insert(index + 1, right.copyWith(overlays: rightOverlays));
    return Result.ok(_withClips(next));
  }

  /// Changes the output framing.
  EditProject withAspect(OutputAspect value) => EditProject(
        id: id,
        title: title,
        clips: clips,
        aspect: value,
      );

  Result<EditProject> _notFound(String clipId) => Result.err(
        ValidationFailure('clipe "$clipId" não está na linha do tempo.'),
      );
}
