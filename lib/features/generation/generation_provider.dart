import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:uuid/uuid.dart';
import 'package:voice_huluca/core/audio/audio_file_service.dart';
import 'package:voice_huluca/core/constants/app_constants.dart';
import 'package:voice_huluca/core/localization/app_strings.dart';
import 'package:voice_huluca/data/datasources/local/app_database.dart'
    show appDatabaseProvider;
import 'package:voice_huluca/data/datasources/local/audio_local_datasource.dart';
import 'package:voice_huluca/data/repositories/audio_repository_impl.dart';
import 'package:voice_huluca/data/services/tts_provider.dart';
import 'package:voice_huluca/domain/entities/audio_asset.dart';
import 'package:voice_huluca/domain/entities/tts_response.dart';
import 'package:voice_huluca/domain/usecases/synthesize_text.dart';
import 'package:voice_huluca/features/voice/voice_provider.dart';

enum GenerationStatus {
  idle,
  validating,
  uploading,
  generating,
  downloading,
  processing,
  success,
  error,
  cancelled,
}

class GenerationState {
  final GenerationStatus status;
  final String text;
  final String voiceId;
  final String voiceName;

  /// Local database id of the voice used, so the library can show its name.
  final int? localVoiceId;
  final double speed;
  final double progress;
  final String? errorMessage;
  final AudioAsset? audioAsset;
  final String? ttsRequestId;
  final DateTime? startedAt;
  final DateTime? completedAt;

  /// Provider the UI may offer to switch to after a provider failure.
  /// Null when no switch is suggested.
  final String? fallbackProviderId;

  const GenerationState({
    this.status = GenerationStatus.idle,
    this.text = '',
    this.voiceId = '',
    this.voiceName = '',
    this.localVoiceId,
    this.speed = 1.0,
    this.progress = 0.0,
    this.errorMessage,
    this.audioAsset,
    this.ttsRequestId,
    this.startedAt,
    this.completedAt,
    this.fallbackProviderId,
  });

  bool get isBusy =>
      status == GenerationStatus.validating ||
      status == GenerationStatus.uploading ||
      status == GenerationStatus.generating ||
      status == GenerationStatus.downloading ||
      status == GenerationStatus.processing;

  bool get isTerminal =>
      status == GenerationStatus.success ||
      status == GenerationStatus.error ||
      status == GenerationStatus.cancelled;

  int get characterCount => text.length;

  String get statusText {
    switch (status) {
      case GenerationStatus.idle:
        return '';
      case GenerationStatus.validating:
        return AppStrings.generationValidating;
      case GenerationStatus.uploading:
        return AppStrings.generationUploading;
      case GenerationStatus.generating:
        return AppStrings.generationGenerating;
      case GenerationStatus.downloading:
        return AppStrings.generationDownloading;
      case GenerationStatus.processing:
        return AppStrings.generationProcessing;
      case GenerationStatus.success:
        return AppStrings.generationComplete;
      case GenerationStatus.error:
        return AppStrings.generationFailed;
      case GenerationStatus.cancelled:
        return AppStrings.generationCancelled;
    }
  }

  GenerationState copyWith({
    GenerationStatus? status,
    String? text,
    String? voiceId,
    String? voiceName,
    int? localVoiceId,
    double? speed,
    double? progress,
    String? errorMessage,
    AudioAsset? audioAsset,
    String? ttsRequestId,
    DateTime? startedAt,
    DateTime? completedAt,
    String? fallbackProviderId,
    bool clearError = false,
    bool clearAudio = false,
    bool clearFallback = false,
  }) {
    return GenerationState(
      status: status ?? this.status,
      text: text ?? this.text,
      voiceId: voiceId ?? this.voiceId,
      voiceName: voiceName ?? this.voiceName,
      localVoiceId: localVoiceId ?? this.localVoiceId,
      speed: speed ?? this.speed,
      progress: progress ?? this.progress,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      audioAsset: clearAudio ? null : (audioAsset ?? this.audioAsset),
      ttsRequestId: ttsRequestId ?? this.ttsRequestId,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      fallbackProviderId: clearFallback
          ? null
          : (fallbackProviderId ?? this.fallbackProviderId),
    );
  }
}

final dioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      connectTimeout: AppConstants.connectionTimeout,
      receiveTimeout: AppConstants.apiTimeout,
    ),
  );
});

final audioLocalDataSourceProvider = Provider<AudioLocalDataSource>((ref) {
  return AudioLocalDataSource(ref.watch(appDatabaseProvider));
});

