import 'package:flutter_test/flutter_test.dart';
import 'package:voice_huluca/core/utils/text_preprocessor.dart';

void main() {
  group('TextPreprocessor.normalizeWhitespace', () {
    test('collapses multiple spaces into one', () {
      expect(
        TextPreprocessor.normalizeWhitespace('hello   world'),
        'hello world',
      );
    });

    test('collapses tabs into single space', () {
      expect(
        TextPreprocessor.normalizeWhitespace('hello\t\tworld'),
        'hello world',
      );
    });

    test('trims leading and trailing whitespace', () {
      expect(TextPreprocessor.normalizeWhitespace('  hello  '), 'hello');
    });

    test('handles empty string', () {
      expect(TextPreprocessor.normalizeWhitespace(''), '');
    });

    test('handles string with only whitespace', () {
      expect(TextPreprocessor.normalizeWhitespace('   '), '');
    });
  });

  group('TextPreprocessor.normalizeNewlines', () {
    test('collapses 3+ newlines into 2', () {
      expect(TextPreprocessor.normalizeNewlines('a\n\n\nb'), 'a\n\nb');
    });

    test('collapses many newlines into 2', () {
      expect(TextPreprocessor.normalizeNewlines('a\n\n\n\n\nb'), 'a\n\nb');
    });

    test('preserves single newline', () {
      expect(TextPreprocessor.normalizeNewlines('a\nb'), 'a\nb');
    });

    test('preserves double newline', () {
      expect(TextPreprocessor.normalizeNewlines('a\n\nb'), 'a\n\nb');
    });
  });

  group('TextPreprocessor.removeRepeatedChars', () {
    test('limits repeated exclamation marks to 3', () {
      expect(TextPreprocessor.removeRepeatedChars('hello!!!!!!'), 'hello!!!');
    });

    test('limits repeated question marks to 3', () {
      expect(TextPreprocessor.removeRepeatedChars('what??????'), 'what???');
    });

    test('limits repeated periods to 3', () {
      expect(TextPreprocessor.removeRepeatedChars('wait.......'), 'wait...');
    });

    test('limits repeated identical chars to 3', () {
      expect(TextPreprocessor.removeRepeatedChars('haaaaaa'), 'haaa');
    });

    test('preserves normal text', () {
      expect(
        TextPreprocessor.removeRepeatedChars('hello world'),
        'hello world',
      );
    });
  });

  group('TextPreprocessor.formatBasicNumbers', () {
    test('formats 4-digit number with comma', () {
      expect(TextPreprocessor.formatBasicNumbers('1000'), '1,000');
    });

    test('formats large number with commas', () {
      expect(TextPreprocessor.formatBasicNumbers('1000000'), '1,000,000');
    });

    test('does not format 3-digit number', () {
      expect(TextPreprocessor.formatBasicNumbers('999'), '999');
    });

    test('formats number within text', () {
      expect(
        TextPreprocessor.formatBasicNumbers('Tổng: 5000 đồng'),
        'Tổng: 5,000 đồng',
      );
    });

    test('formats multiple numbers in text', () {
      expect(
        TextPreprocessor.formatBasicNumbers('1000 và 2000'),
        '1,000 và 2,000',
      );
    });
  });

  group('TextPreprocessor.preserveTechnicalTerms', () {
    test('preserves model names', () {
      final input = 'Sử dụng eleven_multilingual_v2 model';
      final result = TextPreprocessor.preserveTechnicalTerms(input);
      expect(result, contains('eleven_multilingual_v2'));
    });

    test('preserves error codes', () {
      final input = 'Lỗi ERR_CONNECTION_FAILED xảy ra';
      final result = TextPreprocessor.preserveTechnicalTerms(input);
      expect(result, contains('ERR_CONNECTION_FAILED'));
    });

    test('preserves HTTP status codes', () {
      final input = 'HTTP_500 error';
      final result = TextPreprocessor.preserveTechnicalTerms(input);
      expect(result, contains('HTTP_500'));
    });

    test('preserves abbreviations', () {
      final input = 'API và TTS là các viết tắt';
      final result = TextPreprocessor.preserveTechnicalTerms(input);
      expect(result, contains('API'));
      expect(result, contains('TTS'));
    });

    test('preserves version numbers', () {
      final input = 'Phiên bản v2.1.0';
      final result = TextPreprocessor.preserveTechnicalTerms(input);
      expect(result, contains('v2.1.0'));
    });
  });

  group('TextPreprocessor.preprocess', () {
    test('applies all preprocessing steps', () {
      final input = '  hello   world\n\n\n\n!!!!  ';
      final result = TextPreprocessor.preprocess(input);
      expect(result, 'hello world\n\n!!!');
    });

    test('handles Vietnamese text', () {
      final input = '  Xin   chào\n\n\nthế   giới  ';
      final result = TextPreprocessor.preprocess(input);
      expect(result, 'Xin chào\n\nthế giới');
    });
  });

  group('TextPreprocessor.estimateDuration', () {
    test('estimates duration for 15 chars as ~1 second', () {
      final text = 'a' * 15;
      final duration = TextPreprocessor.estimateDuration(text);
      expect(duration.inSeconds, 1);
    });

    test('estimates duration for 150 chars as ~10 seconds', () {
      final text = 'a' * 150;
      final duration = TextPreprocessor.estimateDuration(text);
      expect(duration.inSeconds, 10);
    });

    test('returns zero for empty text', () {
      final duration = TextPreprocessor.estimateDuration('');
      expect(duration, Duration.zero);
    });

    test('estimates Vietnamese text duration', () {
      final text = 'Xin chào thế giới';
      final duration = TextPreprocessor.estimateDuration(text);
      expect(duration.inMilliseconds, greaterThan(0));
    });
  });
}
