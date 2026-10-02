import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_huluca/core/design_system/design_tokens.dart';
import 'package:voice_huluca/core/localization/app_strings.dart';
import 'package:voice_huluca/data/models/voice.dart';
import 'package:voice_huluca/features/voice/voice_cloning_screen.dart';
import 'package:voice_huluca/features/voice/voice_provider.dart';
import 'package:voice_huluca/features/voice/widgets/record_voice_sheet.dart';
import 'package:voice_huluca/features/voice/widgets/voice_card.dart';

class VoiceSelectorScreen extends ConsumerWidget {
  const VoiceSelectorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(voiceListProvider);
    final notifier = ref.read(voiceListProvider.notifier);

    ref.listen(voiceListProvider, (previous, next) {
      final previewError = next.previewError;
      if (previewError != null && previewError != previous?.previewError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(previewError)));
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _Header(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: _SearchField(
                query: state.searchQuery,
                onChanged: notifier.setSearchQuery,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _FilterChips(
              selected: state.filter,
              onSelected: notifier.setFilter,
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(child: _Body(state: state)),
          ],
        ),
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
                AppStrings.voiceSelectorTitle,
                style: AppTypography.title,
                textAlign: TextAlign.center,
              ),
            ),
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const VoiceCloningScreen()),
                );
              },
              icon: const Icon(AppIcons.add, size: AppSizes.iconMedium),
              label: const Text(AppStrings.voiceSelectorCreateVoice),
              style: TextButton.styleFrom(
                foregroundColor: scheme.primary,
                minimumSize: const Size(0, AppSizes.touchTarget),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.query, required this.onChanged});

  final String query;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = AppColorScheme.of(Theme.of(context).brightness);
    return TextField(
      onChanged: onChanged,
      style: AppTypography.body,
      decoration: InputDecoration(
        hintText: AppStrings.voiceSelectorSearch,
        prefixIcon: Icon(AppIcons.search, color: scheme.textTertiary),
        suffixIcon: query.isEmpty
            ? null
            : IconButton(
                icon: Icon(AppIcons.close, color: scheme.textTertiary),
                onPressed: () => onChanged(''),
              ),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.selected, required this.onSelected});

  final VoiceFilter selected;
  final ValueChanged<VoiceFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    final filters = <(VoiceFilter, String)>[
      (VoiceFilter.all, AppStrings.voiceSelectorFilterAll),
      (VoiceFilter.mine, AppStrings.voiceSelectorFilterMine),
      (VoiceFilter.male, AppStrings.voiceSelectorFilterMale),
      (VoiceFilter.female, AppStrings.voiceSelectorFilterFemale),
      (VoiceFilter.favorites, AppStrings.voiceSelectorFilterFavorites),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          for (final (filter, label) in filters)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: _FilterPill(
                label: label,
                selected: selected == filter,
                onTap: () => onSelected(filter),
              ),
            ),
        ],
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = AppColorScheme.of(Theme.of(context).brightness);
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 36),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: selected ? scheme.primary : scheme.surface,
            borderRadius: AppRadius.pillAll,
            border: Border.all(
              color: selected ? scheme.primary : scheme.divider,
            ),
          ),
          child: Text(
            label,
            maxLines: 1,
            softWrap: false,
            style: AppTypography.bodySmall.copyWith(
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              color: selected ? scheme.onPrimary : scheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.state});

  final VoiceListState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(voiceListProvider.notifier);

    if (state.isLoading && state.voices.isEmpty) {
      return const _LoadingState();
    }
    if (state.error != null && state.voices.isEmpty) {
      return _ErrorState(
        message: state.error!,
        onRetry: () => notifier.loadVoices(),
      );
    }

    final clonedVoices = state.filteredClonedVoices;
    final providerVoices = state.filteredProviderVoices;
    final hasAnyResults = clonedVoices.isNotEmpty || providerVoices.isNotEmpty;

    if (!hasAnyResults) {
      return _EmptyState(
        isMineFilter: state.filter == VoiceFilter.mine,
        supportsCloning: ref.read(activeProviderSupportsCloningProvider),
        onRecordVoice: () => showRecordVoiceSheet(context, ref),
        onCreateVoice: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const VoiceCloningScreen()));
        },
      );
    }

    return RefreshIndicator(
      onRefresh: () => notifier.loadVoices(isRefresh: true),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.xs,
          AppSpacing.lg,
          AppSpacing.xxl,
        ),
        children: [
          if (state.isRefreshing)
            const Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.sm),
              child: _LoadingState(),
            ),
          if (ref.read(activeProviderSupportsCloningProvider))
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _RecordNewVoiceButton(
                onPressed: () => showRecordVoiceSheet(context, ref),
              ),
            ),
          if (clonedVoices.isNotEmpty) ...[
            const _SectionHeader(title: AppStrings.voiceSelectorSectionMine),
            // The section header already says these are the user's own voices.
            ...clonedVoices.map(
              (voice) => _buildCard(context, voice, notifier, showBadge: false),
            ),
          ],
          if (providerVoices.isNotEmpty) ...[
            const _SectionHeader(
              title: AppStrings.voiceSelectorSectionProvider,
            ),
            ...providerVoices.map(
              (voice) => _buildCard(context, voice, notifier),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    Voice voice,
    VoiceListNotifier notifier, {
    bool showBadge = true,
  }) {
    return VoiceCard(
      voice: voice,
      isSelected: state.selectedVoiceId == voice.id,
      isPlaying: state.playingVoiceId == voice.id,
      onTap: () => notifier.selectVoice(voice),
      onPreviewPressed: () => notifier.togglePreview(voice),
      onFavoritePressed: () => notifier.toggleFavorite(voice),
      onMenuSelected: (action) =>
          _handleMenuAction(context, voice, action, notifier),
      onDeletePressed: voice.isCloned
          ? () => _confirmDelete(context, voice, notifier)
          : null,
      showClonedBadge: showBadge,
    );
  }

  Future<void> _handleMenuAction(
    BuildContext context,
    Voice voice,
    VoiceCardMenuAction action,
    VoiceListNotifier notifier,
  ) async {
    switch (action) {
      case VoiceCardMenuAction.select:
        await notifier.selectVoice(voice);
      case VoiceCardMenuAction.preview:
        await notifier.togglePreview(voice);
      case VoiceCardMenuAction.favorite:
        await notifier.toggleFavorite(voice);
      case VoiceCardMenuAction.delete:
        await _confirmDelete(context, voice, notifier);
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    Voice voice,
    VoiceListNotifier notifier,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.voiceSelectorDeleteTitle),
        content: const Text(AppStrings.voiceSelectorDeleteDesc),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(AppStrings.libraryCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: AppColorScheme.of(
                Theme.of(context).brightness,
              ).error,
            ),
            child: const Text(AppStrings.libraryConfirm),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await notifier.deleteVoice(voice);
    }
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final scheme = AppColorScheme.of(Theme.of(context).brightness);
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.lg, bottom: AppSpacing.md),
      child: Text(
        title,
        style: AppTypography.title.copyWith(color: scheme.textPrimary),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    final scheme = AppColorScheme.of(Theme.of(context).brightness);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: AppSpacing.lg),
          Text(
            AppStrings.voiceSelectorLoading,
            style: AppTypography.bodySmall.copyWith(
              color: scheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = AppColorScheme.of(Theme.of(context).brightness);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              AppIcons.errorOutlined,
              size: AppSizes.iconExtraLarge * 1.5,
              color: scheme.error,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              message,
              style: AppTypography.body.copyWith(color: scheme.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(AppIcons.refresh, size: AppSizes.iconMedium),
              label: const Text(AppStrings.voiceSelectorRetry),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecordNewVoiceButton extends StatelessWidget {
  const _RecordNewVoiceButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = AppColorScheme.of(Theme.of(context).brightness);
    return SizedBox(
      width: double.infinity,
      height: AppSizes.buttonLarge,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(AppIcons.mic, size: AppSizes.iconMedium),
        label: Text(
          AppStrings.voiceSelectorRecordNew,
          style: AppTypography.label.copyWith(color: scheme.primary),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          side: BorderSide(color: scheme.primary),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.largeAll),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.isMineFilter,
    required this.onCreateVoice,
    required this.onRecordVoice,
    required this.supportsCloning,
  });

  final bool isMineFilter;
  final VoidCallback onCreateVoice;
  final VoidCallback onRecordVoice;
  final bool supportsCloning;

  @override
  Widget build(BuildContext context) {
    final scheme = AppColorScheme.of(Theme.of(context).brightness);
    final message = isMineFilter
        ? AppStrings.voiceSelectorEmptyMine
        : AppStrings.voiceSelectorNoResults;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isMineFilter ? AppIcons.mic : AppIcons.voice,
              size: AppSizes.iconExtraLarge * 1.5,
              color: scheme.textTertiary,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              message,
              style: AppTypography.body.copyWith(color: scheme.textSecondary),
              textAlign: TextAlign.center,
            ),
            if (isMineFilter) ...[
              const SizedBox(height: AppSpacing.xl),
              if (supportsCloning) ...[
                ElevatedButton.icon(
                  onPressed: onRecordVoice,
                  icon: const Icon(AppIcons.mic, size: AppSizes.iconMedium),
                  label: const Text(AppStrings.voiceSelectorRecordNew),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
              TextButton(
                onPressed: onCreateVoice,
                child: const Text(AppStrings.voiceSelectorCreateVoice),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
