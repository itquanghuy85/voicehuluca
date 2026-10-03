import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:voice_huluca/core/audio/voice_sample_config.dart';
import 'package:voice_huluca/core/audio/wav_converter.dart';
import 'package:voice_huluca/core/constants/app_constants.dart';
import 'package:voice_huluca/core/localization/app_strings.dart';
import 'package:voice_huluca/data/models/voice.dart';
import 'package:voice_huluca/data/repositories/tts_repository_impl.dart';
import 'package:voice_huluca/data/services/tts_provider.dart';
import 'package:voice_huluca/features/voice/voice_provider.dart';

enum CloningStatus { idle, recording, processing, success, error }

class CloningState {
  final CloningStatus status;
  final Duration recordingDuration;
  final List<double> waveformData;
  final String? audioFilePath;
  final String? audioFileName;
  final int? audioFileSizeBytes;
  final String? errorMessage;
  final double progress;
  final Voice? clonedVoice;

  const CloningState({
    this.status = CloningStatus.idle,
    this.recordingDuration = Duration.zero,
    this.waveformData = const [],
    this.audioFilePath,
    this.audioFileName,
    this.audioFileSizeBytes,
    this.errorMessage,
    this.progress = 0,
    this.clonedVoice,
  });

  CloningState copyWith({
    CloningStatus? status,
    Duration? recordingDuration,
    List<double>? waveformData,
    String? audioFilePath,
    String? audioFileName,
    int? audioFileSizeBytes,
    String? errorMessage,
    double? progress,
    Voice? clonedVoice,
    bool clearError = false,
    bool clearAudio = false,
  }) {
    return CloningState(
      status: status ?? this.status,
      recordingDuration: recordingDuration ?? this.recordingDuration,
      waveformData: waveformData ?? this.waveformData,
      audioFilePath: clearAudio ? null : (audioFilePath ?? this.audioFilePath),
      audioFileName: clearAudio ? null : (audioFileName ?? this.audioFileName),
      audioFileSizeBytes: clearAudio
          ? null
          : (audioFileSizeBytes ?? this.audioFileSizeBytes),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      progress: progress ?? this.progress,
      clonedVoice: clonedVoice ?? this.clonedVoice,
    );
  }

  bool get hasAudio => audioFilePath != null;

  bool get isBusy =>
      status == CloningStatus.recording || status == CloningStatus.processing;
}

final cloningProvider = NotifierProvider<CloningNotifier, CloningState>(
  CloningNotifier.new,
);

class CloningNotifier extends Notifier<CloningState> {
  // The sidecar rejects samples outside 5-30s, so the screen has to stop at the
  // same bounds instead of letting the user record something that will fail.
  static const Duration maxRecordingDuration = recordVoiceMaxDuration;
  static const Duration minRecordingDuration = recordVoiceMinDuration;
  static const int maxWaveformSamples = 60;
  static const Duration waveformInterval = Duration(milliseconds: 100);

  final AudioRecorder _recorder = AudioRecorder();
  Timer? _recordingTimer;
  Timer? _progressTimer;

  TtsRepositoryImpl get _tts => ref.read(ttsRepositoryProvider);

  @override
  CloningState build() {
    ref.onDispose(() async {
      _recordingTimer?.cancel();
      _progressTimer?.cancel();
      await _recorder.dispose();
    });
    return const CloningState();
  }

  Future<void> startRecording() async {
    if (state.isBusy) return;
    try {
      final hasPermission = await _recorder.hasPermission();
      if (!hasPermission) {
        state = state.copyWith(
          status: CloningStatus.error,
          errorMessage: AppStrings.errorMicrophonePermission,
        );
        return;
      }
      final directory = await getTemporaryDirectory();
      final filePath = p.join(
        directory.path,
        'voice_clone_${DateTime.now().millisecondsSinceEpoch}.wav',
      );
      await _recorder.start(recordVoiceConfig, path: filePath);
      state = state.copyWith(
        status: CloningStatus.recording,
        recordingDuration: Duration.zero,
        waveformData: const [],
        audioFilePath: filePath,
        clearError: true,
      );
      _recordingTimer?.cancel();
      _recordingTimer = Timer.periodic(
        waveformInterval,
        (_) => _updateRecording(),
      );
    } catch (_) {
      state = state.copyWith(
        status: CloningStatus.error,
        errorMessage: AppStrings.errorUnknown,
      );
    }
  }

  Future<void> _updateRecording() async {
    try {
      final amplitude = await _recorder.getAmplitude();
      final normalized = ((amplitude.current + 60) / 60).clamp(0.05, 1.0);
      final data = [...state.waveformData, normalized];
      if (data.length > maxWaveformSamples) {
        data.removeAt(0);
      }
      final newDuration = state.recordingDuration + waveformInterval;
      state = state.copyWith(
        recordingDuration: newDuration,
        waveformData: data,
      );
      if (newDuration >= maxRecordingDuration) {
        await stopRecording();
      }
    } catch (_) {
      // Amplitude polling may fail between ticks; keep recording.
    }
  }

