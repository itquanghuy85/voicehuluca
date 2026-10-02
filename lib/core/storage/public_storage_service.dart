import 'dart:io';

import 'package:flutter/services.dart';

class PublicStorageService {
  PublicStorageService._();

  static const MethodChannel _channel = MethodChannel(
    'com.vietvoice.vietvoice_studio/storage',
  );

  /// Copies [sourcePath] into the public Downloads folder (Android 10+ uses
  /// MediaStore, older versions write to the legacy public directory) and
  /// returns a human readable location.
  static Future<String> saveToPublicDownloads(
    String sourcePath,
    String fileName,
  ) async {
    if (!Platform.isAndroid) {
      throw UnsupportedError(
        'Public downloads storage is only available on Android',
      );
    }
    final location = await _channel.invokeMethod<String>(
      'saveToPublicDownloads',
      {'path': sourcePath, 'fileName': fileName},
    );
    return location ?? sourcePath;
  }
}
