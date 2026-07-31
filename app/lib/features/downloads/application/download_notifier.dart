/// Turns terminal queue events into system notifications.
///
/// Responsibility: policy. What deserves a notification (done, final
/// failure, drained queue — never per-percent progress), in which language,
/// and with which style. The style comes from Settings: this is the class
/// that finally makes the "notification style" choice do something.
library;

import 'dart:async';
import 'dart:ui';

import '../../../core/platform/notification_port.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../settings/domain/app_settings.dart';
import '../../settings/domain/settings_repository.dart';
import '../domain/download_repository.dart';
import '../domain/download_state.dart';
import '../domain/download_task.dart';

/// Subscribes to the manager's terminal stream and notifies accordingly.
final class DownloadNotifier {
  /// Creates the notifier and starts listening to [terminalUpdates].
  DownloadNotifier({
    required Stream<DownloadTask> terminalUpdates,
    required DownloadRepository repository,
    required SettingsRepository settings,
    required NotificationPort port,
  })  : _repository = repository,
        _settings = settings,
        _port = port {
    _subscription = terminalUpdates.listen(_onTerminal);
  }

  final DownloadRepository _repository;
  final SettingsRepository _settings;
  final NotificationPort _port;
  late final StreamSubscription<DownloadTask> _subscription;

  /// Terminal events since the queue was last idle. The drained-queue
  /// notification only fires when this reaches two: with a single
  /// download, "«X» concluído" immediately followed by "todos os downloads
  /// terminaram" says the same thing twice, and a notifier that repeats
  /// itself gets muted by the user — which kills the feature.
  int _terminalSinceIdle = 0;

  /// Stops listening. Safe to call once the manager is being disposed.
  void dispose() {
    unawaited(_subscription.cancel());
  }

  /// Notification text in the user's chosen language, not the device's:
  /// the app's own language setting wins everywhere else in the UI, and a
  /// notification in a different language than the app it came from reads
  /// as someone else's.
  AppLocalizations _localize(AppLanguage language) {
    final parts = language.code.split('-');
    final locale = parts.length == 2
        ? Locale(parts.first, parts.last)
        : Locale(parts.first);
    return lookupAppLocalizations(locale);
  }

  /// Settings style → delivery, spelled out per value so a fourth style
  /// added to Settings fails to compile here until someone decides how it
  /// is delivered — the same exhaustive-switch rule the l10n mappings use.
  NotificationDelivery _deliveryOf(NotificationStyle style) => switch (style) {
        NotificationStyle.sound => NotificationDelivery.sound,
        NotificationStyle.vibrate => NotificationDelivery.vibrationOnly,
        NotificationStyle.silent => NotificationDelivery.silent,
      };

  Future<void> _onTerminal(DownloadTask task) async {
    _terminalSinceIdle++;

    final settings =
        (await _settings.load()).valueOrNull ?? const AppSettings();
    final delivery = _deliveryOf(settings.notificationStyle);
    final l10n = _localize(settings.language);

    if (task.state == DownloadState.done) {
      await _port.show(
        SystemNotification(
          kind: SystemNotificationKind.downloadDone,
          title: l10n.downloadsAnnounceDone(task.title),
        ),
        delivery: delivery,
      );
    } else {
      await _port.show(
        SystemNotification(
          kind: SystemNotificationKind.downloadFailed,
          title: l10n.downloadsAnnounceFailed(task.title),
          body: task.failureReason ?? '',
        ),
        delivery: delivery,
      );
    }

    if (await _queueIsIdle()) {
      if (_terminalSinceIdle >= 2) {
        await _port.show(
          SystemNotification(
            kind: SystemNotificationKind.queueFinished,
            title: l10n.downloadsAnnounceQueueDone,
          ),
          delivery: delivery,
        );
      }
      _terminalSinceIdle = 0;
    }
  }

  /// Idle means nothing is waiting or moving. A paused task does not hold
  /// the queue open: the user parked it on purpose, and "everything you
  /// asked for is finished" is still true.
  Future<bool> _queueIsIdle() async {
    final all = (await _repository.all()).valueOrNull;
    if (all == null) return false;
    return all.every(
      (task) =>
          task.state != DownloadState.queued &&
          task.state != DownloadState.connecting &&
          task.state != DownloadState.downloading,
    );
  }
}
