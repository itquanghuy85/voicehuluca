import 'package:drift/drift.dart';

import '../../models/voice.dart';
import '../../models/voice_reference.dart';
import 'app_database.dart' hide Voice, VoiceReference;

Voice _toVoice(d) => Voice(
  id: d.id,
  provider: d.provider,
  providerVoiceId: d.providerVoiceId,
  name: d.name,
  description: d.description,
  language: d.language,
  gender: d.gender,
  accent: d.accent,
  isCloned: d.isCloned,
  isFavorite: d.isFavorite,
  createdAt: d.createdAt,
  updatedAt: d.updatedAt,
);

VoiceReference _toVoiceReference(d) => VoiceReference(
  id: d.id,
  voiceId: d.voiceId,
  localFilePath: d.localFilePath,
  durationMs: d.durationMs,
  provider: d.provider,
  createdAt: d.createdAt,
);

class VoiceLocalDataSource {
  final AppDatabase _database;

  VoiceLocalDataSource(this._database);

  Future<List<Voice>> getAllVoices() async {
    final data = await _database.getAllVoices();
    return data.map(_toVoice).toList();
  }

  Stream<List<Voice>> watchAllVoices() =>
      _database.watchAllVoices().map((data) => data.map(_toVoice).toList());

  Future<List<Voice>> getVoicesByProvider(String provider) async {
    final data = await _database.getVoicesByProvider(provider);
    return data.map(_toVoice).toList();
  }

  Future<List<Voice>> getFavoriteVoices() async {
    final data = await _database.getFavoriteVoices();
    return data.map(_toVoice).toList();
  }

  Stream<List<Voice>> watchFavoriteVoices() => _database
      .watchFavoriteVoices()
      .map((data) => data.map(_toVoice).toList());

  Future<Voice?> getVoiceById(int id) async {
    final data = await _database.getVoice(id);
    return data != null ? _toVoice(data) : null;
  }

  Future<Voice?> getVoiceByProviderId(
    String provider,
    String providerVoiceId,
  ) async {
    final data = await _database.getVoiceByProviderId(
      provider,
      providerVoiceId,
    );
    return data != null ? _toVoice(data) : null;
  }

  Future<int> insertVoice(Voice voice) {
    final companion = VoicesCompanion(
      provider: Value(voice.provider),
      providerVoiceId: Value(voice.providerVoiceId),
      name: Value(voice.name),
      description: Value(voice.description),
      language: Value(voice.language),
      gender: Value(voice.gender),
      accent: Value(voice.accent),
      isCloned: Value(voice.isCloned),
      isFavorite: Value(voice.isFavorite),
    );
    return _database.insertVoice(companion);
  }

  Future<bool> updateVoice(Voice voice) {
    final companion = VoicesCompanion(
      id: Value(voice.id),
      provider: Value(voice.provider),
      providerVoiceId: Value(voice.providerVoiceId),
      name: Value(voice.name),
      description: Value(voice.description),
      language: Value(voice.language),
      gender: Value(voice.gender),
      accent: Value(voice.accent),
      isCloned: Value(voice.isCloned),
      isFavorite: Value(voice.isFavorite),
      createdAt: Value(voice.createdAt),
      updatedAt: Value(voice.updatedAt),
    );
    return _database.updateVoice(companion);
  }

  Future<int> deleteVoice(int id) => _database.deleteVoice(id);

  Future<bool> toggleFavorite(int voiceId, bool isFavorite) async {
    final voice = await _database.getVoice(voiceId);
    if (voice == null) return false;
    final updated = await _database.updateVoiceFavorite(voiceId, isFavorite);
    return updated > 0;
  }

  Future<List<VoiceReference>> getVoiceReferences(int voiceId) async {
    final data = await _database.getReferencesByVoice(voiceId);
    return data.map(_toVoiceReference).toList();
  }

  Future<VoiceReference?> getVoiceReferenceById(int id) async {
    final data = await _database.getVoiceReference(id);
    return data != null ? _toVoiceReference(data) : null;
  }

  Future<int> insertVoiceReference(VoiceReference reference) {
    final companion = VoiceReferencesCompanion(
      voiceId: Value(reference.voiceId),
      localFilePath: Value(reference.localFilePath),
      durationMs: Value(reference.durationMs),
      provider: Value(reference.provider),
    );
    return _database.insertVoiceReference(companion);
  }

  Future<bool> updateVoiceReference(VoiceReference reference) {
    final companion = VoiceReferencesCompanion(
      id: Value(reference.id),
      voiceId: Value(reference.voiceId),
      localFilePath: Value(reference.localFilePath),
      durationMs: Value(reference.durationMs),
      provider: Value(reference.provider),
      createdAt: Value(reference.createdAt),
    );
    return _database.updateVoiceReference(companion);
  }

  Future<int> deleteVoiceReference(int id) =>
      _database.deleteVoiceReference(id);

  Future<int> deleteReferencesByVoice(int voiceId) =>
      _database.deleteReferencesByVoice(voiceId);

  Future<void> deleteVoiceCascade(int voiceId) =>
      _database.deleteVoiceCascade(voiceId);

  Future<List<Voice>> searchVoices(String query) async {
    final allVoices = await _database.getAllVoices();
    final lowerQuery = query.toLowerCase();
    return allVoices
        .where(
          (voice) =>
              voice.name.toLowerCase().contains(lowerQuery) ||
              (voice.description?.toLowerCase().contains(lowerQuery) ??
                  false) ||
              voice.language.toLowerCase().contains(lowerQuery),
        )
        .map(_toVoice)
        .toList();
  }

  Future<int> getVoiceCount() async {
    final voices = await _database.getAllVoices();
    return voices.length;
  }
}
