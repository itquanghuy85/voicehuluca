import '../entities/tts_request.dart';
import '../entities/tts_response.dart';
import '../repositories/tts_repository.dart';

class SynthesizeText {
  final TtsRepository _repository;

  SynthesizeText(this._repository);

  Future<TtsResponse> execute({
    required String text,
    required String voiceId,
    String modelId = '',
    double speed = 1.0,
    double? stability,
    double? similarityBoost,
    double? style,
    bool? useSpeakerBoost,
    String outputFormat = 'mp3',
    int sampleRate = 24000,
    Map<String, dynamic>? extraParams,
  }) async {
    final request = TtsRequest(
      id: _generateRequestId(),
      text: text,
      voiceId: voiceId,
      modelId: modelId,
      speed: speed,
      stability: stability,
      similarityBoost: similarityBoost,
      style: style,
      useSpeakerBoost: useSpeakerBoost,
      outputFormat: outputFormat,
      sampleRate: sampleRate,
      extraParams: extraParams,
    );

    return _repository.synthesize(request);
  }

  Stream<TtsResponse> executeWithProgress({
    required String text,
    required String voiceId,
    String modelId = '',
    double speed = 1.0,
    double? stability,
    double? similarityBoost,
    double? style,
    bool? useSpeakerBoost,
    String outputFormat = 'mp3',
    int sampleRate = 24000,
    Map<String, dynamic>? extraParams,
  }) {
    final request = TtsRequest(
      id: _generateRequestId(),
      text: text,
      voiceId: voiceId,
      modelId: modelId,
      speed: speed,
      stability: stability,
      similarityBoost: similarityBoost,
      style: style,
      useSpeakerBoost: useSpeakerBoost,
      outputFormat: outputFormat,
      sampleRate: sampleRate,
      extraParams: extraParams,
    );

    return _repository.synthesizeWithProgress(request);
  }

  String _generateRequestId() {
    return 'req_${DateTime.now().millisecondsSinceEpoch}_${_randomString(8)}';
  }

  String _randomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    return List.generate(
      length,
      (i) => chars[(timestamp + i * 31) % chars.length],
    ).join();
  }
}
