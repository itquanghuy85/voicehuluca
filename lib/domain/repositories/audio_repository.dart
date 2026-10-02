import 'dart:typed_data';

import '../entities/audio_asset.dart';

abstract class AudioRepository {
  Future<AudioAsset> saveAudio({
    required String fileName,
    required Uint8List audioData,
    String? scriptId,
    String? projectId,
    String? voiceId,
    String? generationJobId,
  });

  Future<AudioAsset?> getAudio(String id);

  Future<List<AudioAsset>> getAudioList({
    String? projectId,
    String? scriptId,
    bool includeDeleted = false,
  });

  Future<Uint8List?> getAudioData(String id);

  Future<String?> getAudioFilePath(String id);

  Future<void> deleteAudio(String id, {bool permanent = false});

  Future<void> restoreAudio(String id);

  Future<List<AudioAsset>> searchAudio(String query);

  Future<int> getTotalStorageUsed();

  Future<void> cleanupOrphanedAudio();
}
