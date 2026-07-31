import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('pt')
  ];

  /// Nome do produto. Não é traduzido em nenhum idioma.
  ///
  /// In pt, this message translates to:
  /// **'Vidora'**
  String get appName;

  /// No description provided for @actionRetry.
  ///
  /// In pt, this message translates to:
  /// **'Tentar novamente'**
  String get actionRetry;

  /// No description provided for @actionRetryShort.
  ///
  /// In pt, this message translates to:
  /// **'Tentar de novo'**
  String get actionRetryShort;

  /// No description provided for @actionCancel.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get actionCancel;

  /// No description provided for @actionClear.
  ///
  /// In pt, this message translates to:
  /// **'Limpar'**
  String get actionClear;

  /// No description provided for @actionDismiss.
  ///
  /// In pt, this message translates to:
  /// **'Dispensar'**
  String get actionDismiss;

  /// No description provided for @actionPause.
  ///
  /// In pt, this message translates to:
  /// **'Pausar'**
  String get actionPause;

  /// No description provided for @actionResume.
  ///
  /// In pt, this message translates to:
  /// **'Continuar'**
  String get actionResume;

  /// Avança para a próxima página do onboarding.
  ///
  /// In pt, this message translates to:
  /// **'Continuar'**
  String get actionContinue;

  /// Traço usado quando ainda não há valor a mostrar (velocidade, ETA, porcentagem indeterminada).
  ///
  /// In pt, this message translates to:
  /// **'—'**
  String get valueUnavailable;

  /// No description provided for @navAnalyze.
  ///
  /// In pt, this message translates to:
  /// **'Analisar'**
  String get navAnalyze;

  /// No description provided for @navDownloads.
  ///
  /// In pt, this message translates to:
  /// **'Downloads'**
  String get navDownloads;

  /// No description provided for @navLibrary.
  ///
  /// In pt, this message translates to:
  /// **'Biblioteca'**
  String get navLibrary;

  /// No description provided for @navSearch.
  ///
  /// In pt, this message translates to:
  /// **'Buscar'**
  String get navSearch;

  /// No description provided for @navConverter.
  ///
  /// In pt, this message translates to:
  /// **'Converter'**
  String get navConverter;

  /// No description provided for @navSettings.
  ///
  /// In pt, this message translates to:
  /// **'Ajustes'**
  String get navSettings;

  /// No description provided for @analyzeUrlHint.
  ///
  /// In pt, this message translates to:
  /// **'Cole um link autorizado'**
  String get analyzeUrlHint;

  /// No description provided for @analyzeAction.
  ///
  /// In pt, this message translates to:
  /// **'Analisar'**
  String get analyzeAction;

  /// No description provided for @analyzeClipboardPrompt.
  ///
  /// In pt, this message translates to:
  /// **'Colar link copiado? {url}'**
  String analyzeClipboardPrompt(String url);

  /// No description provided for @analyzeRecents.
  ///
  /// In pt, this message translates to:
  /// **'Recentes'**
  String get analyzeRecents;

  /// No description provided for @analyzeEmptyTitle.
  ///
  /// In pt, this message translates to:
  /// **'Baixe apenas o que é permitido'**
  String get analyzeEmptyTitle;

  /// No description provided for @analyzeEmptyBody.
  ///
  /// In pt, this message translates to:
  /// **'O Vidora aceita links com download oficial, licença aberta, conteúdo do seu próprio perfil ou arquivos públicos diretos.'**
  String get analyzeEmptyBody;

  /// No description provided for @analyzeSkeletonSemantics.
  ///
  /// In pt, this message translates to:
  /// **'Analisando o link'**
  String get analyzeSkeletonSemantics;

  /// No description provided for @analyzeGenericError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível analisar este link.'**
  String get analyzeGenericError;

  /// No description provided for @analyzeQueuedSnack.
  ///
  /// In pt, this message translates to:
  /// **'“{title}” entrou na fila.'**
  String analyzeQueuedSnack(String title);

  /// No description provided for @analyzeSeeQueue.
  ///
  /// In pt, this message translates to:
  /// **'Ver fila'**
  String get analyzeSeeQueue;

  /// No description provided for @resultQuality.
  ///
  /// In pt, this message translates to:
  /// **'Qualidade'**
  String get resultQuality;

  /// No description provided for @resultDownload.
  ///
  /// In pt, this message translates to:
  /// **'Baixar {quality}'**
  String resultDownload(String quality);

  /// No description provided for @resultLicenseTerms.
  ///
  /// In pt, this message translates to:
  /// **'Condições da licença: {terms}.'**
  String resultLicenseTerms(String terms);

  /// No description provided for @ineligibleTitle.
  ///
  /// In pt, this message translates to:
  /// **'Download não autorizado'**
  String get ineligibleTitle;

  /// No description provided for @ineligibleTechnicalDetails.
  ///
  /// In pt, this message translates to:
  /// **'Detalhes técnicos'**
  String get ineligibleTechnicalDetails;

  /// No description provided for @ineligibleDetailBody.
  ///
  /// In pt, this message translates to:
  /// **'Origem analisada: {host}\nBase de autorização encontrada: {basis}\nFormatos liberados: nenhum'**
  String ineligibleDetailBody(String host, String basis);

  /// Rótulo de acessibilidade do selo de autorização.
  ///
  /// In pt, this message translates to:
  /// **'Autorização: {basis}'**
  String badgeAuthorization(String basis);

  /// No description provided for @badgeUnauthorized.
  ///
  /// In pt, this message translates to:
  /// **'Download não autorizado: {basis}'**
  String badgeUnauthorized(String basis);

  /// No description provided for @sourceOfficialApi.
  ///
  /// In pt, this message translates to:
  /// **'Download oficial'**
  String get sourceOfficialApi;

  /// No description provided for @sourceOpenLicense.
  ///
  /// In pt, this message translates to:
  /// **'Licença aberta'**
  String get sourceOpenLicense;

  /// No description provided for @sourceUserOwned.
  ///
  /// In pt, this message translates to:
  /// **'Seu conteúdo'**
  String get sourceUserOwned;

  /// No description provided for @sourceDirectFile.
  ///
  /// In pt, this message translates to:
  /// **'Arquivo direto'**
  String get sourceDirectFile;

  /// No description provided for @sourceNone.
  ///
  /// In pt, this message translates to:
  /// **'Não autorizado'**
  String get sourceNone;

  /// No description provided for @licensePublicDomain.
  ///
  /// In pt, this message translates to:
  /// **'Domínio público'**
  String get licensePublicDomain;

  /// No description provided for @licenseCc0.
  ///
  /// In pt, this message translates to:
  /// **'Licença CC0'**
  String get licenseCc0;

  /// No description provided for @licenseCcBy.
  ///
  /// In pt, this message translates to:
  /// **'Licença CC-BY'**
  String get licenseCcBy;

  /// No description provided for @licenseCcBySa.
  ///
  /// In pt, this message translates to:
  /// **'Licença CC-BY-SA'**
  String get licenseCcBySa;

  /// No description provided for @licenseCcByNc.
  ///
  /// In pt, this message translates to:
  /// **'Licença CC-BY-NC'**
  String get licenseCcByNc;

  /// No description provided for @licenseCcByNd.
  ///
  /// In pt, this message translates to:
  /// **'Licença CC-BY-ND'**
  String get licenseCcByNd;

  /// No description provided for @licenseRestrictionAttribution.
  ///
  /// In pt, this message translates to:
  /// **'atribuição obrigatória'**
  String get licenseRestrictionAttribution;

  /// No description provided for @licenseRestrictionShareAlike.
  ///
  /// In pt, this message translates to:
  /// **'compartilhamento pela mesma licença'**
  String get licenseRestrictionShareAlike;

  /// No description provided for @licenseRestrictionNonCommercial.
  ///
  /// In pt, this message translates to:
  /// **'uso não comercial'**
  String get licenseRestrictionNonCommercial;

  /// No description provided for @licenseRestrictionNoDerivatives.
  ///
  /// In pt, this message translates to:
  /// **'sem obras derivadas'**
  String get licenseRestrictionNoDerivatives;

  /// No description provided for @downloadsPauseAll.
  ///
  /// In pt, this message translates to:
  /// **'Pausar tudo'**
  String get downloadsPauseAll;

  /// No description provided for @downloadsResumeAll.
  ///
  /// In pt, this message translates to:
  /// **'Retomar tudo'**
  String get downloadsResumeAll;

  /// No description provided for @downloadsClearFinished.
  ///
  /// In pt, this message translates to:
  /// **'Limpar concluídos'**
  String get downloadsClearFinished;

  /// No description provided for @downloadsEmptyTitle.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum download na fila'**
  String get downloadsEmptyTitle;

  /// No description provided for @downloadsEmptyBody.
  ///
  /// In pt, this message translates to:
  /// **'Analise um link autorizado para começar.'**
  String get downloadsEmptyBody;

  /// No description provided for @downloadsCancelTitle.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar download?'**
  String get downloadsCancelTitle;

  /// No description provided for @downloadsCancelBody.
  ///
  /// In pt, this message translates to:
  /// **'O progresso de “{title}” será descartado.'**
  String downloadsCancelBody(String title);

  /// No description provided for @downloadsCancelKeep.
  ///
  /// In pt, this message translates to:
  /// **'Manter'**
  String get downloadsCancelKeep;

  /// No description provided for @downloadsCancelConfirm.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar download'**
  String get downloadsCancelConfirm;

  /// No description provided for @downloadsEta.
  ///
  /// In pt, this message translates to:
  /// **'ETA {value}'**
  String downloadsEta(String value);

  /// No description provided for @downloadsProgressSemantics.
  ///
  /// In pt, this message translates to:
  /// **'{state}, {percent} por cento'**
  String downloadsProgressSemantics(String state, int percent);

  /// No description provided for @downloadsPauseItem.
  ///
  /// In pt, this message translates to:
  /// **'Pausar “{title}”'**
  String downloadsPauseItem(String title);

  /// No description provided for @downloadsResumeItem.
  ///
  /// In pt, this message translates to:
  /// **'Continuar “{title}”'**
  String downloadsResumeItem(String title);

  /// No description provided for @downloadsRetryItem.
  ///
  /// In pt, this message translates to:
  /// **'Tentar “{title}” de novo'**
  String downloadsRetryItem(String title);

  /// No description provided for @downloadsCancelItem.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar “{title}”'**
  String downloadsCancelItem(String title);

  /// No description provided for @downloadsItemSemantics.
  ///
  /// In pt, this message translates to:
  /// **'{title}, {state}'**
  String downloadsItemSemantics(String title, String state);

  /// No description provided for @downloadsAnnounceDone.
  ///
  /// In pt, this message translates to:
  /// **'“{title}” concluído'**
  String downloadsAnnounceDone(String title);

  /// No description provided for @downloadsAnnounceFailed.
  ///
  /// In pt, this message translates to:
  /// **'“{title}” falhou'**
  String downloadsAnnounceFailed(String title);

  /// No description provided for @downloadsAnnounceQueueDone.
  ///
  /// In pt, this message translates to:
  /// **'Todos os downloads terminaram'**
  String get downloadsAnnounceQueueDone;

  /// No description provided for @downloadStateQueued.
  ///
  /// In pt, this message translates to:
  /// **'Na fila'**
  String get downloadStateQueued;

  /// No description provided for @downloadStateConnecting.
  ///
  /// In pt, this message translates to:
  /// **'Conectando'**
  String get downloadStateConnecting;

  /// No description provided for @downloadStateDownloading.
  ///
  /// In pt, this message translates to:
  /// **'Baixando'**
  String get downloadStateDownloading;

  /// No description provided for @downloadStatePaused.
  ///
  /// In pt, this message translates to:
  /// **'Pausado'**
  String get downloadStatePaused;

  /// No description provided for @downloadStateCompleted.
  ///
  /// In pt, this message translates to:
  /// **'Concluindo'**
  String get downloadStateCompleted;

  /// No description provided for @downloadStateVerifying.
  ///
  /// In pt, this message translates to:
  /// **'Verificando integridade'**
  String get downloadStateVerifying;

  /// No description provided for @downloadStateDone.
  ///
  /// In pt, this message translates to:
  /// **'Concluído'**
  String get downloadStateDone;

  /// No description provided for @downloadStateFailed.
  ///
  /// In pt, this message translates to:
  /// **'Falhou'**
  String get downloadStateFailed;

  /// No description provided for @downloadStateCanceled.
  ///
  /// In pt, this message translates to:
  /// **'Cancelado'**
  String get downloadStateCanceled;

  /// No description provided for @libraryViewAsList.
  ///
  /// In pt, this message translates to:
  /// **'Ver em lista'**
  String get libraryViewAsList;

  /// No description provided for @libraryViewAsGrid.
  ///
  /// In pt, this message translates to:
  /// **'Ver em grade'**
  String get libraryViewAsGrid;

  /// No description provided for @librarySort.
  ///
  /// In pt, this message translates to:
  /// **'Ordenar'**
  String get librarySort;

  /// No description provided for @librarySortDownloadedAt.
  ///
  /// In pt, this message translates to:
  /// **'Data do download'**
  String get librarySortDownloadedAt;

  /// No description provided for @librarySortName.
  ///
  /// In pt, this message translates to:
  /// **'Nome'**
  String get librarySortName;

  /// No description provided for @librarySortSize.
  ///
  /// In pt, this message translates to:
  /// **'Tamanho'**
  String get librarySortSize;

  /// No description provided for @librarySortDuration.
  ///
  /// In pt, this message translates to:
  /// **'Duração'**
  String get librarySortDuration;

  /// No description provided for @librarySortPlatform.
  ///
  /// In pt, this message translates to:
  /// **'Plataforma'**
  String get librarySortPlatform;

  /// No description provided for @libraryTabVideos.
  ///
  /// In pt, this message translates to:
  /// **'Vídeos'**
  String get libraryTabVideos;

  /// No description provided for @libraryTabAudios.
  ///
  /// In pt, this message translates to:
  /// **'Áudios'**
  String get libraryTabAudios;

  /// No description provided for @libraryTabFavorites.
  ///
  /// In pt, this message translates to:
  /// **'Favoritos'**
  String get libraryTabFavorites;

  /// No description provided for @libraryTabRecents.
  ///
  /// In pt, this message translates to:
  /// **'Recentes'**
  String get libraryTabRecents;

  /// No description provided for @libraryTabWithCount.
  ///
  /// In pt, this message translates to:
  /// **'{label} ({count})'**
  String libraryTabWithCount(String label, int count);

  /// No description provided for @libraryFileMissing.
  ///
  /// In pt, this message translates to:
  /// **'Arquivo não encontrado'**
  String get libraryFileMissing;

  /// No description provided for @libraryFavoriteAdd.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar aos favoritos'**
  String get libraryFavoriteAdd;

  /// No description provided for @libraryFavoriteRemove.
  ///
  /// In pt, this message translates to:
  /// **'Remover dos favoritos'**
  String get libraryFavoriteRemove;

  /// No description provided for @libraryEmptyTitle.
  ///
  /// In pt, this message translates to:
  /// **'Nada por aqui ainda'**
  String get libraryEmptyTitle;

  /// No description provided for @libraryEmptyBody.
  ///
  /// In pt, this message translates to:
  /// **'Downloads concluídos aparecem nesta aba.'**
  String get libraryEmptyBody;

  /// No description provided for @searchHint.
  ///
  /// In pt, this message translates to:
  /// **'Nome, autor, plataforma ou etiqueta'**
  String get searchHint;

  /// No description provided for @searchApproximate.
  ///
  /// In pt, this message translates to:
  /// **'Nada exato — mostrando resultados parecidos.'**
  String get searchApproximate;

  /// No description provided for @searchEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum resultado para esta busca.'**
  String get searchEmpty;

  /// No description provided for @searchClearFilters.
  ///
  /// In pt, this message translates to:
  /// **'Limpar ({count})'**
  String searchClearFilters(int count);

  /// No description provided for @searchKindVideo.
  ///
  /// In pt, this message translates to:
  /// **'Vídeo'**
  String get searchKindVideo;

  /// No description provided for @searchKindAudio.
  ///
  /// In pt, this message translates to:
  /// **'Áudio'**
  String get searchKindAudio;

  /// No description provided for @searchDurationShort.
  ///
  /// In pt, this message translates to:
  /// **'< 5 min'**
  String get searchDurationShort;

  /// No description provided for @searchDurationMedium.
  ///
  /// In pt, this message translates to:
  /// **'5–20 min'**
  String get searchDurationMedium;

  /// No description provided for @searchDurationLong.
  ///
  /// In pt, this message translates to:
  /// **'> 20 min'**
  String get searchDurationLong;

  /// No description provided for @converterClearFinished.
  ///
  /// In pt, this message translates to:
  /// **'Limpar concluídas'**
  String get converterClearFinished;

  /// No description provided for @converterEmptyTitle.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma conversão'**
  String get converterEmptyTitle;

  /// No description provided for @converterEmptyBody.
  ///
  /// In pt, this message translates to:
  /// **'Escolha um item da biblioteca para converter. O arquivo original é preservado.'**
  String get converterEmptyBody;

  /// No description provided for @conversionStateQueued.
  ///
  /// In pt, this message translates to:
  /// **'Na fila'**
  String get conversionStateQueued;

  /// No description provided for @conversionStateConverting.
  ///
  /// In pt, this message translates to:
  /// **'Convertendo'**
  String get conversionStateConverting;

  /// No description provided for @conversionStateCompleted.
  ///
  /// In pt, this message translates to:
  /// **'Concluída'**
  String get conversionStateCompleted;

  /// No description provided for @conversionStateFailed.
  ///
  /// In pt, this message translates to:
  /// **'Falhou'**
  String get conversionStateFailed;

  /// No description provided for @conversionStateCanceled.
  ///
  /// In pt, this message translates to:
  /// **'Cancelada'**
  String get conversionStateCanceled;

  /// No description provided for @settingsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Configurações'**
  String get settingsTitle;

  /// No description provided for @settingsSearchHint.
  ///
  /// In pt, this message translates to:
  /// **'Buscar nas configurações'**
  String get settingsSearchHint;

  /// No description provided for @settingsNoResults.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma configuração encontrada.'**
  String get settingsNoResults;

  /// No description provided for @settingsSectionGeneral.
  ///
  /// In pt, this message translates to:
  /// **'Geral'**
  String get settingsSectionGeneral;

  /// No description provided for @settingsSectionDownloads.
  ///
  /// In pt, this message translates to:
  /// **'Downloads'**
  String get settingsSectionDownloads;

  /// No description provided for @settingsSectionNotifications.
  ///
  /// In pt, this message translates to:
  /// **'Notificações'**
  String get settingsSectionNotifications;

  /// No description provided for @settingsSectionBattery.
  ///
  /// In pt, this message translates to:
  /// **'Bateria e dados'**
  String get settingsSectionBattery;

  /// No description provided for @settingsSectionStorage.
  ///
  /// In pt, this message translates to:
  /// **'Armazenamento'**
  String get settingsSectionStorage;

  /// No description provided for @settingsSectionPrivacy.
  ///
  /// In pt, this message translates to:
  /// **'Privacidade'**
  String get settingsSectionPrivacy;

  /// No description provided for @settingsSectionAbout.
  ///
  /// In pt, this message translates to:
  /// **'Sobre'**
  String get settingsSectionAbout;

  /// No description provided for @settingsTheme.
  ///
  /// In pt, this message translates to:
  /// **'Tema'**
  String get settingsTheme;

  /// No description provided for @settingsLanguage.
  ///
  /// In pt, this message translates to:
  /// **'Idioma'**
  String get settingsLanguage;

  /// No description provided for @settingsClipboardDetection.
  ///
  /// In pt, this message translates to:
  /// **'Detectar link na área de transferência'**
  String get settingsClipboardDetection;

  /// No description provided for @settingsConcurrency.
  ///
  /// In pt, this message translates to:
  /// **'Downloads simultâneos'**
  String get settingsConcurrency;

  /// No description provided for @settingsSpeedLimit.
  ///
  /// In pt, this message translates to:
  /// **'Limite de velocidade'**
  String get settingsSpeedLimit;

  /// No description provided for @settingsWifiOnly.
  ///
  /// In pt, this message translates to:
  /// **'Somente Wi-Fi'**
  String get settingsWifiOnly;

  /// No description provided for @settingsResumeOnReconnect.
  ///
  /// In pt, this message translates to:
  /// **'Retomar ao reconectar'**
  String get settingsResumeOnReconnect;

  /// No description provided for @settingsNotifyOnComplete.
  ///
  /// In pt, this message translates to:
  /// **'Avisar ao concluir'**
  String get settingsNotifyOnComplete;

  /// No description provided for @settingsNotifyOnError.
  ///
  /// In pt, this message translates to:
  /// **'Avisar em caso de erro'**
  String get settingsNotifyOnError;

  /// No description provided for @settingsNotificationStyle.
  ///
  /// In pt, this message translates to:
  /// **'Estilo das notificações'**
  String get settingsNotificationStyle;

  /// No description provided for @settingsDailySummary.
  ///
  /// In pt, this message translates to:
  /// **'Resumo diário'**
  String get settingsDailySummary;

  /// No description provided for @settingsBatterySaver.
  ///
  /// In pt, this message translates to:
  /// **'Modo economia'**
  String get settingsBatterySaver;

  /// No description provided for @settingsBatterySaverBody.
  ///
  /// In pt, this message translates to:
  /// **'Reduz downloads simultâneos e desliga animações.'**
  String get settingsBatterySaverBody;

  /// No description provided for @settingsPauseOnLowBattery.
  ///
  /// In pt, this message translates to:
  /// **'Pausar com bateria baixa'**
  String get settingsPauseOnLowBattery;

  /// No description provided for @settingsPauseOnLowBatteryBody.
  ///
  /// In pt, this message translates to:
  /// **'Abaixo de {percent}%.'**
  String settingsPauseOnLowBatteryBody(int percent);

  /// No description provided for @settingsThumbnailCache.
  ///
  /// In pt, this message translates to:
  /// **'Cache de miniaturas'**
  String get settingsThumbnailCache;

  /// No description provided for @settingsMegabytes.
  ///
  /// In pt, this message translates to:
  /// **'{value} MB'**
  String settingsMegabytes(int value);

  /// No description provided for @settingsTrashRetention.
  ///
  /// In pt, this message translates to:
  /// **'Retenção da lixeira'**
  String get settingsTrashRetention;

  /// No description provided for @settingsDays.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 dia} other{{count} dias}}'**
  String settingsDays(int count);

  /// No description provided for @settingsAnalytics.
  ///
  /// In pt, this message translates to:
  /// **'Enviar dados de uso'**
  String get settingsAnalytics;

  /// No description provided for @settingsAnalyticsBody.
  ///
  /// In pt, this message translates to:
  /// **'Desligado por padrão. Nada é enviado sem sua permissão.'**
  String get settingsAnalyticsBody;

  /// No description provided for @settingsPolicy.
  ///
  /// In pt, this message translates to:
  /// **'Política de uso responsável'**
  String get settingsPolicy;

  /// No description provided for @settingsPolicyBody.
  ///
  /// In pt, this message translates to:
  /// **'O Vidora só baixa conteúdo autorizado pela plataforma de origem ou pelo titular dos direitos.'**
  String get settingsPolicyBody;

  /// No description provided for @settingsAbout.
  ///
  /// In pt, this message translates to:
  /// **'Versão e licenças'**
  String get settingsAbout;

  /// No description provided for @themeLight.
  ///
  /// In pt, this message translates to:
  /// **'Claro'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In pt, this message translates to:
  /// **'Escuro'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In pt, this message translates to:
  /// **'Automático'**
  String get themeSystem;

  /// No description provided for @notificationStyleSound.
  ///
  /// In pt, this message translates to:
  /// **'Som'**
  String get notificationStyleSound;

  /// No description provided for @notificationStyleVibrate.
  ///
  /// In pt, this message translates to:
  /// **'Vibrar'**
  String get notificationStyleVibrate;

  /// No description provided for @notificationStyleSilent.
  ///
  /// In pt, this message translates to:
  /// **'Silencioso'**
  String get notificationStyleSilent;

  /// No description provided for @categoryMusic.
  ///
  /// In pt, this message translates to:
  /// **'Música'**
  String get categoryMusic;

  /// No description provided for @categoryPodcast.
  ///
  /// In pt, this message translates to:
  /// **'Podcast'**
  String get categoryPodcast;

  /// No description provided for @categoryLecture.
  ///
  /// In pt, this message translates to:
  /// **'Aula'**
  String get categoryLecture;

  /// No description provided for @categoryTutorial.
  ///
  /// In pt, this message translates to:
  /// **'Tutorial'**
  String get categoryTutorial;

  /// No description provided for @categoryUnknown.
  ///
  /// In pt, this message translates to:
  /// **'Sem categoria'**
  String get categoryUnknown;

  /// No description provided for @presetMaxCompatibility.
  ///
  /// In pt, this message translates to:
  /// **'Compatibilidade máxima'**
  String get presetMaxCompatibility;

  /// No description provided for @presetSmallestSize.
  ///
  /// In pt, this message translates to:
  /// **'Menor tamanho'**
  String get presetSmallestSize;

  /// No description provided for @presetPodcastAudio.
  ///
  /// In pt, this message translates to:
  /// **'Áudio para podcast'**
  String get presetPodcastAudio;

  /// No description provided for @presetLossless.
  ///
  /// In pt, this message translates to:
  /// **'Sem perdas'**
  String get presetLossless;

  /// No description provided for @onboardingFinish.
  ///
  /// In pt, this message translates to:
  /// **'Entendi, começar'**
  String get onboardingFinish;

  /// No description provided for @onboardingTitle1.
  ///
  /// In pt, this message translates to:
  /// **'Só o que é permitido'**
  String get onboardingTitle1;

  /// No description provided for @onboardingBody1.
  ///
  /// In pt, this message translates to:
  /// **'O Vidora baixa mídia quando a plataforma de origem ou o titular dos direitos autoriza. Todo link é verificado antes de qualquer download começar.'**
  String get onboardingBody1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In pt, this message translates to:
  /// **'Quatro formas de autorização'**
  String get onboardingTitle2;

  /// No description provided for @onboardingBody2.
  ///
  /// In pt, this message translates to:
  /// **'Download oficial da plataforma, licença aberta (como Creative Commons), conteúdo do seu próprio perfil, ou arquivo público de acesso direto. Você vê qual delas valeu em cada item.'**
  String get onboardingBody2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In pt, this message translates to:
  /// **'O que o app não faz'**
  String get onboardingTitle3;

  /// No description provided for @onboardingBody3.
  ///
  /// In pt, this message translates to:
  /// **'Nada de contornar DRM, paywall ou login de terceiros. Quando um link não pode ser baixado, explicamos o motivo e, quando existe, o caminho legítimo.'**
  String get onboardingBody3;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
