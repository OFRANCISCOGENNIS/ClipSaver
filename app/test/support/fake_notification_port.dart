/// Records notifications instead of showing them.
library;

import 'package:vidora/core/platform/notification_port.dart';

/// One recorded call to [NotificationPort.show].
typedef ShownNotification = ({
  SystemNotificationKind kind,
  String title,
  String body,
  NotificationDelivery delivery,
});

/// In-memory [NotificationPort] for tests.
final class FakeNotificationPort implements NotificationPort {
  /// Everything shown so far, in order.
  final List<ShownNotification> shown = [];

  /// Kinds shown so far, for terse assertions.
  List<SystemNotificationKind> get kinds =>
      shown.map((entry) => entry.kind).toList();

  @override
  Future<void> show(
    SystemNotification notification, {
    required NotificationDelivery delivery,
  }) async {
    shown.add((
      kind: notification.kind,
      title: notification.title,
      body: notification.body,
      delivery: delivery,
    ));
  }
}
