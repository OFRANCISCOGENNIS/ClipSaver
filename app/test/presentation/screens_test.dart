/// Widget tests for the Library, Search, Converter and Settings screens,
/// plus the navigation shell and the route table.
///
/// The ViewModels behind these screens are covered on their own; what is
/// asserted here is the wiring nothing else catches — that the tree
/// actually renders the state, that the adaptive shell picks the right
/// chrome for the window size, and that every route builds.
library;

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vidora/app/providers.dart';
import 'package:vidora/app/router.dart';
import 'package:vidora/app/shell.dart';
import 'package:vidora/app/theme/app_theme.dart';
import 'package:vidora/core/domain/value_objects/file_size.dart';
import 'package:vidora/core/domain/value_objects/media_format.dart';
import 'package:vidora/core/storage/database.dart';
import 'package:vidora/features/converter/domain/conversion_job.dart';
import 'package:vidora/features/converter/domain/conversion_request.dart';
import 'package:vidora/features/converter/infrastructure/in_memory_converter_repository.dart';
import 'package:vidora/features/converter/presentation/converter_view.dart';
import 'package:vidora/features/downloads/presentation/downloads_view.dart';
import 'package:vidora/features/library/domain/library_entry.dart';
import 'package:vidora/features/library/presentation/library_view.dart';
import 'package:vidora/features/search/presentation/search_view.dart';
import 'package:vidora/features/settings/presentation/settings_view.dart';
import 'package:vidora/l10n/l10n.dart';

import '../application/conversion_manager_test.dart' show FakeConverter;
import '../support/download_fakes.dart';
import '../support/localized_app.dart';