final audioRepositoryProvider = Provider<AudioRepositoryImpl>((ref) {
  return AudioRepositoryImpl(ref.watch(audioLocalDataSourceProvider));
});

final synthesizeTextProvider = Provider<SynthesizeText>((ref) {
  return SynthesizeText(ref.watch(ttsRepositoryProvider));
});

/// Persists generated audio and returns the file path.
typedef AudioFileWriter =
    Future<String> Function(Uint8List bytes, String fileName);

/// Reads the real duration of a saved audio file.
typedef AudioDurationReader = Future<Duration> Function(String filePath);

/// How long to wait before giving up on a generation of [characters].
///
/// Streaming providers answer in seconds, so they keep the flat budget. The
/// local provider is different: a cloned voice is rendered by XTTS on the CPU
/// and its cost scales with the script, so the budget grows with the text. The
/// old flat five minutes cut these requests off while the backend was still
/// working, and the generation was reported as failed even though the audio
/// arrived moments later.
Duration generationTimeoutFor({
  required String providerId,
  required int characters,
}) {
  if (providerId != TtsProviderIds.local) {
    return AppConstants.generationTimeout;
  }
  final allowance = Duration(
    milliseconds:
        (characters / AppConstants.localGenerationCharsPerSecond * 1000).round(),
  );
  final total = AppConstants.localGenerationBaseTimeout + allowance;
  return total > AppConstants.localGenerationMaxTimeout
      ? AppConstants.localGenerationMaxTimeout
      : total;
}

/// What to say when a generation runs out of time.
///
/// A local clone that ran out of budget was never going to be quick, so it gets
/// the message that names the slow model instead of one that reads like a
/// dropped connection and invites a retry that will be just as slow.
String generationTimeoutMessageFor(String providerId) =>
    providerId == TtsProviderIds.local
    ? AppStrings.generationTimeoutLocal
    : AppStrings.errorTimeout;

final generationProvider =
    StateNotifierProvider<GenerationNotifier, GenerationState>(
      (ref) => GenerationNotifier(
        ref.watch(synthesizeTextProvider),
        ref.watch(audioRepositoryProvider),
        isOffline: () => ref.read(isOfflineProvider).valueOrNull == true,
        activeProviderId: () => ref.read(ttsProviderIdProvider),
      ),
    );

class GenerationNotifier extends StateNotifier<GenerationState> {
  final SynthesizeText _synthesize;
  final AudioRepositoryImpl _audioRepository;
  final bool Function() _isOffline;
  final String Function() _activeProviderId;
  final AudioFileWriter _writeAudio;
  final AudioDurationReader _readAudioDuration;

  StreamSubscription<TtsResponse>? _subscription;
  Timer? _timeoutTimer;

  /// True while the final response is being written to disk and stored, so the
  /// stream's onDone does not report a false failure.
  bool _isCompleting = false;

  GenerationNotifier(
    this._synthesize,
    this._audioRepository, {
    required bool Function() isOffline,
    required String Function() activeProviderId,
    AudioFileWriter? writeAudio,
    AudioDurationReader? readDuration,
  }) : _isOffline = isOffline,
       _activeProviderId = activeProviderId,
       _writeAudio =
           writeAudio ??
           ((bytes, fileName) =>
               AudioFileService.saveAudioFile(bytes, fileName: fileName)),
       _readAudioDuration = readDuration ?? _readDurationFromFile,
       super(const GenerationState());

  static Future<Duration> _readDurationFromFile(String filePath) async {
    final player = AudioPlayer();
    try {
      await player.setFilePath(filePath);
      return player.duration ?? Duration.zero;
    } catch (_) {
      return Duration.zero;
    } finally {
      await player.dispose();
    }
  }

  Future<void> startGeneration({
    required String text,
    required String voiceId,
    required String voiceName,
    int? localVoiceId,
    double speed = 1.0,
  }) async {
    if (state.isBusy) return;

    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      state = state.copyWith(
        status: GenerationStatus.error,
        errorMessage: AppStrings.editorEmptyScript,
      );
      return;
    }
    if (trimmed.length > AppConstants.maxScriptLength) {
      state = state.copyWith(
        status: GenerationStatus.error,
        errorMessage: AppStrings.editorScriptTooLong,
      );
      return;
    }

    if (_isOffline()) {
      state = state.copyWith(
        status: GenerationStatus.error,
        errorMessage: AppStrings.offlineGenerateDisabled,
      );
      return;
    }

