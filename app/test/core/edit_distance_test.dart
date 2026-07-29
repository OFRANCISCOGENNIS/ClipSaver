import 'package:flutter_test/flutter_test.dart';
import 'package:vidora/core/utils/edit_distance.dart';

void main() {
  group('withinOneEdit', () {
    test('identical words match', () {
      expect(withinOneEdit('flutter', 'flutter'), isTrue);
      expect(withinOneEdit('', ''), isTrue);
    });

    test('is case-insensitive', () {
      expect(withinOneEdit('Flutter', 'flutter'), isTrue);
    });

    test('accepts a single substitution', () {
      expect(withinOneEdit('aula', 'aule'), isTrue);
      expect(withinOneEdit('podcast', 'podkast'), isTrue);
    });

    test('accepts a single deletion', () {
      expect(withinOneEdit('flutter', 'flutte'), isTrue);
      expect(withinOneEdit('flutter', 'lutter'), isTrue);
      expect(withinOneEdit('flutter', 'futter'), isTrue);
    });

    test('accepts a single insertion', () {
      expect(withinOneEdit('aula', 'aulaa'), isTrue);
      expect(withinOneEdit('aula', 'aaula'), isTrue);
      expect(withinOneEdit('aula', 'auxla'), isTrue);
    });

    test('rejects two or more edits', () {
      expect(withinOneEdit('flutter', 'fluttre'), isFalse); // transposition
      expect(withinOneEdit('aula', 'bulb'), isFalse);
      expect(withinOneEdit('aula', 'au'), isFalse);
    });

    test('rejects words whose lengths differ by more than one', () {
      expect(withinOneEdit('conversao', 'con'), isFalse);
    });

    test('handles accented characters as distinct', () {
      expect(withinOneEdit('musica', 'música'), isTrue);
      expect(withinOneEdit('musica', 'mùsicà'), isFalse);
    });
  });

  group('anyWordWithinOneEdit', () {
    test('matches any word of the haystack', () {
      expect(anyWordWithinOneEdit('Aula de Flutter', 'flutte'), isTrue);
      expect(anyWordWithinOneEdit('Aula de Flutter', 'aula'), isTrue);
    });

    test('does not match across word boundaries', () {
      expect(anyWordWithinOneEdit('Aula de Flutter', 'auladeflutter'), isFalse);
    });

    test('an empty needle never matches', () {
      expect(anyWordWithinOneEdit('Aula', ''), isFalse);
    });

    test('tolerates repeated whitespace', () {
      expect(anyWordWithinOneEdit('Aula   de    Flutter', 'flutter'), isTrue);
    });
  });
}
