/// Navigation shell hosting the primary destinations.
///
/// Responsibility: adapt the navigation chrome to the window size — a
/// bottom bar on phones, a rail on tablets and desktop (section 3 asks for
/// one codebase across six platforms).
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'theme/tokens.dart';

/// Width at which the bottom bar gives way to a navigation rail.
const double kRailBreakpoint = 720;

/// Shell with the app's primary destinations.
class VidoraShell extends StatelessWidget {
  /// Creates the shell around [navigationShell].
  const VidoraShell({required this.navigationShell, super.key});

  /// The branch navigator provided by go_router.
  final StatefulNavigationShell navigationShell;

  static const List<_Destination> _destinations = [
    _Destination(
      label: 'Analisar',
      icon: Icons.search_outlined,
      selectedIcon: Icons.search,
    ),
    _Destination(
      label: 'Downloads',
      icon: Icons.download_outlined,
      selectedIcon: Icons.download,
    ),
  ];

  void _go(int index) => navigationShell.goBranch(
        index,
        initialLocation: index == navigationShell.currentIndex,
      );

  @override
  Widget build(BuildContext context) {
    final useRail = MediaQuery.sizeOf(context).width >= kRailBreakpoint;
    if (!useRail) {
      return Scaffold(
        body: navigationShell,
        bottomNavigationBar: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: _go,
          destinations: [
            for (final destination in _destinations)
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
              for (final destination in _destinations)
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
