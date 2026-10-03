import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:voice_huluca/core/audio/recording_analyzer.dart';

/// Builds a PCM WAV the way the record plugin writes it, at any sample width so
/// the analyzer can be checked against every shape a device may return.
/// [speechRatio] is the share of the clip that carries the tone, so a test can
/// model a quiet voice separated by long pauses.
Uint8List buildWav({
  required double amplitude,
  int sampleRate = 22050,
  int seconds = 5,
  double speechRatio = 1.0,
  int bitsPerSample = 16,
  int formatTag = 1,
}) {
  final bytesPerSample = bitsPerSample ~/ 8;
  final sampleCount = sampleRate * seconds;
  final dataLength = sampleCount * bytesPerSample;
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
  bytes.setUint16(20, formatTag, Endian.little);
  bytes.setUint16(22, 1, Endian.little); // mono
  bytes.setUint32(24, sampleRate, Endian.little);
  bytes.setUint32(28, sampleRate * bytesPerSample, Endian.little);
  bytes.setUint16(32, bytesPerSample, Endian.little);
  bytes.setUint16(34, bitsPerSample, Endian.little);
  writeAscii(36, 'data');
  bytes.setUint32(40, dataLength, Endian.little);

  void writeSample(int index, double value) {
    final offset = 44 + index * bytesPerSample;
    switch (bitsPerSample) {
      case 8:
        bytes.setUint8(offset, (value * 127 + 128).round());
      case 16:
        bytes.setInt16(offset, (value * 32767).round(), Endian.little);
      case 24:
        final raw = (value * 8388607).round() & 0xFFFFFF;
        bytes.setUint8(offset, raw & 0xFF);
        bytes.setUint8(offset + 1, (raw >> 8) & 0xFF);
        bytes.setUint8(offset + 2, (raw >> 16) & 0xFF);
      case 32:
        if (formatTag == 3) {
          bytes.setFloat32(offset, value, Endian.little);
        } else {
          bytes.setInt32(offset, (value * 2147483647).round(), Endian.little);
        }
    }
  }

  final speaking = (sampleCount * speechRatio).round();
  final random = Random(7);
  for (var i = 0; i < sampleCount; i++) {
    final noise = (random.nextDouble() - 0.5) * 0.002;
    final wave = i < speaking ? sin(2 * pi * 220 * i / sampleRate) : 0.0;
    writeSample(i, (wave + noise) * amplitude);
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

    test('24-bit PCM is measured, not rejected', () {
      final bytes = buildWav(amplitude: 0.3, bitsPerSample: 24);
      final quality = analyzeWavBytes(bytes);

      expect(quality.status, RecordingStatus.ok);
      expect(quality.hasSpeech, isTrue);
      expect(quality.peak, closeTo(0.3, 0.01));
      expect(quality.detected, contains('24-bit'));
    });

    test('32-bit float PCM is measured, not rejected', () {
      final bytes = buildWav(
        amplitude: 0.3,
        bitsPerSample: 32,
        formatTag: 3,
      );
      final quality = analyzeWavBytes(bytes);

      expect(quality.hasSpeech, isTrue);
      expect(quality.detected, contains('float32'));
    });

    test('a compressed stream is refused by name', () {
      final bytes = buildWav(amplitude: 0.3);
      ByteData.sublistView(bytes).setUint16(20, 0x00FF, Endian.little);

      final quality = analyzeWavBytes(bytes);

      expect(quality.status, RecordingStatus.unsupportedFormat);
      expect(quality.detected, contains('0xff'));
    });

    test('a file that is not a RIFF container is named in the message', () {
      final bytes = buildWav(amplitude: 0.3);
      bytes.setRange(0, 4, 'ftyp'.codeUnits);

      final quality = analyzeWavBytes(bytes);

      expect(quality.status, RecordingStatus.notRiff);
      expect(quality.detected, contains('ftyp'));
    });

    test('a data chunk with no size is measured from the bytes present', () {
      final bytes = buildWav(amplitude: 0.3);
      // Recorders that stream leave this at 0 until the file is closed.
      ByteData.sublistView(bytes).setUint32(40, 0, Endian.little);

      final quality = analyzeWavBytes(bytes);

      expect(quality.hasSpeech, isTrue);
      expect(quality.duration.inSeconds, 5);
    });

    test('a zero bits-per-sample is derived from the block alignment', () {
      final bytes = buildWav(amplitude: 0.3);
      ByteData.sublistView(bytes).setUint16(34, 0, Endian.little);

      final quality = analyzeWavBytes(bytes);

      expect(quality.detected, contains('16-bit'));
      expect(quality.hasSpeech, isTrue);
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
