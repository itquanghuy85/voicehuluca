import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:voice_huluca/core/app/app_settings_opener.dart';
import 'package:voice_huluca/core/audio/recording_analyzer.dart';
import 'package:voice_huluca/core/audio/voice_sample_config.dart';
import 'package:voice_huluca/core/audio/wav_converter.dart';
import 'package:voice_huluca/core/design_system/design_tokens.dart';
import 'package:voice_huluca/core/localization/app_strings.dart';
import 'package:voice_huluca/data/services/tts_provider.dart';
import 'package:voice_huluca/features/voice/voice_provider.dart';

const Duration _minDuration = recordVoiceMinDuration;
const Duration _maxDuration = recordVoiceMaxDuration;

/// Opens the sheet. Resolves to true when a new voice was saved.
Future<bool> showRecordVoiceSheet(BuildContext context, WidgetRef ref) async {
  final saved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => const RecordVoiceSheet(),
  );
  if (saved == true) {
    // Pull the new voice from the provider so it shows up in the list.
    await ref.read(voiceListProvider.notifier).loadVoices(isRefresh: true);
  }
  return saved ?? false;
}

/// Records a short sample and turns it into a reusable voice.
class RecordVoiceSheet extends ConsumerStatefulWidget {
  const RecordVoiceSheet({super.key});

  @override
  ConsumerState<RecordVoiceSheet> createState() => _RecordVoiceSheetState();
}

class _RecordVoiceSheetState extends ConsumerState<RecordVoiceSheet> {
  final AudioRecorder _recorder = AudioRecorder();
  final TextEditingController _nameController = TextEditingController();

  Timer? _timer;
  Duration _elapsed = Duration.zero;

  /// Wall clock since the recorder opened the file. Adding a fixed step per tick
  /// made the counter drift away from the audio, so the 30s cap could overshoot
  /// into the range the backend rejects.
  final Stopwatch _stopwatch = Stopwatch();

  String? _recordingPath;
  String? _error;
  bool _isRecording = false;
  bool _isSaving = false;
  bool _needsMicPermission = false;

  /// True once a save has failed, which turns the save button into "Thử lại"
  /// so the recording is reused instead of re-recorded.
  bool _canRetry = false;

  /// Loudest level seen while recording, in dBFS (0 is full scale, -160 silent).
  double _peakDb = -160;

