/// Navigation shell hosting the primary destinations.
///
/// Responsibility: adapt the navigation chrome to the window size — a
/// bottom bar on phones, a rail on tablets and desktop (section 3 asks for
/// one codebase across six platforms).
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../l10n/l10n.dart';
import 'theme/tokens.dart';

/// Width at which the bottom bar gives way to a navigation rail.
const double kRailBreakpoint = 720;

/// Shell with the app's primary destinations.
class VidoraShell extends StatelessWidget {
  /// Creates the shell around [navigationShell].
  const VidoraShell({required this.navigationShell, super.key});

  /// The branch navigator provided by go_router.
  final StatefulNavigationShell navigationShell;

  // Built per frame rather than held in a const list: the labels are
  // localized, so they have to be resolved against the current context.
  static List<_Destination> _destinationsFor(AppLocalizations l10n) => [
        _Destination(
          label: l10n.navAnalyze,
          icon: Icons.search_outlined,
          selectedIcon: Icons.search,
        ),
        _Destination(
          label: l10n.navDownloads,
          icon: Icons.download_outlined,
          selectedIcon: Icons.download,
        ),
        _Destination(
          label: l10n.navLibrary,
          icon: Icons.video_library_outlined,
          selectedIcon: Icons.video_library,
        ),
        _Destination(
          label: l10n.navSearch,
          icon: Icons.manage_search_outlined,
          selectedIcon: Icons.manage_search,
        ),
        _Destination(
          label: l10n.navConverter,
          icon: Icons.swap_horiz_outlined,
          selectedIcon: Icons.swap_horiz,
        ),
        _Destination(
          label: l10n.navSettings,
          icon: Icons.settings_outlined,
          selectedIcon: Icons.settings,
        ),
      ];

  void _go(int index) => navigationShell.goBranch(
        index,
        initialLocation: index == navigationShell.currentIndex,
      );

  @override
  Widget build(BuildContext context) {
    final destinations = _destinationsFor(context.l10n);
    final useRail = MediaQuery.sizeOf(context).width >= kRailBreakpoint;
    if (!useRail) {
      return Scaffold(
        body: navigationShell,
        bottomNavigationBar: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: _go,
          destinations: [
            for (final destination in destinations)
              NavigationDestination(
                icon: Icon(destination.icon),
                selectedIcon: Icon(destination.selectedIcon),
                label: destination.label,
              ),
          ],
        ),
      );
    }
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: _go,
            labelType: NavigationRailLabelType.all,
            destinations: [
              for (final destination in destinations)
                NavigationRailDestination(
                  icon: Icon(destination.icon),
                  selectedIcon: Icon(destination.selectedIcon),
                  label: Text(destination.label),
                ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: navigationShell),
        ],
      ),
    );
  }
}

final class _Destination {
  const _Destination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

/// Standard page padding, on the 4px grid.
const EdgeInsets kPagePadding = EdgeInsets.all(VidoraSpacing.lg);
