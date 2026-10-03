import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:voice_huluca/core/audio/recording_analyzer.dart';

/// The local XTTS engine reads samples with Python's `wave` module, which only
/// understands integer PCM. Android and iOS recorders do not always hand back
/// 16-bit: some devices produce 24-bit or 32-bit float WAV. Rather than refuse
/// those recordings, they are rewritten as 16-bit PCM.
class WavConverter {
  const WavConverter._();

  /// Returns [source] untouched when it is already 16-bit PCM, otherwise writes
  /// a converted copy in the temporary directory.
  static Future<File> ensurePcm16(File source) async {
    final converted = toPcm16Bytes(await source.readAsBytes());
    if (converted == null) return source;

    final directory = await getTemporaryDirectory();
    final target = File(
      p.join(
        directory.path,
        '${p.basenameWithoutExtension(source.path)}_pcm16.wav',
      ),
    );
    await target.writeAsBytes(converted, flush: true);
    return target;
  }

  /// Rewrites PCM WAV bytes as 16-bit PCM, keeping sample rate and channel
  /// count. Returns null when no conversion is needed or possible.
  static Uint8List? toPcm16Bytes(Uint8List bytes) {
    final layout = parseWav(bytes);
    if (layout == null || !layout.isDecodable || !layout.needsConversion) {
      return null;
    }

    final frames = math.min(
      layout.dataLength ~/ layout.frameSize,
      (bytes.length - layout.dataOffset) ~/ layout.frameSize,
    );
    if (frames <= 0 || layout.channels <= 0) return null;

    final view = ByteData.sublistView(bytes);
    final out = ByteData(44 + frames * layout.channels * 2);
    _writeHeader(
      out,
      channels: layout.channels,
      sampleRate: layout.sampleRate,
      dataLength: frames * layout.channels * 2,
    );

    var cursor = 44;
    for (var frame = 0; frame < frames; frame++) {
      final base = layout.dataOffset + frame * layout.frameSize;
      for (var channel = 0; channel < layout.channels; channel++) {
        final source = base + channel * layout.bytesPerSample;
        if (source + layout.bytesPerSample > bytes.length) continue;
        final value = layout.readNormalized(view, source).clamp(-1.0, 1.0);
        out.setInt16(
          cursor,
          (value * 32767).round().clamp(-32768, 32767),
          Endian.little,
        );
        cursor += 2;
      }
    }

    return out.buffer.asUint8List();
  }

  static void _writeHeader(
    ByteData out, {
    required int channels,
    required int sampleRate,
    required int dataLength,
  }) {
    void ascii(int offset, String value) {
      for (var i = 0; i < value.length; i++) {
        out.setUint8(offset + i, value.codeUnitAt(i));
      }
    }

    final blockAlign = channels * 2;
    ascii(0, 'RIFF');
    out.setUint32(4, 36 + dataLength, Endian.little);
    ascii(8, 'WAVE');
    ascii(12, 'fmt ');
    out.setUint32(16, 16, Endian.little);
    out.setUint16(20, 1, Endian.little); // integer PCM
    out.setUint16(22, channels, Endian.little);
    out.setUint32(24, sampleRate, Endian.little);
    out.setUint32(28, sampleRate * blockAlign, Endian.little);
    out.setUint16(32, blockAlign, Endian.little);
    out.setUint16(34, 16, Endian.little);
    ascii(36, 'data');
    out.setUint32(40, dataLength, Endian.little);
  }
}