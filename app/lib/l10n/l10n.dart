/// Localization access and the domain→text mapping (section 16).
///
/// Responsibility: keep every user-facing string out of the domain. The
/// domain enums below carry identity, wire values and behaviour; what a
/// user reads for each one lives in the ARB files and is resolved here,
/// in the presentation layer, where a [BuildContext] exists.
///
/// The mappings are exhaustive `switch` expressions on purpose: adding a
/// new enum value then fails to compile until its text exists in every
/// language, instead of silently rendering the enum's Dart name.
library;

import 'package:flutter/widgets.dart';

import '../core/domain/value_objects/license.dart';
import '../features/analyze/domain/authorization_source.dart';
import '../features/converter/domain/conversion_job.dart';
import '../features/converter/domain/conversion_request.dart';
import '../features/downloads/domain/download_state.dart';
import '../features/intelligence/domain/media_classifier.dart';
import '../features/library/presentation/library_state.dart';
import '../features/search/domain/search_query.dart';
import '../features/settings/domain/app_settings.dart';
import 'generated/app_localizations.dart';

export 'generated/app_localizations.dart';

/// Shorthand for [AppLocalizations.of], which every widget below needs.
extension L10nContext on BuildContext {
  /// The active translations.
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// Text for the authorization badge (section 2.3).
extension AuthorizationSourceL10n on AuthorizationSource {
  /// Localized badge label.
  String label(AppLocalizations l10n) => switch (this) {
        AuthorizationSource.officialApi => l10n.sourceOfficialApi,
        AuthorizationSource.openLicense => l10n.sourceOpenLicense,
        AuthorizationSource.userOwned => l10n.sourceUserOwned,
        AuthorizationSource.directFile => l10n.sourceDirectFile,
        AuthorizationSource.none => l10n.sourceNone,
      };
}

/// Text for a detected license.
extension LicenseL10n on License {
  /// Localized badge name, e.g. "Licença CC-BY" / "CC-BY license".
  ///
  /// Keyed on [License.spdxId] because that identifier — not the label —
  /// is what the catalogue and the backend agree on.
  String label(AppLocalizations l10n) => switch (spdxId) {
        'PDM' => l10n.licensePublicDomain,
        'CC0-1.0' => l10n.licenseCc0,
        'CC-BY-4.0' => l10n.licenseCcBy,
        'CC-BY-SA-4.0' => l10n.licenseCcBySa,
        'CC-BY-NC-4.0' => l10n.licenseCcByNc,
        'CC-BY-ND-4.0' => l10n.licenseCcByNd,
        // `allRightsReserved` and anything unmapped: the badge is only
        // ever shown for licenses that authorize a download, so this is
        // the fail-closed identifier rather than a user-facing name.
        _ => spdxId,
      };
}

/// Text for a license obligation.
extension LicenseRestrictionL10n on LicenseRestriction {
  /// Localized obligation, e.g. "atribuição obrigatória".
  String label(AppLocalizations l10n) => switch (this) {
        LicenseRestriction.attribution => l10n.licenseRestrictionAttribution,
        LicenseRestriction.shareAlike => l10n.licenseRestrictionShareAlike,
        LicenseRestriction.nonCommercial =>
          l10n.licenseRestrictionNonCommercial,
        LicenseRestriction.noDerivatives =>
          l10n.licenseRestrictionNoDerivatives,
      };
}

/// Text for a node of the download state machine (section 8.1).
extension DownloadStateL10n on DownloadState {
  /// Localized state name shown on the queue chip.
  String label(AppLocalizations l10n) => switch (this) {
        DownloadState.queued => l10n.downloadStateQueued,
        DownloadState.connecting => l10n.downloadStateConnecting,
        DownloadState.downloading => l10n.downloadStateDownloading,
        DownloadState.paused => l10n.downloadStatePaused,
        DownloadState.completed => l10n.downloadStateCompleted,
        DownloadState.verifying => l10n.downloadStateVerifying,
        DownloadState.done => l10n.downloadStateDone,
        DownloadState.failed => l10n.downloadStateFailed,
        DownloadState.canceled => l10n.downloadStateCanceled,
      };
}

/// Text for a node of the conversion state machine (section 11).
extension ConversionStateL10n on ConversionState {
  /// Localized state name.
  String label(AppLocalizations l10n) => switch (this) {
        ConversionState.queued => l10n.conversionStateQueued,
        ConversionState.converting => l10n.conversionStateConverting,
        ConversionState.completed => l10n.conversionStateCompleted,
        ConversionState.failed => l10n.conversionStateFailed,
        ConversionState.canceled => l10n.conversionStateCanceled,
      };
}

/// Text for a ready-made conversion (section 11).
extension ConversionPresetL10n on ConversionPreset {
  /// Localized preset name.
  String label(AppLocalizations l10n) => switch (this) {
        ConversionPreset.maxCompatibility => l10n.presetMaxCompatibility,
        ConversionPreset.smallestSize => l10n.presetSmallestSize,
        ConversionPreset.podcastAudio => l10n.presetPodcastAudio,
        ConversionPreset.lossless => l10n.presetLossless,
      };
}

/// Text for a library tab (section 9).
extension LibraryTabL10n on LibraryTab {
  /// Localized tab title.
  String label(AppLocalizations l10n) => switch (this) {
        LibraryTab.videos => l10n.libraryTabVideos,
        LibraryTab.audios => l10n.libraryTabAudios,
        LibraryTab.favorites => l10n.libraryTabFavorites,
        LibraryTab.recents => l10n.libraryTabRecents,
      };
}

/// Text for a duration filter (section 10).
extension DurationBucketL10n on DurationBucket {
  /// Localized chip text.
  String label(AppLocalizations l10n) => switch (this) {
        DurationBucket.short => l10n.searchDurationShort,
        DurationBucket.medium => l10n.searchDurationMedium,
        DurationBucket.long => l10n.searchDurationLong,
      };
}

/// Text for an auto-detected content category (section 15).
extension ContentCategoryL10n on ContentCategory {
  /// Localized category name.
  String label(AppLocalizations l10n) => switch (this) {
        ContentCategory.music => l10n.categoryMusic,
        ContentCategory.podcast => l10n.categoryPodcast,
        ContentCategory.lecture => l10n.categoryLecture,
        ContentCategory.tutorial => l10n.categoryTutorial,
        ContentCategory.unknown => l10n.categoryUnknown,
      };
}

/// Locale resolution for the language picker (section 16).
extension AppLanguageL10n on AppLanguage {
  /// The [Locale] this choice maps to.
  ///
  /// `pt-BR` becomes `Locale('pt', 'BR')`; Flutter then resolves it to the
  /// `pt` translations, so a Portuguese variant we do not ship still lands
  /// on Portuguese rather than falling through to the template default.
  Locale get locale {
    final parts = code.split('-');
    return parts.length == 2 ? Locale(parts[0], parts[1]) : Locale(parts[0]);
  }
}

/// Text for the theme picker (section 6.3).
extension AppThemeModeL10n on AppThemeMode {
  /// Localized option name.
  String label(AppLocalizations l10n) => switch (this) {
        AppThemeMode.light => l10n.themeLight,
        AppThemeMode.dark => l10n.themeDark,
        AppThemeMode.system => l10n.themeSystem,
      };
}

/// Text for the notification-style picker (section 16).
extension NotificationStyleL10n on NotificationStyle {
  /// Localized option name.
  String label(AppLocalizations l10n) => switch (this) {
        NotificationStyle.sound => l10n.notificationStyleSound,
        NotificationStyle.vibrate => l10n.notificationStyleVibrate,
        NotificationStyle.silent => l10n.notificationStyleSilent,
      };
}
