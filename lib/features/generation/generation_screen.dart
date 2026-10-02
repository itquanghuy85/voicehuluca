import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_huluca/core/constants/app_constants.dart';
import 'package:voice_huluca/core/design_system/design_tokens.dart';
import 'package:voice_huluca/core/localization/app_strings.dart';
import 'package:voice_huluca/features/generation/generation_provider.dart';
import 'package:voice_huluca/features/settings/settings_provider.dart';
import 'package:voice_huluca/features/voice/voice_provider.dart';

class GenerationScreen extends ConsumerWidget {
  const GenerationScreen({super.key, this.onComplete, this.onCancel});

  final VoidCallback? onComplete;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColorScheme.of(Theme.of(context).brightness);
    final state = ref.watch(generationProvider);

    ref.listen(generationProvider, (previous, next) {
      if (previous?.status != GenerationStatus.success &&
          next.status == GenerationStatus.success) {
        onComplete?.call();
      }
      if (next.fallbackProviderId != null &&
          previous?.fallbackProviderId != next.fallbackProviderId) {
        _showProviderFallbackDialog(context, ref);
      }
    });

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            _Header(
              status: state.status,
              onCancel: () => _handleCancel(context, ref),
            ),
            Expanded(
              child: _Body(state: state, onRetry: _handleRetry),
            ),
          ],
        ),
      ),
    );
  }

  /// Asks before switching to the paid provider, so a failure never silently
  /// starts spending the user's ElevenLabs quota.
  Future<void> _showProviderFallbackDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final fallbackId = ref.read(generationProvider).fallbackProviderId;
    if (fallbackId == null) return;

    final registry = ref.read(ttsProviderRegistryProvider);
    final fallbackName = registry.getById(fallbackId)?.name ?? fallbackId;
    final currentName =
        registry.getById(ref.read(ttsProviderIdProvider))?.name ?? fallbackId;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppStrings.providerFallbackTitleFor(fallbackName)),
        content: Text(
          AppStrings.providerFallbackDescFor(currentName, fallbackName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(AppStrings.providerFallbackStay(currentName)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await ref
                  .read(settingsProvider.notifier)
                  .updateTtsProvider(fallbackId);
              final notifier = ref.read(generationProvider.notifier);
              notifier.clearFallbackSuggestion();
              // Voices belong to their provider, so reload before retrying.
              final voices = await ref
                  .read(voiceListProvider.notifier)
                  .loadVoices(isRefresh: true);
              if (voices.isEmpty) return;
              final voice = voices.first;
              await notifier.retryGenerationWithVoice(
                voiceId: voice.providerVoiceId,
                voiceName: voice.name,
                localVoiceId: voice.id,
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColorScheme.of(
                Theme.of(context).brightness,
              ).primary,
            ),
            child: const Text(AppStrings.providerFallbackAccept),
          ),
        ],
      ),
    );

    ref.read(generationProvider.notifier).clearFallbackSuggestion();
  }

  void _handleCancel(BuildContext context, WidgetRef ref) {
    final state = ref.read(generationProvider);
    if (state.isBusy) {
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text(AppStrings.generationCancelConfirmTitle),
          content: const Text(AppStrings.generationCancelConfirmDesc),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(AppStrings.generationKeepWaiting),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                ref.read(generationProvider.notifier).cancelGeneration();
                onCancel?.call();
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColorScheme.of(
                  Theme.of(context).brightness,
                ).error,
              ),
              child: const Text(AppStrings.generationCancelConfirm),
            ),
          ],
        ),
      );
    } else {
      onCancel?.call();
    }
  }

  void _handleRetry(WidgetRef ref) {
    ref.read(generationProvider.notifier).retryGeneration();
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.status, required this.onCancel});

  final GenerationStatus status;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(Theme.of(context).brightness);
    final showCancel =
        status != GenerationStatus.success &&
        status != GenerationStatus.error &&
        status != GenerationStatus.cancelled;

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
              onPressed: onCancel,
            ),
            Expanded(
              child: Text(
                AppStrings.generationScreenTitle,
                style: AppTypography.title,
                textAlign: TextAlign.center,
              ),
            ),
            if (showCancel)
              TextButton(
                onPressed: onCancel,
                style: TextButton.styleFrom(
                  foregroundColor: colors.textSecondary,
                  minimumSize: const Size(0, AppSizes.touchTarget),
                ),
                child: const Text(AppStrings.generationCancel),
              )
            else
              const SizedBox(width: AppSizes.touchTarget),
          ],
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.state, required this.onRetry});

  final GenerationState state;
  final void Function(WidgetRef ref) onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(Theme.of(context).brightness);

    if (state.status == GenerationStatus.error) {
      return _ErrorState(
        message: state.errorMessage ?? AppStrings.errorUnknown,
        onRetry: onRetry,
      );
    }

    if (state.status == GenerationStatus.cancelled) {
      return _CancelledState(onRetry: onRetry);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.xxl),
          _ProgressIndicator(status: state.status),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            state.statusText,
            style: AppTypography.title.copyWith(color: colors.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _statusDescription(state.status),
            style: AppTypography.body.copyWith(color: colors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xxl),
          _InfoCard(state: state),
          const SizedBox(height: AppSpacing.xl),
          _CancelButton(onPressed: state.isBusy ? () {} : null),
        ],
      ),
    );
  }

  String _statusDescription(GenerationStatus status) {
    switch (status) {
      case GenerationStatus.validating:
        return 'Kiểm tra kịch bản và giọng đọc';
      case GenerationStatus.uploading:
        return 'Chuẩn bị dữ liệu gửi lên máy chủ';
      case GenerationStatus.generating:
        return 'AI đang tổng hợp giọng nói tiếng Việt';
      case GenerationStatus.downloading:
        return 'Nhận dữ liệu âm thanh từ máy chủ';
      case GenerationStatus.processing:
        return 'Xử lý và lưu tệp âm thanh';
      default:
        return '';
    }
  }
}

