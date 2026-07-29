/// Builds FFmpeg argument lists (section 11).
///
/// Responsibility: turn a [ConversionRequest] into the exact argv FFmpeg
/// should receive. Pure and synchronous on purpose — this is where the
/// subtle decisions live (stream copy vs re-encode, seek placement, codec
/// defaults per container), and they deserve unit tests rather than being
/// buried in a process call.
library;

import '../domain/conversion_job.dart';
import '../domain/conversion_request.dart';

/// Assembles FFmpeg arguments.
abstract final class FfmpegCommandBuilder {
  /// Arguments for converting [sourcePath] into [outputPath].
  ///
  /// The list excludes the executable itself, so the caller can run it
  /// through a bundled binary, a platform channel or FFmpeg.wasm.
  static List<String> build({
    required String sourcePath,
    required String outputPath,
    required ConversionRequest request,
  }) {
    final args = <String>[
      // Never block waiting for a "file exists, overwrite?" prompt: the
      // caller writes to a temporary path it already owns.
      '-y',
      // Only surface real problems; FFmpeg's default banner is noise.
      '-hide_banner',
      '-loglevel', 'error',
      // Machine-readable progress on stdout, which the queue parses into
      // the percentage shown per item.
      '-progress', 'pipe:1',
      '-nostats',
    ];

    final trim = request.trim;
    if (trim != null) {
      // `-ss` before `-i` seeks by keyframe index instead of decoding the
      // whole file — the difference between instant and minutes on a long
      // video. It is exact enough because the trim is also re-clamped by
      // `-t` below.
      args.addAll(['-ss', _timestamp(trim.start)]);
    }

    args.addAll(['-i', sourcePath]);

    if (trim != null) {
      args.addAll(['-t', _timestamp(trim.duration)]);
    }

    if (request.isLosslessTrim) {
      // Cutting without touching the streams: no quality loss, no CPU.
      args.addAll(['-c', 'copy']);
      args.add(outputPath);
      return args;
    }

    if (request.target.isAudioOnly) {
      // Extracting audio: drop the video stream entirely, keep metadata
      // (section 11 requires preserving it).
      args.addAll(['-vn', '-map_metadata', '0']);
      args.addAll(_audioArgs(request));
    } else {
      args.addAll(_videoArgs(request));
      args.addAll(_audioArgs(request));
    }

    args.add(outputPath);
    return args;
  }

  static List<String> _videoArgs(ConversionRequest request) {
    final codec = request.videoCodec ?? _defaultVideoCodec(request.target);
    final args = <String>['-c:v', codec.ffmpegName];
    if (codec != VideoCodec.copy) {
      if (request.crf != null) {
        args.addAll(['-crf', '${request.crf}']);
      }
      if (request.heightPx != null) {
        // -2 keeps the aspect ratio and rounds the width to an even
        // number, which H.264/H.265 require.
        args.addAll(['-vf', 'scale=-2:${request.heightPx}']);
      }
    }
    return args;
  }

  static List<String> _audioArgs(ConversionRequest request) {
    final codec = request.audioCodec ?? _defaultAudioCodec(request.target);
    final args = <String>['-c:a', codec.ffmpegName];
    if (codec == AudioCodec.copy) return args;

    // Lossless codecs have no bitrate knob; passing one is an error.
    final lossless = codec == AudioCodec.flac || codec == AudioCodec.pcm;
    if (request.audioBitrateKbps != null && !lossless) {
      args.addAll(['-b:a', '${request.audioBitrateKbps}k']);
    }
    if (request.sampleRateHz != null) {
      args.addAll(['-ar', '${request.sampleRateHz}']);
    }
    if (request.channels != null) {
      args.addAll(['-ac', '${request.channels}']);
    }
    return args;
  }

  static VideoCodec _defaultVideoCodec(ConversionTarget target) =>
      switch (target) {
        ConversionTarget.webm => VideoCodec.vp9,
        ConversionTarget.mkv => VideoCodec.copy,
        _ => VideoCodec.h264,
      };

  static AudioCodec _defaultAudioCodec(ConversionTarget target) =>
      switch (target) {
        ConversionTarget.mp3 => AudioCodec.mp3,
        ConversionTarget.aac || ConversionTarget.mp4 => AudioCodec.aac,
        ConversionTarget.wav => AudioCodec.pcm,
        ConversionTarget.flac => AudioCodec.flac,
        ConversionTarget.ogg => AudioCodec.vorbis,
        ConversionTarget.opus || ConversionTarget.webm => AudioCodec.opus,
        ConversionTarget.mkv => AudioCodec.copy,
      };

  /// `HH:MM:SS.mmm`, the format FFmpeg accepts for seeks and durations.
  static String _timestamp(Duration value) {
    final hours = value.inHours.toString().padLeft(2, '0');
    final minutes = value.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = value.inSeconds.remainder(60).toString().padLeft(2, '0');
    final millis =
        value.inMilliseconds.remainder(1000).toString().padLeft(3, '0');
    return '$hours:$minutes:$seconds.$millis';
  }
}

/// Parses FFmpeg's `-progress` output into a fraction of [totalDuration].
///
/// FFmpeg emits `out_time_us=…` (microseconds of media processed) among
/// other keys; everything else is ignored.
double? parseFfmpegProgress(String line, Duration totalDuration) {
  if (totalDuration <= Duration.zero) return null;
  final match = RegExp(r'^out_time_(us|ms)=(-?\d+)$').firstMatch(line.trim());
  if (match == null) return null;
  final value = int.parse(match.group(2)!);
  if (value < 0) return null;
  final processed = match.group(1) == 'us'
      ? Duration(microseconds: value)
      : Duration(milliseconds: value);
  final fraction = processed.inMicroseconds / totalDuration.inMicroseconds;
  return fraction.clamp(0.0, 1.0);
}
