/// Duplicate detection (section 15).
///
/// Responsibility: find library items that are the same media, and hand
/// the groups to a review screen. It never deletes anything — section 15
/// is explicit that a review step comes before any deletion, and this
/// class has no way to remove a file even if asked.
///
/// Two kinds of duplicate are detected from metadata alone:
///
/// * **exact** — same size and same normalized title: the same file
///   downloaded twice.
/// * **sameMedia** — same normalized title and near-identical duration,
///   different size: the same content at two qualities.
///
/// A true perceptual hash would need to decode the media; that belongs
/// with the platform codec work, not here. Duration plus title catches
/// the case users actually hit — "baixei de novo em 1080p" — without
/// reading a single byte.
library;

import '../../../core/domain/value_objects/file_size.dart';
import '../../library/domain/library_entry.dart';

/// Why a group was flagged.
enum DuplicateKind {
  /// Byte-for-byte the same file, as far as metadata can tell.
  exact,

  /// Same content, different rendition.
  sameMedia,
}

/// A set of entries believed to be the same media.
final class DuplicateGroup {
  /// Creates a group.
  DuplicateGroup({required this.kind, required List<LibraryEntry> entries})
      : entries = List.unmodifiable(entries) {
    if (entries.length < 2) {
      throw ArgumentError('a duplicate group needs at least two entries');
    }
  }

  /// What made these look alike.
  final DuplicateKind kind;

  /// The entries, largest first — the one most likely worth keeping.
  final List<LibraryEntry> entries;

  /// The entry suggested for keeping (largest file).
  LibraryEntry get suggestedKeep => entries.first;

  /// The entries suggested for removal — a suggestion only.
  List<LibraryEntry> get suggestedRemove => entries.sublist(1);

  /// Space that removing the suggestions would free.
  FileSize get reclaimableSpace => suggestedRemove.fold(
        FileSize.zero,
        (total, entry) => total + entry.size,
      );
}

/// Finds duplicate groups in a library.
abstract final class DuplicateDetector {
  /// Durations within this of each other count as the same media —
  /// different encoders disagree by a frame or two.
  static const Duration durationTolerance = Duration(seconds: 2);

  /// Groups duplicates found among [entries].
  ///
  /// Trashed and missing entries are skipped: there is nothing to reclaim
  /// from a file that is already gone.
  static List<DuplicateGroup> findDuplicates(List<LibraryEntry> entries) {
    final candidates = entries
        .where((entry) => entry.status == LibraryFileStatus.available)
        .toList();

    final byTitle = <String, List<LibraryEntry>>{};
    for (final entry in candidates) {
      (byTitle[normalizeForComparison(entry.title)] ??= []).add(entry);
    }

    final groups = <DuplicateGroup>[];
    for (final sameTitle in byTitle.values) {
      if (sameTitle.length < 2) continue;
      groups.addAll(_groupBySize(sameTitle));
      groups.addAll(_groupByDuration(sameTitle));
    }
    return groups;
  }

  /// Same title and same byte count: the same file twice.
  static List<DuplicateGroup> _groupBySize(List<LibraryEntry> entries) {
    final bySize = <int, List<LibraryEntry>>{};
    for (final entry in entries) {
      (bySize[entry.size.bytes] ??= []).add(entry);
    }
    return [
      for (final group in bySize.values)
        if (group.length >= 2)
          DuplicateGroup(
              kind: DuplicateKind.exact, entries: _largestFirst(group)),
    ];
  }

  /// Same title and near-identical duration, but different sizes: the
  /// same content at different qualities.
  static List<DuplicateGroup> _groupByDuration(List<LibraryEntry> entries) {
    final withDuration =
        entries.where((entry) => entry.duration != null).toList();
    final groups = <DuplicateGroup>[];
    final consumed = <String>{};

    for (final entry in withDuration) {
      if (consumed.contains(entry.id)) continue;
      final cluster = withDuration.where((other) {
        if (consumed.contains(other.id)) return false;
        final delta = (other.duration! - entry.duration!).abs();
        return delta <= durationTolerance;
      }).toList();

      // Entries of identical size are already reported as `exact`.
      final distinctSizes = cluster.map((e) => e.size.bytes).toSet();
      if (cluster.length < 2 || distinctSizes.length < 2) continue;

      for (final member in cluster) {
        consumed.add(member.id);
      }
      groups.add(
        DuplicateGroup(
          kind: DuplicateKind.sameMedia,
          entries: _largestFirst(cluster),
        ),
      );
    }
    return groups;
  }

  static List<LibraryEntry> _largestFirst(List<LibraryEntry> entries) =>
      [...entries]..sort((a, b) => b.size.compareTo(a.size));

  /// Normalizes a title for comparison: lowercase, no accents, no
  /// punctuation, collapsed whitespace.
  static String normalizeForComparison(String title) {
    const accented = 'áàâãäéèêëíìîïóòôõöúùûüçñ';
    const plain = 'aaaaaeeeeiiiiooooouuuucn';
    final buffer = StringBuffer();
    for (final rune in title.toLowerCase().runes) {
      final char = String.fromCharCode(rune);
      final index = accented.indexOf(char);
      buffer.write(index == -1 ? char : plain[index]);
    }
    return buffer
        .toString()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
