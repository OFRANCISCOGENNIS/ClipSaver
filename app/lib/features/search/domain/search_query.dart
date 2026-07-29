/// The search request: free text plus the combinable filters of
/// section 10.
///
/// Responsibility: be an immutable, comparable description of what the
/// user asked for, so the UI can render it as removable chips and the
/// repository can translate it to SQL without re-deriving intent.
library;

import '../../../core/domain/value_objects/file_size.dart';
import '../../../core/domain/value_objects/media_format.dart';

/// Duration buckets offered as filters (section 10).
enum DurationBucket {
  /// Under five minutes.
  short('< 5 min', null, Duration(minutes: 5)),

  /// Between five and twenty minutes.
  medium('5–20 min', Duration(minutes: 5), Duration(minutes: 20)),

  /// Over twenty minutes.
  long('> 20 min', Duration(minutes: 20), null);

  const DurationBucket(this.label, this.min, this.max);

  /// Chip text.
  final String label;

  /// Inclusive lower bound, or null for open-ended.
  final Duration? min;

  /// Exclusive upper bound, or null for open-ended.
  final Duration? max;

  /// Whether [duration] falls in this bucket. Unknown durations never do.
  bool contains(Duration? duration) {
    if (duration == null) return false;
    if (min != null && duration < min!) return false;
    if (max != null && duration >= max!) return false;
    return true;
  }
}

/// A closed date interval.
final class DateRange {
  /// Creates the range; [from] must not be after [to].
  DateRange({required this.from, required this.to}) {
    if (from.isAfter(to)) {
      throw ArgumentError('from must not be after to');
    }
  }

  /// Inclusive start.
  final DateTime from;

  /// Inclusive end.
  final DateTime to;

  /// Whether [moment] falls inside the range.
  bool contains(DateTime moment) =>
      !moment.isBefore(from) && !moment.isAfter(to);

  @override
  bool operator ==(Object other) =>
      other is DateRange && other.from == from && other.to == to;

  @override
  int get hashCode => Object.hash(from, to);
}

/// A full search request.
final class SearchQuery {
  /// Creates a query.
  SearchQuery({
    this.text = '',
    this.kind,
    this.platform,
    this.durationBucket,
    this.dateRange,
    this.minSize,
    this.maxSize,
    Set<String> containers = const {},
    Set<String> tags = const {},
  })  : containers = Set.unmodifiable(containers),
        tags = Set.unmodifiable(tags);

  /// Free-text terms. Empty means "everything that matches the filters".
  final String text;

  /// Video or audio.
  final MediaKind? kind;

  /// Origin platform slug.
  final String? platform;

  /// Duration bucket.
  final DurationBucket? durationBucket;

  /// Download date interval.
  final DateRange? dateRange;

  /// Inclusive minimum file size.
  final FileSize? minSize;

  /// Inclusive maximum file size.
  final FileSize? maxSize;

  /// File containers (mp4, mp3…), lowercase without dot.
  final Set<String> containers;

  /// Tags that must all be present.
  final Set<String> tags;

  /// Whether anything at all was asked for.
  bool get isEmpty => text.trim().isEmpty && !hasFilters;

  /// Whether at least one filter is active (drives the chip row).
  bool get hasFilters =>
      kind != null ||
      platform != null ||
      durationBucket != null ||
      dateRange != null ||
      minSize != null ||
      maxSize != null ||
      containers.isNotEmpty ||
      tags.isNotEmpty;

  /// How many filter chips to render.
  int get activeFilterCount =>
      [
        kind,
        platform,
        durationBucket,
        dateRange,
        minSize,
        maxSize,
      ].where((filter) => filter != null).length +
      containers.length +
      tags.length;

  /// Copies the query, overriding fields. Pass the matching `clear*` flag
  /// to remove a filter — passing null alone cannot distinguish "unchanged"
  /// from "remove this".
  SearchQuery copyWith({
    String? text,
    MediaKind? kind,
    String? platform,
    DurationBucket? durationBucket,
    DateRange? dateRange,
    FileSize? minSize,
    FileSize? maxSize,
    Set<String>? containers,
    Set<String>? tags,
    bool clearKind = false,
    bool clearPlatform = false,
    bool clearDurationBucket = false,
    bool clearDateRange = false,
    bool clearSizes = false,
  }) =>
      SearchQuery(
        text: text ?? this.text,
        kind: clearKind ? null : (kind ?? this.kind),
        platform: clearPlatform ? null : (platform ?? this.platform),
        durationBucket: clearDurationBucket
            ? null
            : (durationBucket ?? this.durationBucket),
        dateRange: clearDateRange ? null : (dateRange ?? this.dateRange),
        minSize: clearSizes ? null : (minSize ?? this.minSize),
        maxSize: clearSizes ? null : (maxSize ?? this.maxSize),
        containers: containers ?? this.containers,
        tags: tags ?? this.tags,
      );

  @override
  bool operator ==(Object other) =>
      other is SearchQuery &&
      other.text == text &&
      other.kind == kind &&
      other.platform == platform &&
      other.durationBucket == durationBucket &&
      other.dateRange == dateRange &&
      other.minSize == minSize &&
      other.maxSize == maxSize &&
      _sameSet(other.containers, containers) &&
      _sameSet(other.tags, tags);

  @override
  int get hashCode => Object.hash(
        text,
        kind,
        platform,
        durationBucket,
        dateRange,
        minSize,
        maxSize,
        Object.hashAllUnordered(containers),
        Object.hashAllUnordered(tags),
      );

  static bool _sameSet(Set<String> a, Set<String> b) =>
      a.length == b.length && a.containsAll(b);
}
