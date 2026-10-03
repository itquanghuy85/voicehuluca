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

  /// The file is not a RIFF/WAVE container at all.
  notRiff,

  /// The container has no `fmt ` or `data` chunk.
  missingData,

  /// Inside the container but not decodable PCM (AAC, 24-bit float, ...).
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
    this.detected = '',
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

  /// What the file header said it was, for the error message and the log.
  final String detected;

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

  RecordingQuality withStatus(RecordingStatus value, [String? detected]) =>
      RecordingQuality(
        duration: duration,
        peak: peak,
        rms: rms,
        peakWindowRms: peakWindowRms,
        status: value,
        detected: detected ?? this.detected,
      );

  @override
  String toString() =>
      'RecordingQuality(${status.name}, ${duration.inMilliseconds}ms, '
      'peak=${peak.toStringAsFixed(4)}, rms=${rms.toStringAsFixed(4)}, '
      'window=${peakWindowRms.toStringAsFixed(4)}, detected="$detected")';
}

/// Length of the sliding window used to find the loudest part of the sample.
const int _windowMs = 20;

/// Reads a PCM WAV file and measures its loudness. Every PCM sample width is
/// accepted, not just 16-bit: recorders happily hand back 8/24/32-bit int or
/// 32/64-bit float, and rejecting those would fail a perfectly good recording.
RecordingQuality analyzeWavFile(File file) {
  try {
    return analyzeWavBytes(file.readAsBytesSync());
  } catch (_) {
    return RecordingQuality.unreadableValue;
  }
}

/// Locates the `fmt ` and `data` chunks of a RIFF/WAVE file, or null when the
/// bytes are not a WAV container.
WavLayout? parseWav(Uint8List bytes) => WavLayout.parse(bytes);

RecordingQuality analyzeWavBytes(Uint8List bytes) {
  if (bytes.length < 44) {
    return RecordingQuality.silent.withStatus(
      RecordingStatus.malformedHeader,
      '${bytes.length} byte',
    );
  }

  final layout = WavLayout.parse(bytes);
  if (layout == null) {
    return RecordingQuality.silent.withStatus(
      RecordingStatus.notRiff,
      _magic(bytes),
    );
  }

  final label = layout.describe();
  if (!layout.isDecodable ||
      layout.channels <= 0 ||
      layout.sampleRate <= 0 ||
      layout.frameSize == 0) {
    return RecordingQuality.silent.withStatus(
      RecordingStatus.unsupportedFormat,
      label,
    );
  }

  final frames = math.min(
    layout.dataLength ~/ layout.frameSize,
    (bytes.length - layout.dataOffset) ~/ layout.frameSize,
  );
  if (frames <= 0) {
    return RecordingQuality.silent.withStatus(RecordingStatus.empty, label);
  }

  final view = ByteData.sublistView(bytes);
  final windowFrames = math.max(1, (layout.sampleRate * _windowMs / 1000).round());

  var peak = 0.0;
  var totalEnergy = 0.0;
  var windowEnergy = 0.0;
  var inWindow = 0;
  var peakWindowRms = 0.0;
  var counted = 0;

  void closeWindow(int framesInWindow) {
    final value = math.sqrt(windowEnergy / framesInWindow);
    if (value > peakWindowRms) peakWindowRms = value;
    windowEnergy = 0;
    inWindow = 0;
  }

  for (var frame = 0; frame < frames; frame++) {
    final base = layout.dataOffset + frame * layout.frameSize;
    for (var channel = 0; channel < layout.channels; channel++) {
      final offset = base + channel * layout.bytesPerSample;
      if (offset + layout.bytesPerSample > bytes.length) continue;
      final magnitude = layout.readMagnitude(view, offset);
      if (magnitude > peak) peak = magnitude;
      final energy = magnitude * magnitude;
      totalEnergy += energy;
      windowEnergy += energy;
      counted++;
      inWindow++;
      if (inWindow >= windowFrames * layout.channels) {
        closeWindow(inWindow);
      }
    }
  }
  if (inWindow > 0) closeWindow(inWindow);

  final duration = Duration(
    microseconds: (frames / layout.sampleRate * 1000000).round(),
  );
  final quality = RecordingQuality(
    duration: duration,
    peak: peak,
    rms: counted == 0 ? 0 : math.sqrt(totalEnergy / counted),
    peakWindowRms: peakWindowRms,
    status: RecordingStatus.ok,
    detected: label,
  );

  final audible =
      quality.peak >= RecordingQuality.minPeak &&
      quality.peakWindowRms >= RecordingQuality.minWindowRms;
  return quality.withStatus(
    audible ? RecordingStatus.ok : RecordingStatus.silent,
  );
}

