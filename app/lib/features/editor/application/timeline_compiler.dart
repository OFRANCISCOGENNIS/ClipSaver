/// Compiles an [EditProject] into FFmpeg arguments.
///
/// Responsibility: the whole render decision in one pure function. Every
/// subtlety that silently produces a wrong video — chained `atempo`,
/// padding instead of stretching, escaping text, keeping a muted clip's
/// audio stream alive — is a line here with a test next to it, rather
/// than something discovered on an exported file.
///
/// Pure and synchronous. The process call lives in the converter
/// infrastructure; this never touches the filesystem.
library;

import '../domain/edit_project.dart';

/// Assembles the argv for rendering a timeline.
abstract final class TimelineCompiler {
  /// Arguments that render [project] into [outputPath].
  ///
  /// Throws [ArgumentError] on an empty project: rendering nothing is a
  /// caller bug, not a user-facing failure — the UI disables Export when
  /// the timeline is empty.
  static List<String> build({
    required EditProject project,
    required String outputPath,
  }) {
    if (project.isEmpty) {
      throw ArgumentError('cannot render an empty timeline');
    }

    final args = <String>[
      '-y',
      '-hide_banner',
      '-loglevel',
      'error',
      '-progress',
      'pipe:1',
      '-nostats',
    ];

    // One input per clip, even when two clips read the same file. Reusing
    // an input would mean two filter chains seeking the same decoder, and
    // FFmpeg serves that from one position — the second clip would come
    // out as a duplicate of the first.
    for (final clip in project.clips) {
      args.addAll(['-i', clip.sourcePath]);
    }

    final filters = <String>[];
    final concatInputs = StringBuffer();

    for (var index = 0; index < project.clips.length; index++) {
      final clip = project.clips[index];
      filters.add(_videoChain(clip, index, project.aspect));
      filters.add(_audioChain(clip, index));
      concatInputs.write('[v$index][a$index]');
    }

    filters.add(
      '${concatInputs}concat=n=${project.clips.length}:v=1:a=1[outv][outa]',
    );

    args.addAll([
      '-filter_complex', filters.join(';'),
      '-map', '[outv]',
      '-map', '[outa]',
      // Re-encoding is unavoidable: concat of differently-encoded sources
      // through the filter graph produces raw frames, and stream copy has
      // nothing to copy.
      '-c:v', 'libx264',
      '-preset', 'medium',
      '-crf', '21',
      '-pix_fmt', 'yuv420p',
      '-c:a', 'aac',
      '-b:a', '192k',
      outputPath,
    ]);
    return args;
  }

  static String _videoChain(EditClip clip, int index, OutputAspect aspect) {
    final steps = <String>[
      'trim=start=${_seconds(clip.sourceStart)}:'
          'end=${_seconds(clip.sourceEnd)}',
      // After trimming, timestamps still start where the source did;
      // without this the concat would leave a gap the length of the in
      // point, and the player would show a freeze instead of a cut.
      'setpts=PTS-STARTPTS',
    ];

    if (clip.speed != 1) {
      // Video speed is a timestamp divide: 2x means each frame is shown
      // for half as long.
      steps.add('setpts=PTS/${_number(clip.speed)}');
    }

    final size = aspect.size;
    if (size != null) {
      // force_original_aspect_ratio=decrease fits the frame inside the
      // target, and pad centres it. Scaling to the target outright is the
      // one-character difference that stretches every face in the video.
      steps
        ..add(
          'scale=${size.width}:${size.height}:'
          'force_original_aspect_ratio=decrease',
        )
        ..add(
          'pad=${size.width}:${size.height}:'
          '(ow-iw)/2:(oh-ih)/2:color=black',
        )
        ..add('setsar=1');
    }

    for (final overlay in clip.overlays) {
      steps.add(_drawText(overlay, clip.speed));
    }

    return '[$index:v]${steps.join(',')}[v$index]';
  }

  static String _audioChain(EditClip clip, int index) {
    final steps = <String>[
      'atrim=start=${_seconds(clip.sourceStart)}:'
          'end=${_seconds(clip.sourceEnd)}',
      'asetpts=PTS-STARTPTS',
    ];

    for (final factor in _atempoChain(clip.speed)) {
      steps.add('atempo=${_number(factor)}');
    }

    // A muted clip keeps its (silent) stream. Dropping it would leave the
    // concat with fewer audio inputs than video ones, and FFmpeg then
    // pairs the wrong streams together — every later clip plays the
    // previous clip's sound.
    if (clip.volume != 1) {
      steps.add('volume=${_number(clip.volume)}');
    }

    // Normalizing the layout costs nothing and stops concat from refusing
    // a timeline that mixes a mono phone recording with a stereo export.
    steps.add(
        'aformat=sample_fmts=fltp:sample_rates=48000:channel_layouts=stereo');

    return '[$index:a]${steps.join(',')}[a$index]';
  }

  /// Decomposes [speed] into factors `atempo` accepts.
  ///
  /// `atempo` is documented for 0.5–2.0 and silently misbehaves outside
  /// it, so 4x becomes 2.0 × 2.0 and 0.25x becomes 0.5 × 0.5. Without
  /// this the video speeds up and the audio does not — the kind of defect
  /// that only shows up on export, with no error anywhere.
  static List<double> atempoChain(double speed) => _atempoChain(speed);

  static List<double> _atempoChain(double speed) {
    if (speed == 1) return const [];
    final factors = <double>[];
    var remaining = speed;
    while (remaining > 2) {
      factors.add(2);
      remaining /= 2;
    }
    while (remaining < 0.5) {
      factors.add(0.5);
      remaining /= 0.5;
    }
    factors.add(remaining);
    return factors;
  }

  static String _drawText(TextOverlay overlay, double speed) {
    final y = switch (overlay.anchor) {
      TextAnchor.top => 'h*0.08',
      TextAnchor.center => '(h-text_h)/2',
      TextAnchor.bottom => 'h*0.92-text_h',
    };
    // The overlay window is authored in rendered time, but drawtext runs
    // before the speed change in this chain is observable to it, so the
    // window is converted back to source time.
    final start = overlay.start.inMicroseconds * speed / 1000000;
    final end = overlay.end.inMicroseconds * speed / 1000000;
    return 'drawtext='
        "text='${_escapeDrawText(overlay.text)}'"
        ':fontsize=${overlay.fontSizePx}'
        ':fontcolor=white'
        ':borderw=3:bordercolor=black@0.7'
        ':x=(w-text_w)/2'
        ':y=$y'
        ":enable='between(t,${_number(start)},${_number(end)})'";
  }

  /// Escapes [text] for a `drawtext` filter argument.
  ///
  /// Public because this is a safety boundary, not a formatting detail: a
  /// title containing a quote would otherwise end the argument early and
  /// let the rest of the string be read as further filter options.
  /// Backslash goes first — escaping it after the others would escape the
  /// escapes.
  static String escapeDrawText(String text) => _escapeDrawText(text);

  static String _escapeDrawText(String text) => text
      .replaceAll(r'\', r'\\')
      .replaceAll("'", r"\'")
      .replaceAll(':', r'\:')
      .replaceAll('%', r'\%')
      .replaceAll('\n', ' ');

  static String _seconds(Duration value) =>
      (value.inMicroseconds / 1000000).toStringAsFixed(3);

  /// Formats a multiplier without a trailing `.0`, which FFmpeg accepts
  /// but makes every expected string in a test harder to read.
  static String _number(double value) {
    final text = value.toStringAsFixed(4);
    return text.contains('.')
        ? text.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '')
        : text;
  }
}
