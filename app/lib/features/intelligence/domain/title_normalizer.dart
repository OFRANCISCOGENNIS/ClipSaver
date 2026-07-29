/// Smart title suggestions (section 15: "normalização inteligente de
/// títulos").
///
/// Responsibility: propose a cleaner title — never apply one. Section 15
/// requires a preview before anything changes, so this returns both the
/// original and the suggestion and lets the user decide.
///
/// Deliberately rule-based rather than a model: the transformations are
/// small, explainable and reversible, and a user who renames their own
/// files deserves to understand exactly what changed.
library;

/// A proposed rename.
final class TitleSuggestion {
  /// Creates a suggestion.
  const TitleSuggestion({
    required this.original,
    required this.suggestion,
    required this.changes,
  });

  /// The title as it is today.
  final String original;

  /// The proposed replacement.
  final String suggestion;

  /// Human-readable list of what was done, for the preview.
  final List<String> changes;

  /// Whether anything would actually change.
  bool get hasChanges => suggestion != original;
}

/// Cleans up noisy media titles.
abstract final class TitleNormalizer {
  /// Bracketed noise commonly appended by uploaders.
  static final RegExp _bracketNoise = RegExp(
    r'[\[\(]\s*(oficial|official|hd|full\s*hd|4k|1080p|720p|480p|lyric[s]?|'
    r'audio|áudio|video\s*oficial|vídeo\s*oficial|clipe\s*oficial|'
    r'legendado|letra|remaster(ed)?|ao\s*vivo|live)\s*[\]\)]',
    caseSensitive: false,
  );

  /// Clickbait phrases that carry no information about the content.
  static final RegExp _clickbait = RegExp(
    r'\b(voc[êe]\s+n[ãa]o\s+vai\s+acreditar|imperd[íi]vel|'
    r'you\s+won.?t\s+believe|must\s+watch|olha\s+isso|'
    r'chocante|shocking|insano|insane|absurdo)\b[!\s]*',
    caseSensitive: false,
  );

  /// Emoji and pictographic symbols.
  static final RegExp _emoji = RegExp(
    r'[\u{1F000}-\u{1FAFF}\u{2600}-\u{27BF}\u{FE00}-\u{FE0F}\u{1F1E6}-\u{1F1FF}]',
    unicode: true,
  );

  /// Proposes a cleaner version of [title].
  static TitleSuggestion suggest(String title) {
    final changes = <String>[];
    var working = title;

    final withoutEmoji = working.replaceAll(_emoji, ' ');
    if (withoutEmoji != working) {
      changes.add('emojis removidos');
      working = withoutEmoji;
    }

    final withoutClickbait = working.replaceAll(_clickbait, ' ');
    if (withoutClickbait != working) {
      changes.add('chamadas sensacionalistas removidas');
      working = withoutClickbait;
    }

    final withoutBrackets = working.replaceAll(_bracketNoise, ' ');
    if (withoutBrackets != working) {
      changes.add('marcações de qualidade removidas');
      working = withoutBrackets;
    }

    // Runs of !!! or ??? carry no information and shout at the reader.
    // replaceAllMapped, not replaceAll: the latter treats `$1` literally.
    final withoutShouting = working.replaceAllMapped(
      RegExp(r'([!?])\1+'),
      (match) => match.group(1)!,
    );
    if (withoutShouting != working) {
      changes.add('pontuação repetida reduzida');
      working = withoutShouting;
    }

    final decased = _fixShouting(working);
    if (decased != working) {
      changes.add('CAPS LOCK corrigido');
      working = decased;
    }

    final tidied = _tidy(working);
    if (tidied != working) {
      changes.add('espaços e separadores ajustados');
      working = tidied;
    }

    // Removals can leave the title starting mid-sentence; a title that
    // begins in lower case reads like a fragment.
    final capitalized = _capitalizeFirst(working);
    if (capitalized != working) working = capitalized;

    // Never propose an empty name: an all-emoji title has nothing to
    // improve, so leave it alone rather than blank it.
    final suggestion = working.trim().isEmpty ? title.trim() : working;
    return TitleSuggestion(
      original: title,
      suggestion: suggestion,
      changes: suggestion == title ? const [] : changes,
    );
  }

  /// Converts SHOUTED words to title case, leaving short acronyms alone.
  static String _fixShouting(String text) {
    final letters = text.replaceAll(RegExp(r'[^\p{L}]', unicode: true), '');
    if (letters.length < 4) return text;
    final upper = letters.replaceAll(RegExp(r'[^\p{Lu}]', unicode: true), '');
    // Only intervene when most of the title is upper case; a couple of
    // capitals is normal writing.
    if (upper.length / letters.length < 0.7) return text;

    final words = text.split(' ');
    return words.indexed.map((entry) {
      final (index, word) = entry;
      final lower = word.toLowerCase();
      if (lower.isEmpty) return word;
      // Connectives stay lower case unless they open the title — title
      // case that shouts "DE" reads worse than the original.
      if (index > 0 && _connectives.contains(lower)) return lower;
      final firstLetter = lower.indexOf(RegExp(r'\p{L}', unicode: true));
      if (firstLetter == -1) return word;
      return lower.substring(0, firstLetter) +
          lower[firstLetter].toUpperCase() +
          lower.substring(firstLetter + 1);
    }).join(' ');
  }

  /// Words that stay lower case inside a title (pt-BR, en, es).
  static const Set<String> _connectives = {
    'a',
    'à',
    'ao',
    'aos',
    'as',
    'às',
    'com',
    'da',
    'das',
    'de',
    'del',
    'do',
    'dos',
    'e',
    'em',
    'la',
    'las',
    'lo',
    'los',
    'na',
    'nas',
    'no',
    'nos',
    'o',
    'os',
    'ou',
    'para',
    'por',
    'y',
    'an',
    'and',
    'at',
    'for',
    'in',
    'of',
    'on',
    'or',
    'the',
    'to',
  };

  /// Upper-cases the first letter of [text], leaving the rest alone.
  static String _capitalizeFirst(String text) {
    final index = text.indexOf(RegExp(r'\p{L}', unicode: true));
    if (index == -1) return text;
    final char = text[index];
    if (char == char.toUpperCase()) return text;
    return text.substring(0, index) +
        char.toUpperCase() +
        text.substring(index + 1);
  }

  /// Collapses whitespace and trims dangling separators.
  static String _tidy(String text) => text
      .replaceAll(RegExp(r'\s+'), ' ')
      // replaceAllMapped, not replaceAll: `$1` is literal in the latter.
      .replaceAllMapped(
        RegExp(r'\s*([|·–—-])(?:\s*\1)+'),
        (match) => ' ${match.group(1)} ',
      )
      .replaceAll(RegExp(r'\s+'), ' ')
      .replaceAll(RegExp(r'^[\s|·–—\-,.]+'), '')
      .replaceAll(RegExp(r'[\s|·–—\-,]+$'), '')
      .trim();
}
