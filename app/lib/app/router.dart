/// Application routing (go_router, section 5).
///
/// Responsibility: declare the route table and the shell that hosts the
/// primary destinations, plus the `vidora://` deep link contract used by
/// the system share sheet (section 3).
library;

import 'package:go_router/go_router.dart';

import '../features/analyze/presentation/analyze_view.dart';
import '../features/converter/presentation/converter_view.dart';
import '../features/downloads/presentation/downloads_view.dart';
import '../features/library/presentation/library_view.dart';
import '../features/search/presentation/search_view.dart';
import 'shell.dart';

/// Route paths, referenced instead of raw strings.
abstract final class Routes {
  /// Analyze (home).
  static const String analyze = '/';

  /// Download queue.
  static const String downloads = '/downloads';

  /// Library of finished downloads.
  static const String library = '/library';

  /// Global search over the library.
  static const String search = '/search';

  /// Conversion queue.
  static const String converter = '/converter';
}

/// Query parameter carrying a shared URL into [Routes.analyze],
/// e.g. `vidora://analyze?url=https%3A%2F%2F…`.
const String kSharedUrlParam = 'url';

/// Builds the router. [initialLocation] is injectable for tests.
GoRouter buildRouter({String initialLocation = Routes.analyze}) => GoRouter(
      initialLocation: initialLocation,
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) =>
              VidoraShell(navigationShell: navigationShell),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: Routes.analyze,
                  builder: (context, state) => AnalyzeView(
                    sharedUrl: state.uri.queryParameters[kSharedUrlParam],
                  ),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: Routes.downloads,
                  builder: (context, state) => const DownloadsView(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: Routes.library,
                  builder: (context, state) => const LibraryView(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: Routes.search,
                  builder: (context, state) => const SearchView(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: Routes.converter,
                  builder: (context, state) => const ConverterView(),
                ),
              ],
            ),
          ],
        ),
      ],
    );
