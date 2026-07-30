/// Download lifecycle states and the legal transitions between them
/// (section 8.1).
///
/// Responsibility: encode the state machine as data so [DownloadTask]
/// can refuse illegal transitions and tests can verify the full matrix.
///
/// ```
/// queued → connecting → downloading ⇄ paused
///                           ↓
///                      completed | failed → (retry) → queued
///                           ↓
///                       verifying → done
/// canceled (from any active state)
/// ```
library;

/// Lifecycle states of a download (section 8.1).
enum DownloadState {
  /// Waiting for a scheduler slot.
  queued,

  /// Handshaking with the origin server.
  connecting,

  /// Receiving bytes.
  downloading,

  /// Paused by the user or by connectivity policy.
  paused,

  /// All bytes received; integrity not yet verified.
  completed,

  /// Running checksum/container verification (section 8.3).
  verifying,

  /// Verified and moved to the library. Terminal.
  done,

  /// Failed with a reason; may be retried. Terminal unless retried.
  failed,

  /// Canceled by the user. Terminal.
  canceled;

  /// States in which the task still occupies the queue/scheduler.
  bool get isActive => switch (this) {
        queued ||
        connecting ||
        downloading ||
        paused ||
        completed ||
        verifying =>
          true,
        done || failed || canceled => false,
      };

  /// Terminal states: no further transitions except retry from [failed].
  bool get isTerminal => this == done || this == canceled || this == failed;

  static const Map<DownloadState, Set<DownloadState>> _transitions = {
    queued: {connecting, canceled},
    connecting: {downloading, failed, canceled},
    downloading: {paused, completed, failed, canceled},
    paused: {downloading, canceled},
    completed: {verifying, canceled},
    verifying: {done, failed, canceled},
    failed: {queued}, // retry re-enqueues
    done: {},
    canceled: {},
  };

  /// Whether moving from `this` to [next] is allowed by section 8.1.
  bool canTransitionTo(DownloadState next) =>
      _transitions[this]!.contains(next);
}
