import '../entities/voice.dart';

abstract class VoiceRepository {
  Future<List<Voice>> getVoices({
    String? provider,
    String? language,
    bool? isCustom,
  });

  Future<Voice?> getVoice(String id);

  Future<Voice> createVoice(Voice voice);

  Future<Voice> updateVoice(Voice voice);

  Future<void> deleteVoice(String id);

  Future<Voice> cloneVoice({
    required String name,
    required String description,
    required List<String> audioFilePaths,
    String? provider,
  });

  Future<List<String>> getAvailableLanguages();

  Future<List<String>> getAvailableProviders();

  Future<String?> getPreviewUrl(String voiceId);
}
