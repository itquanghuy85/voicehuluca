import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_huluca/core/design_system/design_tokens.dart';
import 'package:voice_huluca/core/localization/app_strings.dart';
import 'package:voice_huluca/data/services/tts_provider.dart';
import 'package:voice_huluca/features/settings/settings_provider.dart';
import 'package:voice_huluca/features/voice/voice_cloning_provider.dart';
import 'package:voice_huluca/features/voice/voice_provider.dart';

class VoiceCloningScreen extends ConsumerStatefulWidget {
  const VoiceCloningScreen({super.key});

  @override
  ConsumerState<VoiceCloningScreen> createState() => _VoiceCloningScreenState();
}

class _VoiceCloningScreenState extends ConsumerState<VoiceCloningScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _transcriptController = TextEditingController();
  bool _confirmed = false;
  bool _confirmationError = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _transcriptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cloningProvider);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _Header(),
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: AppStrings.cloningTabRecord),
                    Tab(text: AppStrings.cloningTabFile),
                  ],
                ),
                if (!ref.watch(activeProviderSupportsCloningProvider))
                  _CloningUnsupportedBanner(
                    onSwitchProvider: _switchToCloningProvider,
                  ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _RecordingTab(
                        state: state,
                        nameController: _nameController,
                        transcriptController: _transcriptController,
                        confirmed: _confirmed,
                        confirmationError: _confirmationError,
                        onConfirmChanged: (value) => setState(() {
                          _confirmed = value;
                          _confirmationError = false;
                        }),
                        onSubmit: _submit,
                      ),
                      _FileTab(
                        state: state,
                        nameController: _nameController,
                        transcriptController: _transcriptController,
                        confirmed: _confirmed,
                        confirmationError: _confirmationError,
                        onConfirmChanged: (value) => setState(() {
                          _confirmed = value;
                          _confirmationError = false;
                        }),
                        onSubmit: _submit,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (state.status == CloningStatus.processing)
              _ProcessingOverlay(
                progress: state.progress,
                onCancel: () =>
                    ref.read(cloningProvider.notifier).cancelCloning(),
              ),
            if (state.status == CloningStatus.success)
              _SuccessOverlay(
                onDone: () async {
                  // The new clone only lives on the server, so pull it into the
                  // list before leaving: otherwise "Giọng của tôi" stays stale
                  // until the next launch or a manual refresh.
                  await ref
                      .read(voiceListProvider.notifier)
                      .loadVoices(isRefresh: true);
                  ref.read(cloningProvider.notifier).reset();
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_confirmed) {
      setState(() => _confirmationError = true);
      return;
    }
    await ref
        .read(cloningProvider.notifier)
        .startCloning(
          name: _nameController.text,
          transcript: _transcriptController.text,
        );
  }

  /// Only ElevenLabs can clone; switch to it after the user confirms.
  Future<void> _switchToCloningProvider() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(AppStrings.providerSwitchAction),
        content: const Text(AppStrings.providerElevenLabsDesc),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text(AppStrings.settingsCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(AppStrings.settingsConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await ref
        .read(settingsProvider.notifier)
        .updateTtsProvider(TtsProviderIds.elevenLabs);
  }
}

/// Explains plainly that the active provider cannot clone voices.
class _CloningUnsupportedBanner extends StatelessWidget {
  const _CloningUnsupportedBanner({required this.onSwitchProvider});

  final VoidCallback onSwitchProvider;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(Theme.of(context).brightness);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(AppSpacing.lg),
      padding: AppSpacing.mdAll,
      decoration: BoxDecoration(
        color: colors.errorContainer,
        borderRadius: AppRadius.mediumAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                AppIcons.warning,
                size: AppSizes.iconMedium,
                color: colors.error,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  AppStrings.providerCloningUnavailableTitle,
                  style: AppTypography.label.copyWith(color: colors.error),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            AppStrings.providerCloningUnavailableDesc,
            style: AppTypography.bodySmall.copyWith(
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onSwitchProvider,
              child: Text(
                AppStrings.providerSwitchAction,
                style: AppTypography.label.copyWith(color: colors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = AppColorScheme.of(Theme.of(context).brightness);
    return SizedBox(
      height: AppSizes.appBarHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        child: Row(
          children: [
            IconButton(
              icon: Icon(AppIcons.arrowBack, color: scheme.textPrimary),
              constraints: const BoxConstraints(
                minWidth: AppSizes.touchTarget,
                minHeight: AppSizes.touchTarget,
              ),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            Expanded(
              child: Text(
                AppStrings.cloningScreenTitle,
                style: AppTypography.title,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: AppSizes.touchTarget),
          ],
        ),
      ),
    );
  }
}

class _RecordingTab extends ConsumerWidget {
  const _RecordingTab({
    required this.state,
    required this.nameController,
    required this.transcriptController,
    required this.confirmed,
    required this.confirmationError,
    required this.onConfirmChanged,
    required this.onSubmit,
  });

  final CloningState state;
  final TextEditingController nameController;
  final TextEditingController transcriptController;
  final bool confirmed;
  final bool confirmationError;
  final ValueChanged<bool> onConfirmChanged;
  final Future<void> Function() onSubmit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        const _InstructionsCard(),
        const SizedBox(height: AppSpacing.lg),
        if (state.status == CloningStatus.recording)
          _RecordingControl(state: state)
        else if (!state.hasAudio)
          _RecordButton(
            onPressed: () =>
                ref.read(cloningProvider.notifier).startRecording(),
          )
        else
          _AudioReadyCard(state: state),
        const SizedBox(height: AppSpacing.lg),
        const _QualityChecklistCard(),
        if (state.hasAudio) ...[
          const SizedBox(height: AppSpacing.lg),
          _CloningForm(
            nameController: nameController,
            transcriptController: transcriptController,
            confirmed: confirmed,
            confirmationError: confirmationError,
            onConfirmChanged: onConfirmChanged,
            onSubmit: onSubmit,
          ),
        ],
      ],
    );
  }
}

class _FileTab extends ConsumerWidget {
  const _FileTab({
    required this.state,
    required this.nameController,
    required this.transcriptController,
    required this.confirmed,
    required this.confirmationError,
    required this.onConfirmChanged,
    required this.onSubmit,
  });

  final CloningState state;
  final TextEditingController nameController;
  final TextEditingController transcriptController;
  final bool confirmed;
  final bool confirmationError;
  final ValueChanged<bool> onConfirmChanged;
  final Future<void> Function() onSubmit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        if (!state.hasAudio)
          _FilePickerCard(
            onPressed: () =>
                ref.read(cloningProvider.notifier).selectAudioFile(),
          )
        else
          _AudioReadyCard(state: state),
        if (state.hasAudio) ...[
          const SizedBox(height: AppSpacing.lg),
          _CloningForm(
            nameController: nameController,
            transcriptController: transcriptController,
            confirmed: confirmed,
            confirmationError: confirmationError,
            onConfirmChanged: onConfirmChanged,
            onSubmit: onSubmit,
          ),
        ],
      ],
    );
  }
}

