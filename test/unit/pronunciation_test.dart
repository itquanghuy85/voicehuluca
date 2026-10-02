import 'package:flutter_test/flutter_test.dart';
import 'package:voice_huluca/core/utils/pronunciation.dart';

void main() {
  group('PronunciationRule', () {
    test('creates rule with pattern, replacement, and description', () {
      const rule = PronunciationRule(
        pattern: r'\btest\b',
        replacement: 'test',
        description: 'Test rule',
      );
      expect(rule.pattern, r'\btest\b');
      expect(rule.replacement, 'test');
      expect(rule.description, 'Test rule');
    });

    test('regex is compiled from pattern', () {
      const rule = PronunciationRule(
        pattern: r'\bhello\b',
        replacement: 'hello',
        description: 'Greeting',
      );
      expect(rule.regex.hasMatch('hello world'), isTrue);
      expect(rule.regex.hasMatch('world'), isFalse);
    });
  });

  group('PronunciationDictionary', () {
    test('rules list is not empty', () {
      expect(PronunciationDictionary.rules, isNotEmpty);
    });

    test('rules list is unmodifiable', () {
      expect(
        () => PronunciationDictionary.rules.add(
          const PronunciationRule(
            pattern: 'test',
            replacement: 'test',
            description: 'test',
          ),
        ),
        throwsUnsupportedError,
      );
    });

    test('findRule returns matching rule', () {
      final rule = PronunciationDictionary.findRule('giờ');
      expect(rule, isNotNull);
      expect(rule!.description, contains('hour'));
    });

    test('findRule returns null for non-matching word', () {
      final rule = PronunciationDictionary.findRule('xyznonexistent');
      expect(rule, isNull);
    });

    test('applyRules processes text without errors', () {
      const input = 'Bây giờ là 5 giờ chiều';
      final result = PronunciationDictionary.applyRules(input);
      expect(result, isA<String>());
      expect(result.isNotEmpty, isTrue);
    });

    test('contains number pronunciation rules', () {
      final descriptions = PronunciationDictionary.rules
          .map((r) => r.description)
          .join(' ');
      expect(descriptions, contains('one'));
      expect(descriptions, contains('two'));
      expect(descriptions, contains('three'));
    });

    test('contains time-related rules', () {
      final descriptions = PronunciationDictionary.rules
          .map((r) => r.description)
          .join(' ');
      expect(descriptions, contains('hour'));
      expect(descriptions, contains('minute'));
      expect(descriptions, contains('second'));
    });

    test('contains currency rules', () {
      final descriptions = PronunciationDictionary.rules
          .map((r) => r.description)
          .join(' ');
      expect(descriptions, contains('currency'));
      expect(descriptions, contains('thousand'));
      expect(descriptions, contains('million'));
    });
  });
}
