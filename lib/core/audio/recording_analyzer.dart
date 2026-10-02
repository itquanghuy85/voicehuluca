import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

/// Loudness of a recorded sample, used to refuse a silent recording before it
/// becomes an unusable cloned voice.
class RecordingQuality {
  const RecordingQuality({
    required this.duration,
    required this.peak,
    required this.rms,
  });

  final Duration duration;
  final double peak;
  final double rms;

  /// A usable sample has audible speech. Speech sits well above -30 dBFS RMS;
  /// a quiet room only produces faint noise around -35 dBFS.
  bool get hasSpeech => peak >= 0.06 && rms >= 0.02;

  static const RecordingQuality silent = RecordingQuality(
    duration: Duration.zero,
    peak: 0,
    rms: 0,
  );
}

/// Reads a 16-bit PCM WAV file and measures its loudness. Only the parts
/// needed for the check are read, so a long recording stays cheap.
RecordingQuality analyzeWavFile(File file) {
  try {
    final bytes = file.readAsBytesSync();
    return analyzeWavBytes(bytes);
  } catch (_) {
    return RecordingQuality.silent;
  }
}

RecordingQuality analyzeWavBytes(Uint8List bytes) {
  if (bytes.length < 44) return RecordingQuality.silent;

  final dataRange = _findDataChunk(bytes);
  if (dataRange == null) return RecordingQuality.silent;
  final (dataOffset, dataLength) = dataRange;

  final channels = _readInt16(bytes, 22);
  final sampleRate = _readInt32(bytes, 24);
  final bitsPerSample = _readInt16(bytes, 34);
  if (sampleRate <= 0 || channels <= 0 || bitsPerSample != 16) {
    return RecordingQuality.silent;
  }

  final available = math.min(dataLength ~/ 2, (bytes.length - dataOffset) ~/ 2);
  final samples = math.max(0, available);
  if (samples == 0) return RecordingQuality.silent;

  var peak = 0;
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
    sumSquares += magnitude * magnitude;
  }

  final duration = Duration(
    microseconds: (samples / channels / sampleRate * 1000000).round(),
  );
  return RecordingQuality(
    duration: duration,
    peak: peak / 32768,
    rms: samples == 0 ? 0 : _sqrt(sumSquares / samples) / 32768,
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

double _sqrt(double value) {
  if (value <= 0) return 0;
  var guess = value;
  for (var i = 0; i < 12; i++) {
    guess = 0.5 * (guess + value / guess);
  }
  return guess;
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
