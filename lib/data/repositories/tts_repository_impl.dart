import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import '../../domain/entities/tts_request.dart';
import '../../domain/entities/tts_response.dart';
import '../../domain/repositories/tts_repository.dart';
import '../datasources/local/voice_local_datasource.dart';
import '../datasources/remote/tts_remote_datasource.dart';
import '../models/voice.dart';
import '../models/voice_reference.dart';
import '../services/tts_provider.dart';

class TtsRepositoryImpl implements TtsRepository {
  final TtsRemoteDatasource _remote;
  final VoiceLocalDataSource _local;

  TtsRepositoryImpl(this._remote, this._local);

  /// Id of the provider this repository instance talks to.
  String get providerId => _remote.provider;

  /// Voices of the active provider, cached locally between launches.
  ///
  /// [forceRefresh] re-reads the provider list and upserts it into the local
  /// cache so favourites, cloned flags and local ids survive a refresh.
  Future<List<Voice>> getVoices({bool forceRefresh = false}) async {
    if (forceRefresh) {
      await _syncVoices();
      return _local.getVoicesByProvider(providerId);
    }

    final cached = await _local.getVoicesByProvider(providerId);
    if (cached.isNotEmpty) {
      return cached;
    }

    await _syncVoices();
    return _local.getVoicesByProvider(providerId);
  }

  Future<void> _syncVoices() async {
    final remoteVoices = await _remote.getVoices();
    for (final voice in remoteVoices) {
      final existing = await _local.getVoiceByProviderId(
        voice.provider,
        voice.providerVoiceId,
      );
      if (existing == null) {
        await _local.insertVoice(voice);
      } else {
        await _local.updateVoice(
          voice.copyWith(id: existing.id, isFavorite: existing.isFavorite),
        );
      }
    }
  }

  Future<Uint8List> synthesizeWithStream({
    required String voiceId,
    required String text,
    double speed = 1.0,
    double stability = 0.5,
    double similarityBoost = 0.75,
    double style = 0.0,
    bool useSpeakerBoost = true,
    String? modelId,
  }) {
    return _remote.synthesize(
      voiceId: voiceId,
      text: text,
      options: TtsOptions(
        speed: speed,
        stability: stability,
        similarityBoost: similarityBoost,
        style: style,
        useSpeakerBoost: useSpeakerBoost,
        modelId: modelId,
      ),
    );
  }

  @override
  Future<TtsResponse> synthesize(TtsRequest request) async {
    final audio = await _remote.synthesizeAudio(
      voiceId: request.voiceId,
      text: request.text,
      options: TtsOptions(
        speed: request.speed,
        stability: request.stability ?? 0.5,
        similarityBoost: request.similarityBoost ?? 0.75,
        style: request.style ?? 0.0,
        useSpeakerBoost: request.useSpeakerBoost ?? true,
        modelId: request.modelId,
      ),
    );
    return TtsResponse(
      id: request.id,
      status: 'completed',
      audioUrl: '',
      duration: Duration.zero,
      characterCount: request.text.length,
      createdAt: DateTime.now(),
      metadata: {
        'bytes': audio.bytes.length,
        'provider': providerId,
        'format': audio.format,
      },
    );
  }

  @override
  Future<TtsResponse> getStatus(String requestId) async {
    return TtsResponse(
      id: requestId,
      status: 'completed',
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<List<TtsResponse>> getHistory({int limit = 50, int offset = 0}) async {
    return [];
  }

  @override
  Future<void> cancelGeneration(String requestId) async {}

  @override
  Stream<TtsResponse> synthesizeWithProgress(TtsRequest request) async* {
    yield TtsResponse(
      id: request.id,
      status: 'generating',
      characterCount: request.text.length,
      createdAt: DateTime.now(),
    );

    final audio = await _remote.synthesizeAudio(
      voiceId: request.voiceId,
      text: request.text,
      options: TtsOptions(
        speed: request.speed,
        stability: request.stability ?? 0.5,
        similarityBoost: request.similarityBoost ?? 0.75,
        style: request.style ?? 0.0,
        useSpeakerBoost: request.useSpeakerBoost ?? true,
        modelId: request.modelId,
      ),
    );

    yield TtsResponse(
      id: request.id,
      status: 'downloading',
      characterCount: request.text.length,
      createdAt: DateTime.now(),
    );
    yield TtsResponse(
      id: request.id,
      status: 'processing',
      characterCount: request.text.length,
      createdAt: DateTime.now(),
    );
    yield TtsResponse(
      id: request.id,
      status: 'completed',
      audioUrl: '',
      duration: Duration.zero,
      characterCount: request.text.length,
      createdAt: DateTime.now(),
      metadata: {
        'bytes': audio.bytes.length,
        'provider': providerId,
        'format': audio.format,
        'audio': audio.bytes,
      },
    );
  }

  /// Asks the backend whether it is up before an upload, so the user is told the
  /// real cause instead of a failed clone.
@override
Future<BackendHealth> checkHealth() => _remote.checkHealth();

  @override
  Future<Voice> cloneVoice({
    required String name,
    required String description,
    required List<File> audioFiles,
    String? language,
    String? refText,
  }) async {
    final voice = await _remote.cloneVoice(
      name: name,
      description: description,
      audioFiles: audioFiles,
      language: language,
      refText: refText,
    );
    final existing = await _local.getVoiceByProviderId(
      voice.provider,
      voice.providerVoiceId,
    );
    if (existing == null) {
      await _local.insertVoice(voice);
    } else {
      await _local.updateVoice(voice.copyWith(id: existing.id));
    }
    return voice;
  }

  /// Removes the voice from the provider (when supported) and the local cache.
  Future<void> deleteVoice(Voice voice) async {
    if (voice.isCloned) {
      await _remote.deleteVoice(voice.providerVoiceId);
    }
    await _local.deleteVoiceCascade(voice.id);
  }

  @override
  Future<TtsUsage?> getUsage() => _remote.getUsage();

  Future<bool> testConnection() => _remote.testConnection();

  Future<Voice?> getLocalVoice(int id) => _local.getVoiceById(id);

  Future<bool> toggleVoiceFavorite(int voiceId, bool isFavorite) =>
      _local.toggleFavorite(voiceId, isFavorite);

  Future<List<Voice>> getFavoriteVoices() => _local.getFavoriteVoices();

  Future<List<Voice>> searchVoices(String query) => _local.searchVoices(query);

  Future<int> saveVoiceReference({
    required int voiceId,
    required String localFilePath,
    required int durationMs,
    required String provider,
  }) async {
    final reference = VoiceReference(
      id: 0,
      voiceId: voiceId,
      localFilePath: localFilePath,
      durationMs: durationMs,
      provider: provider,
      createdAt: DateTime.now(),
    );
    return _local.insertVoiceReference(reference);
  }

  Future<List<VoiceReference>> getVoiceReferences(int voiceId) =>
      _local.getVoiceReferences(voiceId);
}
