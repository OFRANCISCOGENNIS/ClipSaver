import 'package:flutter_test/flutter_test.dart';
import 'package:vidora/core/domain/value_objects/file_size.dart';
import 'package:vidora/core/domain/value_objects/media_format.dart';
import 'package:vidora/features/intelligence/domain/duplicate_detector.dart';
import 'package:vidora/features/intelligence/domain/media_classifier.dart';
import 'package:vidora/features/intelligence/domain/series_detector.dart';
import 'package:vidora/features/intelligence/domain/storage_report.dart';
import 'package:vidora/features/intelligence/domain/title_normalizer.dart';
import 'package:vidora/features/library/domain/library_entry.dart';
import 'package:vidora/features/premium/domain/entitlements.dart';

void main() {
  group('TitleNormalizer (section 15)', () {
    String suggest(String title) => TitleNormalizer.suggest(title).suggestion;

    test('strips emoji', () {
      expect(suggest('🔥🔥 Aula de Flutter 🚀'), 'Aula de Flutter');
    });

    test('strips quality and "official" brackets', () {
      expect(suggest('Canção Bonita (OFICIAL) [HD]'), 'Canção Bonita');
      expect(suggest('Show ao vivo [1080p]'), 'Show ao vivo');
    });

    test('strips clickbait phrases', () {
      expect(
        suggest('VOCÊ NÃO VAI ACREDITAR no que aconteceu'),
        'No que aconteceu',
      );
    });

    test('reduces repeated punctuation', () {
      expect(suggest('Incrível!!!!'), 'Incrível!');
    });

    test('fixes shouting but keeps short acronyms', () {
      expect(suggest('AULA COMPLETA DE FLUTTER'), 'Aula Completa de Flutter');
      expect(suggest('Documentário da BBC'), 'Documentário da BBC');
    });

    test('leaves an already-clean title untouched', () {
      final result = TitleNormalizer.suggest('Aula de Flutter');
      expect(result.hasChanges, isFalse);
      expect(result.changes, isEmpty);
    });

    test('never proposes an empty title', () {
      final result = TitleNormalizer.suggest('🔥🔥🔥');
      expect(result.suggestion, isNotEmpty);
    });

    test('reports what it changed, for the preview', () {
      final result = TitleNormalizer.suggest('🔥 CANÇÃO BONITA (OFICIAL)');
      expect(result.hasChanges, isTrue);
      expect(result.changes, isNotEmpty);
      expect(result.original, '🔥 CANÇÃO BONITA (OFICIAL)');
    });

    test('collapses whitespace left by removals', () {
      expect(suggest('Aula   de    Flutter'), 'Aula de Flutter');
    });

    test('collapses repeated separators without leaking regex syntax', () {
      // Guards the replaceAll/replaceAllMapped trap: replaceAll would
      // insert a literal "\$1" here.
      final result = suggest('Aula - - Flutter');
      expect(result, isNot(contains(r'$1')));
      expect(result, 'Aula - Flutter');
    });
  });

  group('SeriesDetector (section 15)', () {
    test('detects SxxExx', () {
      final marker = SeriesDetector.detect('Minha Série S01E02')!;
      expect(marker.seriesName, 'Minha Série');
      expect(marker.season, 1);
      expect(marker.episode, 2);
    });

    test('detects episode words in Portuguese and English', () {
      expect(SeriesDetector.detect('Podcast Ep. 12')!.episode, 12);
      expect(SeriesDetector.detect('Podcast Episódio 7')!.episode, 7);
      expect(SeriesDetector.detect('Show Episode 3')!.episode, 3);
      expect(SeriesDetector.detect('Curso Capítulo 4')!.episode, 4);
    });

    test('detects part markers', () {
      final marker = SeriesDetector.detect('Documentário Parte 3')!;
      expect(marker.seriesName, 'Documentário');
      expect(marker.episode, 3);
      expect(marker.season, isNull);
    });

    test('detects hash numbering', () {
      expect(SeriesDetector.detect('Café com Código #42')!.episode, 42);
    });

    test('returns null when there is no marker', () {
      expect(SeriesDetector.detect('Aula de Flutter'), isNull);
    });

    test('returns null when the title is only a marker', () {
      expect(SeriesDetector.detect('Ep. 5'), isNull);
    });

    test('groups by series and sorts by season then episode', () {
      final groups = SeriesDetector.groupBySeries([
        'Minha Série S01E02',
        'Minha Série S01E01',
        'Minha Série S02E01',
        'Outra coisa',
      ]);
      expect(groups.keys, ['minha série']);
      expect(
        groups['minha série']!.map((m) => '${m.season}-${m.episode}'),
        ['1-1', '1-2', '2-1'],
      );
    });

    test('a single episode is not a series', () {
      expect(SeriesDetector.groupBySeries(['Podcast Ep. 1']), isEmpty);
    });
  });

  group('HeuristicMediaClassifier (section 15)', () {
    const classifier = HeuristicMediaClassifier();

    Classification classify({
      required String title,
      MediaKind kind = MediaKind.video,
      Duration? duration,
      String? platform,
      String? author,
    }) =>
        classifier.classify(
          ClassificationInput(
            title: title,
            kind: kind,
            duration: duration,
            platform: platform,
            author: author,
          ),
        );

    test('recognizes music from keywords and short audio duration', () {
      final result = classify(
        title: 'Canção Bonita (clipe)',
        kind: MediaKind.audio,
        duration: const Duration(minutes: 3),
      );
      expect(result.category, ContentCategory.music);
      expect(result.isConfident, isTrue);
    });

    test('a podcast RSS feed is authoritative about its own type', () {
      final result = classify(
        title: 'Conversa qualquer',
        kind: MediaKind.audio,
        platform: 'podcast_rss',
        duration: const Duration(minutes: 45),
      );
      expect(result.category, ContentCategory.podcast);
    });

    test('recognizes lectures and tutorials by keyword', () {
      expect(
        classify(title: 'Aula 1 — Cálculo').category,
        ContentCategory.lecture,
      );
      expect(
        classify(title: 'Tutorial: como fazer pão').category,
        ContentCategory.tutorial,
      );
    });

    test('returns unknown with zero confidence when nothing matches', () {
      final result = classify(title: 'asdfgh');
      expect(result.category, ContentCategory.unknown);
      expect(result.confidence, 0);
      expect(result.isConfident, isFalse);
    });

    test('ambiguous titles get lower confidence than clear ones', () {
      final clear = classify(
        title: 'Tutorial passo a passo',
        duration: const Duration(minutes: 10),
      );
      final ambiguous = classify(title: 'Aula tutorial de música');
      expect(ambiguous.confidence, lessThan(clear.confidence));
    });
  });

  group('DuplicateDetector (section 15)', () {
    LibraryEntry entry({
      required String id,
      String title = 'Aula de Flutter',
      int sizeBytes = 1000,
      Duration? duration,
      LibraryFileStatus status = LibraryFileStatus.available,
      DateTime? trashedAt,
    }) =>
        LibraryEntry(
          id: id,
          title: title,
          filePath: '/library/$id.mp4',
          kind: MediaKind.video,
          size: FileSize.ofBytes(sizeBytes),
          downloadedAt: DateTime.utc(2026, 7, 1),
          duration: duration,
          status: status,
          trashedAt: trashedAt,
        );

    test('flags the same file downloaded twice as exact', () {
      final groups = DuplicateDetector.findDuplicates([
        entry(id: 'a'),
        entry(id: 'b'),
      ]);
      expect(groups, hasLength(1));
      expect(groups.single.kind, DuplicateKind.exact);
    });

    test('flags the same media at different qualities', () {
      final groups = DuplicateDetector.findDuplicates([
        entry(id: 'sd', sizeBytes: 1000, duration: const Duration(minutes: 10)),
        entry(id: 'hd', sizeBytes: 9000, duration: const Duration(minutes: 10)),
      ]);
      expect(groups, hasLength(1));
      expect(groups.single.kind, DuplicateKind.sameMedia);
      // The largest is suggested for keeping, the rest for review.
      expect(groups.single.suggestedKeep.id, 'hd');
      expect(groups.single.suggestedRemove.map((e) => e.id), ['sd']);
      expect(groups.single.reclaimableSpace, FileSize.ofBytes(1000));
    });

    test('tolerates small duration differences between encoders', () {
      final groups = DuplicateDetector.findDuplicates([
        entry(
          id: 'a',
          sizeBytes: 1000,
          duration: const Duration(minutes: 10),
        ),
        entry(
          id: 'b',
          sizeBytes: 9000,
          duration: const Duration(minutes: 10, seconds: 1),
        ),
      ]);
      expect(groups, hasLength(1));
    });

    test('does not group titles that merely look similar', () {
      final groups = DuplicateDetector.findDuplicates([
        entry(id: 'a', title: 'Aula de Flutter'),
        entry(id: 'b', title: 'Aula de Dart'),
      ]);
      expect(groups, isEmpty);
    });

    test('ignores accents and punctuation when comparing titles', () {
      expect(
        DuplicateDetector.normalizeForComparison('Canção: Bonita!'),
        DuplicateDetector.normalizeForComparison('Cancao Bonita'),
      );
    });

    test('skips trashed and missing entries', () {
      final groups = DuplicateDetector.findDuplicates([
        entry(id: 'a'),
        entry(
          id: 'b',
          status: LibraryFileStatus.trashed,
          trashedAt: DateTime.utc(2026, 7, 5),
        ),
        entry(id: 'c', status: LibraryFileStatus.missing),
      ]);
      expect(groups, isEmpty);
    });

    test('a group always has at least two entries', () {
      expect(
        () => DuplicateGroup(
          kind: DuplicateKind.exact,
          entries: [entry(id: 'a')],
        ),
        throwsArgumentError,
      );
    });
  });

  group('StorageReport (section 15)', () {
    LibraryEntry entry({
      required String id,
      String title = 'Item',
      MediaKind kind = MediaKind.video,
      int sizeBytes = 1000,
      DateTime? downloadedAt,
      DateTime? lastPlayedAt,
      String extension = 'mp4',
      LibraryFileStatus status = LibraryFileStatus.available,
      DateTime? trashedAt,
    }) =>
        LibraryEntry(
          id: id,
          title: title,
          filePath: '/library/$id.$extension',
          kind: kind,
          size: FileSize.ofBytes(sizeBytes),
          downloadedAt: downloadedAt ?? DateTime.utc(2026, 7, 1),
          lastPlayedAt: lastPlayedAt,
          status: status,
          trashedAt: trashedAt,
        );

    final now = DateTime.utc(2026, 7, 29);

    test('totals space by category, excluding the trash', () {
      final report = StorageReportBuilder.build([
        entry(id: 'v', sizeBytes: 3000),
        entry(id: 'a', kind: MediaKind.audio, sizeBytes: 1000),
        entry(
          id: 't',
          sizeBytes: 500,
          status: LibraryFileStatus.trashed,
          trashedAt: DateTime.utc(2026, 7, 20),
        ),
      ], now);

      expect(report.totalSize, FileSize.ofBytes(4000));
      expect(report.videoSize, FileSize.ofBytes(3000));
      expect(report.audioSize, FileSize.ofBytes(1000));
      expect(report.trashSize, FileSize.ofBytes(500));
    });

    test('suggests items downloaded long ago and never played', () {
      final report = StorageReportBuilder.build([
        entry(id: 'velho', downloadedAt: DateTime.utc(2026, 1, 1)),
        entry(
          id: 'visto',
          downloadedAt: DateTime.utc(2026, 1, 1),
          lastPlayedAt: DateTime.utc(2026, 6, 1),
        ),
        entry(id: 'novo', downloadedAt: DateTime.utc(2026, 7, 20)),
      ], now);

      final unplayed = report.suggestions
          .where((s) => s.kind == StorageSuggestionKind.neverPlayed)
          .single;
      expect(unplayed.entries.map((e) => e.id), ['velho']);
    });

    test('suggests re-encoding large files in dated containers', () {
      const big = 400 * 1024 * 1024;
      final report = StorageReportBuilder.build([
        entry(id: 'antigo', sizeBytes: big, extension: 'avi'),
        entry(id: 'moderno', sizeBytes: big, extension: 'mp4'),
        entry(id: 'pequeno', sizeBytes: 1000, extension: 'avi'),
      ], now);

      final convertible = report.suggestions
          .where((s) => s.kind == StorageSuggestionKind.convertible)
          .single;
      expect(convertible.entries.map((e) => e.id), ['antigo']);
    });

    test('surfaces duplicates as a suggestion, never a deletion', () {
      final report = StorageReportBuilder.build([
        entry(id: 'a', title: 'Mesmo'),
        entry(id: 'b', title: 'Mesmo'),
      ], now);

      final duplicates = report.suggestions
          .where((s) => s.kind == StorageSuggestionKind.duplicates)
          .single;
      expect(duplicates.entries, hasLength(2));
      expect(duplicates.detail, contains('automaticamente'));
    });

    test('counts overlapping suggestions once, never overstating savings', () {
      // Same file twice, both old and unplayed: it appears in two
      // suggestions but can only be reclaimed once.
      final report = StorageReportBuilder.build([
        entry(
          id: 'a',
          title: 'Mesmo',
          sizeBytes: 1000,
          downloadedAt: DateTime.utc(2026, 1, 1),
        ),
        entry(
          id: 'b',
          title: 'Mesmo',
          sizeBytes: 1000,
          downloadedAt: DateTime.utc(2026, 1, 1),
        ),
      ], now);

      final naiveSum = report.suggestions.fold(
        0,
        (int total, s) => total + s.reclaimableSpace.bytes,
      );
      expect(report.totalReclaimable.bytes, lessThan(naiveSum));
      expect(report.totalReclaimable, FileSize.ofBytes(2000));
    });

    test('an empty library produces no suggestions', () {
      final report = StorageReportBuilder.build([], now);
      expect(report.suggestions, isEmpty);
      expect(report.totalReclaimable, FileSize.zero);
    });

    test('suggestions come ordered by the biggest saving first', () {
      final report = StorageReportBuilder.build([
        entry(id: 'a', title: 'Dup', sizeBytes: 50),
        entry(id: 'b', title: 'Dup', sizeBytes: 50),
        entry(
          id: 'c',
          sizeBytes: 900000,
          downloadedAt: DateTime.utc(2026, 1, 1),
        ),
      ], now);

      final savings = report.suggestions
          .map((suggestion) => suggestion.reclaimableSpace.bytes)
          .toList();
      final sorted = [...savings]..sort((a, b) => b.compareTo(a));
      expect(savings, orderedEquals(sorted));
    });
  });

  group('Entitlements (section 14)', () {
    test('free and premium differ on the documented limits', () {
      expect(Entitlements.free.maxConcurrentDownloads, 2);
      expect(Entitlements.premium.maxConcurrentDownloads, 8);
      expect(Entitlements.free.maxTags, 3);
      expect(Entitlements.premium.maxTags, Entitlements.unlimitedTags);
      expect(Entitlements.premium.maxBatchItems, 100);
    });

    test('premium-only features are gated', () {
      for (final check in <bool Function(Entitlements)>[
        (e) => e.canBatchDownload,
        (e) => e.canSchedule,
        (e) => e.canSaveSmartSearches,
        (e) => e.canSyncLibrary,
        (e) => e.canBackup,
        (e) => e.canBatchConvert,
      ]) {
        expect(check(Entitlements.free), isFalse);
        expect(check(Entitlements.premium), isTrue);
      }
    });

    test('tag limits are enforced by count, unlimited for premium', () {
      expect(Entitlements.free.allowsTagCount(3), isTrue);
      expect(Entitlements.free.allowsTagCount(4), isFalse);
      expect(Entitlements.premium.allowsTagCount(9999), isTrue);
    });

    test('concurrency is clamped so a lapsed plan cannot keep 8 slots', () {
      expect(Entitlements.free.clampConcurrency(8), 2);
      expect(Entitlements.premium.clampConcurrency(8), 8);
      expect(Entitlements.premium.clampConcurrency(99), 8);
      expect(Entitlements.free.clampConcurrency(0), 1);
    });

    test('AI tier follows the plan', () {
      expect(Entitlements.free.aiTier, AiTier.limited);
      expect(Entitlements.premium.aiTier, AiTier.full);
    });

    group('trial', () {
      final start = DateTime.utc(2026, 7, 1);
      final trial = TrialStatus(startedAt: start);

      test('lasts seven days', () {
        expect(trial.chargesAt, DateTime.utc(2026, 7, 8));
        expect(trial.isActive(DateTime.utc(2026, 7, 7)), isTrue);
        expect(trial.isActive(DateTime.utc(2026, 7, 8)), isFalse);
      });

      test('counts remaining days without going negative', () {
        expect(trial.daysRemaining(DateTime.utc(2026, 7, 1)), 7);
        expect(trial.daysRemaining(DateTime.utc(2026, 7, 30)), 0);
      });

      test('warns with time left to cancel, not on the charge day', () {
        expect(trial.shouldWarnBeforeCharge(DateTime.utc(2026, 7, 2)), isFalse);
        expect(trial.shouldWarnBeforeCharge(DateTime.utc(2026, 7, 6)), isTrue);
        // Already charged: no warning to give.
        expect(trial.shouldWarnBeforeCharge(DateTime.utc(2026, 7, 9)), isFalse);
      });
    });
  });
}