  Future<void> stopRecording() async {
    if (state.status != CloningStatus.recording) return;
    _recordingTimer?.cancel();
    final path = await _recorder.stop();
    if (path == null || state.recordingDuration < minRecordingDuration) {
      state = state.copyWith(
        status: CloningStatus.error,
        errorMessage: AppStrings.errorRecordingTooShort,
        recordingDuration: Duration.zero,
        waveformData: const [],
        clearAudio: true,
      );
      return;
    }
    state = state.copyWith(status: CloningStatus.idle);
  }

  Future<void> selectAudioFile() async {
    if (state.isBusy) return;
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        withData: false,
      );
      if (result == null || result.files.isEmpty) return;
      final file = result.files.first;
      if (file.path == null) {
        state = state.copyWith(
          status: CloningStatus.error,
          errorMessage: AppStrings.errorInvalidAudio,
        );
        return;
      }
      if (file.size > AppConstants.maxAudioFileSizeBytes) {
        state = state.copyWith(
          status: CloningStatus.error,
          errorMessage: AppStrings.errorFileTooLarge,
        );
        return;
      }
      final extension = (file.extension ?? '').toLowerCase();
      if (extension.isNotEmpty &&
          !AppConstants.supportedAudioFormats.contains(extension)) {
        state = state.copyWith(
          status: CloningStatus.error,
          errorMessage: AppStrings.errorUnsupportedFormat,
        );
        return;
      }
      state = state.copyWith(
        status: CloningStatus.idle,
        audioFilePath: file.path,
        audioFileName: file.name,
        audioFileSizeBytes: file.size,
        clearError: true,
      );
    } catch (_) {
      state = state.copyWith(
        status: CloningStatus.error,
        errorMessage: AppStrings.errorUnknown,
      );
    }
  }

  Future<void> startCloning({required String name, String? transcript}) async {
    if (state.isBusy) return;
    if (!ref.read(activeProviderSupportsCloningProvider)) {
      state = state.copyWith(
        status: CloningStatus.error,
        errorMessage: AppStrings.cloningUnsupportedMessage,
      );
      return;
    }
    if (name.trim().isEmpty) {
      state = state.copyWith(
        status: CloningStatus.error,
        errorMessage: AppStrings.cloningNameRequired,
      );
      return;
    }
    final audioPath = state.audioFilePath;
    if (audioPath == null) {
      state = state.copyWith(
        status: CloningStatus.error,
        errorMessage: AppStrings.cloningAudioRequired,
      );
      return;
    }
    state = state.copyWith(
      status: CloningStatus.processing,
      progress: 0,
      clearError: true,
    );
    _startProgressAnimation();
    try {
      // Picked files may be 24-bit or float WAV; the engine reads integer PCM.
      final sample = await WavConverter.ensurePcm16(File(audioPath));
      final voice = await _tts.cloneVoice(
        name: name.trim(),
        description: transcript?.trim() ?? '',
        audioFiles: [sample],
        language: 'vi',
      );
      _progressTimer?.cancel();
      state = state.copyWith(
        status: CloningStatus.success,
        progress: 1,
        clonedVoice: voice,
      );
    } catch (error) {
      _progressTimer?.cancel();
      state = state.copyWith(
        status: CloningStatus.error,
        errorMessage: mapError(error),
      );
    }
  }

  void _startProgressAnimation() {
    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (state.status == CloningStatus.processing && state.progress < 0.9) {
        state = state.copyWith(
          progress: (state.progress + 0.02).clamp(0.0, 0.9),
        );
      }
    });
  }

  void cancelCloning() {
    _progressTimer?.cancel();
    state = state.copyWith(
      status: CloningStatus.idle,
      progress: 0,
      clearError: true,
    );
  }

  void discardAudio() {
    if (state.isBusy) return;
    state = state.copyWith(
      audioFilePath: null,
      audioFileName: null,
      audioFileSizeBytes: null,
      recordingDuration: Duration.zero,
      waveformData: const [],
      clearError: true,
    );
  }

  void reset() {
    _recordingTimer?.cancel();
    _progressTimer?.cancel();
    state = const CloningState();
  }

  String mapError(Object error) {
    if (error is SocketException) {
      return AppStrings.errorNetwork;
    }
    if (error is TtsProviderException) {
      switch (error.kind) {
        case TtsErrorKind.unconfigured:
          return AppStrings.errorBackendNotConfigured;
        case TtsErrorKind.unsupported:
          return AppStrings.cloningUnsupportedMessage;
        case TtsErrorKind.unauthorized:
          return AppStrings.errorUnauthorized;
        case TtsErrorKind.paymentRequired:
          return AppStrings.errorPaymentRequired;
        case TtsErrorKind.fileTooLarge:
          return AppStrings.errorFileTooLarge;
        case TtsErrorKind.rateLimit:
          return AppStrings.errorRateLimit;
        case TtsErrorKind.server:
        case TtsErrorKind.unavailable:
        case TtsErrorKind.network:
          return AppStrings.errorProviderUnavailable;
        default:
          return AppStrings.errorCloningFailed;
      }
    }
    return AppStrings.errorCloningFailed;
  }
}
