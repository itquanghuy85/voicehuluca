import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:voice_huluca/core/constants/app_constants.dart';
import 'package:voice_huluca/core/design_system/design_tokens.dart';
import 'package:voice_huluca/core/localization/app_strings.dart';
import 'package:voice_huluca/core/storage/audio_export_service.dart';
import 'package:voice_huluca/core/utils/share_origin.dart';
import 'package:voice_huluca/domain/entities/audio_asset.dart';
import 'package:voice_huluca/features/generation/generation_provider.dart';

class ResultScreen extends ConsumerStatefulWidget {
  const ResultScreen({super.key});

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  double _playbackSpeed = 1.0;
  bool _isLoadingAudio = true;
  String? _playbackError;

  static const List<double> _speeds = [0.5, 0.75, 1.0, 1.25, 1.5];

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    final asset = ref.read(generationProvider).audioAsset;
    if (asset == null) {
      setState(() => _isLoadingAudio = false);
      return;
    }

    _duration = asset.duration;

    try {
      if (asset.filePath.isNotEmpty && !asset.filePath.startsWith('http')) {
        final file = File(asset.filePath);
        if (await file.exists()) {
          await _player.setFilePath(file.path);
        }
      } else if (asset.filePath.startsWith('http')) {
        await _player.setUrl(asset.filePath);
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _playbackError = AppStrings.resultPlaybackError;
          _isLoadingAudio = false;
        });
      }
      return;
    }

    _player.playerStateStream.listen((playerState) {
      if (!mounted) return;
      setState(() {
        _isPlaying = playerState.playing;
        if (playerState.processingState == ProcessingState.completed) {
          _isPlaying = false;
          _position = _duration;
        }
      });
    });

    _player.positionStream.listen((position) {
      if (!mounted) return;
      setState(() => _position = position);
    });

    _player.durationStream.listen((duration) {
      if (!mounted || duration == null) return;
      setState(() => _duration = duration);
    });

    if (mounted) {
      setState(() => _isLoadingAudio = false);
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _togglePlayPause() async {
    if (_playbackError != null) return;
    try {
      if (_isPlaying) {
        await _player.pause();
      } else {
        if (_position >= _duration && _duration > Duration.zero) {
          await _player.seek(Duration.zero);
        }
        await _player.play();
      }
    } catch (_) {
      if (mounted) {
        setState(() => _playbackError = AppStrings.resultPlaybackError);
      }
    }
  }

  Future<void> _seekBy(Duration offset) async {
    final target = _position + offset;
    final clamped = target < Duration.zero
        ? Duration.zero
        : (target > _duration ? _duration : target);
    await _player.seek(clamped);
  }

  Future<void> _setSpeed(double speed) async {
    setState(() => _playbackSpeed = speed);
    await _player.setSpeed(speed);
  }

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

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    return '$hour:$minute $day/${month}/${dateTime.year}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(Theme.of(context).brightness);
    final state = ref.watch(generationProvider);
    final asset = state.audioAsset;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            _Header(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.lg,
                  AppSpacing.xxl,
                ),
                children: [
                  _SuccessBanner(),
                  const SizedBox(height: AppSpacing.lg),
                  if (asset != null) ...[
                    _FileInfoCard(
                      asset: asset,
                      voiceName: state.voiceName,
                      formatTime: _formatTime,
                      formatFileSize: _formatFileSize,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _WaveformCard(
                      asset: asset,
                      position: _position,
                      duration: _duration,
                      isPlaying: _isPlaying,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _PlayerCard(
                      isPlaying: _isPlaying,
                      isLoading: _isLoadingAudio,
                      playbackError: _playbackError,
                      position: _position,
                      duration: _duration,
                      formatDuration: _formatDuration,
                      onPlayPause: _togglePlayPause,
                      onSeekBy: _seekBy,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _SpeedSelector(
                      speeds: _speeds,
                      selected: _playbackSpeed,
                      onSelected: _setSpeed,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _DownloadButton(asset: asset),
                    const SizedBox(height: AppSpacing.md),
                    _SecondaryActions(asset: asset),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(Theme.of(context).brightness);
    return SizedBox(
      height: AppSizes.appBarHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        child: Row(
          children: [
            IconButton(
              icon: Icon(AppIcons.arrowBack, color: colors.textPrimary),
              constraints: const BoxConstraints(
                minWidth: AppSizes.touchTarget,
                minHeight: AppSizes.touchTarget,
              ),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            Expanded(
              child: Text(
                AppStrings.resultTitle,
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

class _SuccessBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(Theme.of(context).brightness);
    return Container(
      width: double.infinity,
      padding: AppSpacing.lgAll,
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: AppRadius.largeAll,
        border: Border.all(color: colors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: AppSizes.avatarMedium,
            height: AppSizes.avatarMedium,
            decoration: BoxDecoration(
              color: colors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              AppIcons.check,
              color: AppColors.onPrimary,
              size: AppSizes.iconMedium,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.resultSuccess,
                  style: AppTypography.label.copyWith(
                    color: colors.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  AppStrings.generationComplete,
                  style: AppTypography.caption.copyWith(
                    color: colors.onPrimaryContainer.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FileInfoCard extends StatelessWidget {
  const _FileInfoCard({
    required this.asset,
    required this.voiceName,
    required this.formatTime,
    required this.formatFileSize,
  });

  final AudioAsset asset;
  final String voiceName;
  final String Function(DateTime) formatTime;
  final String Function(int) formatFileSize;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(Theme.of(context).brightness);

    return Container(
      width: double.infinity,
      padding: AppSpacing.lgAll,
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: AppRadius.largeAll,
        border: Border.all(color: colors.divider),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          _InfoRow(
            icon: AppIcons.audio,
            label: AppStrings.resultFileName,
            value: asset.fileName,
          ),
          const SizedBox(height: AppSpacing.md),
          _InfoRow(
            icon: AppIcons.history,
            label: AppStrings.resultDuration,
            value: _formatAssetDuration(asset.duration),
          ),
          const SizedBox(height: AppSpacing.md),
          _InfoRow(
            icon: AppIcons.tune,
            label: AppStrings.resultFileSize,
            value: formatFileSize(asset.fileSizeBytes),
          ),
          const SizedBox(height: AppSpacing.md),
          _InfoRow(
            icon: AppIcons.queue,
            label: AppStrings.resultFormat,
            value: asset.format.toUpperCase(),
          ),
          const SizedBox(height: AppSpacing.md),
          _InfoRow(
            icon: AppIcons.voice,
            label: AppStrings.resultVoice,
            value: voiceName,
          ),
          const SizedBox(height: AppSpacing.md),
          _InfoRow(
            icon: AppIcons.history,
            label: AppStrings.resultCreatedAt,
            value: formatTime(asset.createdAt),
          ),
        ],
      ),
    );
  }

  String _formatAssetDuration(Duration duration) {
    if (duration == Duration.zero) return '--:--';
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(Theme.of(context).brightness);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: AppSizes.iconSmall, color: colors.textTertiary),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.caption.copyWith(
                  color: colors.textTertiary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTypography.bodySmall.copyWith(
                  color: colors.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WaveformCard extends StatelessWidget {
  const _WaveformCard({
    required this.asset,
    required this.position,
    required this.duration,
    required this.isPlaying,
  });

  final AudioAsset asset;
  final Duration position;
  final Duration duration;
  final bool isPlaying;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(Theme.of(context).brightness);
    final progress = duration.inMilliseconds > 0
        ? (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      width: double.infinity,
      padding: AppSpacing.lgAll,
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: AppRadius.largeAll,
        border: Border.all(color: colors.divider),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                AppIcons.waveform,
                size: AppSizes.iconMedium,
                color: colors.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                AppStrings.generationProgress,
                style: AppTypography.label.copyWith(color: colors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _WaveformView(
            seed: asset.id.hashCode,
            progress: progress,
            isPlaying: isPlaying,
          ),
        ],
      ),
    );
  }
}

class _WaveformView extends StatelessWidget {
  const _WaveformView({
    required this.seed,
    required this.progress,
    required this.isPlaying,
  });

  final int seed;
  final double progress;
  final bool isPlaying;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(Theme.of(context).brightness);
    const barCount = 48;
    final random = math.Random(seed);

    return SizedBox(
      height: 72,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(barCount, (index) {
          final baseHeight = 0.15 + random.nextDouble() * 0.85;
          final isPlayed = index / barCount <= progress;
          return AnimatedContainer(
            duration: isPlaying
                ? const Duration(milliseconds: 120)
                : Duration.zero,
            width: 3,
            height: 4 + baseHeight * 64,
            margin: const EdgeInsets.symmetric(horizontal: 1.5),
            decoration: BoxDecoration(
              color: isPlayed ? colors.primary : colors.divider,
              borderRadius: AppRadius.pillAll,
            ),
          );
        }),
      ),
    );
  }
}

class _PlayerCard extends StatelessWidget {
  const _PlayerCard({
    required this.isPlaying,
    required this.isLoading,
    required this.playbackError,
    required this.position,
    required this.duration,
    required this.formatDuration,
    required this.onPlayPause,
    required this.onSeekBy,
  });

  final bool isPlaying;
  final bool isLoading;
  final String? playbackError;
  final Duration position;
  final Duration duration;
  final String Function(Duration) formatDuration;
  final VoidCallback onPlayPause;
  final Future<void> Function(Duration) onSeekBy;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(Theme.of(context).brightness);
    final maxMs = duration.inMilliseconds.toDouble();
    final posMs = position.inMilliseconds
        .toDouble()
        .clamp(0.0, maxMs)
        .toDouble();

    return Container(
      width: double.infinity,
      padding: AppSpacing.lgAll,
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: AppRadius.largeAll,
        border: Border.all(color: colors.divider),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                AppIcons.play,
                size: AppSizes.iconMedium,
                color: colors.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                AppStrings.generationPlay,
                style: AppTypography.label.copyWith(color: colors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (playbackError != null)
            Text(
              playbackError!,
              style: AppTypography.bodySmall.copyWith(color: colors.error),
              textAlign: TextAlign.center,
            )
          else ...[
            Row(
              children: [
                Text(
                  formatDuration(position),
                  style: AppTypography.caption.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                Expanded(
                  child: SliderTheme(
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
                      value: maxMs > 0 ? posMs : 0.0,
                      max: maxMs > 0 ? maxMs : 1.0,
                      onChanged: maxMs > 0
                          ? (value) async {
                              await onSeekBy(
                                Duration(milliseconds: value.round()) -
                                    position,
                              );
                            }
                          : null,
                    ),
                  ),
                ),
                Text(
                  formatDuration(duration),
                  style: AppTypography.caption.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _PlayerActionButton(
                  icon: Icons.history,
                  label: AppStrings.resultBack15s,
                  onPressed: () => onSeekBy(const Duration(seconds: -15)),
                ),
                const SizedBox(width: AppSpacing.lg),
                _PlayPauseButton(
                  isPlaying: isPlaying,
                  isLoading: isLoading,
                  onPressed: onPlayPause,
                ),
                const SizedBox(width: AppSpacing.lg),
                _PlayerActionButton(
                  icon: Icons.fast_forward,
                  label: AppStrings.resultForward15s,
                  onPressed: () => onSeekBy(const Duration(seconds: 15)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _PlayerActionButton extends StatelessWidget {
  const _PlayerActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(Theme.of(context).brightness);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: AppSizes.touchTargetLarge,
          height: AppSizes.touchTargetLarge,
          child: IconButton(
            icon: Icon(icon, color: colors.textPrimary),
            onPressed: onPressed,
            constraints: const BoxConstraints(
              minWidth: AppSizes.touchTarget,
              minHeight: AppSizes.touchTarget,
            ),
          ),
        ),
        Text(
          label,
          style: AppTypography.caption.copyWith(color: colors.textTertiary),
        ),
      ],
    );
  }
}

class _PlayPauseButton extends StatelessWidget {
  const _PlayPauseButton({
    required this.isPlaying,
    required this.isLoading,
    required this.onPressed,
  });

  final bool isPlaying;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(Theme.of(context).brightness);
    return SizedBox(
      width: AppSizes.fabSize,
      height: AppSizes.fabSize,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          shape: const CircleBorder(),
          padding: EdgeInsets.zero,
          elevation: 0,
        ),
        child: isLoading
            ? SizedBox(
                width: AppSizes.iconMedium,
                height: AppSizes.iconMedium,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(colors.onPrimary),
                ),
              )
            : Icon(
                isPlaying ? AppIcons.pause : AppIcons.play,
                size: AppSizes.iconExtraLarge,
              ),
      ),
    );
  }
}

class _SpeedSelector extends StatelessWidget {
  const _SpeedSelector({
    required this.speeds,
    required this.selected,
    required this.onSelected,
  });

  final List<double> speeds;
  final double selected;
  final ValueChanged<double> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(Theme.of(context).brightness);
    return Container(
      width: double.infinity,
      padding: AppSpacing.lgAll,
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: AppRadius.largeAll,
        border: Border.all(color: colors.divider),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                AppIcons.speed,
                size: AppSizes.iconMedium,
                color: colors.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                AppStrings.resultSpeedLabel,
                style: AppTypography.label.copyWith(color: colors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: speeds.map((speed) {
              final isSelected = (speed - selected).abs() < 0.01;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: speed != speeds.last ? AppSpacing.sm : 0,
                  ),
                  child: GestureDetector(
                    onTap: () => onSelected(speed),
                    child: Container(
                      height: AppSizes.buttonMedium,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected ? colors.primary : colors.surface,
                        borderRadius: AppRadius.mediumAll,
                        border: Border.all(
                          color: isSelected ? colors.primary : colors.divider,
                        ),
                      ),
                      child: Text(
                        '${speed}x',
                        style: AppTypography.label.copyWith(
                          color: isSelected
                              ? colors.onPrimary
                              : colors.textSecondary,
                        ),
                      ),
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
}

class _DownloadButton extends ConsumerWidget {
  const _DownloadButton({required this.asset});

  final AudioAsset asset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColorScheme.of(Theme.of(context).brightness);

    return SizedBox(
      width: double.infinity,
      height: AppSizes.buttonLarge,
      child: ElevatedButton.icon(
        onPressed: () => _download(context, ref, 'mp3'),
        icon: const Icon(AppIcons.download, size: AppSizes.iconLarge),
        label: const Text(AppStrings.resultDownloadMp3),
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.largeAll),
        ),
      ),
    );
  }

  Future<void> _download(
    BuildContext context,
    WidgetRef ref,
    String format,
  ) async {
    final colors = AppColorScheme.of(Theme.of(context).brightness);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(AppStrings.resultDownloadStarted),
        duration: AppConstants.snackBarDuration,
      ),
    );

    try {
      final directory = await getTemporaryDirectory();
      final fileName = p.basenameWithoutExtension(asset.fileName);
      final exportName = '$fileName.$format';
      final targetPath = p.join(directory.path, exportName);
      final targetFile = File(targetPath);
      await targetFile.parent.create(recursive: true);

      if (asset.filePath.startsWith('http')) {
        final dio = ref.read(dioProvider);
        final response = await dio.download(asset.filePath, targetPath);
        if (response.statusCode != 200) {
          throw Exception('Download failed');
        }
      } else {
        final sourceFile = File(asset.filePath);
        if (await sourceFile.exists()) {
          await sourceFile.copy(targetPath);
        } else {
          throw Exception('Source file not found');
        }
      }

      final saved = await AudioExportService.exportToDownloads(
        sourcePath: targetPath,
        fileName: exportName,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.resultSavedTo(saved.location)),
            duration: AppConstants.snackBarDuration,
            backgroundColor: colors.success,
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(AppStrings.errorDownloadFailed),
            duration: AppConstants.snackBarDuration,
            backgroundColor: colors.error,
          ),
        );
      }
    }
  }
}

class _SecondaryActions extends ConsumerWidget {
  const _SecondaryActions({required this.asset});

  final AudioAsset asset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        _SecondaryButton(
          icon: AppIcons.download,
          label: AppStrings.resultDownloadWav,
          onPressed: () => _downloadWav(context, ref),
        ),
        const SizedBox(width: AppSpacing.sm),
        _SecondaryButton(
          icon: AppIcons.share,
          label: AppStrings.resultShare,
          onPressed: () => _share(context, ref),
        ),
        const SizedBox(width: AppSpacing.sm),
        _SecondaryButton(
          icon: AppIcons.saveOutlined,
          label: AppStrings.resultKeep,
          onPressed: () => _keep(context, ref),
        ),
        const SizedBox(width: AppSpacing.sm),
        _SecondaryButton(
          icon: AppIcons.refresh,
          label: AppStrings.resultRegenerate,
          onPressed: () => _regenerate(context, ref),
        ),
      ],
    );
  }

  Future<void> _downloadWav(BuildContext context, WidgetRef ref) async {
    final colors = AppColorScheme.of(Theme.of(context).brightness);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(AppStrings.resultDownloadStarted),
        duration: AppConstants.snackBarDuration,
      ),
    );

    try {
      final directory = await getTemporaryDirectory();
      final fileName = p.basenameWithoutExtension(asset.fileName);
      final exportName = '$fileName.wav';
      final targetPath = p.join(directory.path, exportName);
      final targetFile = File(targetPath);
      await targetFile.parent.create(recursive: true);

      if (asset.filePath.startsWith('http')) {
        final dio = ref.read(dioProvider);
        await dio.download(asset.filePath, targetPath);
      } else {
        final sourceFile = File(asset.filePath);
        if (await sourceFile.exists()) {
          await sourceFile.copy(targetPath);
        } else {
          throw Exception('Source file not found');
        }
      }

      final saved = await AudioExportService.exportToDownloads(
        sourcePath: targetPath,
        fileName: exportName,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.resultSavedTo(saved.location)),
            duration: AppConstants.snackBarDuration,
            backgroundColor: colors.success,
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(AppStrings.errorDownloadFailed),
            duration: AppConstants.snackBarDuration,
            backgroundColor: colors.error,
          ),
        );
      }
    }
  }

  Future<void> _share(BuildContext context, WidgetRef ref) async {
    final colors = AppColorScheme.of(Theme.of(context).brightness);
    // Read before the first await: iPad needs the anchor and the context must
    // not be touched again once this method has yielded.
    final shareOrigin = shareOriginOf(context);
    try {
      final file = File(asset.filePath);
      if (await file.exists()) {
        await Share.shareXFiles([
          XFile(file.path),
        ], text: AppStrings.resultSuccess, sharePositionOrigin: shareOrigin);
      } else {
        await Share.share(
          '${AppStrings.resultSuccess}\n${asset.fileName}',
          sharePositionOrigin: shareOrigin,
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(AppStrings.errorShareFailed),
            duration: AppConstants.snackBarDuration,
            backgroundColor: colors.error,
          ),
        );
      }
    }
  }

  void _keep(BuildContext context, WidgetRef ref) {
    ref.read(generationProvider.notifier).reset();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _regenerate(BuildContext context, WidgetRef ref) {
    ref.read(generationProvider.notifier).reset();
    Navigator.of(context).pop();
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(Theme.of(context).brightness);
    return Expanded(
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          height: AppSizes.buttonLarge + AppSpacing.lg,
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: AppRadius.mediumAll,
            border: Border.all(color: colors.divider),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: colors.primary, size: AppSizes.iconMedium),
              const SizedBox(height: AppSpacing.xs),
              Text(
                label,
                style: AppTypography.caption.copyWith(
                  color: colors.textSecondary,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
