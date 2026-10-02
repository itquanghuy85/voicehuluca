import 'package:voice_huluca/core/constants/app_constants.dart';

class DurationEstimator {
  DurationEstimator._();

  static const double _charsPerSecond = AppConstants.vietnameseCharsPerSecond;
  static const double _minSeconds = AppConstants.minEstimatedDurationSeconds;
  static const double _maxSeconds = AppConstants.maxEstimatedDurationSeconds;

  static Duration estimate(String text) {
    if (text.isEmpty) return Duration.zero;
    final seconds = text.length / _charsPerSecond;
    final clamped = seconds.clamp(_minSeconds, _maxSeconds);
    return Duration(milliseconds: (clamped * 1000).round());
  }

  static Duration estimateWithSpeed(String text, double speed) {
    if (text.isEmpty || speed <= 0) return Duration.zero;
    final baseSeconds = text.length / _charsPerSecond;
    final adjustedSeconds = baseSeconds / speed;
    final clamped = adjustedSeconds.clamp(_minSeconds, _maxSeconds);
    return Duration(milliseconds: (clamped * 1000).round());
  }

  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    }
    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    }
    return '${seconds}s';
  }

  static String formatDurationShort(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  static double estimateProgress(String text, Duration elapsed) {
    final estimated = estimate(text);
    if (estimated.inMilliseconds == 0) return 0.0;
    final progress = elapsed.inMilliseconds / estimated.inMilliseconds;
    return progress.clamp(0.0, 1.0);
  }
}
