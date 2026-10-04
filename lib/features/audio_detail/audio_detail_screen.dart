import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/app_constants.dart';
import '../../core/design_system/design_tokens.dart';
import '../../core/localization/app_strings.dart';
import '../../core/utils/share_origin.dart';
import '../../data/models/audio_asset.dart';
import '../audio_library/library_provider.dart';
import 'audio_detail_provider.dart';

class AudioDetailScreen extends ConsumerStatefulWidget {
  final int audioId;

  const AudioDetailScreen({super.key, required this.audioId});

  @override
  ConsumerState<AudioDetailScreen> createState() => _AudioDetailScreenState();
}

class _AudioDetailScreenState extends ConsumerState<AudioDetailScreen> {
  late TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  void _showRenameDialog(AudioAsset audio) {
    _titleController.text = audio.title;
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text(AppStrings.audioDetailRenameTitle),
        content: Padding(
          padding: const EdgeInsets.only(top: AppSpacing.md),
          child: CupertinoTextField(
            controller: _titleController,
            placeholder: AppStrings.audioDetailRenameHint,
            autofocus: true,
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.libraryCancel),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              if (_titleController.text.trim().isNotEmpty) {
                ref
                    .read(audioDetailProvider(widget.audioId).notifier)
                    .updateTitle(_titleController.text.trim());
                Navigator.pop(context);
                _showSnackBar(AppStrings.audioDetailRenameSuccess);
              }
            },
            child: const Text(AppStrings.settingsSave),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(AudioAsset audio) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text(AppStrings.audioDetailDeleteConfirm),
        content: const Text(AppStrings.audioDetailDeleteDesc),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.libraryCancel),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              ref.read(audioDetailProvider(widget.audioId).notifier).delete();
              Navigator.pop(context);
              Navigator.pop(context);
              _showSnackBar(AppStrings.audioDetailDeleteSuccess);
            },
            child: const Text(AppStrings.libraryConfirm),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: AppConstants.snackBarDuration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mediumAll),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(audioDetailProvider(widget.audioId));
    final colorScheme = AppColorScheme.of(Theme.of(context).brightness);

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(colorScheme),
            Expanded(child: _buildContent(state, colorScheme)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          CupertinoButton(
            padding: const EdgeInsets.all(AppSpacing.sm),
            minSize: AppSizes.touchTarget,
            onPressed: () => Navigator.pop(context),
            child: Icon(
              AppIcons.arrowBack,
              color: colorScheme.primary,
              size: AppSizes.iconLarge,
            ),
          ),
          Expanded(
            child: Text(
              AppStrings.audioDetailTitle,
              style: AppTypography.title.copyWith(
                color: colorScheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          CupertinoButton(
            padding: const EdgeInsets.all(AppSpacing.sm),
            minSize: AppSizes.touchTarget,
            onPressed: () {
              final state = ref.read(audioDetailProvider(widget.audioId));
              if (state.audio != null) {
                _showRenameDialog(state.audio!);
              }
            },
            child: Icon(
              AppIcons.edit,
              color: colorScheme.primary,
              size: AppSizes.iconLarge,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(AudioDetailState state, AppColorScheme colorScheme) {
    if (state.isLoading) {
      return const Center(child: CupertinoActivityIndicator());
    }

    if (state.error != null) {
      return _buildError(state.error!, colorScheme);
    }

    if (state.audio == null) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitle(state.audio!, colorScheme),
          const SizedBox(height: AppSpacing.xxl),
          _buildWaveform(state, colorScheme),
          const SizedBox(height: AppSpacing.xxl),
          _buildPlayerControls(state, colorScheme),
          const SizedBox(height: AppSpacing.xxl),
          _buildSpeedSelector(state, colorScheme),
          const SizedBox(height: AppSpacing.xxl),
          _buildFileInfo(state.audio!, colorScheme),
          const SizedBox(height: AppSpacing.xxl),
          _buildActionButtons(state.audio!, colorScheme),
        ],
      ),
    );
  }

  Widget _buildError(String error, AppColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              AppIcons.error,
              size: AppSizes.iconExtraLarge,
              color: colorScheme.error,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              AppStrings.audioDetailErrorLoading,
              style: AppTypography.body.copyWith(
                color: colorScheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            CupertinoButton(
              onPressed: () {
                ref
                    .read(audioDetailProvider(widget.audioId).notifier)
                    .loadAudio();
              },
              color: colorScheme.primary,
              borderRadius: AppRadius.mediumAll,
              child: const Text(AppStrings.audioDetailRetry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(AudioAsset audio, AppColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.audioDetailTitleLabel,
          style: AppTypography.bodySmall.copyWith(
            color: colorScheme.textTertiary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          audio.title,
          style: AppTypography.headline.copyWith(
            color: colorScheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildWaveform(AudioDetailState state, AppColorScheme colorScheme) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: colorScheme.card,
        borderRadius: AppRadius.largeAll,
        border: Border.all(color: colorScheme.divider),
      ),
      child: ClipRRect(
        borderRadius: AppRadius.largeAll,
        child: CustomPaint(
          size: Size.infinite,
          painter: WaveformPainter(
            audioId: state.audio?.id ?? 0,
            progress: state.duration.inMilliseconds > 0
                ? state.position.inMilliseconds / state.duration.inMilliseconds
                : 0.0,
            color: colorScheme.primary,
            backgroundColor: colorScheme.card,
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerControls(
    AudioDetailState state,
    AppColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.card,
        borderRadius: AppRadius.largeAll,
        border: Border.all(color: colorScheme.divider),
      ),
      child: Column(
        children: [
          _buildSeekBar(state, colorScheme),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CupertinoButton(
                padding: const EdgeInsets.all(AppSpacing.sm),
                minSize: AppSizes.touchTarget,
                onPressed: () {
                  ref
                      .read(audioDetailProvider(widget.audioId).notifier)
                      .skipBackward();
                },
                child: Icon(
                  AppIcons.replay,
                  color: colorScheme.textSecondary,
                  size: AppSizes.iconLarge,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              GestureDetector(
                onTap: () {
                  if (state.isPlaying) {
                    ref
                        .read(audioDetailProvider(widget.audioId).notifier)
                        .pause();
                  } else {
                    ref
                        .read(audioDetailProvider(widget.audioId).notifier)
                        .play();
                  }
                },
                child: Container(
                  width: AppSizes.fabSize,
                  height: AppSizes.fabSize,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                    boxShadow: AppShadows.button,
                  ),
                  child: Icon(
                    state.isPlaying ? AppIcons.pause : AppIcons.play,
                    color: colorScheme.onPrimary,
                    size: AppSizes.iconExtraLarge,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              CupertinoButton(
                padding: const EdgeInsets.all(AppSpacing.sm),
                minSize: AppSizes.touchTarget,
                onPressed: () {
                  ref
                      .read(audioDetailProvider(widget.audioId).notifier)
                      .skipForward();
                },
                child: Icon(
                  AppIcons.skipNext,
                  color: colorScheme.textSecondary,
                  size: AppSizes.iconLarge,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSeekBar(AudioDetailState state, AppColorScheme colorScheme) {
    final maxDuration = state.duration.inMilliseconds.toDouble();
    final currentPosition = state.position.inMilliseconds.toDouble().clamp(
      0.0,
      maxDuration,
    );

    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: AppSizes.sliderHeight,
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: AppSizes.sliderThumbSize / 2,
            ),
            overlayShape: const RoundSliderOverlayShape(
              overlayRadius: AppSizes.sliderThumbSize,
            ),
          ),
          child: Slider(
            value: maxDuration > 0 ? currentPosition : 0.0,
            max: maxDuration > 0 ? maxDuration : 1.0,
            activeColor: colorScheme.primary,
            inactiveColor: colorScheme.divider,
            onChanged: (value) {
              ref
                  .read(audioDetailProvider(widget.audioId).notifier)
                  .seek(Duration(milliseconds: value.toInt()));
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(state.position),
                style: AppTypography.bodySmall.copyWith(
                  color: colorScheme.textTertiary,
                ),
              ),
              Text(
                _formatDuration(state.duration),
                style: AppTypography.bodySmall.copyWith(
                  color: colorScheme.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSpeedSelector(
    AudioDetailState state,
    AppColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.card,
        borderRadius: AppRadius.largeAll,
        border: Border.all(color: colorScheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.audioDetailSpeed,
            style: AppTypography.bodySmall.copyWith(
              color: colorScheme.textTertiary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: AppConstants.supportedSpeechRates.map((speed) {
              final isSelected = state.speed == speed;
              return GestureDetector(
                onTap: () {
                  ref
                      .read(audioDetailProvider(widget.audioId).notifier)
                      .setSpeed(speed);
                },
                child: Container(
                  width: AppSizes.touchTarget,
                  height: AppSizes.touchTarget,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.surface,
                    borderRadius: AppRadius.mediumAll,
                    border: Border.all(
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.divider,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${speed}x',
                    style: AppTypography.bodySmall.copyWith(
                      color: isSelected
                          ? colorScheme.onPrimary
                          : colorScheme.textSecondary,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFileInfo(AudioAsset audio, AppColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.card,
        borderRadius: AppRadius.largeAll,
        border: Border.all(color: colorScheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.audioDetailFileInfo,
            style: AppTypography.label.copyWith(color: colorScheme.textPrimary),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildInfoRow(
            AppIcons.waveform,
            AppStrings.audioDetailDuration,
            _formatDuration(Duration(milliseconds: audio.durationMs)),
            colorScheme,
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildInfoRow(
            AppIcons.audio,
            AppStrings.audioDetailSize,
            _formatFileSize(audio.fileSize),
            colorScheme,
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildInfoRow(
            AppIcons.audio,
            AppStrings.audioDetailFormat,
            audio.format.toUpperCase(),
            colorScheme,
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildInfoRow(
            AppIcons.voice,
            AppStrings.audioDetailVoice,
            ref.watch(libraryVoiceNamesProvider).valueOrNull?[audio.voiceId] ??
                AppStrings.libraryVoiceUnknown,
            colorScheme,
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildInfoRow(
            AppIcons.history,
            AppStrings.audioDetailCreated,
            _formatDate(audio.createdAt),
            colorScheme,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    AppColorScheme colorScheme,
  ) {
    return Row(
      children: [
        Icon(icon, size: AppSizes.iconSmall, color: colorScheme.textTertiary),
        const SizedBox(width: AppSpacing.sm),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: colorScheme.textSecondary,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: AppTypography.bodySmall.copyWith(
            color: colorScheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(AudioAsset audio, AppColorScheme colorScheme) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                AppIcons.edit,
                AppStrings.libraryRename,
                colorScheme,
                () => _showRenameDialog(audio),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildActionButton(
                audio.isFavorite
                    ? AppIcons.favorite
                    : AppIcons.favoriteOutlined,
                audio.isFavorite
                    ? AppStrings.libraryUnfavorite
                    : AppStrings.libraryFavorite,
                colorScheme,
                () {
                  ref
                      .read(audioDetailProvider(widget.audioId).notifier)
                      .toggleFavorite();
                  _showSnackBar(
                    audio.isFavorite
                        ? AppStrings.audioDetailFavoriteRemoved
                        : AppStrings.audioDetailFavoriteAdded,
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                AppIcons.share,
                AppStrings.generationShare,
                colorScheme,
                () {
                  Share.share(
                    audio.filePath,
                    subject: AppStrings.audioDetailShareTitle,
                    sharePositionOrigin: shareOriginOf(context),
                  );
                },
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildActionButton(
                AppIcons.export,
                AppStrings.libraryExport,
                colorScheme,
                () {
                  _showSnackBar(AppStrings.audioDetailExportSuccess);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          width: double.infinity,
          child: _buildActionButton(
            AppIcons.delete,
            AppStrings.libraryDelete,
            colorScheme,
            () => _showDeleteDialog(audio),
            isDestructive: true,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String label,
    AppColorScheme colorScheme,
    VoidCallback onPressed, {
    bool isDestructive = false,
  }) {
    final color = isDestructive ? colorScheme.error : colorScheme.primary;
    return CupertinoButton(
      onPressed: onPressed,
      color: colorScheme.surface,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      borderRadius: AppRadius.mediumAll,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: AppRadius.mediumAll,
          border: Border.all(color: colorScheme.divider),
        ),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Column(
          children: [
            Icon(icon, color: color, size: AppSizes.iconMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(label, style: AppTypography.bodySmall.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}

class WaveformPainter extends CustomPainter {
  final int audioId;
  final double progress;
  final Color color;
  final Color backgroundColor;

  WaveformPainter({
    required this.audioId,
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final backgroundPaint = Paint()
      ..color = backgroundColor.withOpacity(0.3)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    const barCount = 40;
    final barWidth = size.width / barCount;
    final centerY = size.height / 2;

    final random = Random(audioId);

    for (var i = 0; i < barCount; i++) {
      final x = i * barWidth + barWidth / 2;
      final barHeight =
          random.nextDouble() * size.height * 0.8 + size.height * 0.1;
      final isPlayed = i / barCount <= progress;

      canvas.drawLine(
        Offset(x, centerY - barHeight / 2),
        Offset(x, centerY + barHeight / 2),
        isPlayed ? paint : backgroundPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant WaveformPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.audioId != audioId;
  }
}