/// The `fmt ` and `data` chunks of a RIFF/WAVE file.
class WavLayout {
  WavLayout({
    required this.formatTag,
    required this.channels,
    required this.sampleRate,
    required this.bitsPerSample,
    required this.dataOffset,
    required this.dataLength,
  });

  /// 1 = integer PCM, 3 = IEEE float.
  final int formatTag;
  final int channels;
  final int sampleRate;
  final int bitsPerSample;
  final int dataOffset;
  final int dataLength;

  int get bytesPerSample => bitsPerSample ~/ 8;

  int get frameSize => bytesPerSample * channels;

  bool get _isFloat => formatTag == 3;

  bool get isPcm16 => formatTag == 1 && bitsPerSample == 16;

  /// Only integer PCM and IEEE float carry samples we can read. Anything else
  /// in a WAV wrapper (AAC, ADPCM, ...) has to be refused by name.
  bool get isDecodable => formatTag == 1 || formatTag == 3;

  /// True when the samples can be handed to the XTTS engine untouched.
  bool get needsConversion => !isPcm16;

  /// Reads one sample as a signed value in -1..1.
  double readNormalized(ByteData view, int offset) {
    switch (bitsPerSample) {
      case 8:
        // 8-bit WAV PCM is unsigned with a 128 bias.
        return (view.getUint8(offset) - 128) / 128.0;
      case 16:
        return view.getInt16(offset, Endian.little) / 32768.0;
      case 24:
        final raw =
            view.getUint8(offset) |
            (view.getUint8(offset + 1) << 8) |
            (view.getUint8(offset + 2) << 16);
        final signed = raw > 0x7FFFFF ? raw - 0x1000000 : raw;
        return signed / 8388608.0;
      case 32:
        return _isFloat
            ? view.getFloat32(offset, Endian.little)
            : view.getInt32(offset, Endian.little) / 2147483648.0;
      case 64:
        return view.getFloat64(offset, Endian.little);
      default:
        return 0;
    }
  }

  /// Reads one sample as a 0..1 magnitude.
  double readMagnitude(ByteData view, int offset) =>
      readNormalized(view, offset).abs();

  String describe() {
    final kind = _isFloat
        ? 'float$bitsPerSample'
        : formatTag == 1
        ? 'PCM $bitsPerSample-bit'
        : 'format 0x${formatTag.toRadixString(16)}';
    return '$kind, ${sampleRate}Hz, ${channels}ch';
  }

  /// Walks the RIFF chunks. Returns null when this is not a RIFF/WAVE file.
  /// Both chunks are located by walking, never by fixed offset, because some
  /// recorders emit `LIST`/`fact` before `fmt `.
  static WavLayout? parse(Uint8List bytes) {
    if (bytes.length < 12) return null;
    if (String.fromCharCodes(bytes.sublist(0, 4)) != 'RIFF') return null;
    if (String.fromCharCodes(bytes.sublist(8, 12)) != 'WAVE') return null;

    var fmtOffset = -1;
    var fmtSize = 0;
    var dataOffset = -1;
    var dataLength = 0;

    var offset = 12;
    while (offset + 8 <= bytes.length) {
      final id = String.fromCharCodes(bytes.sublist(offset, offset + 4));
      final size = _readInt32(bytes, offset + 4);
      if (size < 0) break;
      final body = offset + 8;
      if (id == 'fmt ' && fmtOffset < 0) {
        fmtOffset = body;
        fmtSize = size;
      } else if (id == 'data' && dataOffset < 0) {
        dataOffset = body;
        dataLength = math.min(size, bytes.length - body);
      }
      if (fmtOffset >= 0 && dataOffset >= 0) break;
      offset = body + size + (size.isOdd ? 1 : 0);
    }

    if (fmtOffset < 0 || dataOffset < 0 || fmtSize < 16) return null;

    var formatTag = _readInt16(bytes, fmtOffset);
    final channels = _readInt16(bytes, fmtOffset + 2);
    final sampleRate = _readInt32(bytes, fmtOffset + 4);
    final bitsPerSample = _readInt16(bytes, fmtOffset + 14);

    // WAVE_FORMAT_EXTENSIBLE keeps the real tag at the head of the sub-format
    // GUID, 24 bytes into the chunk body.
    if (formatTag == 0xFFFE && fmtSize >= 40) {
      final real = _readInt16(bytes, fmtOffset + 24);
      if (real != 0) formatTag = real;
    }

    return WavLayout(
      formatTag: formatTag,
      channels: channels,
      sampleRate: sampleRate,
      bitsPerSample: bitsPerSample,
      dataOffset: dataOffset,
      dataLength: dataLength,
    );
  }
}

String _magic(Uint8List bytes) {
  final head = bytes.length >= 4
      ? String.fromCharCodes(bytes.sublist(0, 4))
      : '${bytes.length} byte';
  return 'not a WAV file (starts with "$head")';
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