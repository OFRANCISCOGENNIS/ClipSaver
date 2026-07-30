/// Series and episode detection (section 15: "série detectada — padrões
/// 'Ep. 12', 'Parte 3'").
///
/// Responsibility: recognize that several library items belong to one
/// series so they can be grouped, without asking the user to tag them by
/// hand.
library;

/// One recognized episode marker.
final class SeriesMarker {
  /// Creates a marker.
  const SeriesMarker({
    required this.seriesName,
    required this.episode,
    this.season,
  });

  /// Title with the episode marker stripped, used as the group key.
  final String seriesName;

  /// Episode number.
  final int episode;

  /// Season number, when the title carries one.
  final int? season;

  /// Stable key for grouping, case- and accent-insensitive enough for
  /// titles that differ only in capitalization.
  String get groupKey => seriesName.toLowerCase();

  @override
  bool operator ==(Object other) =>
      other is SeriesMarker &&
      other.seriesName == seriesName &&
      other.episode == episode &&
      other.season == season;

  @override
  int get hashCode => Object.hash(seriesName, episode, season);

  @override
  String toString() => 'SeriesMarker($seriesName, s=$season, e=$episode)';
}

/// Finds episode markers in titles.
abstract final class SeriesDetector {
  /// `S01E02` / `s1e2`, the most explicit form, so it is tried first.
  static final RegExp _seasonEpisode =
      RegExp(r'\bs\s*(\d{1,2})\s*e\s*(\d{1,3})\b', caseSensitive: false);

  /// `Ep. 12`, `Episódio 12`, `Episode 12`, `Cap. 4`, `Capítulo 4`.
  static final RegExp _episodeWord = RegExp(
    r'\b(?:ep|epis[óo]dio|episode|cap|cap[íi]tulo|chapter)\.?\s*#?\s*(\d{1,4})\b',
    caseSensitive: false,
  );

  /// `Parte 3`, `Part 3`, `Pt. 3`.
  static final RegExp _partWord = RegExp(
    r'\b(?:parte|part|pt)\.?\s*(\d{1,3})\b',
    caseSensitive: false,
  );

  /// `#12` used as a numbering suffix.
  static final RegExp _hashNumber = RegExp(r'#\s*(\d{1,4})\b');

  /// Detects an episode marker in [title], or null when there is none.
  static SeriesMarker? detect(String title) {
    for (final pattern in [
      _seasonEpisode,
      _episodeWord,
      _partWord,
      _hashNumber
    ]) {
      final match = pattern.firstMatch(title);
      if (match == null) continue;

      final isSeasonEpisode = pattern == _seasonEpisode;
      final episode = int.parse(match.group(isSeasonEpisode ? 2 : 1)!);
      final season = isSeasonEpisode ? int.parse(match.group(1)!) : null;

      final name = _stripMarker(title, match.start, match.end);
      // A title that is *only* a marker gives us no series to group by.
      if (name.isEmpty) return null;

      return SeriesMarker(
        seriesName: name,
        episode: episode,
        season: season,
      );
    }
    return null;
  }

  /// Groups [titles] by detected series, dropping unmatched ones.
  ///
  /// A "series" needs at least two episodes — one lone `Ep. 1` is just a
  /// title, and grouping it alone would only add noise to the library.
  static Map<String, List<SeriesMarker>> groupBySeries(
    Iterable<String> titles,
  ) {
    final groups = <String, List<SeriesMarker>>{};
    for (final title in titles) {
      final marker = detect(title);
      if (marker == null) continue;
      (groups[marker.groupKey] ??= []).add(marker);
    }
    groups.removeWhere((_, markers) => markers.length < 2);
    for (final markers in groups.values) {
      markers.sort((a, b) {
        final bySeason = (a.season ?? 0).compareTo(b.season ?? 0);
        return bySeason != 0 ? bySeason : a.episode.compareTo(b.episode);
      });
    }
    return groups;
  }

  /// Removes the marker and the separators left behind around it.
  static String _stripMarker(String title, int start, int end) {
    final remainder = title.substring(0, start) + title.substring(end);
    return remainder
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'^[\s|·–—\-,.:]+'), '')
        .replaceAll(RegExp(r'[\s|·–—\-,.:]+$'), '')
        .trim();
  }
}
