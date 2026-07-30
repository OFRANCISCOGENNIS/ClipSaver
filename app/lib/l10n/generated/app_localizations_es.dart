// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Vidora';

  @override
  String get actionRetry => 'Intentar de nuevo';

  @override
  String get actionRetryShort => 'Reintentar';

  @override
  String get actionCancel => 'Cancelar';

  @override
  String get actionClear => 'Limpiar';

  @override
  String get actionDismiss => 'Descartar';

  @override
  String get actionPause => 'Pausar';

  @override
  String get actionResume => 'Continuar';

  @override
  String get actionContinue => 'Continuar';

  @override
  String get valueUnavailable => '—';

  @override
  String get navAnalyze => 'Analizar';

  @override
  String get navDownloads => 'Descargas';

  @override
  String get navLibrary => 'Biblioteca';

  @override
  String get navSearch => 'Buscar';

  @override
  String get navConverter => 'Convertir';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get analyzeUrlHint => 'Pega un enlace autorizado';

  @override
  String get analyzeAction => 'Analizar';

  @override
  String analyzeClipboardPrompt(String url) {
    return '¿Pegar el enlace copiado? $url';
  }

  @override
  String get analyzeRecents => 'Recientes';

  @override
  String get analyzeEmptyTitle => 'Descarga solo lo permitido';

  @override
  String get analyzeEmptyBody =>
      'Vidora acepta enlaces con descarga oficial, licencia abierta, contenido de tu propio perfil o archivos públicos directos.';

  @override
  String get analyzeSkeletonSemantics => 'Analizando el enlace';

  @override
  String get analyzeGenericError => 'No se pudo analizar este enlace.';

  @override
  String analyzeQueuedSnack(String title) {
    return '«$title» entró en la cola.';
  }

  @override
  String get analyzeSeeQueue => 'Ver la cola';

  @override
  String get resultQuality => 'Calidad';

  @override
  String resultDownload(String quality) {
    return 'Descargar $quality';
  }

  @override
  String resultLicenseTerms(String terms) {
    return 'Condiciones de la licencia: $terms.';
  }

  @override
  String get ineligibleTitle => 'Descarga no autorizada';

  @override
  String get ineligibleTechnicalDetails => 'Detalles técnicos';

  @override
  String ineligibleDetailBody(String host, String basis) {
    return 'Origen analizado: $host\nBase de autorización encontrada: $basis\nFormatos disponibles: ninguno';
  }

  @override
  String badgeAuthorization(String basis) {
    return 'Autorización: $basis';
  }

  @override
  String badgeUnauthorized(String basis) {
    return 'Descarga no autorizada: $basis';
  }

  @override
  String get sourceOfficialApi => 'Descarga oficial';

  @override
  String get sourceOpenLicense => 'Licencia abierta';

  @override
  String get sourceUserOwned => 'Tu contenido';

  @override
  String get sourceDirectFile => 'Archivo directo';

  @override
  String get sourceNone => 'No autorizado';

  @override
  String get licensePublicDomain => 'Dominio público';

  @override
  String get licenseCc0 => 'Licencia CC0';

  @override
  String get licenseCcBy => 'Licencia CC-BY';

  @override
  String get licenseCcBySa => 'Licencia CC-BY-SA';

  @override
  String get licenseCcByNc => 'Licencia CC-BY-NC';

  @override
  String get licenseCcByNd => 'Licencia CC-BY-ND';

  @override
  String get licenseRestrictionAttribution => 'atribución obligatoria';

  @override
  String get licenseRestrictionShareAlike => 'compartir igual';

  @override
  String get licenseRestrictionNonCommercial => 'uso no comercial';

  @override
  String get licenseRestrictionNoDerivatives => 'sin obras derivadas';

  @override
  String get downloadsPauseAll => 'Pausar todo';

  @override
  String get downloadsResumeAll => 'Reanudar todo';

  @override
  String get downloadsClearFinished => 'Limpiar completadas';

  @override
  String get downloadsEmptyTitle => 'No hay descargas en la cola';

  @override
  String get downloadsEmptyBody => 'Analiza un enlace autorizado para empezar.';

  @override
  String get downloadsCancelTitle => '¿Cancelar la descarga?';

  @override
  String downloadsCancelBody(String title) {
    return 'Se descartará el progreso de «$title».';
  }

  @override
  String get downloadsCancelKeep => 'Mantener';

  @override
  String get downloadsCancelConfirm => 'Cancelar descarga';

  @override
  String downloadsEta(String value) {
    return 'ETA $value';
  }

  @override
  String downloadsProgressSemantics(String state, int percent) {
    return '$state, $percent por ciento';
  }

  @override
  String get downloadStateQueued => 'En cola';

  @override
  String get downloadStateConnecting => 'Conectando';

  @override
  String get downloadStateDownloading => 'Descargando';

  @override
  String get downloadStatePaused => 'En pausa';

  @override
  String get downloadStateCompleted => 'Finalizando';

  @override
  String get downloadStateVerifying => 'Verificando integridad';

  @override
  String get downloadStateDone => 'Completada';

  @override
  String get downloadStateFailed => 'Falló';

  @override
  String get downloadStateCanceled => 'Cancelada';

  @override
  String get libraryViewAsList => 'Ver en lista';

  @override
  String get libraryViewAsGrid => 'Ver en cuadrícula';

  @override
  String get librarySort => 'Ordenar';

  @override
  String get librarySortDownloadedAt => 'Fecha de descarga';

  @override
  String get librarySortName => 'Nombre';

  @override
  String get librarySortSize => 'Tamaño';

  @override
  String get librarySortDuration => 'Duración';

  @override
  String get librarySortPlatform => 'Plataforma';

  @override
  String get libraryTabVideos => 'Vídeos';

  @override
  String get libraryTabAudios => 'Audios';

  @override
  String get libraryTabFavorites => 'Favoritos';

  @override
  String get libraryTabRecents => 'Recientes';

  @override
  String libraryTabWithCount(String label, int count) {
    return '$label ($count)';
  }

  @override
  String get libraryFileMissing => 'Archivo no encontrado';

  @override
  String get libraryFavoriteAdd => 'Añadir a favoritos';

  @override
  String get libraryFavoriteRemove => 'Quitar de favoritos';

  @override
  String get libraryEmptyTitle => 'Todavía no hay nada';

  @override
  String get libraryEmptyBody =>
      'Las descargas completadas aparecen en esta pestaña.';

  @override
  String get searchHint => 'Nombre, autor, plataforma o etiqueta';

  @override
  String get searchApproximate =>
      'Nada exacto: mostrando resultados parecidos.';

  @override
  String get searchEmpty => 'Ningún resultado para esta búsqueda.';

  @override
  String searchClearFilters(int count) {
    return 'Limpiar ($count)';
  }

  @override
  String get searchKindVideo => 'Vídeo';

  @override
  String get searchKindAudio => 'Audio';

  @override
  String get searchDurationShort => '< 5 min';

  @override
  String get searchDurationMedium => '5–20 min';

  @override
  String get searchDurationLong => '> 20 min';

  @override
  String get converterClearFinished => 'Limpiar completadas';

  @override
  String get converterEmptyTitle => 'Ninguna conversión';

  @override
  String get converterEmptyBody =>
      'Elige un elemento de la biblioteca para convertir. El archivo original se conserva.';

  @override
  String get conversionStateQueued => 'En cola';

  @override
  String get conversionStateConverting => 'Convirtiendo';

  @override
  String get conversionStateCompleted => 'Completada';

  @override
  String get conversionStateFailed => 'Falló';

  @override
  String get conversionStateCanceled => 'Cancelada';

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get settingsSearchHint => 'Buscar en la configuración';

  @override
  String get settingsNoResults => 'No se encontró ninguna opción.';

  @override
  String get settingsSectionGeneral => 'General';

  @override
  String get settingsSectionDownloads => 'Descargas';

  @override
  String get settingsSectionNotifications => 'Notificaciones';

  @override
  String get settingsSectionBattery => 'Batería y datos';

  @override
  String get settingsSectionStorage => 'Almacenamiento';

  @override
  String get settingsSectionPrivacy => 'Privacidad';

  @override
  String get settingsSectionAbout => 'Acerca de';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsClipboardDetection =>
      'Detectar enlaces en el portapapeles';

  @override
  String get settingsConcurrency => 'Descargas simultáneas';

  @override
  String get settingsSpeedLimit => 'Límite de velocidad';

  @override
  String get settingsWifiOnly => 'Solo Wi-Fi';

  @override
  String get settingsResumeOnReconnect => 'Reanudar al reconectar';

  @override
  String get settingsNotifyOnComplete => 'Avisar al terminar';

  @override
  String get settingsNotifyOnError => 'Avisar si hay error';

  @override
  String get settingsNotificationStyle => 'Estilo de las notificaciones';

  @override
  String get settingsDailySummary => 'Resumen diario';

  @override
  String get settingsBatterySaver => 'Modo ahorro';

  @override
  String get settingsBatterySaverBody =>
      'Reduce las descargas simultáneas y apaga las animaciones.';

  @override
  String get settingsPauseOnLowBattery => 'Pausar con batería baja';

  @override
  String settingsPauseOnLowBatteryBody(int percent) {
    return 'Por debajo del $percent%.';
  }

  @override
  String get settingsThumbnailCache => 'Caché de miniaturas';

  @override
  String settingsMegabytes(int value) {
    return '$value MB';
  }

  @override
  String get settingsTrashRetention => 'Retención de la papelera';

  @override
  String settingsDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días',
      one: '1 día',
    );
    return '$_temp0';
  }

  @override
  String get settingsAnalytics => 'Enviar datos de uso';

  @override
  String get settingsAnalyticsBody =>
      'Desactivado por defecto. No se envía nada sin tu permiso.';

  @override
  String get settingsPolicy => 'Política de uso responsable';

  @override
  String get settingsPolicyBody =>
      'Vidora solo descarga contenido autorizado por la plataforma de origen o por el titular de los derechos.';

  @override
  String get settingsAbout => 'Versión y licencias';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get themeSystem => 'Automático';

  @override
  String get notificationStyleSound => 'Sonido';

  @override
  String get notificationStyleVibrate => 'Vibrar';

  @override
  String get notificationStyleSilent => 'Silencioso';

  @override
  String get categoryMusic => 'Música';

  @override
  String get categoryPodcast => 'Pódcast';

  @override
  String get categoryLecture => 'Clase';

  @override
  String get categoryTutorial => 'Tutorial';

  @override
  String get categoryUnknown => 'Sin categoría';

  @override
  String get presetMaxCompatibility => 'Compatibilidad máxima';

  @override
  String get presetSmallestSize => 'Menor tamaño';

  @override
  String get presetPodcastAudio => 'Audio para pódcast';

  @override
  String get presetLossless => 'Sin pérdidas';

  @override
  String get onboardingFinish => 'Entendido, empezar';

  @override
  String get onboardingTitle1 => 'Solo lo permitido';

  @override
  String get onboardingBody1 =>
      'Vidora descarga medios cuando la plataforma de origen o el titular de los derechos lo autoriza. Cada enlace se verifica antes de que empiece cualquier descarga.';

  @override
  String get onboardingTitle2 => 'Cuatro formas de autorización';

  @override
  String get onboardingBody2 =>
      'Descarga oficial de la plataforma, licencia abierta (como Creative Commons), contenido de tu propio perfil o archivo público de acceso directo. Verás cuál se aplicó en cada elemento.';

  @override
  String get onboardingTitle3 => 'Lo que la app no hace';

  @override
  String get onboardingBody3 =>
      'Nada de sortear DRM, muros de pago ni el inicio de sesión de terceros. Cuando un enlace no se puede descargar, explicamos el motivo y, cuando existe, la vía legítima.';
}
