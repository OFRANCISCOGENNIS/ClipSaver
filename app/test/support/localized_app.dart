/// Test harness for localized widgets.
///
/// Every screen now reads its text through `AppLocalizations`, which is
/// only reachable when the delegates are installed. Centralizing that here
/// keeps each test from re-declaring the same four lines — and makes
/// pumping a screen in another language a one-argument change.
library;

import 'package:flutter/material.dart';
import 'package:vidora/l10n/l10n.dart';

/// Wraps [home] in a [MaterialApp] with the app's localization delegates.
///
/// Defaults to `pt` because that is the template language the assertions
/// are written against; pass [locale] to exercise a translation.
MaterialApp localizedApp({
  required Widget home,
  ThemeData? theme,
  Locale locale = const Locale('pt'),
}) =>
    MaterialApp(
      theme: theme,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    );

/// Loads the translations for [locale] outside a widget tree.
///
/// Used by tests that assert on a mapping (enum → text) rather than on a
/// rendered screen.
Future<AppLocalizations> loadL10n([Locale locale = const Locale('pt')]) =>
    AppLocalizations.delegate.load(locale);
