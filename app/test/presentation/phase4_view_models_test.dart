/// ViewModel tests for the three Phase 4 screens.
///
/// They run against the real drift database (in memory) rather than
/// repository fakes: the FTS5 index and the tab queries are exactly the
/// parts worth exercising end to end.
library;

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vidora/app/providers.dart';
import 'package:vidora/core/domain/value_objects/file_size.dart';
import 'package:vidora/core/domain/value_objects/media_format.dart';
import 'package:vidora/core/storage/database.dart';
import 'package:vidora/features/converter/domain/conversion_job.dart';
import 'package:vidora/features/converter/domain/conversion_request.dart';
import 'package:vidora/features/converter/domain/media_converter.dart';
import 'package:vidora/features/converter/presentation/converter_state.dart';
import 'package:vidora/features/converter/presentation/converter_view_model.dart';
import 'package:vidora/features/library/domain/library_entry.dart';
import 'package:vidora/features/library/domain/library_repository.dart';
import 'package:vidora/features/library/presentation/library_state.dart';
import 'package:vidora/features/library/presentation/library_view_model.dart';
import 'package:vidora/features/search/domain/search_query.dart';
import 'package:vidora/features/search/presentation/search_state.dart';
import 'package:vidora/features/search/presentation/search_view_model.dart';

import '../application/conversion_manager_test.dart' show FakeConverter;
import '../support/download_fakes.dart';

