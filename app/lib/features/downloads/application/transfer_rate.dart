/// Transfer speed and ETA estimation (section 8.2).
///
/// Responsibility: turn a series of (bytes, timestamp) observations into
/// the instantaneous speed, an exponentially smoothed average and an ETA.
/// Kept pure and separate from the UI so the smoothing behavior can be
/// tested deterministically with an injected clock.
library;

import '../../../core/domain/value_objects/file_size.dart';

/// A speed reading for one download.
final class TransferRate {
  /// Creates a reading.
  const TransferRate({
    required this.instantBytesPerSecond,
    required this.averageBytesPerSecond,
    this.eta,
  });

  /// Speed of the most recent interval.
  final double instantBytesPerSecond;

  /// Exponentially smoothed average, used for the ETA.
  final double averageBytesPerSecond;

  /// Estimated time remaining; null while unknown (no total size or the
  /// average is still zero).
  final Duration? eta;

  /// Adaptive speed label, e.g. "1.2 MB/s" (section 8.2).
  String get speedLabel {
    final perSecond = averageBytesPerSecond;
    if (perSecond <= 0) return '—';
    return '${FileSize.ofBytes(perSecond.round()).formatted}/s';
  }

  /// Compact ETA label, e.g. "2 min 5 s"; "—" while unknown.
  String get etaLabel {
    final remaining = eta;
    if (remaining == null) return '—';
    if (remaining.inHours > 0) {
      return '${remaining.inHours} h ${remaining.inMinutes % 60} min';
    }
    if (remaining.inMinutes > 0) {
      return '${remaining.inMinutes} min ${remaining.inSeconds % 60} s';
    }
    return '${remaining.inSeconds} s';
  }
}

/// Tracks per-download transfer rates using an exponential moving average.
final class TransferRateTracker {
  /// Creates a tracker; [clock] is injectable for deterministic tests.
  TransferRateTracker({DateTime Function() clock = DateTime.now})
      : _clock = clock;

  /// Smoothing factor: higher reacts faster, lower is steadier.
  static const double smoothing = 0.3;

  /// Intervals shorter than this are ignored — dividing a few bytes by a
  /// sub-millisecond gap yields nonsense speeds that make the UI jump.
  static const Duration minimumInterval = Duration(milliseconds: 200);

  final DateTime Function() _clock;
  final Map<String, _Observation> _observations = {};

  /// Records [bytesDownloaded] for [taskId] and returns the current rate.
  ///
  /// Returns null until there are two observations far enough apart to
  /// measure. [totalBytes] enables the ETA when known.
  TransferRate? update(String taskId, int bytesDownloaded, {int? totalBytes}) {
    final now = _clock();
    final previous = _observations[taskId];

    if (previous == null) {
      _observations[taskId] = _Observation(bytesDownloaded, now, 0);
      return null;
    }

    final elapsed = now.difference(previous.at);
    if (elapsed < minimumInterval) {
      return previous.average == 0
          ? null
          : _rate(
              previous.average, previous.average, bytesDownloaded, totalBytes);
    }

    final deltaBytes = bytesDownloaded - previous.bytes;
    // A negative delta means the transfer restarted (server ignored our
    // Range header); drop the history rather than report a negative speed.
    if (deltaBytes < 0) {
      _observations[taskId] = _Observation(bytesDownloaded, now, 0);
      return null;
    }

    final instant = deltaBytes / (elapsed.inMicroseconds / 1e6);
    final average = previous.average == 0
        ? instant
        : smoothing * instant + (1 - smoothing) * previous.average;
    _observations[taskId] = _Observation(bytesDownloaded, now, average);
    return _rate(instant, average, bytesDownloaded, totalBytes);
  }

  /// Forgets [taskId]'s history (download finished, canceled or removed).
  void forget(String taskId) => _observations.remove(taskId);

  /// Forgets every download not in [liveTaskIds], keeping memory bounded.
  void retainOnly(Set<String> liveTaskIds) =>
      _observations.removeWhere((id, _) => !liveTaskIds.contains(id));

  TransferRate _rate(
    double instant,
    double average,
    int bytesDownloaded,
    int? totalBytes,
  ) {
    Duration? eta;
    if (totalBytes != null && average > 0) {
      final remaining = totalBytes - bytesDownloaded;
      if (remaining > 0) {
        eta = Duration(microseconds: (remaining / average * 1e6).round());
      } else {
        eta = Duration.zero;
      }
    }
    return TransferRate(
      instantBytesPerSecond: instant,
      averageBytesPerSecond: average,
      eta: eta,
    );
  }
}

final class _Observation {
  const _Observation(this.bytes, this.at, this.average);

  final int bytes;
  final DateTime at;
  final double average;
}
