import 'package:uuid/uuid.dart';

class FileNamer {
  FileNamer._();

  static const int _maxFileNameLength = 100;
  static const String _defaultExtension = 'mp3';

  static String sanitizeFileName(String name) {
    var sanitized = name.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
    sanitized = sanitized.replaceAll(RegExp(r'\s+'), '_');
    sanitized = sanitized.replaceAll(RegExp(r'_+'), '_');
    sanitized = sanitized.replaceAll(RegExp(r'^_+|_+$'), '');
    if (sanitized.isEmpty) {
      sanitized = 'audio_${DateTime.now().millisecondsSinceEpoch}';
    }
    // ignore: prefer_null_aware_elements
    if (sanitized.length > _maxFileNameLength) {
      sanitized = sanitized.substring(0, _maxFileNameLength);
    }
    return sanitized;
  }

  static String generateFileName({
    String? prefix,
    String? suffix,
    String extension = _defaultExtension,
  }) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final uuid = const Uuid().v4().substring(0, 8);
    final parts = <String>[
      prefix ?? 'audio',
      timestamp.toString(),
      uuid,
      ?suffix,
    ];
    final name = parts.join('_');
    return '$name.$extension';
  }

  static String generateVoiceFileName(String voiceName) {
    final sanitized = sanitizeFileName(voiceName);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${sanitized}_$timestamp.$_defaultExtension';
  }

  static String generateScriptFileName(String scriptTitle) {
    final sanitized = sanitizeFileName(scriptTitle);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${sanitized}_$timestamp.txt';
  }

  static String generateExportFileName(String baseName, String format) {
    final sanitized = sanitizeFileName(baseName);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${sanitized}_$timestamp.$format';
  }

  static String getExtension(String fileName) {
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == fileName.length - 1) {
      return '';
    }
    return fileName.substring(dotIndex + 1).toLowerCase();
  }

  static String changeExtension(String fileName, String newExtension) {
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex == -1) {
      return '$fileName.$newExtension';
    }
    return '${fileName.substring(0, dotIndex)}.$newExtension';
  }

  static bool isValidFileName(String name) {
    if (name.isEmpty || name.length > _maxFileNameLength) return false;
    return !RegExp(r'[<>:"/\\|?*]').hasMatch(name);
  }
}
