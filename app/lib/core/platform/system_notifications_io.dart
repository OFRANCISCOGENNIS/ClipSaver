/// Desktop/mobile adapter for [NotificationPort], backed by
/// `flutter_local_notifications`.
library;

import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'notification_port.dart';

/// Creates the notification port for io platforms.
///
/// Windows is a no-op: the plugin has no stable implementation there, and
/// an explicit no-op beats a `MissingPluginException` mid-queue.
NotificationPort createNotificationPort() {
  if (Platform.isWindows) return const NoopNotificationPort();
  return LocalNotificationPort(FlutterLocalNotificationsPlugin());
}

/// Android channel ids, one per (kind, delivery) pair.
///
/// Pure and public because channel identity is behavior worth pinning in a
/// test: Android freezes a channel's sound/vibration settings at creation,
/// so reusing one id across deliveries would make whichever was created
/// first win forever.
String channelIdFor(
  SystemNotificationKind kind, {
  required NotificationDelivery delivery,
}) {
  final base = switch (kind) {
    SystemNotificationKind.downloadDone => 'downloads_done',
    SystemNotificationKind.downloadFailed => 'downloads_failed',
    SystemNotificationKind.queueFinished => 'downloads_queue',
  };
  return switch (delivery) {
    NotificationDelivery.sound => base,
    NotificationDelivery.vibrationOnly => '${base}_vibrate',
    NotificationDelivery.silent => '${base}_silent',
  };
}

/// Stable per-notification id so a repeat replaces instead of stacking.
///
/// Public for the same reason as [channelIdFor]: a wrong id here means ten
/// finished downloads collapse into one notification, or one failure
/// spawns ten.
int notificationIdFor(SystemNotificationKind kind, String title) =>
    Object.hash(kind, title) & 0x7fffffff;

/// `flutter_local_notifications` implementation.
final class LocalNotificationPort implements NotificationPort {
  /// Creates the adapter over [plugin].
  LocalNotificationPort(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  /// Lazy so the app never asks for notification permission at startup —
  /// only when there is actually something to say (first finished
  /// download), which is when the prompt makes sense to the user.
  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    _initialized = true;
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
        macOS: DarwinInitializationSettings(),
        linux: LinuxInitializationSettings(defaultActionName: 'Abrir'),
      ),
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  @override
  Future<void> show(
    SystemNotification notification, {
    required NotificationDelivery delivery,
  }) async {
    await _ensureInitialized();
    final channelId = channelIdFor(notification.kind, delivery: delivery);
    final playSound = delivery == NotificationDelivery.sound;
    final vibrate = delivery != NotificationDelivery.silent;
    await _plugin.show(
      id: notificationIdFor(notification.kind, notification.title),
      title: notification.title,
      body: notification.body.isEmpty ? null : notification.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelId,
          importance: delivery == NotificationDelivery.silent
              ? Importance.low
              : Importance.defaultImportance,
          priority: delivery == NotificationDelivery.silent
              ? Priority.low
              : Priority.defaultPriority,
          playSound: playSound,
          enableVibration: vibrate,
        ),
        iOS: DarwinNotificationDetails(presentSound: playSound),
        macOS: DarwinNotificationDetails(presentSound: playSound),
        linux: const LinuxNotificationDetails(),
      ),
    );
  }
}
