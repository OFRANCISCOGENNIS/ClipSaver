/// Typo tolerance for search (section 10: "tolerância a erros de
/// digitação — distância de edição 1").
///
/// Responsibility: answer one question cheaply — are two words within a
/// single edit of each other? A full Levenshtein matrix is overkill for a
/// yes/no at distance 1, and this runs on every keystroke over thousands
/// of terms, so it exits early instead.
library;

/// Whether [a] and [b] differ by at most one insertion, deletion or
/// substitution. Comparison is case-insensitive.
bool withinOneEdit(String a, String b) {
  final left = a.toLowerCase();
  final right = b.toLowerCase();
  if (left == right) return true;

  final lengthDelta = left.length - right.length;
  if (lengthDelta.abs() > 1) return false;

  // Same length → at most one substitution.
  if (lengthDelta == 0) {
    var differences = 0;
    for (var i = 0; i < left.length; i++) {
      if (left.codeUnitAt(i) != right.codeUnitAt(i)) {
        differences++;
        if (differences > 1) return false;
      }
    }
    return differences == 1;
  }

  // Lengths differ by one → at most one insertion/deletion. Walk both,
  // allowing exactly one skip in the longer string.
  final longer = lengthDelta > 0 ? left : right;
  final shorter = lengthDelta > 0 ? right : left;
  var longIndex = 0;
  var shortIndex = 0;
  var skipped = false;
  while (shortIndex < shorter.length && longIndex < longer.length) {
    if (longer.codeUnitAt(longIndex) == shorter.codeUnitAt(shortIndex)) {
      longIndex++;
      shortIndex++;
      continue;
    }
    if (skipped) return false;
    skipped = true;
    longIndex++;
  }
  return true;
}

/// Whether any whitespace-separated word of [haystack] is within one edit
/// of [needle] — the shape the search fallback actually needs.
bool anyWordWithinOneEdit(String haystack, String needle) {
  if (needle.isEmpty) return false;
  for (final word in haystack.split(RegExp(r'\s+'))) {
    if (word.isEmpty) continue;
    if (withinOneEdit(word, needle)) return true;
  }
  return false;
}
