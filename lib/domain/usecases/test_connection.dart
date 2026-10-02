import '../repositories/tts_repository.dart';

/// Checks that the backend gateway for the active provider answers.
class TestConnection {
  final TtsRepository _repository;

  TestConnection(this._repository);

  /// True when the provider call succeeds. Google reports no usage data but
  /// a completed call still proves the backend and provider are reachable.
  Future<bool> execute() async {
    try {
      await _repository.getUsage();
      return true;
    } catch (_) {
      return false;
    }
  }
}
