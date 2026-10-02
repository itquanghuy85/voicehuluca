import '../entities/voice.dart';
import '../repositories/voice_repository.dart';

class GetVoices {
  final VoiceRepository _repository;

  GetVoices(this._repository);

  Future<List<Voice>> execute({
    String? provider,
    String? language,
    bool? isCustom,
  }) {
    return _repository.getVoices(
      provider: provider,
      language: language,
      isCustom: isCustom,
    );
  }
}
