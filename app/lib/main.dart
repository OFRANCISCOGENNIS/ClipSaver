/// Application entry point.
///
/// Responsibility: resolve the platform services once, then hand a
/// fully-wired provider container to the widget tree. Every platform
/// difference is behind [initPlatformServices], so this file compiles
/// unchanged for all six targets.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/providers.dart';
import 'app/router.dart';
import 'app/theme/app_theme.dart';
import 'core/platform/platform_services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final platform = await initPlatformServices();

  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(platform.database),
        downloadsDirectoryProvider.overrideWithValue(
          platform.downloadsDirectory,
        ),
        downloadFileSystemProvider.overrideWithValue(platform.fileSystem),
      ],
      child: const VidoraApp(),
    ),
  );
}

/// Root widget: theme, routing and system-driven brightness.
class VidoraApp extends StatefulWidget {
  /// Creates the app.
  const VidoraApp({super.key});

  @override
  State<VidoraApp> createState() => _VidoraAppState();
}

class _VidoraAppState extends State<VidoraApp> {
  // Built once and kept: rebuilding the router would reset the navigation
  // stack on every hot reload and theme change.
  final _router = buildRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Vidora',
      debugShowCheckedModeBanner: false,
      theme: buildVidoraTheme(Brightness.light),
      darkTheme: buildVidoraTheme(Brightness.dark),
      // Section 6.3: follow the system, with MaterialApp's built-in
      // cross-fade animating the switch.
      themeMode: ThemeMode.system,
      routerConfig: _router,
    );
  }
}
