import 'package:flutter_test/flutter_test.dart';
import 'package:vidora/features/downloads/application/transfer_rate.dart';

void main() {
  late DateTime now;
  late TransferRateTracker tracker;

  setUp(() {
    now = DateTime.utc(2026, 7, 1);
    tracker = TransferRateTracker(clock: () => now);
  });

  void advance(Duration duration) => now = now.add(duration);

  test('needs two observations before reporting a rate', () {
    expect(tracker.update('t', 0), isNull);
    advance(const Duration(seconds: 1));
    expect(tracker.update('t', 1000), isNotNull);
  });

  test('computes the instantaneous speed from the interval', () {
    tracker.update('t', 0);
    advance(const Duration(seconds: 2));
    final rate = tracker.update('t', 2000)!;
    expect(rate.instantBytesPerSecond, closeTo(1000, 0.001));
    // The first measured interval seeds the average.
    expect(rate.averageBytesPerSecond, closeTo(1000, 0.001));
  });

  test('smooths the average toward new readings', () {
    tracker.update('t', 0);
    advance(const Duration(seconds: 1));
    tracker.update('t', 1000); // average = 1000
    advance(const Duration(seconds: 1));
    final rate = tracker.update('t', 3000)!; // instant = 2000

    // 0.3 * 2000 + 0.7 * 1000
    expect(rate.averageBytesPerSecond, closeTo(1300, 0.001));
  });

  test('ignores intervals below the minimum sampling window', () {
    tracker.update('t', 0);
    advance(const Duration(milliseconds: 10));
    // Too soon to measure and no average yet.
    expect(tracker.update('t', 5), isNull);

    advance(const Duration(seconds: 1));
    final measured = tracker.update('t', 1000)!;
    advance(const Duration(milliseconds: 10));
    // Still too soon, but the previous average carries the reading.
    final carried = tracker.update('t', 1005)!;
    expect(
      carried.averageBytesPerSecond,
      closeTo(measured.averageBytesPerSecond, 0.001),
    );
  });

  test('resets when the byte count goes backwards (restarted transfer)', () {
    tracker.update('t', 5000);
    advance(const Duration(seconds: 1));
    tracker.update('t', 6000);
    advance(const Duration(seconds: 1));
    expect(tracker.update('t', 100), isNull);
  });

  group('ETA', () {
    test('is derived from the smoothed average and remaining bytes', () {
      tracker.update('t', 0, totalBytes: 10000);
      advance(const Duration(seconds: 1));
      final rate = tracker.update('t', 1000, totalBytes: 10000)!;
      // 9000 bytes left at 1000 B/s.
      expect(rate.eta, const Duration(seconds: 9));
      expect(rate.etaLabel, '9 s');
    });

    test('is null while the total size is unknown', () {
      tracker.update('t', 0);
      advance(const Duration(seconds: 1));
      final rate = tracker.update('t', 1000)!;
      expect(rate.eta, isNull);
      expect(rate.etaLabel, '—');
    });

    test('is zero once everything has arrived', () {
      tracker.update('t', 0, totalBytes: 1000);
      advance(const Duration(seconds: 1));
      expect(tracker.update('t', 1000, totalBytes: 1000)!.eta, Duration.zero);
    });

    test('formats minutes and hours compactly', () {
      tracker.update('t', 0, totalBytes: 1000000);
      advance(const Duration(seconds: 1));
      final rate = tracker.update('t', 1000, totalBytes: 1000000)!;
      // 999000 bytes at 1000 B/s ≈ 16 min 39 s.
      expect(rate.etaLabel, '16 min 39 s');
    });
  });

  group('speed label', () {
    test('adapts the unit to the magnitude', () {
      tracker.update('t', 0);
      advance(const Duration(seconds: 1));
      expect(tracker.update('t', 2048)!.speedLabel, '2.0 KB/s');

      tracker.forget('t');
      tracker.update('t', 0);
      advance(const Duration(seconds: 1));
      expect(tracker.update('t', 5 * 1024 * 1024)!.speedLabel, '5.0 MB/s');
    });
  });

  group('bookkeeping', () {
    test('forget drops a single history', () {
      tracker.update('t', 0);
      tracker.forget('t');
      advance(const Duration(seconds: 1));
      expect(tracker.update('t', 1000), isNull);
    });

    test('retainOnly drops histories for downloads that left the queue', () {
      tracker.update('a', 0);
      tracker.update('b', 0);
      tracker.retainOnly({'a'});
      advance(const Duration(seconds: 1));
      expect(tracker.update('a', 1000), isNotNull);
      expect(tracker.update('b', 1000), isNull);
    });
  });
}