class _InstructionsCard extends StatelessWidget {
  const _InstructionsCard();

  @override
  Widget build(BuildContext context) {
    final scheme = AppColorScheme.of(Theme.of(context).brightness);
    final instructions = <String>[
      AppStrings.cloningInstructionQuiet,
      AppStrings.cloningInstructionNatural,
      AppStrings.cloningInstructionSingleSpeaker,
      AppStrings.cloningInstructionNoMusic,
      AppStrings.cloningInstructionNoEcho,
      AppStrings.cloningInstructionStableVolume,
    ];
    return Container(
      padding: AppSpacing.lgAll,
      decoration: BoxDecoration(
        color: scheme.card,
        borderRadius: AppRadius.largeAll,
        border: Border.all(color: scheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                AppIcons.infoOutlined,
                size: AppSizes.iconMedium,
                color: scheme.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                AppStrings.cloningRecordTitle,
                style: AppTypography.label.copyWith(color: scheme.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...instructions.map(
            (instruction) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 2,
                      right: AppSpacing.sm,
                    ),
                    child: Icon(
                      AppIcons.check,
                      size: AppSizes.iconSmall,
                      color: scheme.success,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      instruction,
                      style: AppTypography.body.copyWith(
                        color: scheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecordButton extends StatelessWidget {
  const _RecordButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = AppColorScheme.of(Theme.of(context).brightness);
    return Container(
      padding: AppSpacing.xlAll,
      decoration: BoxDecoration(
        color: scheme.card,
        borderRadius: AppRadius.largeAll,
        border: Border.all(color: scheme.divider),
      ),
      child: Column(
        children: [
          SizedBox(
            width: AppSizes.fabSize,
            height: AppSizes.fabSize,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: scheme.error,
                foregroundColor: AppColors.onError,
                shape: const CircleBorder(),
                padding: EdgeInsets.zero,
                elevation: 0,
              ),
              child: const Icon(AppIcons.mic, size: AppSizes.iconExtraLarge),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            AppStrings.cloningStartRecording,
            style: AppTypography.label.copyWith(color: scheme.textPrimary),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            AppStrings.cloningRecordingLimit,
            style: AppTypography.caption.copyWith(color: scheme.textTertiary),
          ),
        ],
      ),
    );
  }
}

class _RecordingControl extends ConsumerWidget {
  const _RecordingControl({required this.state});

  final CloningState state;

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = AppColorScheme.of(Theme.of(context).brightness);
    return Container(
      padding: AppSpacing.xlAll,
      decoration: BoxDecoration(
        color: scheme.card,
        borderRadius: AppRadius.largeAll,
        border: Border.all(color: scheme.divider),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: AppSizes.badgeLargeSize,
                height: AppSizes.badgeLargeSize,
                decoration: BoxDecoration(
                  color: scheme.error,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                '${_formatDuration(state.recordingDuration)} / ${_formatDuration(CloningNotifier.maxRecordingDuration)}',
                style: AppTypography.title.copyWith(
                  color: scheme.textPrimary,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          _WaveformView(data: state.waveformData, animate: true),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: AppSizes.fabSize,
            height: AppSizes.fabSize,
            child: ElevatedButton(
              onPressed: () =>
                  ref.read(cloningProvider.notifier).stopRecording(),
              style: ElevatedButton.styleFrom(
                backgroundColor: scheme.textPrimary,
                foregroundColor: scheme.surface,
                shape: const CircleBorder(),
                padding: EdgeInsets.zero,
                elevation: 0,
              ),
              child: const Icon(AppIcons.stop, size: AppSizes.iconExtraLarge),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            AppStrings.cloningRecording,
            style: AppTypography.label.copyWith(color: scheme.textPrimary),
          ),
        ],
      ),
    );
  }
}

class _WaveformView extends StatelessWidget {
  const _WaveformView({required this.data, required this.animate});

  final List<double> data;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final scheme = AppColorScheme.of(Theme.of(context).brightness);
    return SizedBox(
      height: 64,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(40, (index) {
          final value = index < data.length ? data[index] : 0.0;
          return AnimatedContainer(
            duration: animate
                ? const Duration(milliseconds: 80)
                : Duration.zero,
            width: 4,
            height: 4 + value * 56,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: value > 0 ? scheme.primary : scheme.divider,
              borderRadius: AppRadius.pillAll,
            ),
          );
        }),
      ),
    );
  }
}

class _AudioReadyCard extends ConsumerWidget {
  const _AudioReadyCard({required this.state});

  final CloningState state;

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = AppColorScheme.of(Theme.of(context).brightness);
    final fileName = state.audioFileName ?? '';
    final fileSize = state.audioFileSizeBytes ?? 0;
    final duration = state.recordingDuration;
    return Container(
      padding: AppSpacing.lgAll,
      decoration: BoxDecoration(
        color: scheme.card,
        borderRadius: AppRadius.largeAll,
        border: Border.all(color: scheme.success),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(AppIcons.success, color: scheme.success),
              const SizedBox(width: AppSpacing.sm),
              Text(
                AppStrings.cloningAudioReady,
                style: AppTypography.label.copyWith(color: scheme.success),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _AudioInfoRow(icon: AppIcons.audio, label: fileName, value: ''),
          if (fileSize > 0)
            _AudioInfoRow(
              icon: AppIcons.tune,
              label: AppStrings.cloningFileSize,
              value: _formatFileSize(fileSize),
            ),
          if (duration > Duration.zero)
            _AudioInfoRow(
              icon: AppIcons.history,
              label: AppStrings.cloningFileDuration,
              value: _formatDuration(duration),
            ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: () => ref.read(cloningProvider.notifier).discardAudio(),
            icon: const Icon(AppIcons.refresh, size: AppSizes.iconMedium),
            label: const Text(AppStrings.cloningChangeAudio),
          ),
        ],
      ),
    );
  }
}

class _AudioInfoRow extends StatelessWidget {
  const _AudioInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = AppColorScheme.of(Theme.of(context).brightness);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: AppSizes.iconSmall, color: scheme.textTertiary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: scheme.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (value.isNotEmpty)
            Text(
              value,
              style: AppTypography.bodySmall.copyWith(
                color: scheme.textPrimary,
              ),
            ),
        ],
      ),
    );
  }
}