class _ProgressIndicator extends StatelessWidget {
  const _ProgressIndicator({required this.status});

  final GenerationStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(Theme.of(context).brightness);

    return SizedBox(
      width: AppSizes.avatarExtraLarge * 1.5,
      height: AppSizes.avatarExtraLarge * 1.5,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: AppSizes.avatarExtraLarge * 1.5,
            height: AppSizes.avatarExtraLarge * 1.5,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
              backgroundColor: colors.divider,
            ),
          ),
          Container(
            width: AppSizes.avatarExtraLarge * 1.1,
            height: AppSizes.avatarExtraLarge * 1.1,
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _iconForStatus(status),
              color: colors.onPrimaryContainer,
              size: AppSizes.iconExtraLarge,
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconForStatus(GenerationStatus status) {
    switch (status) {
      case GenerationStatus.validating:
        return AppIcons.tune;
      case GenerationStatus.uploading:
        return AppIcons.upload;
      case GenerationStatus.generating:
        return AppIcons.voice;
      case GenerationStatus.downloading:
        return AppIcons.download;
      case GenerationStatus.processing:
        return AppIcons.tune;
      default:
        return AppIcons.mic;
    }
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.state});

  final GenerationState state;

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
            icon: AppIcons.voice,
            label: AppStrings.generationVoiceLabel,
            value: state.voiceName,
          ),
          const SizedBox(height: AppSpacing.md),
          _InfoRow(
            icon: AppIcons.text,
            label: AppStrings.generationCharacterCount,
            value: '${state.characterCount}/${AppConstants.maxScriptLength}',
          ),
        ],
      ),
    );
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
      children: [
        Icon(icon, size: AppSizes.iconMedium, color: colors.primary),
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
              const SizedBox(height: AppSpacing.xs),
              Text(
                value,
                style: AppTypography.label.copyWith(color: colors.textPrimary),
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

class _CancelButton extends StatelessWidget {
  const _CancelButton({required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(Theme.of(context).brightness);

    return SizedBox(
      width: double.infinity,
      height: AppSizes.buttonLarge,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.error,
          side: BorderSide(color: colors.error),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.largeAll),
        ),
        child: const Text(AppStrings.generationCancel),
      ),
    );
  }
}

class _ErrorState extends ConsumerWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final void Function(WidgetRef ref) onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColorScheme.of(Theme.of(context).brightness);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: AppSizes.avatarExtraLarge * 1.5,
              height: AppSizes.avatarExtraLarge * 1.5,
              decoration: BoxDecoration(
                color: colors.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                AppIcons.errorOutlined,
                size: AppSizes.iconExtraLarge * 1.5,
                color: colors.error,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              AppStrings.generationFailed,
              style: AppTypography.title.copyWith(color: colors.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: AppTypography.body.copyWith(color: colors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton.icon(
              onPressed: () => onRetry(ref),
              icon: const Icon(AppIcons.refresh, size: AppSizes.iconMedium),
              label: const Text(AppStrings.generationRetry),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(0, AppSizes.buttonLarge),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CancelledState extends ConsumerWidget {
  const _CancelledState({required this.onRetry});

  final void Function(WidgetRef ref) onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColorScheme.of(Theme.of(context).brightness);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: AppSizes.avatarExtraLarge * 1.5,
              height: AppSizes.avatarExtraLarge * 1.5,
              decoration: BoxDecoration(
                color: colors.secondaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                AppIcons.close,
                size: AppSizes.iconExtraLarge * 1.5,
                color: colors.onSecondaryContainer,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              AppStrings.generationCancelled,
              style: AppTypography.title.copyWith(color: colors.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton.icon(
              onPressed: () => onRetry(ref),
              icon: const Icon(AppIcons.refresh, size: AppSizes.iconMedium),
              label: const Text(AppStrings.generationRetry),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(0, AppSizes.buttonLarge),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
