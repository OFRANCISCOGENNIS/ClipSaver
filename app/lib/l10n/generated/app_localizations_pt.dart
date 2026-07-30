// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appName => 'Vidora';

  @override
  String get actionRetry => 'Tentar novamente';

  @override
  String get actionRetryShort => 'Tentar de novo';

  @override
  String get actionCancel => 'Cancelar';

  @override
  String get actionClear => 'Limpar';

  @override
  String get actionDismiss => 'Dispensar';

  @override
  String get actionPause => 'Pausar';

  @override
  String get actionResume => 'Continuar';

  @override
  String get actionContinue => 'Continuar';

  @override
  String get valueUnavailable => '—';

  @override
  String get navAnalyze => 'Analisar';

  @override
  String get navDownloads => 'Downloads';

  @override
  String get navLibrary => 'Biblioteca';

  @override
  String get navSearch => 'Buscar';

  @override
  String get navConverter => 'Converter';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get analyzeUrlHint => 'Cole um link autorizado';

  @override
  String get analyzeAction => 'Analisar';

  @override
  String analyzeClipboardPrompt(String url) {
    return 'Colar link copiado? $url';
  }

  @override
  String get analyzeRecents => 'Recentes';

  @override
  String get analyzeEmptyTitle => 'Baixe apenas o que é permitido';

  @override
  String get analyzeEmptyBody =>
      'O Vidora aceita links com download oficial, licença aberta, conteúdo do seu próprio perfil ou arquivos públicos diretos.';

  @override
  String get analyzeSkeletonSemantics => 'Analisando o link';

  @override
  String get analyzeGenericError => 'Não foi possível analisar este link.';

  @override
  String analyzeQueuedSnack(String title) {
    return '“$title” entrou na fila.';
  }

  @override
  String get analyzeSeeQueue => 'Ver fila';

  @override
  String get resultQuality => 'Qualidade';

  @override
  String resultDownload(String quality) {
    return 'Baixar $quality';
  }

  @override
  String resultLicenseTerms(String terms) {
    return 'Condições da licença: $terms.';
  }

  @override
  String get ineligibleTitle => 'Download não autorizado';

  @override
  String get ineligibleTechnicalDetails => 'Detalhes técnicos';

  @override
  String ineligibleDetailBody(String host, String basis) {
    return 'Origem analisada: $host\nBase de autorização encontrada: $basis\nFormatos liberados: nenhum';
  }

  @override
  String badgeAuthorization(String basis) {
    return 'Autorização: $basis';
  }

  @override
  String badgeUnauthorized(String basis) {
    return 'Download não autorizado: $basis';
  }

  @override
  String get sourceOfficialApi => 'Download oficial';

  @override
  String get sourceOpenLicense => 'Licença aberta';

  @override
  String get sourceUserOwned => 'Seu conteúdo';

  @override
  String get sourceDirectFile => 'Arquivo direto';

  @override
  String get sourceNone => 'Não autorizado';

  @override
  String get licensePublicDomain => 'Domínio público';

  @override
  String get licenseCc0 => 'Licença CC0';

  @override
  String get licenseCcBy => 'Licença CC-BY';

  @override
  String get licenseCcBySa => 'Licença CC-BY-SA';

  @override
  String get licenseCcByNc => 'Licença CC-BY-NC';

  @override
  String get licenseCcByNd => 'Licença CC-BY-ND';

  @override
  String get licenseRestrictionAttribution => 'atribuição obrigatória';

  @override
  String get licenseRestrictionShareAlike =>
      'compartilhamento pela mesma licença';

  @override
  String get licenseRestrictionNonCommercial => 'uso não comercial';

  @override
  String get licenseRestrictionNoDerivatives => 'sem obras derivadas';

  @override
  String get downloadsPauseAll => 'Pausar tudo';

  @override
  String get downloadsResumeAll => 'Retomar tudo';

  @override
  String get downloadsClearFinished => 'Limpar concluídos';

  @override
  String get downloadsEmptyTitle => 'Nenhum download na fila';

  @override
  String get downloadsEmptyBody => 'Analise um link autorizado para começar.';

  @override
  String get downloadsCancelTitle => 'Cancelar download?';

  @override
  String downloadsCancelBody(String title) {
    return 'O progresso de “$title” será descartado.';
  }

  @override
  String get downloadsCancelKeep => 'Manter';

  @override
  String get downloadsCancelConfirm => 'Cancelar download';

  @override
  String downloadsEta(String value) {
    return 'ETA $value';
  }

  @override
  String downloadsProgressSemantics(String state, int percent) {
    return '$state, $percent por cento';
  }

  @override
  String downloadsPauseItem(String title) {
    return 'Pausar “$title”';
  }

  @override
  String downloadsResumeItem(String title) {
    return 'Continuar “$title”';
  }

  @override
  String downloadsRetryItem(String title) {
    return 'Tentar “$title” de novo';
  }

  @override
  String downloadsCancelItem(String title) {
    return 'Cancelar “$title”';
  }

  @override
  String downloadsItemSemantics(String title, String state) {
    return '$title, $state';
  }

  @override
  String downloadsAnnounceDone(String title) {
    return '“$title” concluído';
  }

  @override
  String downloadsAnnounceFailed(String title) {
    return '“$title” falhou';
  }

  @override
  String get downloadStateQueued => 'Na fila';

  @override
  String get downloadStateConnecting => 'Conectando';

  @override
  String get downloadStateDownloading => 'Baixando';

  @override
  String get downloadStatePaused => 'Pausado';

  @override
  String get downloadStateCompleted => 'Concluindo';

  @override
  String get downloadStateVerifying => 'Verificando integridade';

  @override
  String get downloadStateDone => 'Concluído';

  @override
  String get downloadStateFailed => 'Falhou';

  @override
  String get downloadStateCanceled => 'Cancelado';

  @override
  String get libraryViewAsList => 'Ver em lista';

  @override
  String get libraryViewAsGrid => 'Ver em grade';

  @override
  String get librarySort => 'Ordenar';

  @override
  String get librarySortDownloadedAt => 'Data do download';

  @override
  String get librarySortName => 'Nome';

  @override
  String get librarySortSize => 'Tamanho';

  @override
  String get librarySortDuration => 'Duração';

  @override
  String get librarySortPlatform => 'Plataforma';

  @override
  String get libraryTabVideos => 'Vídeos';

  @override
  String get libraryTabAudios => 'Áudios';

  @override
  String get libraryTabFavorites => 'Favoritos';

  @override
  String get libraryTabRecents => 'Recentes';

  @override
  String libraryTabWithCount(String label, int count) {
    return '$label ($count)';
  }

  @override
  String get libraryFileMissing => 'Arquivo não encontrado';

  @override
  String get libraryFavoriteAdd => 'Adicionar aos favoritos';

  @override
  String get libraryFavoriteRemove => 'Remover dos favoritos';

  @override
  String get libraryEmptyTitle => 'Nada por aqui ainda';

  @override
  String get libraryEmptyBody => 'Downloads concluídos aparecem nesta aba.';

  @override
  String get searchHint => 'Nome, autor, plataforma ou etiqueta';

  @override
  String get searchApproximate =>
      'Nada exato — mostrando resultados parecidos.';

  @override
  String get searchEmpty => 'Nenhum resultado para esta busca.';

  @override
  String searchClearFilters(int count) {
    return 'Limpar ($count)';
  }

  @override
  String get searchKindVideo => 'Vídeo';

  @override
  String get searchKindAudio => 'Áudio';

  @override
  String get searchDurationShort => '< 5 min';

  @override
  String get searchDurationMedium => '5–20 min';

  @override
  String get searchDurationLong => '> 20 min';

  @override
  String get converterClearFinished => 'Limpar concluídas';

  @override
  String get converterEmptyTitle => 'Nenhuma conversão';

  @override
  String get converterEmptyBody =>
      'Escolha um item da biblioteca para converter. O arquivo original é preservado.';

  @override
  String get conversionStateQueued => 'Na fila';

  @override
  String get conversionStateConverting => 'Convertendo';

  @override
  String get conversionStateCompleted => 'Concluída';

  @override
  String get conversionStateFailed => 'Falhou';

  @override
  String get conversionStateCanceled => 'Cancelada';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get settingsSearchHint => 'Buscar nas configurações';

  @override
  String get settingsNoResults => 'Nenhuma configuração encontrada.';

  @override
  String get settingsSectionGeneral => 'Geral';

  @override
  String get settingsSectionDownloads => 'Downloads';

  @override
  String get settingsSectionNotifications => 'Notificações';

  @override
  String get settingsSectionBattery => 'Bateria e dados';

  @override
  String get settingsSectionStorage => 'Armazenamento';

  @override
  String get settingsSectionPrivacy => 'Privacidade';

  @override
  String get settingsSectionAbout => 'Sobre';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsClipboardDetection =>
      'Detectar link na área de transferência';

  @override
  String get settingsConcurrency => 'Downloads simultâneos';

  @override
  String get settingsSpeedLimit => 'Limite de velocidade';

  @override
  String get settingsWifiOnly => 'Somente Wi-Fi';

  @override
  String get settingsResumeOnReconnect => 'Retomar ao reconectar';

  @override
  String get settingsNotifyOnComplete => 'Avisar ao concluir';

  @override
  String get settingsNotifyOnError => 'Avisar em caso de erro';

  @override
  String get settingsNotificationStyle => 'Estilo das notificações';

  @override
  String get settingsDailySummary => 'Resumo diário';

  @override
  String get settingsBatterySaver => 'Modo economia';

  @override
  String get settingsBatterySaverBody =>
      'Reduz downloads simultâneos e desliga animações.';

  @override
  String get settingsPauseOnLowBattery => 'Pausar com bateria baixa';

  @override
  String settingsPauseOnLowBatteryBody(int percent) {
    return 'Abaixo de $percent%.';
  }

  @override
  String get settingsThumbnailCache => 'Cache de miniaturas';

  @override
  String settingsMegabytes(int value) {
    return '$value MB';
  }

  @override
  String get settingsTrashRetention => 'Retenção da lixeira';

  @override
  String settingsDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dias',
      one: '1 dia',
    );
    return '$_temp0';
  }

  @override
  String get settingsAnalytics => 'Enviar dados de uso';

  @override
  String get settingsAnalyticsBody =>
      'Desligado por padrão. Nada é enviado sem sua permissão.';

  @override
  String get settingsPolicy => 'Política de uso responsável';

  @override
  String get settingsPolicyBody =>
      'O Vidora só baixa conteúdo autorizado pela plataforma de origem ou pelo titular dos direitos.';

  @override
  String get settingsAbout => 'Versão e licenças';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Escuro';

  @override
  String get themeSystem => 'Automático';

  @override
  String get notificationStyleSound => 'Som';

  @override
  String get notificationStyleVibrate => 'Vibrar';

  @override
  String get notificationStyleSilent => 'Silencioso';

  @override
  String get categoryMusic => 'Música';

  @override
  String get categoryPodcast => 'Podcast';

  @override
  String get categoryLecture => 'Aula';

  @override
  String get categoryTutorial => 'Tutorial';

  @override
  String get categoryUnknown => 'Sem categoria';

  @override
  String get presetMaxCompatibility => 'Compatibilidade máxima';

  @override
  String get presetSmallestSize => 'Menor tamanho';

  @override
  String get presetPodcastAudio => 'Áudio para podcast';

  @override
  String get presetLossless => 'Sem perdas';

  @override
  String get onboardingFinish => 'Entendi, começar';

  @override
  String get onboardingTitle1 => 'Só o que é permitido';

  @override
  String get onboardingBody1 =>
      'O Vidora baixa mídia quando a plataforma de origem ou o titular dos direitos autoriza. Todo link é verificado antes de qualquer download começar.';

  @override
  String get onboardingTitle2 => 'Quatro formas de autorização';

  @override
  String get onboardingBody2 =>
      'Download oficial da plataforma, licença aberta (como Creative Commons), conteúdo do seu próprio perfil, ou arquivo público de acesso direto. Você vê qual delas valeu em cada item.';

  @override
  String get onboardingTitle3 => 'O que o app não faz';

  @override
  String get onboardingBody3 =>
      'Nada de contornar DRM, paywall ou login de terceiros. Quando um link não pode ser baixado, explicamos o motivo e, quando existe, o caminho legítimo.';
}
