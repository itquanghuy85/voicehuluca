import 'dart:io';

import 'package:drift/drift.dart';

import '../../models/audio_asset.dart';
import 'app_database.dart' hide AudioAsset;

AudioAsset _toAudioAsset(d) => AudioAsset(
  id: d.id,
  projectId: d.projectId,
  scriptId: d.scriptId,
  segmentId: d.segmentId,
  voiceId: d.voiceId,
  title: d.title,
  filePath: d.filePath,
  format: d.format,
  durationMs: d.durationMs,
  fileSize: d.fileSize,
  createdAt: d.createdAt,
  updatedAt: d.updatedAt,
  isFavorite: d.isFavorite,
);

class AudioLocalDataSource {
  final AppDatabase _database;

  AudioLocalDataSource(this._database);

  Future<List<AudioAsset>> getAllAudio() async {
    final data = await _database.getAllAudioAssets();
    return data.map(_toAudioAsset).toList();
  }

  Stream<List<AudioAsset>> watchAllAudio() => _database
      .watchAllAudioAssets()
      .map((data) => data.map(_toAudioAsset).toList());

  Future<List<AudioAsset>> getAudioByProject(int projectId) async {
    final data = await _database.getAudioByProject(projectId);
    return data.map(_toAudioAsset).toList();
  }

  Future<List<AudioAsset>> getAudioByScript(int scriptId) async {
    final data = await _database.getAudioByScript(scriptId);
    return data.map(_toAudioAsset).toList();
  }

  Future<List<AudioAsset>> getAudioBySegment(int segmentId) async {
    final data = await _database.getAudioBySegment(segmentId);
    return data.map(_toAudioAsset).toList();
  }

  Future<List<AudioAsset>> getAudioByVoice(int voiceId) async {
    final data = await _database.getAudioByVoice(voiceId);
    return data.map(_toAudioAsset).toList();
  }

  Future<List<AudioAsset>> getFavoriteAudio() async {
    final data = await _database.getFavoriteAudio();
    return data.map(_toAudioAsset).toList();
  }

  Stream<List<AudioAsset>> watchFavoriteAudio() => _database
      .watchFavoriteAudio()
      .map((data) => data.map(_toAudioAsset).toList());

  Future<AudioAsset?> getAudioById(int id) async {
    final data = await _database.getAudioAsset(id);
    return data != null ? _toAudioAsset(data) : null;
  }

  Future<int> insertAudio(AudioAsset audio) {
    final companion = AudioAssetsCompanion(
      projectId: Value(audio.projectId),
      scriptId: Value(audio.scriptId),
      segmentId: Value(audio.segmentId),
      voiceId: Value(audio.voiceId),
      title: Value(audio.title),
      filePath: Value(audio.filePath),
      format: Value(audio.format),
      durationMs: Value(audio.durationMs),
      fileSize: Value(audio.fileSize),
      isFavorite: Value(audio.isFavorite),
    );
    return _database.insertAudioAsset(companion);
  }

  Future<bool> updateAudio(AudioAsset audio) {
    final companion = AudioAssetsCompanion(
      id: Value(audio.id),
      projectId: Value(audio.projectId),
      scriptId: Value(audio.scriptId),
      segmentId: Value(audio.segmentId),
      voiceId: Value(audio.voiceId),
      title: Value(audio.title),
      filePath: Value(audio.filePath),
      format: Value(audio.format),
      durationMs: Value(audio.durationMs),
      fileSize: Value(audio.fileSize),
      createdAt: Value(audio.createdAt),
      updatedAt: Value(audio.updatedAt),
      isFavorite: Value(audio.isFavorite),
    );
    return _database.updateAudioAsset(companion);
  }

  Future<int> deleteAudio(int id) => _database.deleteAudioAsset(id);

  Future<int> deleteAudioByProject(int projectId) =>
      _database.deleteAudioByProject(projectId);

  Future<bool> toggleFavorite(int audioId, bool isFavorite) async {
    final audio = await _database.getAudioAsset(audioId);
    if (audio == null) return false;
    final updated = _toAudioAsset(audio).copyWith(isFavorite: isFavorite);
    return _database.updateAudioAsset(
      AudioAssetsCompanion(
        id: Value(updated.id),
        isFavorite: Value(updated.isFavorite),
      ),
    );
  }

  Future<String?> getAudioFilePath(int audioId) async {
    final audio = await _database.getAudioAsset(audioId);
    return audio?.filePath;
  }

  Future<bool> audioFileExists(int audioId) async {
    final audio = await _database.getAudioAsset(audioId);
    if (audio == null) return false;
    return File(audio.filePath).existsSync();
  }

  Future<int> getTotalStorageUsed() async {
    final allAudio = await _database.getAllAudioAssets();
    int total = 0;
    for (final audio in allAudio) {
      total += audio.fileSize;
    }
    return total;
  }

  Future<List<AudioAsset>> searchAudio(String query) async {
    final allAudio = await _database.getAllAudioAssets();
    final lowerQuery = query.toLowerCase();
    return allAudio
        .where((audio) => audio.title.toLowerCase().contains(lowerQuery))
        .map(_toAudioAsset)
        .toList();
  }
}
