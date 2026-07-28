/// A media item as understood after analysis: origin metadata plus the
/// eligibility decision that authorizes (or refuses) its download.
///
/// Responsibility: be the single object the Analyze result card renders
/// from (section 7.2 item 4) and the input to enqueueing a download.
library;

import '../../../core/domain/value_objects/media_url.dart';
import 'eligibility_result.dart';

/// Analyzed media: origin metadata plus its eligibility decision.
final class MediaItem {
  /// Builds an analyzed item; [id] and [title] must be non-blank.
  MediaItem({
    required this.id,
    required this.url,
    required this.title,
    required this.eligibility,
    this.author,
    this.platform,
    this.thumbnailUrl,
    this.duration,
  }) {
    if (id.trim().isEmpty) throw ArgumentError('id must not be empty');
    if (title.trim().isEmpty) throw ArgumentError('title must not be empty');
  }

  /// Stable identifier assigned by the backend analysis (also the cache key).
  final String id;

  /// Origin URL as validated on the client.
  final MediaUrl url;

  /// Display title from the origin platform.
  final String title;

  /// Channel/author display name when the origin reports one.
  final String? author;

  /// Origin platform slug (e.g. "archive_org", "podcast_rss").
  final String? platform;

  /// Thumbnail image URL, when the origin provides one.
  final String? thumbnailUrl;

  /// Media duration when known (audio/video).
  final Duration? duration;

  /// The authorization decision. A [MediaItem] always carries one — an
  /// unanalyzed URL is not a MediaItem yet.
  final EligibilityResult eligibility;

  /// Convenience flag for the enqueue flow.
  bool get isDownloadable => eligibility.eligible;

  @override
  bool operator ==(Object other) => other is MediaItem && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'MediaItem($id, "$title", eligible=${eligibility.eligible})';
}
