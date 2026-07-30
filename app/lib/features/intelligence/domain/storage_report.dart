/// Storage optimization report (section 15).
///
/// Responsibility: show where the space went and *suggest* what could go.
/// Section 15 is unambiguous: nothing is deleted automatically, every
/// suggestion needs confirmation. This class therefore produces a
/// read-only report and has no capacity to remove anything.
library;

import '../../../core/domain/value_objects/file_size.dart';
import '../../../core/domain/value_objects/media_format.dart';
import '../../library/domain/library_entry.dart';
import 'duplicate_detector.dart';

/// Why the report suggests looking at a set of items.
enum StorageSuggestionKind {
  /// The same file more than once.
  duplicates,

  /// Downloaded long ago and never played.
  neverPlayed,

  /// Large files in a container that would shrink noticeably.
  convertible,
}

/// One actionable suggestion.
final class StorageSuggestion {
  /// Creates a suggestion.
  StorageSuggestion({
    required this.kind,
    required this.title,
    required this.detail,
    required List<LibraryEntry> entries,
    required this.reclaimableSpace,
  }) : entries = List.unmodifiable(entries);

  /// What kind of suggestion this is.
  final StorageSuggestionKind kind;

  /// Short headline for the card.
  final String title;

  /// Explanation shown under the headline.
  final String detail;

  /// The items involved — always shown before anything is confirmed.
  final List<LibraryEntry> entries;

  /// How much space acting on this would free.
  final FileSize reclaimableSpace;
}

/// A full storage report.
final class StorageReport {
  /// Creates a report.
  StorageReport({
    required this.totalSize,
    required this.videoSize,
    required this.audioSize,
    required this.trashSize,
    required List<StorageSuggestion> suggestions,
  }) : suggestions = List.unmodifiable(suggestions);

  /// Everything the library holds, excluding the trash.
  final FileSize totalSize;

  /// Space taken by video.
  final FileSize videoSize;

  /// Space taken by audio.
  final FileSize audioSize;

  /// Space still held by trashed items awaiting purge.
  final FileSize trashSize;

  /// Suggestions, largest saving first.
  final List<StorageSuggestion> suggestions;

  /// Total space all suggestions could free together.
  ///
  /// Suggestions can overlap (a duplicate may also be unplayed), so this
  /// counts each entry once — promising the sum would overstate it.
  FileSize get totalReclaimable {
    final counted = <String, int>{};
    for (final suggestion in suggestions) {
      final keep = suggestion.kind == StorageSuggestionKind.duplicates
          ? suggestion.entries.first.id
          : null;
      for (final entry in suggestion.entries) {
        if (entry.id == keep) continue;
        counted[entry.id] = entry.size.bytes;
      }
    }
    return FileSize.ofBytes(
      counted.values.fold(0, (total, bytes) => total + bytes),
    );
  }
}

/// Builds storage reports from a library snapshot.
abstract final class StorageReportBuilder {
  /// How long an item must sit unplayed before it is suggested
  /// (section 15: "nunca reproduzidos há 90+ dias").
  static const Duration unplayedThreshold = Duration(days: 90);

  /// Files this large in a dated container are worth re-encoding.
  static final FileSize convertibleThreshold =
      FileSize.ofBytes(300 * 1024 * 1024);

  /// Containers that reliably shrink when re-encoded to H.265.
  static const Set<String> _datedContainers = {
    'avi',
    'wmv',
    'mpg',
    'mpeg',
    'mov'
  };

  /// Builds the report for [entries] as of [now].
  static StorageReport build(List<LibraryEntry> entries, DateTime now) {
    final live = entries
        .where((entry) => entry.status != LibraryFileStatus.trashed)
        .toList();
    final trashed = entries
        .where((entry) => entry.status == LibraryFileStatus.trashed)
        .toList();

    FileSize sum(Iterable<LibraryEntry> items) => items.fold(
          FileSize.zero,
          (total, entry) => total + entry.size,
        );

    final suggestions = <StorageSuggestion>[
      ..._duplicateSuggestions(live),
      ..._neverPlayedSuggestions(live, now),
      ..._convertibleSuggestions(live),
    ]..sort(
        (a, b) => b.reclaimableSpace.compareTo(a.reclaimableSpace),
      );

    return StorageReport(
      totalSize: sum(live),
      videoSize: sum(live.where((entry) => entry.kind == MediaKind.video)),
      audioSize: sum(live.where((entry) => entry.kind == MediaKind.audio)),
      trashSize: sum(trashed),
      suggestions: suggestions,
    );
  }

  static List<StorageSuggestion> _duplicateSuggestions(
    List<LibraryEntry> entries,
  ) {
    final groups = DuplicateDetector.findDuplicates(entries);
    if (groups.isEmpty) return const [];
    final reclaimable = groups.fold(
      FileSize.zero,
      (total, group) => total + group.reclaimableSpace,
    );
    return [
      StorageSuggestion(
        kind: StorageSuggestionKind.duplicates,
        title: '${groups.length} grupo(s) de duplicados',
        detail: 'Revise antes de excluir — nada é removido automaticamente.',
        entries: [for (final group in groups) ...group.entries],
        reclaimableSpace: reclaimable,
      ),
    ];
  }

  static List<StorageSuggestion> _neverPlayedSuggestions(
    List<LibraryEntry> entries,
    DateTime now,
  ) {
    final stale = entries.where((entry) {
      if (entry.lastPlayedAt != null) return false;
      return now.difference(entry.downloadedAt) >= unplayedThreshold;
    }).toList();
    if (stale.isEmpty) return const [];

    return [
      StorageSuggestion(
        kind: StorageSuggestionKind.neverPlayed,
        title: '${stale.length} item(ns) nunca reproduzido(s)',
        detail: 'Baixados há mais de ${unplayedThreshold.inDays} dias e '
            'ainda não abertos.',
        entries: stale,
        reclaimableSpace: stale.fold(
          FileSize.zero,
          (total, entry) => total + entry.size,
        ),
      ),
    ];
  }

  static List<StorageSuggestion> _convertibleSuggestions(
    List<LibraryEntry> entries,
  ) {
    final candidates = entries.where((entry) {
      if (entry.size.compareTo(convertibleThreshold) < 0) return false;
      final extension = entry.filePath.split('.').last.toLowerCase();
      return _datedContainers.contains(extension);
    }).toList();
    if (candidates.isEmpty) return const [];

    // Re-encoding to H.265 typically halves these; the estimate is
    // deliberately conservative so the report never oversells.
    final estimate = FileSize.ofBytes(
      candidates.fold(0, (total, entry) => total + entry.size.bytes) ~/ 3,
    );
    return [
      StorageSuggestion(
        kind: StorageSuggestionKind.convertible,
        title: '${candidates.length} arquivo(s) em formato antigo',
        detail: 'Converter para H.265 costuma reduzir bastante o tamanho.',
        entries: candidates,
        reclaimableSpace: estimate,
      ),
    ];
  }
}
