/// Automatic media classification (section 15: "classificação de mídia por
/// tipo de conteúdo — música, podcast, aula, tutorial").
///
/// Responsibility: put every library item in a content category so the
/// library can organize itself.
///
/// Section 15 names an on-device TFLite model. This ships the metadata
/// heuristic behind a port instead: it is explainable, needs no model
/// download, and — being local — satisfies the "IA local primeiro"
/// principle on day one. A learned classifier can replace the
/// implementation without touching a caller.
library;

import '../../../core/domain/value_objects/media_format.dart';

/// Content categories offered by auto-organization.
enum ContentCategory {
  /// Songs and albums.
  music('Música'),

  /// Episodic spoken audio.
  podcast('Podcast'),

  /// Lectures and classes.
  lecture('Aula'),

  /// How-to content.
  tutorial('Tutorial'),

  /// Nothing matched confidently.
  unknown('Sem categoria');

  const ContentCategory(this.label);

  /// User-facing name.
  final String label;
}

/// Everything the classifier is allowed to look at.
final class ClassificationInput {
  /// Creates the input.
  const ClassificationInput({
    required this.title,
    required this.kind,
    this.author,
    this.platform,
    this.duration,
    this.tags = const [],
  });

  /// Media title.
  final String title;

  /// Audio or video.
  final MediaKind kind;

  /// Author/channel.
  final String? author;

  /// Origin platform slug.
  final String? platform;

  /// Media duration.
  final Duration? duration;

  /// User tags.
  final List<String> tags;
}

/// A category with the confidence behind it.
final class Classification {
  /// Creates a classification.
  const Classification({required this.category, required this.confidence});

  /// The chosen category.
  final ContentCategory category;

  /// 0..1. Below [minimumConfidence] the UI should ask rather than file
  /// the item away silently.
  final double confidence;

  /// Confidence floor for acting without asking the user.
  static const double minimumConfidence = 0.6;

  /// Whether the result is strong enough to apply without asking.
  bool get isConfident => confidence >= minimumConfidence;
}

/// Classifies media into [ContentCategory].
abstract interface class MediaClassifier {
  /// Classifies one item.
  Classification classify(ClassificationInput input);
}

/// Keyword- and duration-based classifier.
final class HeuristicMediaClassifier implements MediaClassifier {
  /// Creates the classifier.
  const HeuristicMediaClassifier();

  static const Map<ContentCategory, List<String>> _keywords = {
    ContentCategory.music: [
      'música',
      'musica',
      'song',
      'álbum',
      'album',
      'clipe',
      'cover',
      'acústico',
      'acustico',
      'ao vivo',
      'live session',
      'remix',
      'feat',
    ],
    ContentCategory.podcast: [
      'podcast',
      'episódio',
      'episodio',
      'episode',
      'entrevista',
      'interview',
      'bate-papo',
      'talk',
    ],
    ContentCategory.lecture: [
      'aula',
      'lecture',
      'palestra',
      'curso',
      'course',
      'seminário',
      'seminario',
      'webinar',
      'disciplina',
      'professor',
    ],
    ContentCategory.tutorial: [
      'tutorial',
      'como fazer',
      'how to',
      'howto',
      'passo a passo',
      'guia',
      'guide',
      'aprenda',
      'learn',
      'diy',
    ],
  };

  @override
  Classification classify(ClassificationInput input) {
    final haystack = [
      input.title,
      input.author ?? '',
      ...input.tags,
    ].join(' ').toLowerCase();

    final scores = <ContentCategory, double>{};
    for (final entry in _keywords.entries) {
      var score = 0.0;
      for (final keyword in entry.value) {
        if (haystack.contains(keyword)) score += 0.45;
      }
      if (score > 0) scores[entry.key] = score;
    }

    _applyDurationPriors(input, scores);

    // A podcast RSS feed is authoritative about its own content type.
    if (input.platform == 'podcast_rss') {
      scores[ContentCategory.podcast] =
          (scores[ContentCategory.podcast] ?? 0) + 0.7;
    }

    if (scores.isEmpty) {
      return const Classification(
        category: ContentCategory.unknown,
        confidence: 0,
      );
    }

    final best = scores.entries.reduce((a, b) => a.value >= b.value ? a : b);
    // Competing evidence should lower confidence, not be ignored: a title
    // matching two categories is genuinely ambiguous.
    final total = scores.values.reduce((a, b) => a + b);
    final margin = best.value / total;
    final confidence = (best.value.clamp(0.0, 1.0) * margin).clamp(0.0, 1.0);

    return Classification(category: best.key, confidence: confidence);
  }

  /// Duration says a lot on its own: a three-minute audio track is almost
  /// certainly music; an hour of speech is not.
  void _applyDurationPriors(
    ClassificationInput input,
    Map<ContentCategory, double> scores,
  ) {
    final duration = input.duration;
    if (duration == null) return;

    if (input.kind == MediaKind.audio) {
      if (duration < const Duration(minutes: 8)) {
        scores[ContentCategory.music] =
            (scores[ContentCategory.music] ?? 0) + 0.35;
      } else if (duration > const Duration(minutes: 20)) {
        scores[ContentCategory.podcast] =
            (scores[ContentCategory.podcast] ?? 0) + 0.35;
      }
    } else if (duration > const Duration(minutes: 30)) {
      scores[ContentCategory.lecture] =
          (scores[ContentCategory.lecture] ?? 0) + 0.2;
    }
  }
}