  /// Below this the microphone heard nothing but room tone. Speech at arm's
  /// length peaks around -20 dBFS, so this only trips on real silence.
  static const double _minAudibleDb = -40;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _nameController.dispose();
    _recorder.dispose();
    super.dispose();
  }

  bool get _hasSample => _recordingPath != null;

  Future<void> _openAppSettings() async {
    await openAppSettings();
    // Re-check as soon as the user comes back so the button disappears once
    // the microphone has been granted.
    final granted = await _recorder.hasPermission();
    if (!mounted) return;
    setState(() {
      _needsMicPermission = !granted;
      if (granted) {
        _error = null;
      }
    });
  }

  /// Deletes the local sample only when the user asks: a failed upload keeps
  /// the recording so it can be retried without recording again.
  Future<void> _discardSample() async {
    if (_isSaving || _isRecording) return;
    final path = _recordingPath;
    setState(() {
      _recordingPath = null;
      _elapsed = Duration.zero;
      _error = null;
      _canRetry = false;
    });
    if (path == null) return;
    try {
      await File(path).delete();
    } on Object {
      // Best effort: the file is already forgotten by the UI.
    }
  }

  void _openServerSettings() {
    Navigator.of(context).pop(false);
  }

  bool get _canSave =>
      _hasSample &&
      !_isSaving &&
      _elapsed >= _minDuration &&
      _nameController.text.trim().isNotEmpty;

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _stopRecording();
      return;
    }
    await _startRecording();
  }

  Future<void> _startRecording() async {
    setState(() {
      _error = null;
      _needsMicPermission = false;
      _elapsed = Duration.zero;
      _recordingPath = null;
      _peakDb = -160;
      _canRetry = false;
    });

    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      setState(() {
        _error = AppStrings.recordVoicePermissionHint;
        _needsMicPermission = true;
      });
      return;
    }

    final directory = await getTemporaryDirectory();
    final path = p.join(
      directory.path,
      'vietvoice_sample_${DateTime.now().millisecondsSinceEpoch}.wav',
    );

    try {
      await _recorder.start(recordVoiceConfig, path: path);
    } catch (error) {
      debugPrint('[voice-record] start failed on $path: $error');
      setState(() => _error = AppStrings.recordVoiceFailed);
      return;
    }

    if (!mounted) return;
    setState(() {
      _isRecording = true;
      _recordingPath = path;
    });
    _stopwatch
      ..reset()
      ..start();

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 200), (timer) async {
      if (!mounted || !_isRecording) {
        timer.cancel();
        return;
      }
      final elapsed = _stopwatch.elapsed;
      setState(() => _elapsed = elapsed);
      await _trackLevel();
      if (elapsed >= recordVoiceStopAt) {
        await _stopRecording();
      }
    });
  }

  /// Remembers the loudest level the recorder saw, in dBFS. iOS ignores the WAV
  /// request and returns AAC in an M4A container, so the recorded file cannot
  /// always be measured on the phone; the live level answers "did anyone speak"
  /// whatever the recorder decided to write.
  Future<void> _trackLevel() async {
    try {
      final amplitude = await _recorder.getAmplitude();
      final loudest = math.max(amplitude.current, amplitude.max);
      if (loudest > _peakDb) _peakDb = loudest;
    } catch (_) {
      // Amplitude polling may fail between ticks; keep recording.
    }
  }

  Future<void> _stopRecording() async {
    _timer?.cancel();
    _timer = null;
    _stopwatch.stop();
    try {
      final path = await _recorder.stop();
      if (!mounted) return;
      setState(() {
        _isRecording = false;
        if (path == null) {
          _recordingPath = null;
          _error = AppStrings.recordVoiceFailed;
        }
      });
      if (path == null) return;

      // Refuse a silent sample here: cloning it produces a voice the user
      // cannot hear and cannot use.
      final quality = await _analyzeSample(path);
      debugPrint('[voice-record] $path -> $quality | peakDb=$_peakDb');

      final heardSomething = _peakDb > _minAudibleDb;
      // A file the phone can parse is judged by the samples; anything else (an
      // M4A from iOS) is judged by the live level and left for the sidecar to
      // decode.
      final usable = switch (quality.status) {
        RecordingStatus.ok ||
        RecordingStatus.silent => quality.hasSpeech || heardSomething,
        RecordingStatus.notRiff ||
        RecordingStatus.unsupportedFormat => heardSomething,
        _ => false,
      };

      if (!mounted) return;
      if (!usable) {
        setState(() {
          _recordingPath = null;
          _elapsed = Duration.zero;
          _error = _messageFor(quality.status, quality.detected);
        });
        return;
      }

      // The recorder may hand back 24-bit or float WAV; XTTS reads integer PCM
      // only, so normalise when the phone could parse the file at all.
      final usablePath = await WavConverter.ensurePcm16(File(path));
      debugPrint('[voice-record] usable sample: ${usablePath.path}');
      if (!mounted) return;
      setState(() {
        _recordingPath = usablePath.path;
        if (quality.duration > _elapsed) _elapsed = quality.duration;
        _error = null;
      });
    } catch (error) {
      debugPrint('[voice-record] stop failed: $error');
      if (!mounted) return;
      setState(() {
        _isRecording = false;
        _error = AppStrings.recordVoiceFailed;
      });
    }
  }

  /// A broken recording must not be blamed on the microphone, so each analyzer
  /// outcome gets its own message. [detected] names what the file really was so
  /// the user can tell a format problem from a hardware one.
  String _messageFor(RecordingStatus status, String detected) => switch (status) {
    RecordingStatus.unreadable ||
    RecordingStatus.malformedHeader ||
    RecordingStatus.missingData => AppStrings.recordVoiceUnreadable,
    RecordingStatus.notRiff => AppStrings.recordVoiceNotWav(detected),
    RecordingStatus.unsupportedFormat => AppStrings.recordVoiceBadFormat(
      detected,
    ),
    RecordingStatus.empty => AppStrings.recordVoiceEmpty,
    _ => AppStrings.recordVoiceSilent,
  };

  Future<RecordingQuality> _analyzeSample(String path) async {
    try {
      final file = File(path);
      final bytes = await file.readAsBytes();
      return analyzeWavBytes(bytes);
    } catch (error) {
      debugPrint('[voice-record] cannot read $path: $error');
      return RecordingQuality.unreadableValue;
    }
  }

  Future<void> _save() async {
    final path = _recordingPath;
    if (path == null) return;

    final String name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = AppStrings.recordVoiceNameRequired);
      return;
    }
    if (_elapsed < _minDuration) {
      setState(() => _error = AppStrings.recordVoiceTooShort);
      return;
    }

    setState(() {
      _isSaving = true;
      _error = null;
    });

    final repository = ref.read(ttsRepositoryProvider);
    try {
      // Ask the backend first. Uploading a recording that cannot be stored only
      // produces a second, less useful error, and the recording must survive
      // either way so the user can retry without recording again.
      final health = await repository.checkHealth();
      final providerId = ref.read(ttsProviderIdProvider);
      if (health.providers.isNotEmpty && !health.canClone(providerId)) {
        throw TtsProviderException(
          AppStrings.cloneProviderUnavailable(providerId),
          kind: TtsErrorKind.unavailable,
          providerId: providerId,
        );
      }
      await repository.cloneVoice(
        name: name,
        description: '',
        audioFiles: [File(path)],
        language: 'vi',
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      debugPrint('[voice-record] save failed: $error');
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        // _recordingPath is deliberately kept: the sample is still on disk and
        // "Thử lại" reuses it.
        _error = mapError(error);
        _canRetry = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(Theme.of(context).brightness);
    final supportsCloning = ref.watch(activeProviderSupportsCloningProvider);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppSpacing.xl),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.divider,
                      borderRadius: AppRadius.pillAll,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  AppStrings.recordVoiceTitle,
                  style: AppTypography.title.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  AppStrings.recordVoiceIntro,
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                if (!supportsCloning) ...[
                  const SizedBox(height: AppSpacing.md),
                  _Notice(
                    message: AppStrings.recordVoiceUnsupported,
                    color: colors.error,
                    icon: AppIcons.warning,
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                _SampleText(),
                const SizedBox(height: AppSpacing.md),
                _TimerRow(elapsed: _elapsed, isRecording: _isRecording),
                if (_error != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  _Notice(
                    message: _error!,
                    color: colors.error,
                    icon: AppIcons.errorOutlined,
                  ),
                  // A failed save must not cost the recording: say so, and the
                  // save button becomes "Thử lại" on the same sample.
                  if (_canRetry && _hasSample) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      AppStrings.recordVoiceKeptSample,
                      style: AppTypography.bodySmall.copyWith(
                        color: colors.textTertiary,
                      ),
                    ),
                  ],
                ],
                if (_needsMicPermission) ...[
                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    width: double.infinity,
                    height: AppSizes.buttonLarge,
                    child: ElevatedButton.icon(
                      onPressed: _openAppSettings,
                      icon: const Icon(
                        AppIcons.settings,
                        size: AppSizes.iconLarge,
                      ),
                      label: const Text(AppStrings.recordVoiceOpenSettings),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary,
                        foregroundColor: colors.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.largeAll,
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _nameController,
                  enabled: !_isSaving,
                  textCapitalization: TextCapitalization.words,
                  style: AppTypography.body.copyWith(color: colors.textPrimary),
                  decoration: InputDecoration(
                    labelText: AppStrings.recordVoiceNameLabel,
                    hintText: AppStrings.recordVoiceNameHint,
                    errorText: _error == AppStrings.recordVoiceNameRequired
                        ? _error
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.mediumAll,
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: _RecordButton(
                        isRecording: _isRecording,
                        hasSample: _hasSample,
                        enabled: !_isSaving,
                        onPressed: supportsCloning ? _toggleRecording : null,
                      ),
                    ),
                    if (_hasSample && !_isRecording) ...[
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: SizedBox(
                          height: AppSizes.buttonLarge,
                          child: ElevatedButton(
                            onPressed: _canSave ? _save : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colors.primary,
                              foregroundColor: colors.onPrimary,
                              disabledBackgroundColor: colors.disabled,
                              shape: RoundedRectangleBorder(
                                borderRadius: AppRadius.largeAll,
                              ),
                            ),
                            child: _isSaving
                                ? CupertinoActivityIndicator(
                                    color: colors.onPrimary,
                                  )
                                : Text(
                                    _canRetry
                                        ? AppStrings.recordVoiceRetry
                                        : AppStrings.recordVoiceSave,
                                    style: AppTypography.label.copyWith(
                                      color: colors.onPrimary,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (_isSaving) ...[
                  const SizedBox(height: AppSpacing.md),
                  _Notice(
                    message: AppStrings.recordVoiceCloning,
                    color: colors.textSecondary,
                    icon: AppIcons.download,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    AppStrings.recordVoiceFirstRunWarning,
                    style: AppTypography.caption.copyWith(
                      color: colors.textTertiary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                if (_hasSample && !_isRecording) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: _isSaving ? null : _discardSample,
                          child: Text(AppStrings.recordVoiceDeleteSample),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: TextButton(
                          onPressed: _openServerSettings,
                          child: Text(AppStrings.recordVoiceChooseServer),
                        ),
                      ),
                    ],
                  ),
                ],
                TextButton(
                  onPressed: _isSaving
                      ? null
                      : () => Navigator.of(context).pop(false),
                  child: Text(AppStrings.recordVoiceCancel),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SampleText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(Theme.of(context).brightness);
    return Container(
      padding: AppSpacing.mdAll,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadius.mediumAll,
        border: Border.all(color: colors.divider),
      ),
      child: Text(
        AppStrings.recordVoiceSample,
        style: AppTypography.body.copyWith(color: colors.textPrimary),
      ),
    );
  }
}

class _TimerRow extends StatelessWidget {
  const _TimerRow({required this.elapsed, required this.isRecording});

  final Duration elapsed;
  final bool isRecording;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(Theme.of(context).brightness);
    final seconds = elapsed.inMilliseconds / 1000;
    final inRange = elapsed >= _minDuration && elapsed < _maxDuration;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          isRecording
              ? AppStrings.recordVoiceRecordedFor
              : AppStrings.recordVoiceDurationHint,
          style: AppTypography.caption.copyWith(color: colors.textTertiary),
        ),
        Text(
          '${seconds.toStringAsFixed(1)}s / ${_maxDuration.inSeconds}s',
          style: AppTypography.label.copyWith(
            color: inRange || !isRecording ? colors.textPrimary : colors.error,
          ),
        ),
      ],
    );
  }
}

class _RecordButton extends StatelessWidget {
  const _RecordButton({
    required this.isRecording,
    required this.hasSample,
    required this.enabled,
    required this.onPressed,
  });

  final bool isRecording;
  final bool hasSample;
  final bool enabled;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(Theme.of(context).brightness);
    final label = isRecording
        ? AppStrings.recordVoiceStop
        : hasSample
        ? AppStrings.recordVoiceRerecord
        : AppStrings.recordVoiceStart;

    return SizedBox(
      height: AppSizes.buttonLarge,
      child: ElevatedButton.icon(
        onPressed: enabled ? onPressed : null,
        icon: Icon(
          isRecording ? AppIcons.stop : AppIcons.mic,
          size: AppSizes.iconMedium,
        ),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: isRecording ? colors.error : colors.secondary,
          foregroundColor: colors.onPrimary,
          disabledBackgroundColor: colors.disabled,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.largeAll),
        ),
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({
    required this.message,
    required this.color,
    required this.icon,
  });

  final String message;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: AppSizes.iconMedium, color: color),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            message,
            style: AppTypography.bodySmall.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}
