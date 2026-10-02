import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:voice_huluca/core/constants/app_constants.dart';
import 'package:voice_huluca/core/utils/file_namer.dart';

class AudioFileService {
  AudioFileService._();

  static Future<Directory> getAudioDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final audioDir = Directory(p.join(appDir.path, 'audio'));
    if (!await audioDir.exists()) {
      await audioDir.create(recursive: true);
    }
    return audioDir;
  }

  static Future<Directory> getCacheDirectory() async {
    final cacheDir = await getTemporaryDirectory();
    final audioCacheDir = Directory(p.join(cacheDir.path, 'audio_cache'));
    if (!await audioCacheDir.exists()) {
      await audioCacheDir.create(recursive: true);
    }
    return audioCacheDir;
  }

  static Future<String> saveAudioFile(
    List<int> bytes, {
    String? fileName,
    String? voiceName,
  }) async {
    final dir = await getAudioDirectory();
    final name =
        fileName ??
        (voiceName != null
            ? FileNamer.generateVoiceFileName(voiceName)
            : FileNamer.generateFileName());
    final file = File(p.join(dir.path, name));
    await file.writeAsBytes(bytes);
    return file.path;
  }

  static Future<String> saveAudioToCache(
    List<int> bytes, {
    String? fileName,
  }) async {
    final dir = await getCacheDirectory();
    final name = fileName ?? FileNamer.generateFileName();
    final file = File(p.join(dir.path, name));
    await file.writeAsBytes(bytes);
    return file.path;
  }

  static Future<bool> deleteAudioFile(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
      return true;
    }
    return false;
  }

  static Future<bool> audioFileExists(String filePath) async {
    return File(filePath).exists();
  }

  static Future<int> getFileSize(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      return file.length();
    }
    return 0;
  }

  static Future<int> getTotalStorageUsed() async {
    final dir = await getAudioDirectory();
    if (!await dir.exists()) return 0;
    var total = 0;
    await for (final entity in dir.list(recursive: true)) {
      if (entity is File) {
        total += await entity.length();
      }
    }
    return total;
  }

  static Future<void> clearCache() async {
    final dir = await getCacheDirectory();
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }

  static Future<List<FileSystemEntity>> listAudioFiles() async {
    final dir = await getAudioDirectory();
    if (!await dir.exists()) return [];
    final files = <FileSystemEntity>[];
    await for (final entity in dir.list()) {
      if (entity is File) {
        final ext = FileNamer.getExtension(entity.path);
        if (AppConstants.supportedAudioFormats.contains(ext)) {
          files.add(entity);
        }
      }
    }
    return files;
  }

  static Future<Directory> getExportDirectory() async {
    final dir = await getApplicationDocumentsDirectory();
    final exportDir = Directory(p.join(dir.path, 'exports'));
    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }
    return exportDir;
  }

  static Future<String> exportAudioFile(
    String sourcePath, {
    String? fileName,
  }) async {
    final exportDir = await getExportDirectory();
    final sourceFile = File(sourcePath);
    if (!await sourceFile.exists()) {
      throw const FileSystemException('Source file not found');
    }
    final name =
        fileName ??
        FileNamer.generateFileName(
          prefix: 'export',
          extension: FileNamer.getExtension(sourcePath),
        );
    final destFile = File(p.join(exportDir.path, name));
    await sourceFile.copy(destFile.path);
    return destFile.path;
  }
}
