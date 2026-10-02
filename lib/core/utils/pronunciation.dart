class PronunciationRule {
  final String pattern;
  final String replacement;
  final String description;

  const PronunciationRule({
    required this.pattern,
    required this.replacement,
    required this.description,
  });

  RegExp get regex => RegExp(pattern);
}

class PronunciationDictionary {
  PronunciationDictionary._();

  static final List<PronunciationRule> _rules = [
    PronunciationRule(
      pattern: r'\bgiờ\b',
      replacement: 'giờ',
      description: 'Giờ (hour)',
    ),
    PronunciationRule(
      pattern: r'\bngày\b',
      replacement: 'ngày',
      description: 'Ngày (day)',
    ),
    PronunciationRule(
      pattern: r'\btháng\b',
      replacement: 'tháng',
      description: 'Tháng (month)',
    ),
    PronunciationRule(
      pattern: r'\bnăm\b',
      replacement: 'năm',
      description: 'Năm (year)',
    ),
    PronunciationRule(
      pattern: r'\bphút\b',
      replacement: 'phút',
      description: 'Phút (minute)',
    ),
    PronunciationRule(
      pattern: r'\bgiây\b',
      replacement: 'giây',
      description: 'Giây (second)',
    ),
    PronunciationRule(
      pattern: r'\bđồng\b',
      replacement: 'đồng',
      description: 'Đồng (currency)',
    ),
    PronunciationRule(
      pattern: r'\bnghìn\b',
      replacement: 'nghìn',
      description: 'Nghìn (thousand)',
    ),
    PronunciationRule(
      pattern: r'\btriệu\b',
      replacement: 'triệu',
      description: 'Triệu (million)',
    ),
    PronunciationRule(
      pattern: r'\btỷ\b',
      replacement: 'tỷ',
      description: 'Tỷ (billion)',
    ),
    PronunciationRule(
      pattern: r'\btrăm\b',
      replacement: 'trăm',
      description: 'Trăm (hundred)',
    ),
    PronunciationRule(
      pattern: r'\bmươi\b',
      replacement: 'mươi',
      description: 'Mươi (ten)',
    ),
    PronunciationRule(
      pattern: r'\bkhông\b',
      replacement: 'không',
      description: 'Không (zero)',
    ),
    PronunciationRule(
      pattern: r'\bmột\b',
      replacement: 'một',
      description: 'Một (one)',
    ),
    PronunciationRule(
      pattern: r'\bhai\b',
      replacement: 'hai',
      description: 'Hai (two)',
    ),
    PronunciationRule(
      pattern: r'\bba\b',
      replacement: 'ba',
      description: 'Ba (three)',
    ),
    PronunciationRule(
      pattern: r'\bbốn\b',
      replacement: 'bốn',
      description: 'Bốn (four)',
    ),
    PronunciationRule(
      pattern: r'\bnăm\b',
      replacement: 'năm',
      description: 'Năm (five)',
    ),
    PronunciationRule(
      pattern: r'\bsáu\b',
      replacement: 'sáu',
      description: 'Sáu (six)',
    ),
    PronunciationRule(
      pattern: r'\bbảy\b',
      replacement: 'bảy',
      description: 'Bảy (seven)',
    ),
    PronunciationRule(
      pattern: r'\btám\b',
      replacement: 'tám',
      description: 'Tám (eight)',
    ),
    PronunciationRule(
      pattern: r'\bchín\b',
      replacement: 'chín',
      description: 'Chín (nine)',
    ),
    PronunciationRule(
      pattern: r'\bmười\b',
      replacement: 'mười',
      description: 'Mười (ten)',
    ),
  ];

  static List<PronunciationRule> get rules => List.unmodifiable(_rules);

  static String applyRules(String text) {
    var result = text;
    for (final rule in _rules) {
      result = result.replaceAll(rule.regex, rule.replacement);
    }
    return result;
  }

  static PronunciationRule? findRule(String word) {
    for (final rule in _rules) {
      if (rule.regex.hasMatch(word) || word.contains(rule.replacement)) {
        return rule;
      }
    }
    return null;
  }
}
