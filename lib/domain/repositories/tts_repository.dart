import 'dart:io';

import '../../data/models/voice.dart';
import '../../data/services/tts_provider.dart';
import '../entities/tts_request.dart';
import '../entities/tts_response.dart';

abstract class TtsRepository {
  Future<TtsResponse> synthesize(TtsRequest request);

  Future<TtsResponse> getStatus(String requestId);

  Future<List<TtsResponse>> getHistory({int limit = 50, int offset = 0});

  Future<void> cancelGeneration(String requestId);

  Stream<TtsResponse> synthesizeWithProgress(TtsRequest request);

  Future<Voice> cloneVoice({
    required String name,
    required String description,
    required List<File> audioFiles,
    String? language,
  });

  Future<TtsUsage?> getUsage();

  /// Asks the backend whether it is up, so a clone is not attempted against a
  /// server that is not there. Throws a [TtsProviderException] describing the
  /// real cause.
  Future<BackendHealth> checkHealth();
}
