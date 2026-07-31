/// System-notification port.
///
/// Responsibility: the *contract* for telling the user something outside
/// the app's own window. The queue logic decides what deserves a
/// notification and whether it makes sound; how one is shown — channels,
/// icons, permission prompts — is an adapter concern behind this
/// interface, so the application layer stays testable with a fake.
///
/// This exists because the Settings screen has offered a "notification
/// style" choice since phase 5 while nothing consumed it: a setting that
/// adjusts nothing is worse than no setting at all.
library;

/// What a notification is about. Kinds are an enum, not free-form
/// strings, so an adapter can route each one to a stable channel id —
/// Android channels are immutable once created.
enum SystemNotificationKind {
  /// One download reached `done`.
  downloadDone,

  /// One download failed with its retry budget spent.
  downloadFailed,

  /// The whole queue drained.
  queueFinished,
}

/// One notification, already localized by the caller.
///
/// Text arrives ready-made because localization needs the user's chosen
/// language, and that lives in settings — an adapter has no business
/// reading settings.
final class SystemNotification {
  /// Creates the notification.
  const SystemNotification({
    required this.kind,
    required this.title,
    this.body = '',
  });

  /// Routing kind (also used as a stable per-task collapse key).
  final SystemNotificationKind kind;

  /// Headline shown by the OS.
  final String title;

  /// Optional detail line (e.g. the failure reason).
  final String body;
}

/// How a notification is delivered. Mirrors the three styles Settings
/// offers (som / vibrar / silencioso): every style still *shows* the
/// notification — what changes is how loudly it arrives.
enum NotificationDelivery {
  /// Sound and vibration.
  sound,

  /// Vibration only.
  vibrationOnly,

  /// Neither; the notification appears quietly.
  silent,
}

/// Shows system notifications.
abstract interface class NotificationPort {
  /// Shows [notification] with the given [delivery].
  Future<void> show(
    SystemNotification notification, {
    required NotificationDelivery delivery,
  });
}

/// Adapter for platforms without system notifications (web today).
///
/// Explicit no-op instead of a missing binding: a `MissingPluginException`
/// at the first finished download would take the queue down with it.
final class NoopNotificationPort implements NotificationPort {
  /// Creates the no-op.
  const NoopNotificationPort();

  @override
  Future<void> show(
    SystemNotification notification, {
    required NotificationDelivery delivery,
  }) async {}
}