    state = state.copyWith(
      status: GenerationStatus.validating,
      text: trimmed,
      voiceId: voiceId,
      voiceName: voiceName,
      localVoiceId: localVoiceId ?? int.tryParse(voiceId),
      speed: speed,
      progress: 0.0,
      clearError: true,
      clearAudio: true,
      clearFallback: true,
      startedAt: DateTime.now(),
    );

    try {
      state = state.copyWith(status: GenerationStatus.uploading);

      final stream = _synthesize.executeWithProgress(
        text: trimmed,
        voiceId: voiceId,
        speed: speed,
      );

      _timeoutTimer?.cancel();
      final providerId = _activeProviderId();
      _timeoutTimer = Timer(
        generationTimeoutFor(
          providerId: providerId,
          characters: trimmed.length,
        ),
        () {
          if (state.isBusy) {
            _subscription?.cancel();
            state = state.copyWith(
              status: GenerationStatus.error,
              errorMessage: generationTimeoutMessageFor(providerId),
            );
          }
        },
      );

      _subscription = stream.listen(
        _handleResponse,
        onError: _handleError,
        onDone: () {
          // The final "completed" event starts an async save (write file, read
          // duration, insert row). Until that finishes the state is still
          // busy, so report an error only when nothing is in flight.
          if (state.isBusy && !_isCompleting) {
            state = state.copyWith(
              status: GenerationStatus.error,
              errorMessage: AppStrings.errorUnknown,
            );
          }
        },
        cancelOnError: true,
      );
    } catch (error) {
      _handleError(error);
    }
  }

  void _handleResponse(TtsResponse response) {
    if (!mounted) return;

    final mapped = _mapTtsStatus(response.status);

    switch (mapped) {
      case GenerationStatus.generating:
        state = state.copyWith(
          status: GenerationStatus.generating,
          ttsRequestId: response.id,
          progress: _estimateProgress(response),
        );
      case GenerationStatus.downloading:
        state = state.copyWith(
          status: GenerationStatus.downloading,
          ttsRequestId: response.id,
          progress: 0.85,
        );
      case GenerationStatus.processing:
        state = state.copyWith(
          status: GenerationStatus.processing,
          ttsRequestId: response.id,
          progress: 0.95,
        );
      case GenerationStatus.success:
        _completeGeneration(response);
      case GenerationStatus.error:
        state = state.copyWith(
          status: GenerationStatus.error,
          errorMessage: response.errorMessage ?? AppStrings.errorUnknown,
        );
      case GenerationStatus.cancelled:
        state = state.copyWith(status: GenerationStatus.cancelled);
      default:
        state = state.copyWith(status: mapped, ttsRequestId: response.id);
    }
  }

  /// Builds a readable library title: the first words of the script, falling
  /// back to the voice name so the user never sees `voice_<timestamp>`.
  String _buildTitle() {
    final text = state.text.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (text.isNotEmpty) {
      if (text.length <= 40) return text;
      final cut = text.substring(0, 40);
      final lastSpace = cut.lastIndexOf(' ');
      return '${lastSpace > 20 ? cut.substring(0, lastSpace) : cut}…';
    }
    final voice = state.voiceName.trim();
    return voice.isEmpty ? AppStrings.homeNewAudio : voice;
  }

  Future<void> _completeGeneration(TtsResponse response) async {
    _timeoutTimer?.cancel();
    _isCompleting = true;

    try {
      await _saveCompletedGeneration(response);
    } finally {
      _isCompleting = false;
    }
  }

  Future<void> _saveCompletedGeneration(TtsResponse response) async {
    final bytes = response.metadata?['audio'];
    if (bytes is! Uint8List || bytes.isEmpty) {
      state = state.copyWith(
        status: GenerationStatus.error,
        errorMessage: AppStrings.errorEmptyAudio,
      );
      return;
    }

    // XTTS clones come back as WAV, streaming providers as MP3. Keep the
    // container the backend reported so the player and the file agree.
    final rawFormat = response.metadata?['format'];
    final format = rawFormat == 'wav' ? 'wav' : 'mp3';
    final fileName = 'voice_${DateTime.now().millisecondsSinceEpoch}.$format';
    final filePath = await _writeAudio(bytes, fileName);
    final duration = await _readAudioDuration(filePath);

    final asset = AudioAsset(
      id: const Uuid().v4(),
      fileName: fileName,
      filePath: filePath,
      fileSizeBytes: bytes.length,
      duration: duration,
      format: format,
      voiceId: state.voiceId,
      generationJobId: response.id,
      createdAt: DateTime.now(),
    );

    try {
      await _audioRepository.saveAudio(
        projectId: 0,
        voiceId: state.localVoiceId ?? 0,
        title: _buildTitle(),
        filePath: asset.filePath,
        format: asset.format,
        durationMs: asset.duration.inMilliseconds,
        fileSize: asset.fileSizeBytes,
      );
    } catch (_) {
      // Audio saved to state even if persistence fails.
    }

    state = state.copyWith(
      status: GenerationStatus.success,
      progress: 1.0,
      audioAsset: asset,
      completedAt: DateTime.now(),
    );
  }

  void cancelGeneration() {
    if (!state.isBusy) return;
    _subscription?.cancel();
    _timeoutTimer?.cancel();
    state = state.copyWith(
      status: GenerationStatus.cancelled,
      completedAt: DateTime.now(),
    );
  }

  Future<void> retryGeneration() async {
    if (state.isBusy) return;
    final text = state.text;
    final voiceId = state.voiceId;
    final voiceName = state.voiceName;
    final localVoiceId = state.localVoiceId;
    final speed = state.speed;
    state = const GenerationState();
    await startGeneration(
      text: text,
      voiceId: voiceId,
      voiceName: voiceName,
      localVoiceId: localVoiceId,
      speed: speed,
    );
  }

  /// Retries with a different voice, used after switching provider because
  /// voices belong to the provider that created them.
  Future<void> retryGenerationWithVoice({
    required String voiceId,
    required String voiceName,
    int? localVoiceId,
  }) async {
    if (state.isBusy) return;
    final text = state.text;
    final speed = state.speed;
    state = const GenerationState();
    await startGeneration(
      text: text,
      voiceId: voiceId,
      voiceName: voiceName,
      localVoiceId: localVoiceId,
      speed: speed,
    );
  }

  void reset() {
    _subscription?.cancel();
    _timeoutTimer?.cancel();
    state = const GenerationState();
  }

  GenerationStatus _mapTtsStatus(String status) {
    switch (status.toLowerCase()) {
      case 'validating':
        return GenerationStatus.validating;
      case 'uploading':
        return GenerationStatus.uploading;
      case 'generating':
        return GenerationStatus.generating;
      case 'downloading':
        return GenerationStatus.downloading;
      case 'processing':
        return GenerationStatus.processing;
      case 'completed':
      case 'success':
        return GenerationStatus.success;
      case 'error':
        return GenerationStatus.error;
      case 'cancelled':
        return GenerationStatus.cancelled;
      default:
        return GenerationStatus.generating;
    }
  }

  double _estimateProgress(TtsResponse response) {
    final chars = response.characterCount ?? state.characterCount;
    if (chars <= 0) return 0.1;
    return (0.1 + (chars / AppConstants.maxScriptLength) * 0.6).clamp(0.1, 0.7);
  }

  void _handleError(Object error) {
    _timeoutTimer?.cancel();
    state = state.copyWith(
      status: GenerationStatus.error,
      errorMessage: mapError(error),
      fallbackProviderId: _fallbackProviderFor(error),
    );
  }

  /// Offers ElevenLabs as a fallback when the active provider itself failed.
  /// Never suggests it for auth, quota or offline problems: switching would
  /// cost money without fixing the cause.
  String? _fallbackProviderFor(Object error) {
    final providerId = _activeProviderId();
    if (providerId == AppConstants.fallbackTtsProvider) {
      return null;
    }
    if (error is! TtsProviderException) {
      return null;
    }
    const switchable = {
      TtsErrorKind.server,
      TtsErrorKind.unavailable,
      TtsErrorKind.voiceNotFound,
    };
    if (!switchable.contains(error.kind)) {
      return null;
    }
    return AppConstants.fallbackTtsProvider;
  }

  /// Clears the pending provider suggestion after the user decides.
  void clearFallbackSuggestion() {
    if (state.fallbackProviderId == null) return;
    state = state.copyWith(clearFallback: true);
  }

  String mapError(Object error) {
    if (error is SocketException) {
      return AppStrings.errorNetwork;
    }
    if (error is TtsProviderException) {
      // The local provider shells out to Microsoft Edge TTS, which rate limits
      // aggressively. Say so instead of showing a generic server error.
      if (_activeProviderId() == TtsProviderIds.local &&
          (error.kind == TtsErrorKind.server ||
              error.kind == TtsErrorKind.unavailable)) {
        return AppStrings.errorEdgeUnavailable;
      }
      return mapTtsErrorKind(error.kind);
    }
    return AppStrings.errorUnknown;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _timeoutTimer?.cancel();
    super.dispose();
  }
}
