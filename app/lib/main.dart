/// Application entry point.
///
/// Responsibility: resolve the platform services once, then hand a
/// fully-wired provider container to the widget tree. Every platform
/// difference is behind [initPlatformServices], so this file compiles
/// unchanged for all six targets.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/providers.dart';
import 'app/router.dart';
import 'app/shared_link_routing.dart';
import 'app/theme/app_theme.dart';
import 'core/platform/platform_services.dart';
import 'features/settings/domain/app_settings.dart';
import 'features/settings/presentation/onboarding_view.dart';
import 'features/settings/presentation/settings_view_model.dart';
import 'l10n/l10n.dart';

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

/// Root widget: theme, routing, language and system-driven brightness.
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

  StreamSubscription<String>? _sharedLinks;

  @override
  void initState() {
    super.initState();
    // Read, not watch, and here rather than in a screen: the notifier has
    // to be subscribed to the queue from boot, or a download that finishes
    // while the user is on another screen ends silently.
    ref.read(downloadNotifierProvider);
    _listenForSharedLinks();
  }

  @override
  void dispose() {
    unawaited(_sharedLinks?.cancel());
    super.dispose();
  }

  /// Picks up the link that launched the app, then keeps listening for
  /// shares that arrive while it is running.
  ///
  /// The link only ever *opens Analyze pre-filled*. It is never analyzed
  /// automatically and never enqueued: eligibility is the server's call
  /// (section 2.2), and a share that started a download by itself would be
  /// a way to make the app fetch a URL the user never confirmed.
  void _listenForSharedLinks() {
    final port = ref.read(sharedLinkPortProvider);
    unawaited(
      port.initialLink().then((url) {
        if (url != null && mounted) _router.go(analyzeLocationFor(url));
      }),
    );
    _sharedLinks = port.links().listen((url) {
      if (mounted) _router.go(analyzeLocationFor(url));
    });
  }

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
    // Null while the settings load, and null is exactly what tells
    // MaterialApp to follow the device language — the right default on a
    // first run, before the user has picked anything.
    final locale = settings.valueOrNull?.language.locale;

    final light = buildVidoraTheme(Brightness.light);
    final dark = buildVidoraTheme(Brightness.dark);

    // The compliance onboarding gates the app on first run (section 2.3),
    // so it cannot be skipped by deep-linking past it.
    final needsOnboarding = settings.valueOrNull?.onboardingCompleted == false;
    if (needsOnboarding) {
      return MaterialApp(
        // onGenerateTitle, not title: it runs with a context that already
        // has the localizations, so the task-switcher name follows the
        // chosen language instead of freezing at build time.
        onGenerateTitle: (context) => context.l10n.appName,
        debugShowCheckedModeBanner: false,
        theme: light,
        darkTheme: dark,
        themeMode: themeMode,
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: OnboardingView(onFinished: () => setState(() {})),
      );
    }

    return MaterialApp.router(
      onGenerateTitle: (context) => context.l10n.appName,
      debugShowCheckedModeBanner: false,
      theme: light,
      darkTheme: dark,
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: _router,
    );
  }
}