class _FilePickerCard extends StatelessWidget {
  const _FilePickerCard({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = AppColorScheme.of(Theme.of(context).brightness);
    return Container(
      padding: AppSpacing.xlAll,
      decoration: BoxDecoration(
        color: scheme.card,
        borderRadius: AppRadius.largeAll,
        border: Border.all(color: scheme.divider),
      ),
      child: Column(
        children: [
          Icon(
            AppIcons.upload,
            size: AppSizes.iconExtraLarge,
            color: scheme.primary,
          ),
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton.icon(
            onPressed: onPressed,
            icon: const Icon(AppIcons.audio, size: AppSizes.iconMedium),
            label: const Text(AppStrings.cloningSelectFile),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            AppStrings.cloningRecommendedQuality,
            style: AppTypography.caption.copyWith(color: scheme.textTertiary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${AppStrings.cloningMinDuration} • ${AppStrings.cloningMaxDuration}',
            style: AppTypography.caption.copyWith(color: scheme.textTertiary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _QualityChecklistCard extends StatelessWidget {
  const _QualityChecklistCard();

  @override
  Widget build(BuildContext context) {
    final scheme = AppColorScheme.of(Theme.of(context).brightness);
    final items = <String>[
      AppStrings.cloningChecklistQuiet,
      AppStrings.cloningChecklistSingleSpeaker,
      AppStrings.cloningChecklistNoMusic,
      AppStrings.cloningChecklistStableVolume,
      AppStrings.cloningChecklistNatural,
    ];
    return Container(
      padding: AppSpacing.lgAll,
      decoration: BoxDecoration(
        color: scheme.card,
        borderRadius: AppRadius.largeAll,
        border: Border.all(color: scheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                AppIcons.tune,
                size: AppSizes.iconMedium,
                color: scheme.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                AppStrings.cloningChecklistTitle,
                style: AppTypography.label.copyWith(color: scheme.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 2,
                      right: AppSpacing.sm,
                    ),
                    child: Icon(
                      AppIcons.check,
                      size: AppSizes.iconSmall,
                      color: scheme.success,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item,
                      style: AppTypography.body.copyWith(
                        color: scheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CloningForm extends StatelessWidget {
  const _CloningForm({
    required this.nameController,
    required this.transcriptController,
    required this.confirmed,
    required this.confirmationError,
    required this.onConfirmChanged,
    required this.onSubmit,
  });

  final TextEditingController nameController;
  final TextEditingController transcriptController;
  final bool confirmed;
  final bool confirmationError;
  final ValueChanged<bool> onConfirmChanged;
  final Future<void> Function() onSubmit;

  @override
  Widget build(BuildContext context) {
    final scheme = AppColorScheme.of(Theme.of(context).brightness);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: nameController,
          textCapitalization: TextCapitalization.words,
          style: AppTypography.body,
          decoration: const InputDecoration(
            labelText: AppStrings.cloningVoiceName,
            hintText: AppStrings.cloningVoiceNameHint,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        TextField(
          controller: transcriptController,
          maxLines: 3,
          minLines: 2,
          style: AppTypography.body,
          decoration: const InputDecoration(
            labelText: AppStrings.cloningTranscript,
            hintText: AppStrings.cloningTranscriptHint,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Container(
          padding: AppSpacing.mdAll,
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: AppRadius.mediumAll,
            border: Border.all(color: scheme.divider),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                AppIcons.infoOutlined,
                size: AppSizes.iconSmall,
                color: scheme.info,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  AppStrings.cloningPrivacyNotice,
                  style: AppTypography.caption.copyWith(
                    color: scheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        InkWell(
          onTap: () => onConfirmChanged(!confirmed),
          borderRadius: AppRadius.smallAll,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: Row(
              children: [
                SizedBox(
                  width: AppSizes.touchTarget,
                  height: AppSizes.touchTarget,
                  child: Checkbox(
                    value: confirmed,
                    onChanged: (value) => onConfirmChanged(value ?? false),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.md),
                    child: Text(
                      AppStrings.cloningConfirmation,
                      style: AppTypography.bodySmall.copyWith(
                        color: confirmationError
                            ? scheme.error
                            : scheme.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (confirmationError)
          Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.xl,
              bottom: AppSpacing.sm,
            ),
            child: Text(
              AppStrings.cloningConfirmationRequired,
              style: AppTypography.caption.copyWith(color: scheme.error),
            ),
          ),
        const SizedBox(height: AppSpacing.md),
        ElevatedButton.icon(
          onPressed: () => onSubmit(),
          icon: const Icon(AppIcons.voice, size: AppSizes.iconMedium),
          label: const Text(AppStrings.cloningSubmit),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(0, AppSizes.buttonLarge),
          ),
        ),
      ],
    );
  }
}

class _ProcessingOverlay extends StatelessWidget {
  const _ProcessingOverlay({required this.progress, required this.onCancel});

  final double progress;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final scheme = AppColorScheme.of(Theme.of(context).brightness);
    final phase = progress < 0.5
        ? AppStrings.cloningUploading
        : AppStrings.cloningCloning;
    return Positioned.fill(
      child: Container(
        color: scheme.background.withValues(alpha: 0.92),
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(AppSpacing.xxl),
            padding: AppSpacing.xxlAll,
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: AppRadius.extraLargeAll,
              boxShadow: brightness(context) == Brightness.dark
                  ? AppShadows.modalDark
                  : AppShadows.modal,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  phase,
                  style: AppTypography.label.copyWith(
                    color: scheme.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                ClipRRect(
                  borderRadius: AppRadius.pillAll,
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: scheme.divider,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '${(progress * 100).round()}%',
                  style: AppTypography.caption.copyWith(
                    color: scheme.textTertiary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                TextButton(
                  onPressed: onCancel,
                  child: const Text(AppStrings.cloningCancel),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Brightness brightness(BuildContext context) => Theme.of(context).brightness;
}

class _SuccessOverlay extends StatelessWidget {
  const _SuccessOverlay({required this.onDone});

  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final scheme = AppColorScheme.of(Theme.of(context).brightness);
    return Positioned.fill(
      child: Container(
        color: scheme.background.withValues(alpha: 0.92),
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(AppSpacing.xxl),
            padding: AppSpacing.xxlAll,
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: AppRadius.extraLargeAll,
              boxShadow: Theme.of(context).brightness == Brightness.dark
                  ? AppShadows.modalDark
                  : AppShadows.modal,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: AppSizes.avatarExtraLarge,
                  height: AppSizes.avatarExtraLarge,
                  decoration: BoxDecoration(
                    color: scheme.success.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    AppIcons.success,
                    size: AppSizes.iconExtraLarge,
                    color: scheme.success,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  AppStrings.cloningSuccess,
                  style: AppTypography.title.copyWith(
                    color: scheme.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  AppStrings.cloningSuccessDesc,
                  style: AppTypography.body.copyWith(
                    color: scheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),
                ElevatedButton(
                  onPressed: onDone,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, AppSizes.buttonLarge),
                  ),
                  child: const Text(AppStrings.cloningDone),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
