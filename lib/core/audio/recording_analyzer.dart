import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

/// Why a recorded sample was accepted or refused. The sheet turns this into the
/// message the user sees, so a broken file is never reported as "check your
/// microphone".
enum RecordingStatus {
  /// Audible speech was found.
  ok,

  /// The file could not be read at all.
  unreadable,

  /// The file is too short to contain a WAV header.
  malformedHeader,

  /// The RIFF container has no `data` chunk.
  missingData,

  /// Not 16-bit PCM (24-bit, float, compressed, ...).
  unsupportedFormat,

  /// The `data` chunk holds no samples.
  empty,

  /// Samples exist but the file is effectively silent.
  silent,
}

/// Loudness of a recorded sample, used to refuse a silent recording before it
/// becomes an unusable cloned voice.
class RecordingQuality {
  const RecordingQuality({
    required this.duration,
    required this.peak,
    required this.rms,
    required this.peakWindowRms,
    required this.status,
  });

  final Duration duration;

  /// Loudest single sample, 0..1.
  final double peak;

  /// Loudness averaged over the whole file, 0..1.
  final double rms;

  /// Loudness of the loudest 20 ms window, 0..1. A quiet voice surrounded by
  /// pauses drags the whole-file [rms] down, so this is what actually decides
  /// whether somebody spoke.
  final double peakWindowRms;

  final RecordingStatus status;

  bool get hasSpeech => status == RecordingStatus.ok;

  /// Anything louder than this counts as a voice rather than room tone
  /// (-34 dBFS). Phone microphones in a quiet room still peak well above this
  /// when the user reads the sample text.
  static const double minPeak = 0.02;

  /// The loudest 20 ms window has to reach -42 dBFS. Noise floor of a silent
  /// room sits far below it; breathing and quiet speech sit above it.
  static const double minWindowRms = 0.008;

  static const RecordingQuality unreadableValue = RecordingQuality(
    duration: Duration.zero,
    peak: 0,
    rms: 0,
    peakWindowRms: 0,
    status: RecordingStatus.unreadable,
  );

  static const RecordingQuality silent = RecordingQuality(
    duration: Duration.zero,
    peak: 0,
    rms: 0,
    peakWindowRms: 0,
    status: RecordingStatus.silent,
  );

  RecordingQuality withStatus(RecordingStatus value) => RecordingQuality(
    duration: duration,
    peak: peak,
    rms: rms,
    peakWindowRms: peakWindowRms,
    status: value,
  );

  @override
  String toString() =>
      'RecordingQuality(${status.name}, ${duration.inMilliseconds}ms, '
      'peak=${peak.toStringAsFixed(4)}, rms=${rms.toStringAsFixed(4)}, '
      'window=${peakWindowRms.toStringAsFixed(4)})';
}

/// Length of the sliding window used to find the loudest part of the sample.
const int _windowMs = 20;

/// Reads a 16-bit PCM WAV file and measures its loudness. Only the parts
/// needed for the check are read, so a long recording stays cheap.
RecordingQuality analyzeWavFile(File file) {
  try {
    return analyzeWavBytes(file.readAsBytesSync());
  } catch (_) {
    return RecordingQuality.unreadableValue;
  }
}

RecordingQuality analyzeWavBytes(Uint8List bytes) {
  if (bytes.length < 44) {
    return RecordingQuality.silent.withStatus(
      RecordingStatus.malformedHeader,
    );
  }

  final dataRange = _findDataChunk(bytes);
  if (dataRange == null) {
    return RecordingQuality.silent.withStatus(RecordingStatus.missingData);
  }
  final (dataOffset, dataLength) = dataRange;

  final channels = _readInt16(bytes, 22);
  final sampleRate = _readInt32(bytes, 24);
  final bitsPerSample = _readInt16(bytes, 34);
  if (sampleRate <= 0 || channels <= 0 || bitsPerSample != 16) {
    return RecordingQuality.silent.withStatus(
      RecordingStatus.unsupportedFormat,
    );
  }

  final available = math.min(dataLength ~/ 2, (bytes.length - dataOffset) ~/ 2);
  final samples = math.max(0, available);
  if (samples == 0) {
    return RecordingQuality.silent.withStatus(RecordingStatus.empty);
  }

  final windowSamples = math.max(
    1,
    (sampleRate * _windowMs / 1000).round(),
  );

  var peak = 0;
  var windowSumSquares = 0.0;
  var inWindow = 0;
  var peakWindowRms = 0.0;
  double sumSquares = 0;
  for (var i = 0; i < samples; i++) {
    final index = dataOffset + i * 2;
    if (index + 1 >= bytes.length) break;
    final low = bytes[index];
    final high = bytes[index + 1];
    var sample = (high << 8) | low;
    if (sample > 32767) sample -= 65536;
    final magnitude = sample.abs();
    if (magnitude > peak) peak = magnitude;
    final energy = magnitude * magnitude;
    sumSquares += energy;
    windowSumSquares += energy;
    inWindow++;
    if (inWindow >= windowSamples) {
      final windowRms = math.sqrt(windowSumSquares / inWindow) / 32768;
      if (windowRms > peakWindowRms) peakWindowRms = windowRms;
      windowSumSquares = 0;
      inWindow = 0;
    }
  }
  if (inWindow > 0) {
    final windowRms = math.sqrt(windowSumSquares / inWindow) / 32768;
    if (windowRms > peakWindowRms) peakWindowRms = windowRms;
  }

  final duration = Duration(
    microseconds: (samples / channels / sampleRate * 1000000).round(),
  );
  final quality = RecordingQuality(
    duration: duration,
    peak: peak / 32768,
    rms: sumSquares == 0 ? 0 : math.sqrt(sumSquares / samples) / 32768,
    peakWindowRms: peakWindowRms,
    status: RecordingStatus.ok,
  );

  final audible =
      quality.peak >= RecordingQuality.minPeak &&
      quality.peakWindowRms >= RecordingQuality.minWindowRms;
  return quality.withStatus(
    audible ? RecordingStatus.ok : RecordingStatus.silent,
  );
}

/// Walks the RIFF chunks instead of assuming the payload starts at byte 44.
(int, int)? _findDataChunk(Uint8List bytes) {
  var offset = 12;
  while (offset + 8 <= bytes.length) {
    final id = String.fromCharCodes(bytes.sublist(offset, offset + 4));
    final size = _readInt32(bytes, offset + 4);
    if (size < 0) return null;
    if (id == 'data') {
      final start = offset + 8;
      return (start, math.min(size, bytes.length - start));
    }
    offset += 8 + size + (size.isOdd ? 1 : 0);
  }
  return null;
}

int _readInt16(Uint8List bytes, int offset) {
  if (offset + 1 >= bytes.length) return 0;
  return bytes[offset] | (bytes[offset + 1] << 8);
}

int _readInt32(Uint8List bytes, int offset) {
  if (offset + 3 >= bytes.length) return 0;
  return bytes[offset] |
      (bytes[offset + 1] << 8) |
      (bytes[offset + 2] << 16) |
      (bytes[offset + 3] << 24);
}