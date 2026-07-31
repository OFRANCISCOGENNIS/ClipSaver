/// Web adapter for [NotificationPort].
///
/// The browser has its own Notification API, but it demands a permission
/// prompt that browsers increasingly bury or auto-deny, and the PWA runs
/// in a tab the user is usually looking at. A quiet no-op is honest here;
/// a service-worker push pipeline would be the real feature, and that is
/// server work, not a client adapter.
library;

import 'notification_port.dart';

/// Creates the notification port for the web build.
NotificationPort createNotificationPort() => const NoopNotificationPort();
