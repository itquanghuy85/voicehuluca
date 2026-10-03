import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:voice_huluca/core/audio/recording_analyzer.dart';
import 'package:voice_huluca/core/audio/wav_converter.dart';

import 'recording_analyzer_test.dart' show buildWav;

void main() {
  group('WavConverter', () {
    test('a 16-bit PCM file is left alone', () {
      expect(WavConverter.toPcm16Bytes(buildWav(amplitude: 0.3)), isNull);
    });

    test('a 24-bit PCM file becomes 16-bit PCM', () {
      final converted = WavConverter.toPcm16Bytes(
        buildWav(amplitude: 0.5, bitsPerSample: 24),
      );

      expect(converted, isNotNull);
      final layout = parseWav(converted!);
      expect(layout, isNotNull);
      expect(layout!.isPcm16, isTrue);
      expect(layout.channels, 1);
      expect(layout.sampleRate, 22050);
    });

    test('a 32-bit float file becomes 16-bit PCM without losing level', () {
      final source = buildWav(amplitude: 0.5, bitsPerSample: 32, formatTag: 3);
      final converted = WavConverter.toPcm16Bytes(source)!;

      final before = analyzeWavBytes(source);
      final after = analyzeWavBytes(converted);

      expect(after.peak, closeTo(before.peak, 0.01));
      expect(after.duration, before.duration);
      expect(after.hasSpeech, isTrue);
    });

    test('a file that is not decodable PCM is refused, not corrupted', () {
      final bytes = buildWav(amplitude: 0.3);
      ByteData.sublistView(bytes).setUint16(20, 0x00FF, Endian.little);

      expect(WavConverter.toPcm16Bytes(bytes), isNull);
    });

    test('output carries a header a WAV reader accepts', () {
      final converted = WavConverter.toPcm16Bytes(
        buildWav(amplitude: 0.3, bitsPerSample: 24),
      )!;

      expect(String.fromCharCodes(converted.sublist(0, 4)), 'RIFF');
      expect(String.fromCharCodes(converted.sublist(8, 12)), 'WAVE');
      expect(String.fromCharCodes(converted.sublist(36, 40)), 'data');
      final dataSize = ByteData.sublistView(
        converted,
      ).getUint32(40, Endian.little);
      expect(converted.length, 44 + dataSize);
    });
  });
}