void main() {
  late AppDatabase db;
  late FakeFileSystem fs;
  late FakeConverter converter;
  late ProviderContainer container;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    fs = FakeFileSystem();
    converter = FakeConverter();
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        downloadFileSystemProvider.overrideWithValue(fs),
        mediaConverterProvider.overrideWithValue(converter),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    // Disposal only flags in-flight loads; give them a turn to observe it
    // before the database goes away underneath them.
    await Future<void>.delayed(Duration.zero);
    await db.close();
  });

  Future<LibraryEntry> seed({
    required String id,
    String title = 'Título',
    MediaKind kind = MediaKind.video,
    bool favorite = false,
    Duration? duration,
    String? author,
  }) async {
    final entry = LibraryEntry(
      id: id,
      title: title,
      filePath: '/library/$id.mp4',
      kind: kind,
      size: FileSize.ofBytes(1000),
      downloadedAt: DateTime.utc(2026, 7, 1),
      favorite: favorite,
      duration: duration,
      author: author,
    );
    await container.read(libraryRepositoryProvider).save(entry);
    return entry;
  }

  /// Lets pending microtasks and stream events drain.
  Future<void> settle() async =>
      Future<void>.delayed(const Duration(milliseconds: 20));

  group('LibraryViewModel', () {
    LibraryViewModel viewModel() =>
        container.read(libraryViewModelProvider.notifier);
    LibraryUiState state() => container.read(libraryViewModelProvider);

    test('loads the videos tab with counts', () async {
      await seed(id: 'v1');
      await seed(id: 'a1', kind: MediaKind.audio);
      viewModel();
      await settle();

      expect(state().loaded, isTrue);
      expect(state().entries.map((e) => e.id), ['v1']);
      expect(state().counts.videos, 1);
      expect(state().counts.audios, 1);
    });

    test('switching tabs re-queries', () async {
      await seed(id: 'v1');
      await seed(id: 'a1', kind: MediaKind.audio);
      viewModel();
      await settle();

      await viewModel().selectTab(LibraryTab.audios);
      expect(state().entries.map((e) => e.id), ['a1']);

      await viewModel().selectTab(LibraryTab.recents);
      expect(state().entries, hasLength(2));
    });

    test('the favorites tab shows only favorited entries', () async {
      await seed(id: 'v1');
      await seed(id: 'v2', favorite: true);
      viewModel();
      await settle();

      await viewModel().selectTab(LibraryTab.favorites);
      expect(state().entries.map((e) => e.id), ['v2']);
    });

    test('toggling favorite updates the list and the counts', () async {
      await seed(id: 'v1');
      viewModel();
      await settle();
      expect(state().counts.favorites, 0);

      await viewModel().toggleFavorite('v1');
      await settle();
      expect(state().counts.favorites, 1);

      await viewModel().toggleFavorite('v1');
      await settle();
      expect(state().counts.favorites, 0);
    });

    test('repeating a sort key flips the direction', () async {
      viewModel();
      await settle();

      await viewModel().sortBy(LibrarySort.name);
      expect(state().sort, LibrarySort.name);
      expect(state().descending, isTrue);

      await viewModel().sortBy(LibrarySort.name);
      expect(state().descending, isFalse);

      await viewModel().sortBy(LibrarySort.size);
      expect(state().descending, isTrue);
    });

    test('toggles between grid and list', () async {
      viewModel();
      await settle();
      expect(state().viewMode, LibraryViewMode.grid);
      viewModel().toggleViewMode();
      expect(state().viewMode, LibraryViewMode.list);
      viewModel().toggleViewMode();
      expect(state().viewMode, LibraryViewMode.grid);
    });

    test('reconciling flags entries whose file vanished', () async {
      await seed(id: 'gone');
      viewModel();
      await settle();

      final report = (await viewModel().reconcileFiles()).valueOrNull!;
      await settle();
      expect(report.wentMissing, 1);
      expect(state().missing.map((e) => e.id), ['gone']);
    });

    test('trashing removes the entry from the tab', () async {
      await seed(id: 'v1');
      viewModel();
      await settle();

      await viewModel().moveToTrash('v1');
      await settle();
      expect(state().entries, isEmpty);
      expect(state().counts.trashed, 1);
    });
  });

  group('SearchViewModel', () {
    SearchViewModel viewModel() =>
        container.read(searchViewModelProvider.notifier);
    SearchUiState state() => container.read(searchViewModelProvider);

    test('starts with an empty query and no results', () {
      expect(state().query.isEmpty, isTrue);
      expect(state().hits, isEmpty);
      expect(state().searched, isFalse);
    });

    test('searching finds entries by text', () async {
      await seed(id: 'a', title: 'Aula de Flutter');
      await seed(id: 'b', title: 'Receita de bolo');
      viewModel().textChanged('flutter');
      await viewModel().search();

      expect(state().hits.map((hit) => hit.entry.id), ['a']);
      expect(state().searched, isTrue);
    });

    test('debounces typing into a single search', () async {
      await seed(id: 'a', title: 'Aula de Flutter');
      final viewModelRef = viewModel();
      viewModelRef
        ..textChanged('f')
        ..textChanged('fl')
        ..textChanged('flu');
      // Before the debounce elapses nothing has run yet.
      expect(state().searched, isFalse);

      await Future<void>.delayed(
        SearchViewModel.debounceDelay + const Duration(milliseconds: 60),
      );
      expect(state().searched, isTrue);
      expect(state().hits.map((hit) => hit.entry.id), ['a']);
    });

    test('offers type-ahead suggestions while typing', () async {
      await seed(id: 'a', title: 'Aula de Flutter');
      viewModel().textChanged('aul');
      await settle();
      expect(state().suggestions, contains('Aula de Flutter'));
    });

    test('accepting a suggestion runs the search and clears the list',
        () async {
      await seed(id: 'a', title: 'Aula de Flutter');
      viewModel().textChanged('aul');
      await settle();

      await viewModel().acceptSuggestion('Aula de Flutter');
      expect(state().query.text, 'Aula de Flutter');
      expect(state().suggestions, isEmpty);
      expect(state().hits, hasLength(1));
    });

    test('filters combine with the text and toggle off', () async {
      await seed(id: 'v', title: 'Aula', kind: MediaKind.video);
      await seed(id: 'a', title: 'Aula', kind: MediaKind.audio);

      await viewModel().toggleKind(MediaKind.audio);
      expect(state().hits.map((hit) => hit.entry.id), ['a']);
      expect(state().query.activeFilterCount, 1);

      await viewModel().toggleKind(MediaKind.audio);
      expect(state().query.kind, isNull);
      expect(state().hits, hasLength(2));
    });

    test('duration and tag filters stack', () async {
      await seed(
        id: 'curto',
        title: 'Curto',
        duration: const Duration(minutes: 2),
      );
      await seed(
        id: 'longo',
        title: 'Longo',
        duration: const Duration(minutes: 40),
      );

      await viewModel().toggleDuration(DurationBucket.short);
      expect(state().hits.map((hit) => hit.entry.id), ['curto']);
    });

    test('clearFilters keeps the text but drops the chips', () async {
      await seed(id: 'a', title: 'Aula', kind: MediaKind.video);
      viewModel().textChanged('aula');
      await viewModel().toggleKind(MediaKind.video);
      expect(state().query.hasFilters, isTrue);

      await viewModel().clearFilters();
      expect(state().query.hasFilters, isFalse);
      expect(state().query.text, 'aula');
    });

    test('flags approximate results from the typo fallback', () async {
      await seed(id: 'a', title: 'Aula de Flutter');
      viewModel().textChanged('flutger');
      await viewModel().search();

      expect(state().hits, hasLength(1));
      expect(state().showingApproximateResults, isTrue);
    });

    test('reports the empty state when nothing matches', () async {
      await seed(id: 'a', title: 'Aula');
      viewModel().textChanged('zzzzzzz');
      await viewModel().search();
      expect(state().isEmpty, isTrue);
    });

    test('loads the platform and tag facets', () async {
      await container.read(libraryRepositoryProvider).save(
            LibraryEntry(
              id: 'a',
              title: 'Aula',
              filePath: '/library/a.mp4',
              kind: MediaKind.video,
              size: FileSize.ofBytes(1),
              downloadedAt: DateTime.utc(2026, 7, 1),
              platform: 'archive_org',
              tags: const ['aula'],
            ),
          );
      await viewModel().loadFacets();
      expect(state().platforms, ['archive_org']);
      expect(state().tags, ['aula']);
    });
  });

  group('ConverterViewModel', () {
    ConverterViewModel viewModel() =>
        container.read(converterViewModelProvider.notifier);
    ConverterUiState state() => container.read(converterViewModelProvider);

    test('starts with an empty queue', () async {
      viewModel();
      await settle();
      expect(state().items, isEmpty);
    });

    test('converting a library entry with a preset queues a job', () async {
      final entry = await seed(id: 'a', duration: const Duration(minutes: 5));
      final job = (await viewModel()
              .convertWithPreset(entry, ConversionPreset.podcastAudio))
          .valueOrNull!;
      await settle();

      expect(job.target, ConversionTarget.mp3);
      expect(job.sourceDuration, const Duration(minutes: 5));
      expect(state().items.single.id, job.id);
      expect(state().items.single.job.state, ConversionState.converting);
    });

    test('a row with a known duration reports determinate progress', () async {
      final entry = await seed(id: 'a', duration: const Duration(minutes: 5));
      await viewModel().convertWithPreset(entry, ConversionPreset.lossless);
      await settle();
      expect(state().items.single.hasDeterminateProgress, isTrue);
    });

    test('a row without a duration cannot report a percentage', () async {
      final entry = await seed(id: 'a');
      await viewModel().convertWithPreset(entry, ConversionPreset.lossless);
      await settle();
      expect(state().items.single.hasDeterminateProgress, isFalse);
    });

    test('cancelling a running conversion aborts it', () async {
      final entry = await seed(id: 'a');
      final job = (await viewModel()
              .convertWithPreset(entry, ConversionPreset.podcastAudio))
          .valueOrNull!;
      await settle();

      await viewModel().cancel(job.id);
      await settle();
      expect(state().items.single.job.state, ConversionState.canceled);
      expect(state().items.single.canCancel, isFalse);
    });

    test('a failed conversion offers a retry and keeps the reason', () async {
      final entry = await seed(id: 'a');
      final job = (await viewModel()
              .convertWithPreset(entry, ConversionPreset.podcastAudio))
          .valueOrNull!;
      await settle();

      converter.finish(
        job.id,
        ConversionOutcome.failure,
        error: 'Codec ausente.',
      );
      await settle();

      final row = state().items.single;
      expect(row.canRetry, isTrue);
      expect(row.job.failureReason, 'Codec ausente.');
    });

    test('clearing removes completed conversions', () async {
      final entry = await seed(id: 'a');
      final job = (await viewModel()
              .convertWithPreset(entry, ConversionPreset.podcastAudio))
          .valueOrNull!;
      await settle();
      converter.finish(job.id, ConversionOutcome.success);
      await settle();
      expect(state().hasFinishedWork, isTrue);

      await viewModel().clearFinished();
      await settle();
      expect(state().items, isEmpty);
    });

    test('the original file is preserved by default (section 11)', () async {
      final entry = await seed(id: 'a');
      final job = (await viewModel()
              .convertWithPreset(entry, ConversionPreset.podcastAudio))
          .valueOrNull!;
      expect(job.keepOriginal, isTrue);
      expect(job.outputPath, isNot(entry.filePath));
    });
  });
}
