import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:voice_huluca/core/storage/public_storage_service.dart';

class AudioExportResult {
  const AudioExportResult({required this.location, required this.isPublic});

  /// Human readable location shown to the user after an export.
  final String location;

  /// True when the file ended up in the public Downloads folder.
  final bool isPublic;
}

class AudioExportService {
  AudioExportService._();

  /// Copies [sourcePath] to the public Downloads folder (Android) and reports
  /// where the file went. On platforms without public storage the file is kept
  /// in the app documents directory instead.
  static Future<AudioExportResult> exportToDownloads({
    required String sourcePath,
    required String fileName,
  }) async {
    final source = File(sourcePath);
    if (!await source.exists()) {
      throw const FileSystemException('Source file not found');
    }

    if (Platform.isAndroid) {
      try {
        final location = await PublicStorageService.saveToPublicDownloads(
          sourcePath,
          fileName,
        );
        await source.delete();
        return AudioExportResult(location: location, isPublic: true);
      } on UnsupportedError {
        // fall through to the private directory below
      } on PlatformException catch (e) {
        throw FileSystemException(
          e.message ?? 'Cannot write to public storage',
        );
      }
    }

    final documentsDir = await getApplicationDocumentsDirectory();
    final exportDir = Directory(p.join(documentsDir.path, 'exports'));
    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }
    final dest = p.join(exportDir.path, fileName);
    if (p.equals(dest, sourcePath)) {
      return AudioExportResult(location: dest, isPublic: false);
    }
    await source.copy(dest);
    return AudioExportResult(location: dest, isPublic: false);
  }
}