void main() {
  late AppDatabase db;
  late AppLocalizations l10n;
  late List<Override> overrides;

  late InMemoryConverterRepository conversions;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    l10n = await loadL10n();
    // Shared on purpose: the conversion queue lives in memory, so a job
    // enqueued from a helper container has to reach the same instance the
    // widget tree reads, exactly as one process would see it.
    conversions = InMemoryConverterRepository();
    addTearDown(conversions.dispose);
    overrides = [
      databaseProvider.overrideWithValue(db),
      downloadFileSystemProvider.overrideWithValue(FakeFileSystem()),
      downloadsDirectoryProvider.overrideWithValue('/downloads'),
      downloadTransportProvider.overrideWithValue(FakeTransport([])),
      mediaConverterProvider.overrideWithValue(FakeConverter()),
      converterRepositoryProvider.overrideWithValue(conversions),
    ];
  });

  tearDown(() async {
    // Disposal only flags in-flight loads; give them a turn to observe it
    // before the database goes away underneath them.
    await Future<void>.delayed(Duration.zero);
    await db.close();
  });

  /// A short-lived container for seeding rows and reading them back.
  ProviderContainer container() {
    final result = ProviderContainer(overrides: overrides);
    addTearDown(result.dispose);
    return result;
  }

  /// Seeds one library row.
  Future<LibraryEntry> seed({
    required String id,
    String title = 'Aula aberta',
    MediaKind kind = MediaKind.video,
    Duration? duration,
    String? author,
    LibraryFileStatus status = LibraryFileStatus.available,
  }) async {
    final entry = LibraryEntry(
      id: id,
      title: title,
      filePath: '/library/$id.mp4',
      kind: kind,
      size: FileSize.ofBytes(1000),
      downloadedAt: DateTime.utc(2026, 7, 1),
      duration: duration,
      author: author,
      platform: 'exemplo',
      status: status,
    );
    await container().read(libraryRepositoryProvider).save(entry);
    return entry;
  }

  /// Mounts [screen] with the app's providers, theme and translations,
  /// runs [body] against it, then unmounts.
  ///
  /// The unmount is inside the test on purpose: drift schedules a
  /// zero-duration timer when its stream store closes, and the binding
  /// refuses to finish a test while a timer is pending. A `tearDown` would
  /// run after that check, not before it.
  Future<void> withScreen(
    WidgetTester tester,
    Widget screen,
    Future<void> Function() body, {
    Size size = const Size(400, 900),
    bool settle = true,
    double textScale = 1,
  }) async {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
          child: localizedApp(
            theme: buildVidoraTheme(Brightness.dark),
            home: screen,
          ),
        ),
      ),
    );
    // A running conversion drives an indeterminate progress bar, which
    // animates forever — `pumpAndSettle` would never return.
    if (settle) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump();
      await tester.pump();
    }

    await body();

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 50));
  }

  /// Same, for the cases that need the real router and shell rather than a
  /// single screen.
  Future<void> withRouter(
    WidgetTester tester,
    Future<void> Function() body, {
    Size size = const Size(400, 900),
    String initialLocation = Routes.analyze,
    bool settle = true,
  }) async {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: MaterialApp.router(
          theme: buildVidoraTheme(Brightness.dark),
          // Pinned: without it the app follows the test binding's platform
          // locale (en-US) and every pt assertion silently compares the
          // wrong language.
          locale: const Locale('pt'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: buildRouter(initialLocation: initialLocation),
        ),
      ),
    );
    if (settle) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump();
    }

    await body();

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 50));
  }

  group('LibraryView', () {
    testWidgets('shows the empty state when nothing has been downloaded',
        (tester) async {
      await withScreen(tester, const LibraryView(), () async {
        expect(find.text(l10n.libraryEmptyTitle), findsOneWidget);
        expect(find.text(l10n.libraryEmptyBody), findsOneWidget);
      });
    });

    testWidgets('renders entries with per-tab counts', (tester) async {
      await seed(id: 'v1', duration: const Duration(minutes: 3));
      await seed(id: 'a1', kind: MediaKind.audio);

      await withScreen(tester, const LibraryView(), () async {
        expect(
          find.text(l10n.libraryTabWithCount(l10n.libraryTabVideos, 1)),
          findsOneWidget,
        );
        expect(
          find.text(l10n.libraryTabWithCount(l10n.libraryTabAudios, 1)),
          findsOneWidget,
        );
        expect(find.text('Aula aberta'), findsOneWidget);
        // The duration badge is formatted, not raw.
        expect(find.text('3:00'), findsOneWidget);
      });
    });

    testWidgets('toggles between grid and list', (tester) async {
      await seed(id: 'v1');

      await withScreen(tester, const LibraryView(), () async {
        expect(find.byType(GridView), findsOneWidget);
        await tester.tap(find.byTooltip(l10n.libraryViewAsList));
        await tester.pumpAndSettle();
        expect(find.byType(GridView), findsNothing);
        expect(find.byType(ListView), findsOneWidget);
      });
    });

    testWidgets('favoriting an entry flips the affordance', (tester) async {
      await seed(id: 'v1');

      await withScreen(tester, const LibraryView(), () async {
        expect(find.byTooltip(l10n.libraryFavoriteAdd), findsOneWidget);
        await tester.tap(find.byTooltip(l10n.libraryFavoriteAdd));
        await tester.pumpAndSettle();
        expect(find.byTooltip(l10n.libraryFavoriteRemove), findsOneWidget);
      });
    });

    testWidgets('offers every sort key', (tester) async {
      await seed(id: 'v1');

      await withScreen(tester, const LibraryView(), () async {
        await tester.tap(find.byTooltip(l10n.librarySort));
        await tester.pumpAndSettle();
        expect(find.text(l10n.librarySortName), findsOneWidget);
        expect(find.text(l10n.librarySortSize), findsOneWidget);

        await tester.tap(find.text(l10n.librarySortName));
        await tester.pumpAndSettle();
        expect(find.text('Aula aberta'), findsOneWidget);
      });
    });

    testWidgets('a vanished file is called out instead of looking playable',
        (tester) async {
      await seed(id: 'v1', status: LibraryFileStatus.missing);

      await withScreen(tester, const LibraryView(), () async {
        expect(find.text(l10n.libraryFileMissing), findsOneWidget);
      });
    });
  });

  group('SearchView', () {
    testWidgets('starts empty and offers the kind and duration filters',
        (tester) async {
      await withScreen(tester, const SearchView(), () async {
        expect(find.text(l10n.searchKindVideo), findsOneWidget);
        expect(find.text(l10n.searchKindAudio), findsOneWidget);
        expect(find.text(l10n.searchDurationShort), findsOneWidget);
        // Nothing has been searched yet, so the screen must not claim
        // there are no results — that would be a verdict it has not made.
        expect(find.text(l10n.searchEmpty), findsNothing);
      });
    });

    testWidgets('a search with no match says so', (tester) async {
      await seed(id: 'v1', title: 'Aula de Cálculo');

      await withScreen(tester, const SearchView(), () async {
        await tester.enterText(find.byType(TextField), 'zzzzzz');
        await tester.pumpAndSettle();
        expect(find.text(l10n.searchEmpty), findsOneWidget);
      });
    });

    testWidgets('typing a term finds a seeded entry', (tester) async {
      await seed(id: 'v1', title: 'Aula de Cálculo', author: 'Silva');

      await withScreen(tester, const SearchView(), () async {
        await tester.enterText(find.byType(TextField), 'cálculo');
        await tester.pumpAndSettle();

        expect(find.text('Aula de Cálculo'), findsOneWidget);
        expect(find.text(l10n.searchEmpty), findsNothing);
      });
    });

    testWidgets('a filter shows, and clears, the active-filter count',
        (tester) async {
      await seed(id: 'v1');

      await withScreen(tester, const SearchView(), () async {
        await tester.tap(find.text(l10n.searchKindVideo));
        await tester.pumpAndSettle();
        expect(find.text(l10n.searchClearFilters(1)), findsOneWidget);

        await tester.tap(find.text(l10n.searchKindAudio));
        await tester.pumpAndSettle();
        // Kind is single-choice: switching does not stack a second filter.
        expect(find.text(l10n.searchClearFilters(1)), findsOneWidget);

        await tester.tap(find.text(l10n.searchKindAudio));
        await tester.pumpAndSettle();
        expect(find.text(l10n.searchClearFilters(1)), findsNothing);
      });
    });

    testWidgets('the clear button resets the field', (tester) async {
      await withScreen(tester, const SearchView(), () async {
        await tester.enterText(find.byType(TextField), 'aula');
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip(l10n.actionClear));
        await tester.pumpAndSettle();

        expect(
          tester.widget<TextField>(find.byType(TextField)).controller?.text,
          isEmpty,
        );
      });
    });
  });

  group('ConverterView', () {
    testWidgets('the empty state names the safety guarantee', (tester) async {
      await withScreen(tester, const ConverterView(), () async {
        expect(find.text(l10n.converterEmptyTitle), findsOneWidget);
        // Section 11 promises the original survives; the copy must say so.
        expect(find.text(l10n.converterEmptyBody), findsOneWidget);
      });
    });

    testWidgets('renders a queued job by its output file name', (tester) async {
      await seed(id: 'v1');
      await container().read(conversionManagerProvider).enqueue(
            libraryEntryId: 'v1',
            sourcePath: '/library/v1.mp4',
            request: const ConversionRequest(target: ConversionTarget.mp3),
          );

      await withScreen(tester, const ConverterView(), settle: false, () async {
        expect(find.textContaining('.mp3'), findsWidgets);
        expect(find.text(l10n.converterEmptyTitle), findsNothing);
      });
    });
  });

  group('SettingsView', () {
    // Tall enough that the whole page is laid out: a ListView never builds
    // its off-screen children, and a missing row would otherwise look
    // identical to a row that scrolled away.
    const tall = Size(500, 2600);

    testWidgets('renders every section', (tester) async {
      await withScreen(tester, const SettingsView(), size: tall, () async {
        for (final section in [
          l10n.settingsSectionGeneral,
          l10n.settingsSectionDownloads,
          l10n.settingsSectionNotifications,
          l10n.settingsSectionBattery,
          l10n.settingsSectionStorage,
          l10n.settingsSectionPrivacy,
        ]) {
          expect(find.text(section), findsOneWidget, reason: section);
        }
      });
    });

    testWidgets('the internal search narrows to one section', (tester) async {
      await withScreen(tester, const SettingsView(), () async {
        await tester.enterText(find.byType(TextField).first, 'lgpd');
        await tester.pumpAndSettle();

        expect(find.text(l10n.settingsSectionPrivacy), findsOneWidget);
        expect(find.text(l10n.settingsSectionGeneral), findsNothing);
      });
    });

    testWidgets('an unmatched query says so rather than showing nothing',
        (tester) async {
      await withScreen(tester, const SettingsView(), () async {
        await tester.enterText(find.byType(TextField).first, 'zzzzzz');
        await tester.pumpAndSettle();

        expect(find.text(l10n.settingsNoResults), findsOneWidget);
      });
    });

    testWidgets('toggling a switch persists it', (tester) async {
      await withScreen(tester, const SettingsView(), size: tall, () async {
        final wifiOnly = find.ancestor(
          of: find.text(l10n.settingsWifiOnly),
          matching: find.byType(SwitchListTile),
        );
        expect(tester.widget<SwitchListTile>(wifiOnly).value, isFalse);

        await tester.tap(wifiOnly);
        await tester.pumpAndSettle();
        expect(tester.widget<SwitchListTile>(wifiOnly).value, isTrue);
      });

      final saved = await container().read(settingsRepositoryProvider).load();
      expect(saved.valueOrNull?.wifiOnly, isTrue);
    });

    testWidgets('analytics is off by default (LGPD/GDPR opt-in)',
        (tester) async {
      await withScreen(tester, const SettingsView(), size: tall, () async {
        final analytics = find.ancestor(
          of: find.text(l10n.settingsAnalytics),
          matching: find.byType(SwitchListTile),
        );
        expect(tester.widget<SwitchListTile>(analytics).value, isFalse);
      });
    });

    testWidgets('the concurrency slider is capped by the free plan',
        (tester) async {
      await withScreen(tester, const SettingsView(), () async {
        // Entitlements.free allows two parallel downloads; offering more
        // would let the UI promise what the plan will not honour.
        expect(tester.widget<Slider>(find.byType(Slider).first).max, 2);
      });
    });
  });

  group('VidoraShell', () {
    testWidgets('narrow windows get a bottom bar', (tester) async {
      await withRouter(
        tester,
        size: const Size(kRailBreakpoint - 40, 900),
        () async {
          expect(find.byType(NavigationBar), findsOneWidget);
          expect(find.byType(NavigationRail), findsNothing);
        },
      );
    });

    testWidgets('wide windows get a rail instead', (tester) async {
      await withRouter(
        tester,
        size: const Size(kRailBreakpoint + 400, 900),
        () async {
          expect(find.byType(NavigationRail), findsOneWidget);
          expect(find.byType(NavigationBar), findsNothing);
        },
      );
    });

    testWidgets('every destination navigates to its screen', (tester) async {
      await withRouter(tester, () async {
        // Each branch is its own navigator; walking them proves every
        // route in the table actually builds. The tap is scoped to the
        // bar because a destination's label repeats as its AppBar title
        // once the screen is open.
        for (final destination in <(String, Type)>[
          (l10n.navDownloads, DownloadsView),
          (l10n.navLibrary, LibraryView),
          (l10n.navSearch, SearchView),
          (l10n.navConverter, ConverterView),
          (l10n.navSettings, SettingsView),
        ]) {
          await tester.tap(
            find.descendant(
              of: find.byType(NavigationBar),
              matching: find.text(destination.$1),
            ),
          );
          await tester.pumpAndSettle();
          expect(
            find.byType(destination.$2),
            findsOneWidget,
            reason: 'destino ${destination.$1}',
          );
        }
      });
    });

    testWidgets('a shared link deep-links into Analyze pre-filled',
        (tester) async {
      const shared = 'https://cc.example.com/aula';
      await withRouter(
        tester,
        settle: false,
        initialLocation:
            '${Routes.analyze}?$kSharedUrlParam=${Uri.encodeComponent(shared)}',
        () async {
          await tester.pump();
          expect(find.text(shared), findsOneWidget);
        },
      );
    });
  });

  /// Ninguém configura a fonte do sistema em 2x por capricho: quem faz isso
  /// depende disso para ler. Uma tela que estoura nesse tamanho não fica
  /// feia — fica ilegível na parte que foi empurrada para fora.
  group('escala de texto do sistema', () {
    for (final scale in [2.0, 3.0]) {
      testWidgets('a Biblioteca renderiza sem estouro em ${scale}x',
          (tester) async {
        await seed(id: 'l1', title: 'Aula aberta sobre tipografia acessível');
        await withScreen(tester, const LibraryView(), textScale: scale,
            () async {
          expect(tester.takeException(), isNull);
        });
      });

      testWidgets('a Busca renderiza sem estouro em ${scale}x', (tester) async {
        await seed(id: 's1', title: 'Palestra sobre leitores de tela');
        await withScreen(tester, const SearchView(), textScale: scale,
            () async {
          expect(tester.takeException(), isNull);
        });
      });

      testWidgets(
        'o Conversor renderiza sem estouro em ${scale}x',
        (tester) async {
          await withScreen(tester, const ConverterView(), textScale: scale,
              () async {
            expect(tester.takeException(), isNull);
          });
        },
      );

      testWidgets(
        'os Ajustes renderizam sem estouro em ${scale}x',
        (tester) async {
          await withScreen(tester, const SettingsView(), textScale: scale,
              () async {
            expect(tester.takeException(), isNull);
          });
        },
      );

      testWidgets('a fila renderiza sem estouro em ${scale}x', (tester) async {
        await withScreen(tester, const DownloadsView(), textScale: scale,
            () async {
          expect(tester.takeException(), isNull);
        });
      });
    }
  });
}
