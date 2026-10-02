import '../datasources/local/audio_local_datasource.dart';
import '../models/audio_asset.dart';

class AudioRepositoryImpl {
  final AudioLocalDataSource _local;

  AudioRepositoryImpl(this._local);

  Future<List<AudioAsset>> getAllAudio() => _local.getAllAudio();

  Stream<List<AudioAsset>> watchAllAudio() => _local.watchAllAudio();

  Future<List<AudioAsset>> getAudioByProject(int projectId) =>
      _local.getAudioByProject(projectId);

  Future<List<AudioAsset>> getAudioByScript(int scriptId) =>
      _local.getAudioByScript(scriptId);

  Future<List<AudioAsset>> getAudioBySegment(int segmentId) =>
      _local.getAudioBySegment(segmentId);

  Future<List<AudioAsset>> getAudioByVoice(int voiceId) =>
      _local.getAudioByVoice(voiceId);

  Future<List<AudioAsset>> getFavoriteAudio() => _local.getFavoriteAudio();

  Stream<List<AudioAsset>> watchFavoriteAudio() => _local.watchFavoriteAudio();

  Future<AudioAsset?> getAudioById(int id) => _local.getAudioById(id);

  Future<int> saveAudio({
    required int projectId,
    int? scriptId,
    int? segmentId,
    required int voiceId,
    required String title,
    required String filePath,
    required String format,
    required int durationMs,
    required int fileSize,
  }) {
    final audio = AudioAsset(
      id: 0,
      projectId: projectId,
      scriptId: scriptId,
      segmentId: segmentId,
      voiceId: voiceId,
      title: title,
      filePath: filePath,
      format: format,
      durationMs: durationMs,
      fileSize: fileSize,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    return _local.insertAudio(audio);
  }

  Future<bool> updateAudio(AudioAsset audio) => _local.updateAudio(audio);

  Future<int> deleteAudio(int id) => _local.deleteAudio(id);

  Future<int> deleteAudioByProject(int projectId) =>
      _local.deleteAudioByProject(projectId);

  Future<bool> toggleFavorite(int audioId, bool isFavorite) =>
      _local.toggleFavorite(audioId, isFavorite);

  Future<String?> getAudioFilePath(int audioId) =>
      _local.getAudioFilePath(audioId);

  Future<bool> audioFileExists(int audioId) => _local.audioFileExists(audioId);

  Future<int> getTotalStorageUsed() => _local.getTotalStorageUsed();

  Future<List<AudioAsset>> searchAudio(String query) =>
      _local.searchAudio(query);
}
