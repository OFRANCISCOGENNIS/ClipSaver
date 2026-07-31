/// Conditional entry point for the system-notification adapter, following
/// the same pattern as `platform_services.dart`: one import that resolves
/// to the right implementation per target, so no `dart:io` reaches the
/// web build.
library;

import 'notification_port.dart';
import 'system_notifications_io.dart'
    if (dart.library.js_interop) 'system_notifications_web.dart' as impl;

export 'notification_port.dart';

/// Creates the platform's notification port.
NotificationPort createNotificationPort() => impl.createNotificationPort();
