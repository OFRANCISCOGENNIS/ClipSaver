// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Vidora';

  @override
  String get actionRetry => 'Try again';

  @override
  String get actionRetryShort => 'Retry';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionClear => 'Clear';

  @override
  String get actionDismiss => 'Dismiss';

  @override
  String get actionPause => 'Pause';

  @override
  String get actionResume => 'Resume';

  @override
  String get actionContinue => 'Continue';

  @override
  String get valueUnavailable => '—';

  @override
  String get navAnalyze => 'Analyze';

  @override
  String get navDownloads => 'Downloads';

  @override
  String get navLibrary => 'Library';

  @override
  String get navSearch => 'Search';

  @override
  String get navConverter => 'Convert';

  @override
  String get navSettings => 'Settings';

  @override
  String get analyzeUrlHint => 'Paste an authorized link';

  @override
  String get analyzeAction => 'Analyze';

  @override
  String analyzeClipboardPrompt(String url) {
    return 'Paste the copied link? $url';
  }

  @override
  String get analyzeRecents => 'Recent';

  @override
  String get analyzeEmptyTitle => 'Download only what is allowed';

  @override
  String get analyzeEmptyBody =>
      'Vidora accepts links with an official download, an open license, content from your own profile, or direct public files.';

  @override
  String get analyzeSkeletonSemantics => 'Analyzing the link';

  @override
  String get analyzeGenericError => 'This link could not be analyzed.';

  @override
  String analyzeQueuedSnack(String title) {
    return '“$title” was queued.';
  }

  @override
  String get analyzeSeeQueue => 'View queue';

  @override
  String get resultQuality => 'Quality';

  @override
  String resultDownload(String quality) {
    return 'Download $quality';
  }

  @override
  String resultLicenseTerms(String terms) {
    return 'License terms: $terms.';
  }

  @override
  String get ineligibleTitle => 'Download not authorized';

  @override
  String get ineligibleTechnicalDetails => 'Technical details';

  @override
  String ineligibleDetailBody(String host, String basis) {
    return 'Analyzed origin: $host\nAuthorization basis found: $basis\nAvailable formats: none';
  }

  @override
  String badgeAuthorization(String basis) {
    return 'Authorization: $basis';
  }

  @override
  String badgeUnauthorized(String basis) {
    return 'Download not authorized: $basis';
  }

  @override
  String get sourceOfficialApi => 'Official download';

  @override
  String get sourceOpenLicense => 'Open license';

  @override
  String get sourceUserOwned => 'Your content';

  @override
  String get sourceDirectFile => 'Direct file';

  @override
  String get sourceNone => 'Not authorized';

  @override
  String get licensePublicDomain => 'Public domain';

  @override
  String get licenseCc0 => 'CC0 license';

  @override
  String get licenseCcBy => 'CC-BY license';

  @override
  String get licenseCcBySa => 'CC-BY-SA license';

  @override
  String get licenseCcByNc => 'CC-BY-NC license';

  @override
  String get licenseCcByNd => 'CC-BY-ND license';

  @override
  String get licenseRestrictionAttribution => 'attribution required';

  @override
  String get licenseRestrictionShareAlike => 'share alike';

  @override
  String get licenseRestrictionNonCommercial => 'non-commercial use';

  @override
  String get licenseRestrictionNoDerivatives => 'no derivative works';

  @override
  String get downloadsPauseAll => 'Pause all';

  @override
  String get downloadsResumeAll => 'Resume all';

  @override
  String get downloadsClearFinished => 'Clear finished';

  @override
  String get downloadsEmptyTitle => 'No downloads queued';

  @override
  String get downloadsEmptyBody => 'Analyze an authorized link to get started.';

  @override
  String get downloadsCancelTitle => 'Cancel download?';

  @override
  String downloadsCancelBody(String title) {
    return 'Progress on “$title” will be discarded.';
  }

  @override
  String get downloadsCancelKeep => 'Keep';

  @override
  String get downloadsCancelConfirm => 'Cancel download';

  @override
  String downloadsEta(String value) {
    return 'ETA $value';
  }

  @override
  String downloadsProgressSemantics(String state, int percent) {
    return '$state, $percent percent';
  }

  @override
  String downloadsPauseItem(String title) {
    return 'Pause “$title”';
  }

  @override
  String downloadsResumeItem(String title) {
    return 'Resume “$title”';
  }

  @override
  String downloadsRetryItem(String title) {
    return 'Retry “$title”';
  }

  @override
  String downloadsCancelItem(String title) {
    return 'Cancel “$title”';
  }

  @override
  String downloadsItemSemantics(String title, String state) {
    return '$title, $state';
  }

  @override
  String downloadsAnnounceDone(String title) {
    return '“$title” finished';
  }

  @override
  String downloadsAnnounceFailed(String title) {
    return '“$title” failed';
  }

  @override
  String get downloadStateQueued => 'Queued';

  @override
  String get downloadStateConnecting => 'Connecting';

  @override
  String get downloadStateDownloading => 'Downloading';

  @override
  String get downloadStatePaused => 'Paused';

  @override
  String get downloadStateCompleted => 'Finishing';

  @override
  String get downloadStateVerifying => 'Verifying integrity';

  @override
  String get downloadStateDone => 'Done';

  @override
  String get downloadStateFailed => 'Failed';

  @override
  String get downloadStateCanceled => 'Canceled';

  @override
  String get libraryViewAsList => 'View as list';

  @override
  String get libraryViewAsGrid => 'View as grid';

  @override
  String get librarySort => 'Sort';

  @override
  String get librarySortDownloadedAt => 'Download date';

  @override
  String get librarySortName => 'Name';

  @override
  String get librarySortSize => 'Size';

  @override
  String get librarySortDuration => 'Duration';

  @override
  String get librarySortPlatform => 'Platform';

  @override
  String get libraryTabVideos => 'Videos';

  @override
  String get libraryTabAudios => 'Audio';

  @override
  String get libraryTabFavorites => 'Favorites';

  @override
  String get libraryTabRecents => 'Recent';

  @override
  String libraryTabWithCount(String label, int count) {
    return '$label ($count)';
  }

  @override
  String get libraryFileMissing => 'File not found';

  @override
  String get libraryFavoriteAdd => 'Add to favorites';

  @override
  String get libraryFavoriteRemove => 'Remove from favorites';

  @override
  String get libraryEmptyTitle => 'Nothing here yet';

  @override
  String get libraryEmptyBody => 'Finished downloads show up in this tab.';

  @override
  String get searchHint => 'Name, author, platform or tag';

  @override
  String get searchApproximate => 'No exact match — showing similar results.';

  @override
  String get searchEmpty => 'No results for this search.';

  @override
  String searchClearFilters(int count) {
    return 'Clear ($count)';
  }

  @override
  String get searchKindVideo => 'Video';

  @override
  String get searchKindAudio => 'Audio';

  @override
  String get searchDurationShort => '< 5 min';

  @override
  String get searchDurationMedium => '5–20 min';

  @override
  String get searchDurationLong => '> 20 min';

  @override
  String get converterClearFinished => 'Clear finished';

  @override
  String get converterEmptyTitle => 'No conversions';

  @override
  String get converterEmptyBody =>
      'Pick an item from the library to convert. The original file is kept.';

  @override
  String get conversionStateQueued => 'Queued';

  @override
  String get conversionStateConverting => 'Converting';

  @override
  String get conversionStateCompleted => 'Done';

  @override
  String get conversionStateFailed => 'Failed';

  @override
  String get conversionStateCanceled => 'Canceled';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSearchHint => 'Search settings';

  @override
  String get settingsNoResults => 'No settings found.';

  @override
  String get settingsSectionGeneral => 'General';

  @override
  String get settingsSectionDownloads => 'Downloads';

  @override
  String get settingsSectionNotifications => 'Notifications';

  @override
  String get settingsSectionBattery => 'Battery and data';

  @override
  String get settingsSectionStorage => 'Storage';

  @override
  String get settingsSectionPrivacy => 'Privacy';

  @override
  String get settingsSectionAbout => 'About';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsClipboardDetection => 'Detect links in the clipboard';

  @override
  String get settingsConcurrency => 'Parallel downloads';

  @override
  String get settingsSpeedLimit => 'Speed limit';

  @override
  String get settingsWifiOnly => 'Wi-Fi only';

  @override
  String get settingsResumeOnReconnect => 'Resume on reconnect';

  @override
  String get settingsNotifyOnComplete => 'Notify when finished';

  @override
  String get settingsNotifyOnError => 'Notify on error';

  @override
  String get settingsNotificationStyle => 'Notification style';

  @override
  String get settingsDailySummary => 'Daily summary';

  @override
  String get settingsBatterySaver => 'Saver mode';

  @override
  String get settingsBatterySaverBody =>
      'Cuts parallel downloads and turns animations off.';

  @override
  String get settingsPauseOnLowBattery => 'Pause on low battery';

  @override
  String settingsPauseOnLowBatteryBody(int percent) {
    return 'Below $percent%.';
  }

  @override
  String get settingsThumbnailCache => 'Thumbnail cache';

  @override
  String settingsMegabytes(int value) {
    return '$value MB';
  }

  @override
  String get settingsTrashRetention => 'Trash retention';

  @override
  String settingsDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get settingsAnalytics => 'Send usage data';

  @override
  String get settingsAnalyticsBody =>
      'Off by default. Nothing is sent without your permission.';

  @override
  String get settingsPolicy => 'Responsible use policy';

  @override
  String get settingsPolicyBody =>
      'Vidora only downloads content authorized by the origin platform or by the rights holder.';

  @override
  String get settingsAbout => 'Version and licenses';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'Automatic';

  @override
  String get notificationStyleSound => 'Sound';

  @override
  String get notificationStyleVibrate => 'Vibrate';

  @override
  String get notificationStyleSilent => 'Silent';

  @override
  String get categoryMusic => 'Music';

  @override
  String get categoryPodcast => 'Podcast';

  @override
  String get categoryLecture => 'Lecture';

  @override
  String get categoryTutorial => 'Tutorial';

  @override
  String get categoryUnknown => 'Uncategorized';

  @override
  String get presetMaxCompatibility => 'Maximum compatibility';

  @override
  String get presetSmallestSize => 'Smallest size';

  @override
  String get presetPodcastAudio => 'Podcast audio';

  @override
  String get presetLossless => 'Lossless';

  @override
  String get onboardingFinish => 'Got it, let\'s start';

  @override
  String get onboardingTitle1 => 'Only what is allowed';

  @override
  String get onboardingBody1 =>
      'Vidora downloads media when the origin platform or the rights holder authorizes it. Every link is checked before any download starts.';

  @override
  String get onboardingTitle2 => 'Four ways to be authorized';

  @override
  String get onboardingBody2 =>
      'An official platform download, an open license (such as Creative Commons), content from your own profile, or a direct public file. You see which one applied to each item.';

  @override
  String get onboardingTitle3 => 'What the app does not do';

  @override
  String get onboardingBody3 =>
      'No working around DRM, paywalls or someone else\'s login. When a link cannot be downloaded, we explain why and, when one exists, the legitimate path.';
}
