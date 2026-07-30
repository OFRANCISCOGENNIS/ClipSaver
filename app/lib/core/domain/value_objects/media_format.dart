/// Value object describing one downloadable rendition of a media item
/// (container + codec + resolution/bitrate), as returned by the
/// Eligibility Engine's `availableFormats` (section 2.2).
///
/// Responsibility: carry only *real* formats reported by the origin —
/// the UI must never fabricate resolutions (section 7.2 item 4).
library;

import 'file_size.dart';

/// Whether a rendition carries video or audio only.
enum MediaKind {
  /// Rendition with a video track (possibly muxed with audio).
  video,

  /// Audio-only rendition.
  audio,
}

/// One real downloadable rendition reported by the origin.
final class MediaFormat {
  /// Creates a rendition descriptor; audio formats must not set [height].
  const MediaFormat({
    required this.id,
    required this.kind,
    required this.container,
    this.codec,
    this.height,
    this.bitrateKbps,
    this.estimatedSize,
    this.url,
  })  : assert(id != ''),
        assert(
          kind == MediaKind.video || height == null,
          'audio formats have no vertical resolution',
        );

  /// Origin-side identifier used when requesting this exact rendition.
  final String id;

  /// Video or audio.
  final MediaKind kind;

  /// Container/extension without dot, lowercase: mp4, webm, mp3, opus…
  final String container;

  /// Codec string when known (h264, vp9, aac…).
  final String? codec;

  /// Vertical resolution for video (144…2160). Null for audio.
  final int? height;

  /// Average bitrate when reported by the origin.
  final int? bitrateKbps;

  /// Size estimate for the quality chips (section 7.2 item 4).
  final FileSize? estimatedSize;

  /// Direct URL of this rendition, when the origin exposes a per-format
  /// address. Null for direct-file results, where the analyzed URL *is*
  /// the rendition.
  final String? url;

  /// Label for the resolution/quality chip: "1080p", "320 kbps" or the
  /// container as last resort.
  String get qualityLabel {
    if (height != null) return '${height}p';
    if (bitrateKbps != null) return '$bitrateKbps kbps';
    return container.toUpperCase();
  }

  @override
  bool operator ==(Object other) => other is MediaFormat && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'MediaFormat($id ${kind.name} $qualityLabel)';
}
