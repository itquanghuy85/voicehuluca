import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:voice_huluca/core/audio/recording_analyzer.dart';

/// Builds a 16-bit PCM mono WAV the way the record plugin writes it.
Uint8List buildWav({
  required double amplitude,
  int sampleRate = 22050,
  int seconds = 5,
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

  final random = Random(7);
  for (var i = 0; i < sampleCount; i++) {
    final wave = sin(2 * pi * 220 * i / sampleRate);
    final noise = (random.nextDouble() - 0.5) * 0.002;
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

      expect(quality.hasSpeech, isFalse);
      expect(quality.rms, lessThan(0.02));
    });

    test('a digital silent file is rejected', () {
      final bytes = buildWav(amplitude: 0);
      final quality = analyzeWavBytes(bytes);

      expect(quality.hasSpeech, isFalse);
    });

    test('the silent clone sample from the phone is detected', () {
      final quality = analyzeWavFile(
        File(r'C:\Users\Admin\.vietvoice\voices\2a7001c7ce27\reference.wav'),
      );
      // Recording made in a quiet room with no speech: must be refused.
      expect(quality.duration.inSeconds, greaterThan(5));
      expect(quality.hasSpeech, isFalse);
    });

    test('garbage input does not throw', () {
      expect(analyzeWavBytes(Uint8List(0)).hasSpeech, isFalse);
      expect(analyzeWavBytes(Uint8List.fromList([1, 2, 3])).hasSpeech, isFalse);
    });
  });
}
