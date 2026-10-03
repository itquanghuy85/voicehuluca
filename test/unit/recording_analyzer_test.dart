import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:voice_huluca/core/audio/recording_analyzer.dart';

/// Builds a 16-bit PCM mono WAV the way the record plugin writes it.
/// [speechRatio] is the share of the clip that carries the tone, so a test can
/// model a quiet voice separated by long pauses.
Uint8List buildWav({
  required double amplitude,
  int sampleRate = 22050,
  int seconds = 5,
  double speechRatio = 1.0,
}) {
  final sampleCount = sampleRate * seconds;
  final dataLength = sampleCount * 2;
  final bytes = ByteData(44 + dataLength);

  void writeAscii(int offset, String value) {
    for (var i = 0; i < value.length; i++) {
      bytes.setUint8(offset + i, value.codeUnitAt(i));
    }
  }

  writeAscii(0, 'RIFF');
  bytes.setUint32(4, 36 + dataLength, Endian.little);
  writeAscii(8, 'WAVE');
  writeAscii(12, 'fmt ');
  bytes.setUint32(16, 16, Endian.little);
  bytes.setUint16(20, 1, Endian.little); // PCM
  bytes.setUint16(22, 1, Endian.little); // mono
  bytes.setUint32(24, sampleRate, Endian.little);
  bytes.setUint32(28, sampleRate * 2, Endian.little);
  bytes.setUint16(32, 2, Endian.little);
  bytes.setUint16(34, 16, Endian.little);
  writeAscii(36, 'data');
  bytes.setUint32(40, dataLength, Endian.little);

  final speaking = (sampleCount * speechRatio).round();
  final random = Random(7);
  for (var i = 0; i < sampleCount; i++) {
    final noise = (random.nextDouble() - 0.5) * 0.002;
    final wave = i < speaking ? sin(2 * pi * 220 * i / sampleRate) : 0.0;
    bytes.setInt16(
      44 + i * 2,
      ((wave + noise) * amplitude * 32767).round(),
      Endian.little,
    );
  }
  return bytes.buffer.asUint8List();
}

void main() {
  group('Recording quality', () {
    test('a spoken sample is accepted', () {
      final quality = analyzeWavBytes(buildWav(amplitude: 0.3));

      expect(quality.hasSpeech, isTrue);
      expect(quality.duration.inSeconds, 5);
      expect(quality.peak, greaterThan(0.2));
      expect(quality.rms, greaterThan(0.05));
    });

    test('room tone alone is rejected so no useless voice is created', () {
      final quality = analyzeWavBytes(buildWav(amplitude: 0.004));

      expect(quality.status, RecordingStatus.silent);
      expect(quality.hasSpeech, isFalse);
      expect(quality.rms, lessThan(0.02));
    });

    test('a digital silent file is rejected', () {
      final bytes = buildWav(amplitude: 0);
      final quality = analyzeWavBytes(bytes);

      expect(quality.hasSpeech, isFalse);
      expect(quality.status, RecordingStatus.silent);
    });

    test('a quiet voice diluted by long pauses is still accepted', () {
      // 20 seconds of near-silence followed by 4 seconds of quiet speech:
      // whole-file RMS stays far below the old 0.02 cut-off.
      final quality = analyzeWavBytes(
        buildWav(amplitude: 0.03, seconds: 24, speechRatio: 1 / 6),
      );

      expect(quality.rms, lessThan(0.02));
      expect(quality.hasSpeech, isTrue);
    });

    test('a truncated file is reported as unreadable, not as a quiet room', () {
      final bytes = buildWav(amplitude: 0.3);
      final truncated = Uint8List.sublistView(bytes, 0, 20);

      expect(
        analyzeWavBytes(truncated).status,
        RecordingStatus.malformedHeader,
      );
    });

    test('a non 16-bit file is reported as a format problem', () {
      final bytes = buildWav(amplitude: 0.3);
      ByteData.sublistView(bytes).setUint16(34, 24, Endian.little);

      expect(
        analyzeWavBytes(bytes).status,
        RecordingStatus.unsupportedFormat,
      );
    });

    test('garbage input does not throw', () {
      expect(analyzeWavBytes(Uint8List(0)).hasSpeech, isFalse);
      expect(
        analyzeWavBytes(Uint8List.fromList([1, 2, 3])).status,
        RecordingStatus.malformedHeader,
      );
    });
  });
}
