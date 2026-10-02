import 'package:flutter_test/flutter_test.dart';
import 'package:voice_huluca/core/utils/file_namer.dart';

void main() {
  group('FileNamer.sanitizeFileName', () {
    test('replaces invalid characters with underscore', () {
      expect(FileNamer.sanitizeFileName('file<>:"/\\|?*name'), 'file_name');
    });

    test('replaces spaces with underscore', () {
      expect(FileNamer.sanitizeFileName('my file name'), 'my_file_name');
    });

    test('collapses multiple underscores', () {
      expect(FileNamer.sanitizeFileName('my___file'), 'my_file');
    });

    test('trims leading and trailing underscores', () {
      expect(FileNamer.sanitizeFileName('_my_file_'), 'my_file');
    });

    test('returns fallback for empty string', () {
      final result = FileNamer.sanitizeFileName('');
      expect(result, startsWith('audio_'));
    });

    test('truncates long names to 100 chars', () {
      final longName = 'a' * 150;
      final result = FileNamer.sanitizeFileName(longName);
      expect(result.length, lessThanOrEqualTo(100));
    });

    test('preserves valid characters', () {
      expect(FileNamer.sanitizeFileName('my-file_name123'), 'my-file_name123');
    });
  });

  group('FileNamer.generateFileName', () {
    test('generates file name with default prefix', () {
      final name = FileNamer.generateFileName();
      expect(name, startsWith('audio_'));
      expect(name, endsWith('.mp3'));
    });

    test('generates file name with custom prefix', () {
      final name = FileNamer.generateFileName(prefix: 'voice');
      expect(name, startsWith('voice_'));
    });

    test('generates file name with custom extension', () {
      final name = FileNamer.generateFileName(extension: 'wav');
      expect(name, endsWith('.wav'));
    });

    test('generates unique names', () {
      final name1 = FileNamer.generateFileName();
      final name2 = FileNamer.generateFileName();
      expect(name1, isNot(equals(name2)));
    });

    test('includes suffix when provided', () {
      final name = FileNamer.generateFileName(suffix: 'final');
      expect(name, contains('final'));
    });
  });

  group('FileNamer.generateVoiceFileName', () {
    test('generates voice file name from voice name', () {
      final name = FileNamer.generateVoiceFileName('Giọng Nữ 01');
      expect(name, startsWith('Giọng_Nữ_01_'));
      expect(name, endsWith('.mp3'));
    });

    test('sanitizes voice name', () {
      final name = FileNamer.generateVoiceFileName('Giọng<>Nữ');
      expect(name, isNot(contains('<')));
      expect(name, isNot(contains('>')));
    });
  });

  group('FileNamer.generateScriptFileName', () {
    test('generates script file name', () {
      final name = FileNamer.generateScriptFileName('Kịch bản 1');
      expect(name, startsWith('Kịch_bản_1_'));
      expect(name, endsWith('.txt'));
    });
  });

  group('FileNamer.generateExportFileName', () {
    test('generates export file name', () {
      final name = FileNamer.generateExportFileName('my_audio', 'wav');
      expect(name, startsWith('my_audio_'));
      expect(name, endsWith('.wav'));
    });
  });

  group('FileNamer.getExtension', () {
    test('returns extension for file with extension', () {
      expect(FileNamer.getExtension('file.mp3'), 'mp3');
    });

    test('returns empty string for file without extension', () {
      expect(FileNamer.getExtension('file'), '');
    });

    test('returns empty string for file ending with dot', () {
      expect(FileNamer.getExtension('file.'), '');
    });

    test('returns lowercase extension', () {
      expect(FileNamer.getExtension('file.MP3'), 'mp3');
    });
  });

  group('FileNamer.changeExtension', () {
    test('changes extension', () {
      expect(FileNamer.changeExtension('file.mp3', 'wav'), 'file.wav');
    });

    test('adds extension to file without one', () {
      expect(FileNamer.changeExtension('file', 'mp3'), 'file.mp3');
    });
  });

  group('FileNamer.isValidFileName', () {
    test('returns true for valid name', () {
      expect(FileNamer.isValidFileName('my_file.mp3'), isTrue);
    });

    test('returns false for empty name', () {
      expect(FileNamer.isValidFileName(''), isFalse);
    });

    test('returns false for name with invalid chars', () {
      expect(FileNamer.isValidFileName('file<name'), isFalse);
    });

    test('returns false for name exceeding max length', () {
      expect(FileNamer.isValidFileName('a' * 101), isFalse);
    });
  });
}
