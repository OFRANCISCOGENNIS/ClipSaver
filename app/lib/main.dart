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
import 'features/settings/domain/app_settings.dart';
import 'features/settings/presentation/onboarding_view.dart';
import 'features/settings/presentation/settings_view_model.dart';

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
class VidoraApp extends ConsumerStatefulWidget {
  /// Creates the app.
  const VidoraApp({super.key});

  @override
  ConsumerState<VidoraApp> createState() => _VidoraAppState();
}

class _VidoraAppState extends ConsumerState<VidoraApp> {
  // Built once and kept: rebuilding the router would reset the navigation
  // stack on every hot reload and theme change.
  final _router = buildRouter();

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsViewModelProvider);
    final themeMode = switch (settings.valueOrNull?.themeMode) {
      AppThemeMode.light => ThemeMode.light,
      AppThemeMode.dark => ThemeMode.dark,
      // Section 6.3: follow the system by default, with MaterialApp's
      // built-in cross-fade animating the switch.
      _ => ThemeMode.system,
    };

    final light = buildVidoraTheme(Brightness.light);
    final dark = buildVidoraTheme(Brightness.dark);

    // The compliance onboarding gates the app on first run (section 2.3),
    // so it cannot be skipped by deep-linking past it.
    final needsOnboarding = settings.valueOrNull?.onboardingCompleted == false;
    if (needsOnboarding) {
      return MaterialApp(
        title: 'Vidora',
        debugShowCheckedModeBanner: false,
        theme: light,
        darkTheme: dark,
        themeMode: themeMode,
        home: OnboardingView(onFinished: () => setState(() {})),
      );
    }

    return MaterialApp.router(
      title: 'Vidora',
      debugShowCheckedModeBanner: false,
      theme: light,
      darkTheme: dark,
      themeMode: themeMode,
      routerConfig: _router,
    );
  }
}
