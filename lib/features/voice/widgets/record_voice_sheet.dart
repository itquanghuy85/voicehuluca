import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:voice_huluca/core/design_system/design_tokens.dart';
import 'package:voice_huluca/core/localization/app_strings.dart';
import 'package:voice_huluca/data/services/tts_provider.dart';
import 'package:voice_huluca/features/voice/voice_provider.dart';

/// Recording format expected by the local XTTS pipeline: 22 kHz mono WAV.
const RecordConfig recordVoiceConfig = RecordConfig(
  encoder: AudioEncoder.wav,
  sampleRate: 22050,
  numChannels: 1,
);

const Duration _minDuration = Duration(seconds: 5);
const Duration _maxDuration = Duration(seconds: 30);

/// Sample length the sheet asks the user for (XTTS works best in this range).
const Duration recordVoiceMinDuration = _minDuration;
const Duration recordVoiceMaxDuration = _maxDuration;

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
  String? _recordingPath;
  String? _error;
  bool _isRecording = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = AppStrings.recordVoiceNameHint;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _nameController.dispose();
    _recorder.dispose();
    super.dispose();
  }

  bool get _hasSample => _recordingPath != null;

  bool get _canSave =>
      _hasSample &&
      !_isSaving &&
      _elapsed >= _minDuration &&
      _nameController.text.trim().isNotEmpty &&
      !_nameController.text.trim().startsWith('Ví dụ');

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
      _elapsed = Duration.zero;
      _recordingPath = null;
    });

    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      setState(() => _error = AppStrings.recordVoicePermission);
      return;
    }

    final directory = await getTemporaryDirectory();
    final path = p.join(
      directory.path,
      'vietvoice_sample_${DateTime.now().millisecondsSinceEpoch}.wav',
    );

    try {
      await _recorder.start(recordVoiceConfig, path: path);
    } catch (_) {
      setState(() => _error = AppStrings.recordVoiceFailed);
      return;
    }

    if (!mounted) return;
    setState(() {
      _isRecording = true;
      _recordingPath = path;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 200), (timer) async {
      if (!mounted || !_isRecording) {
        timer.cancel();
        return;
      }
      setState(() => _elapsed += const Duration(milliseconds: 200));
      if (_elapsed >= _maxDuration) {
        await _stopRecording();
      }
    });
  }

  Future<void> _stopRecording() async {
    _timer?.cancel();
    _timer = null;
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
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isRecording = false;
        _error = AppStrings.recordVoiceFailed;
      });
    }
  }

  Future<void> _save() async {
    final path = _recordingPath;
    if (path == null) return;

    final name = _nameController.text.trim();
    if (name.isEmpty || name.startsWith('Ví dụ')) {
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

    try {
      await ref
          .read(ttsRepositoryProvider)
          .cloneVoice(
            name: name,
            description: '',
            audioFiles: [File(path)],
            language: 'vi',
          );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _error = mapTtsErrorKind(
          error is TtsProviderException ? error.kind : TtsErrorKind.unknown,
        );
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
                ],
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _nameController,
                  enabled: !_isSaving,
                  style: AppTypography.body.copyWith(color: colors.textPrimary),
                  decoration: InputDecoration(
                    labelText: AppStrings.recordVoiceNameLabel,
                    hintText: AppStrings.recordVoiceNameHint,
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
                                    AppStrings.recordVoiceSave,
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
