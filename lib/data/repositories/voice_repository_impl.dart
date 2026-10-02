import '../datasources/local/voice_local_datasource.dart';
import '../models/voice.dart';
import '../models/voice_reference.dart';

class VoiceRepositoryImpl {
  final VoiceLocalDataSource _local;

  VoiceRepositoryImpl(this._local);

  Future<List<Voice>> getAllVoices() => _local.getAllVoices();

  Stream<List<Voice>> watchAllVoices() => _local.watchAllVoices();

  Future<List<Voice>> getVoicesByProvider(String provider) =>
      _local.getVoicesByProvider(provider);

  Future<List<Voice>> getFavoriteVoices() => _local.getFavoriteVoices();

  Stream<List<Voice>> watchFavoriteVoices() => _local.watchFavoriteVoices();

  Future<Voice?> getVoiceById(int id) => _local.getVoiceById(id);

  Future<Voice?> getVoiceByProviderId(
    String provider,
    String providerVoiceId,
  ) => _local.getVoiceByProviderId(provider, providerVoiceId);

  Future<int> insertVoice(Voice voice) => _local.insertVoice(voice);

  Future<bool> updateVoice(Voice voice) => _local.updateVoice(voice);

  Future<int> deleteVoice(int id) => _local.deleteVoice(id);

  Future<bool> toggleFavorite(int voiceId, bool isFavorite) =>
      _local.toggleFavorite(voiceId, isFavorite);

  Future<List<VoiceReference>> getVoiceReferences(int voiceId) =>
      _local.getVoiceReferences(voiceId);

  Future<VoiceReference?> getVoiceReferenceById(int id) =>
      _local.getVoiceReferenceById(id);

  Future<int> insertVoiceReference(VoiceReference reference) =>
      _local.insertVoiceReference(reference);

  Future<bool> updateVoiceReference(VoiceReference reference) =>
      _local.updateVoiceReference(reference);

  Future<int> deleteVoiceReference(int id) => _local.deleteVoiceReference(id);

  Future<int> deleteReferencesByVoice(int voiceId) =>
      _local.deleteReferencesByVoice(voiceId);

  Future<void> deleteVoiceCascade(int voiceId) =>
      _local.deleteVoiceCascade(voiceId);

  Future<List<Voice>> searchVoices(String query) => _local.searchVoices(query);

  Future<int> getVoiceCount() => _local.getVoiceCount();
}
