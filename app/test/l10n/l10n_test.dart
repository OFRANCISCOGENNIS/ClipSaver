/// Tests for the localization layer (section 16).
///
/// The point of these is regression, not coverage: a missing translation
/// or a duplicated label does not crash — it ships as Portuguese text in
/// an English UI, or as two queue states that read identically. Both are
/// invisible without an assertion.
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vidora/core/domain/value_objects/license.dart';
import 'package:vidora/features/analyze/domain/authorization_source.dart';
import 'package:vidora/features/converter/domain/conversion_job.dart';
import 'package:vidora/features/converter/domain/conversion_request.dart';
import 'package:vidora/features/downloads/domain/download_state.dart';
import 'package:vidora/features/intelligence/domain/media_classifier.dart';
import 'package:vidora/features/library/presentation/library_state.dart';
import 'package:vidora/features/search/domain/search_query.dart';
import 'package:vidora/features/settings/domain/app_settings.dart';
import 'package:vidora/l10n/l10n.dart';

import '../support/localized_app.dart';

/// Reads an ARB file's translatable keys (`@`-prefixed entries are
/// metadata for the tooling, not strings).
Set<String> arbKeys(String path) {
  final decoded = jsonDecode(File(path).readAsStringSync()) as Map;
  return decoded.keys
      .cast<String>()
      .where((key) => !key.startsWith('@'))
      .toSet();
}

void main() {
  group('ARB files', () {
    const template = 'lib/l10n/app_pt.arb';
    const translations = ['lib/l10n/app_en.arb', 'lib/l10n/app_es.arb'];

    test('every translation covers exactly the template key set', () {
      final expected = arbKeys(template);
      expect(expected, isNotEmpty);

      for (final path in translations) {
        final actual = arbKeys(path);
        expect(
          actual.difference(expected),
          isEmpty,
          reason: '$path has keys the template does not',
        );
        expect(
          expected.difference(actual),
          isEmpty,
          reason: '$path is missing keys — they would render in Portuguese',
        );
      }
    });

    test('no translation leaves a value empty', () {
      for (final path in [template, ...translations]) {
        final decoded =
            jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
        for (final entry in decoded.entries) {
          if (entry.key.startsWith('@')) continue;
          expect(
            (entry.value as String).trim(),
            isNotEmpty,
            reason: '${entry.key} is blank in $path',
          );
        }
      }
    });

    test('the three declared locales are the three supported ones', () {
      expect(
        AppLocalizations.supportedLocales.map((l) => l.languageCode).toSet(),
        {'pt', 'en', 'es'},
      );
    });
  });

  group('domain → text mappings', () {
    /// Asserts every value of an enum maps to distinct, non-empty text in
    /// every shipped language.
    Future<void> expectDistinctLabels<T>(
      List<T> values,
      String Function(T value, AppLocalizations l10n) label,
    ) async {
      for (final locale in AppLocalizations.supportedLocales) {
        final l10n = await loadL10n(locale);
        final labels = [for (final value in values) label(value, l10n)];
        expect(labels, everyElement(isNotEmpty), reason: '$locale');
        expect(
          labels.toSet(),
          hasLength(values.length),
          reason: 'duplicate label in $locale: $labels',
        );
      }
    }

    test('authorization sources', () async {
      await expectDistinctLabels(
        AuthorizationSource.values,
        (value, l10n) => value.label(l10n),
      );
    });

    test('download states', () async {
      await expectDistinctLabels(
        DownloadState.values,
        (value, l10n) => value.label(l10n),
      );
    });

    test('conversion states', () async {
      await expectDistinctLabels(
        ConversionState.values,
        (value, l10n) => value.label(l10n),
      );
    });

    test('conversion presets', () async {
      await expectDistinctLabels(
        ConversionPreset.values,
        (value, l10n) => value.label(l10n),
      );
    });

    test('library tabs', () async {
      await expectDistinctLabels(
        LibraryTab.values,
        (value, l10n) => value.label(l10n),
      );
    });

    test('duration buckets', () async {
      await expectDistinctLabels(
        DurationBucket.values,
        (value, l10n) => value.label(l10n),
      );
    });

    test('content categories', () async {
      await expectDistinctLabels(
        ContentCategory.values,
        (value, l10n) => value.label(l10n),
      );
    });

    test('theme modes', () async {
      await expectDistinctLabels(
        AppThemeMode.values,
        (value, l10n) => value.label(l10n),
      );
    });

    test('notification styles', () async {
      await expectDistinctLabels(
        NotificationStyle.values,
        (value, l10n) => value.label(l10n),
      );
    });

    test('licenses that authorize a download all have a badge name', () async {
      const authorizing = [
        License.publicDomain,
        License.cc0,
        License.ccBy,
        License.ccBySa,
        License.ccByNc,
        License.ccByNd,
      ];
      for (final locale in AppLocalizations.supportedLocales) {
        final l10n = await loadL10n(locale);
        final labels = [for (final license in authorizing) license.label(l10n)];
        expect(labels, everyElement(isNotEmpty), reason: '$locale');
        expect(labels.toSet(), hasLength(authorizing.length));
        // The SPDX id leaking into the UI is the fallback for unmapped
        // licenses; a mapped one must never hit it.
        for (var i = 0; i < authorizing.length; i++) {
          expect(labels[i], isNot(authorizing[i].spdxId), reason: '$locale');
        }
      }
    });

    test('license restrictions', () async {
      await expectDistinctLabels(
        LicenseRestriction.values,
        (value, l10n) => value.label(l10n),
      );
    });
  });

  group('AppLanguage', () {
    test('maps to a locale the app actually supports', () {
      for (final language in AppLanguage.values) {
        expect(
          AppLocalizations.supportedLocales
              .map((locale) => locale.languageCode)
              .contains(language.locale.languageCode),
          isTrue,
          reason: '${language.code} resolves to no shipped translation',
        );
      }
    });

    test('splits a region tag instead of using it as a language code', () {
      // 'pt-BR' as a bare languageCode would match nothing and silently
      // fall back to the first supported locale.
      expect(AppLanguage.ptBr.locale, const Locale('pt', 'BR'));
      expect(AppLanguage.en.locale, const Locale('en'));
      expect(AppLanguage.es.locale, const Locale('es'));
    });

    test('language names are not translated', () async {
      // A user hunting for their own language scans for its endonym.
      expect(AppLanguage.en.label, 'English');
      expect(AppLanguage.es.label, 'Español');
      expect(AppLanguage.ptBr.label, 'Português (Brasil)');
    });
  });
}
