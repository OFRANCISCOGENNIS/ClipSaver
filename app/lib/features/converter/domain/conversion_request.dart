/// What the user asked the converter to do (section 11).
///
/// Responsibility: describe a conversion completely and validate it at
/// construction, so an impossible request (negative CRF, trim that ends
/// before it starts, video settings on an audio target) can never reach
/// FFmpeg.
library;

import 'conversion_job.dart';

/// Ready-made conversions offered on the main screen (section 11).
enum ConversionPreset {
  /// "Compatibilidade máxima": MP4 with H.264 video and AAC audio.
  maxCompatibility(ConversionTarget.mp4),

  /// "Menor tamanho": MP4 with H.265, roughly half the bitrate.
  smallestSize(ConversionTarget.mp4),

  /// "Áudio para podcast": MP3 at 128 kbps.
  podcastAudio(ConversionTarget.mp3),

  /// "Sem perdas": FLAC.
  lossless(ConversionTarget.flac);

  const ConversionPreset(this.target);

  /// Container the preset produces.
  final ConversionTarget target;

  /// Concrete settings for this preset.
  ///
  /// The enum constants are qualified on purpose: a bare identifier in a
  /// pattern is a *variable* pattern, which would bind and match the very
  /// first case for every preset.
  ConversionRequest toRequest() => switch (this) {
        ConversionPreset.maxCompatibility => const ConversionRequest(
            target: ConversionTarget.mp4,
            videoCodec: VideoCodec.h264,
            audioCodec: AudioCodec.aac,
            crf: 23,
          ),
        ConversionPreset.smallestSize => const ConversionRequest(
            target: ConversionTarget.mp4,
            videoCodec: VideoCodec.h265,
            audioCodec: AudioCodec.aac,
            crf: 28,
          ),
        ConversionPreset.podcastAudio => const ConversionRequest(
            target: ConversionTarget.mp3,
            audioCodec: AudioCodec.mp3,
            audioBitrateKbps: 128,
          ),
        ConversionPreset.lossless => const ConversionRequest(
            target: ConversionTarget.flac,
            audioCodec: AudioCodec.flac,
          ),
      };
}

/// Video codecs the converter can emit.
enum VideoCodec {
  /// H.264 — widest device support.
  h264('libx264'),

  /// H.265/HEVC — smaller files, less universal.
  h265('libx265'),

  /// VP9, for WebM.
  vp9('libvpx-vp9'),

  /// Stream copy: remux without re-encoding.
  copy('copy');

  const VideoCodec(this.ffmpegName);

  /// Value passed to `-c:v`.
  final String ffmpegName;
}

/// Audio codecs the converter can emit.
enum AudioCodec {
  /// AAC.
  aac('aac'),

  /// MP3.
  mp3('libmp3lame'),

  /// Opus.
  opus('libopus'),

  /// Vorbis, for Ogg.
  vorbis('libvorbis'),

  /// FLAC, lossless.
  flac('flac'),

  /// Uncompressed PCM, for WAV.
  pcm('pcm_s16le'),

  /// Stream copy.
  copy('copy');

  const AudioCodec(this.ffmpegName);

  /// Value passed to `-c:a`.
  final String ffmpegName;
}

/// A time span to cut out of the source (section 11: corte por timestamps).
final class TrimRange {
  /// Creates the range; [start] must precede [end].
  TrimRange({required this.start, required this.end}) {
    if (start.isNegative || end.isNegative) {
      throw ArgumentError('trim bounds must not be negative');
    }
    if (end <= start) {
      throw ArgumentError('trim end must come after start');
    }
  }

  /// Where the output begins.
  final Duration start;

  /// Where the output ends.
  final Duration end;

  /// Length of the output.
  Duration get duration => end - start;

  @override
  bool operator ==(Object other) =>
      other is TrimRange && other.start == start && other.end == end;

  @override
  int get hashCode => Object.hash(start, end);
}

/// A fully specified conversion.
final class ConversionRequest {
  /// Creates a request, validating the advanced settings.
  const ConversionRequest({
    required this.target,
    this.videoCodec,
    this.audioCodec,
    this.crf,
    this.audioBitrateKbps,
    this.sampleRateHz,
    this.channels,
    this.heightPx,
    this.trim,
    this.keepOriginal = true,
  })  : assert(
          crf == null || (crf >= 0 && crf <= 51),
          'CRF must be within 0..51',
        ),
        assert(
          audioBitrateKbps == null ||
              (audioBitrateKbps >= 8 && audioBitrateKbps <= 512),
          'audio bitrate must be within 8..512 kbps',
        ),
        assert(
          channels == null || channels == 1 || channels == 2,
          'only mono and stereo are offered',
        ),
        assert(
          heightPx == null || heightPx > 0,
          'output height must be positive',
        ),
        assert(
          sampleRateHz == null || sampleRateHz > 0,
          'sample rate must be positive',
        );

  /// Output container.
  final ConversionTarget target;

  /// Video codec; null lets the builder pick the container's default.
  final VideoCodec? videoCodec;

  /// Audio codec; null lets the builder pick the container's default.
  final AudioCodec? audioCodec;

  /// Constant Rate Factor for video (lower is better quality).
  final int? crf;

  /// Audio bitrate in kbps.
  final int? audioBitrateKbps;

  /// Output sample rate.
  final int? sampleRateHz;

  /// 1 for mono, 2 for stereo.
  final int? channels;

  /// Output height in pixels; width follows the source aspect ratio.
  final int? heightPx;

  /// Optional cut.
  final TrimRange? trim;

  /// Section 11: the original is preserved unless the user opts out.
  final bool keepOriginal;

  /// Whether this request only cuts the file, changing nothing else.
  ///
  /// A pure trim can be done with `-c copy`, which is orders of magnitude
  /// faster and lossless — the builder relies on this.
  bool get isLosslessTrim =>
      trim != null &&
      crf == null &&
      audioBitrateKbps == null &&
      sampleRateHz == null &&
      channels == null &&
      heightPx == null &&
      (videoCodec == null || videoCodec == VideoCodec.copy) &&
      (audioCodec == null || audioCodec == AudioCodec.copy);
}
