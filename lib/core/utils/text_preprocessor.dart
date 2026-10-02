class TextPreprocessor {
  TextPreprocessor._();

  static final RegExp _whitespaceRegex = RegExp(r'[ \t]+');
  static final RegExp _newlineRegex = RegExp(r'\n{3,}');
  static final RegExp _repeatedPunctRegex = RegExp(r'([!?.]){4,}');
  static final RegExp _repeatedCharRegex = RegExp(r'(.)\1{4,}');

  static String normalizeWhitespace(String text) {
    return text.replaceAll(_whitespaceRegex, ' ').trim();
  }

  static String normalizeNewlines(String text) {
    return text.replaceAll(_newlineRegex, '\n\n');
  }

  static String removeRepeatedChars(String text) {
    var result = text.replaceAllMapped(
      _repeatedPunctRegex,
      (m) => '${m.group(1)}${m.group(1)}${m.group(1)}',
    );
    result = result.replaceAllMapped(
      _repeatedCharRegex,
      (m) => '${m.group(1)}${m.group(1)}${m.group(1)}',
    );
    return result;
  }

  static String formatBasicNumbers(String text) {
    final numberRegex = RegExp(r'\b(\d{4,})\b');
    return text.replaceAllMapped(numberRegex, (match) {
      final number = match.group(1)!;
      final buffer = StringBuffer();
      for (var i = 0; i < number.length; i++) {
        if (i > 0 && (number.length - i) % 3 == 0) {
          buffer.write(',');
        }
        buffer.write(number[i]);
      }
      return buffer.toString();
    });
  }

  static String preserveTechnicalTerms(String text) {
    final technicalPattern = RegExp(
      r'\b([A-Z]{2,}\d*|\d+[A-Z]+[A-Za-z0-9]*|v\d+\.\d+(?:\.\d+)?|'
      r'[A-Z]+_[A-Z0-9_]+|ERR_[A-Z_]+|HTTP_\d+|ISO\s?\d+|'
      r'\d{4}(?:-\d{2})?(?:-\d{2})?)\b',
    );
    final placeholders = <String, String>{};
    var result = text.replaceAllMapped(technicalPattern, (match) {
      final token = match.group(0)!;
      final placeholder = '__TECH_${placeholders.length}__';
      placeholders[placeholder] = token;
      return placeholder;
    });

    result = normalizeWhitespace(result);
    result = normalizeNewlines(result);
    result = removeRepeatedChars(result);

    for (final entry in placeholders.entries) {
      result = result.replaceAll(entry.key, entry.value);
    }
    return result;
  }

  static String preprocess(String text) {
    var result = text;
    result = normalizeWhitespace(result);
    result = normalizeNewlines(result);
    result = removeRepeatedChars(result);
    result = formatBasicNumbers(result);
    return result;
  }

  static Duration estimateDuration(String text) {
    final charCount = text.length;
    final seconds = charCount / 15.0;
    return Duration(milliseconds: (seconds * 1000).round());
  }
}
