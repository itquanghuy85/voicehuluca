import 'package:flutter_test/flutter_test.dart';
import 'package:voice_huluca/core/utils/duration_estimator.dart';

void main() {
  group('DurationEstimator.estimate', () {
    test('returns zero for empty text', () {
      expect(DurationEstimator.estimate(''), Duration.zero);
    });

    test('estimates ~1 second for 15 chars', () {
      final duration = DurationEstimator.estimate('a' * 15);
      expect(duration.inSeconds, 1);
    });

    test('estimates ~10 seconds for 150 chars', () {
      final duration = DurationEstimator.estimate('a' * 150);
      expect(duration.inSeconds, 10);
    });

    test('estimates ~60 seconds for 900 chars', () {
      final duration = DurationEstimator.estimate('a' * 900);
      expect(duration.inSeconds, 60);
    });

    test('clamps to minimum duration for very short text', () {
      final duration = DurationEstimator.estimate('a');
      expect(duration.inMilliseconds, greaterThan(0));
    });

    test('clamps to maximum duration for very long text', () {
      expect(
        DurationEstimator.estimate('a' * 10000).inSeconds,
        lessThanOrEqualTo(600),
      );
    });
  });

  group('DurationEstimator.estimateWithSpeed', () {
    test('returns zero for empty text', () {
      expect(DurationEstimator.estimateWithSpeed('', 1.0), Duration.zero);
    });

    test('returns zero for zero speed', () {
      expect(DurationEstimator.estimateWithSpeed('hello', 0), Duration.zero);
    });

    test('returns zero for negative speed', () {
      expect(DurationEstimator.estimateWithSpeed('hello', -1), Duration.zero);
    });

    test('faster speed gives shorter duration', () {
      final text = 'a' * 150;
      final normal = DurationEstimator.estimateWithSpeed(text, 1.0);
      final fast = DurationEstimator.estimateWithSpeed(text, 2.0);
      expect(fast.inMilliseconds, lessThan(normal.inMilliseconds));
    });

    test('slower speed gives longer duration', () {
      final text = 'a' * 150;
      final normal = DurationEstimator.estimateWithSpeed(text, 1.0);
      final slow = DurationEstimator.estimateWithSpeed(text, 0.5);
      expect(slow.inMilliseconds, greaterThan(normal.inMilliseconds));
    });

    test('double speed halves duration', () {
      final text = 'a' * 300;
      final normal = DurationEstimator.estimateWithSpeed(text, 1.0);
      final doubleSpeed = DurationEstimator.estimateWithSpeed(text, 2.0);
      expect(
        doubleSpeed.inMilliseconds,
        closeTo(normal.inMilliseconds / 2, 100),
      );
    });
  });

  group('DurationEstimator.formatDuration', () {
    test('formats seconds only', () {
      expect(
        DurationEstimator.formatDuration(const Duration(seconds: 45)),
        '45s',
      );
    });

    test('formats minutes and seconds', () {
      expect(
        DurationEstimator.formatDuration(
          const Duration(minutes: 5, seconds: 30),
        ),
        '5m 30s',
      );
    });

    test('formats hours, minutes, and seconds', () {
      expect(
        DurationEstimator.formatDuration(
          const Duration(hours: 2, minutes: 15, seconds: 10),
        ),
        '2h 15m 10s',
      );
    });

    test('formats zero duration', () {
      expect(DurationEstimator.formatDuration(Duration.zero), '0s');
    });
  });

  group('DurationEstimator.formatDurationShort', () {
    test('formats as MM:SS', () {
      expect(
        DurationEstimator.formatDurationShort(
          const Duration(minutes: 5, seconds: 30),
        ),
        '05:30',
      );
    });

    test('pads single digit values', () {
      expect(
        DurationEstimator.formatDurationShort(
          const Duration(minutes: 1, seconds: 5),
        ),
        '01:05',
      );
    });

    test('formats zero', () {
      expect(DurationEstimator.formatDurationShort(Duration.zero), '00:00');
    });
  });

  group('DurationEstimator.estimateProgress', () {
    test('returns 0 for empty text', () {
      expect(
        DurationEstimator.estimateProgress('', const Duration(seconds: 5)),
        0.0,
      );
    });

    test('returns progress between 0 and 1', () {
      final text = 'a' * 150;
      final progress = DurationEstimator.estimateProgress(
        text,
        const Duration(seconds: 5),
      );
      expect(progress, inInclusiveRange(0.0, 1.0));
    });

    test('returns 1.0 when elapsed exceeds estimate', () {
      final text = 'a' * 15;
      final progress = DurationEstimator.estimateProgress(
        text,
        const Duration(seconds: 10),
      );
      expect(progress, 1.0);
    });

    test('returns partial progress', () {
      final text = 'a' * 150;
      final progress = DurationEstimator.estimateProgress(
        text,
        const Duration(seconds: 5),
      );
      expect(progress, closeTo(0.5, 0.1));
    });
  });
}
