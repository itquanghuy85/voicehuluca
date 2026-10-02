import 'dart:io';

import '../datasources/remote/tts_remote_datasource.dart';
import '../models/voice.dart';
import 'tts_provider.dart';

/// Shared behaviour for providers reached through the VietVoice backend.
///
/// Every subclass only declares identity and capabilities; the transport,
/// error mapping and result shapes are identical, so they live here.
abstract class BackendTtsProvider implements TtsProvider {
  final TtsRemoteDatasource remote;

  BackendTtsProvider(this.remote);

  @override
  String get id;

  @override
  String get name;

  @override
  bool get supportsVoiceCloning => false;

  @override
  bool get isAvailable => true;

  @override
  Future<List<Voice>> getVoices() => remote.getVoices();

  @override
  Future<TtsResult> synthesize({
    required String voiceId,
    required String text,
    TtsOptions options = const TtsOptions(),
  }) async {
    final audio = await remote.synthesize(
      voiceId: voiceId,
      text: text,
      options: options,
    );
    return TtsResult(audio: audio, characterCount: text.length, providerId: id);
  }

  @override
  Future<Voice> cloneVoice({
    required String name,
    required String description,
    required List<File> audioFiles,
    String? language,
  }) async {
    if (!supportsVoiceCloning) {
      throw TtsOperationNotSupportedException(
        'Provider $id does not support voice cloning',
        providerId: id,
      );
    }
    return remote.cloneVoice(
      name: name,
      description: description,
      audioFiles: audioFiles,
      language: language,
    );
  }

  @override
  Future<void> deleteVoice(String providerVoiceId) =>
      remote.deleteVoice(providerVoiceId);

  @override
  Future<TtsUsage?> getUsage() => remote.getUsage();

  @override
  Future<bool> testConnection() => remote.testConnection();
}
