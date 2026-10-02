import '../../data/services/tts_provider.dart';
import '../repositories/tts_repository.dart';

class GetUsage {
  final TtsRepository _repository;

  GetUsage(this._repository);

  /// Real provider usage, or null when the provider reports none.
  Future<TtsUsage?> execute() {
    return _repository.getUsage();
  }
}
