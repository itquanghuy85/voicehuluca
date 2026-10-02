import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/app_constants.dart';
import '../../core/design_system/design_tokens.dart';
import '../../core/localization/app_strings.dart';
import '../../data/models/audio_asset.dart';
import '../audio_detail/audio_detail_screen.dart';
import 'library_provider.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key, this.onCreateFirst});

  final VoidCallback? onCreateFirst;

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(libraryProvider.notifier).loadLibrary();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(libraryProvider.notifier).loadMore();
    }
  }

  String _formatDuration(int milliseconds) {
    final duration = Duration(milliseconds: milliseconds);
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
    return DateFormat('dd/MM/yyyy').format(date);
  }

  void _showRenameDialog(AudioAsset audio) {
    final controller = TextEditingController(text: audio.title);
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text(AppStrings.libraryRenameTitle),
        content: Padding(
          padding: const EdgeInsets.only(top: AppSpacing.md),
          child: CupertinoTextField(
            controller: controller,
            placeholder: AppStrings.libraryRenameHint,
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
              if (controller.text.trim().isNotEmpty) {
                ref
                    .read(libraryProvider.notifier)
                    .renameAudio(audio.id, controller.text.trim());
                Navigator.pop(context);
                _showSnackBar(AppStrings.libraryRenameSuccess);
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
        title: const Text(AppStrings.libraryDeleteConfirm),
        content: const Text(AppStrings.libraryDeleteConfirmDesc),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.libraryCancel),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              ref.read(libraryProvider.notifier).deleteAudio(audio.id);
              Navigator.pop(context);
              _showSnackBar(AppStrings.libraryDeleteSuccess);
            },
            child: const Text(AppStrings.libraryConfirm),
          ),
        ],
      ),
    );
  }

  void _showAudioMenu(AudioAsset audio) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text(audio.title),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _showRenameDialog(audio);
            },
            child: const Text(AppStrings.libraryRename),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              ref.read(libraryProvider.notifier).toggleFavorite(audio.id);
              _showSnackBar(
                audio.isFavorite
                    ? AppStrings.libraryFavoriteRemoved
                    : AppStrings.libraryFavoriteAdded,
              );
            },
            child: Text(
              audio.isFavorite
                  ? AppStrings.libraryUnfavorite
                  : AppStrings.libraryFavorite,
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              Share.share(
                audio.filePath,
                subject: AppStrings.libraryShareTitle,
              );
            },
            child: const Text(AppStrings.generationShare),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar(AppStrings.libraryExportSuccess);
            },
            child: const Text(AppStrings.libraryExport),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              _showDeleteDialog(audio);
            },
            child: const Text(AppStrings.libraryDelete),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text(AppStrings.libraryCancel),
        ),
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
    final state = ref.watch(libraryProvider);
    final colorScheme = AppColorScheme.of(Theme.of(context).brightness);

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(colorScheme),
            _buildSearchField(colorScheme),
            _buildFilterChips(colorScheme),
            Expanded(child: _buildContent(state, colorScheme)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              AppStrings.libraryTitleAudio,
              style: AppTypography.headline.copyWith(
                color: colorScheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(AppColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        height: AppSizes.inputHeight,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: AppRadius.mediumAll,
          border: Border.all(color: colorScheme.divider),
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Icon(
                AppIcons.search,
                color: colorScheme.textTertiary,
                size: AppSizes.iconMedium,
              ),
            ),
            Expanded(
              child: TextField(
                controller: _searchController,
                style: AppTypography.body.copyWith(
                  color: colorScheme.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: AppStrings.librarySearch,
                  hintStyle: AppTypography.body.copyWith(
                    color: colorScheme.textTertiary,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (value) {
                  ref.read(libraryProvider.notifier).setSearchQuery(value);
                },
              ),
            ),
            if (_searchController.text.isNotEmpty)
              CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                minSize: 0,
                onPressed: () {
                  _searchController.clear();
                  ref.read(libraryProvider.notifier).setSearchQuery('');
                },
                child: Icon(
                  AppIcons.close,
                  color: colorScheme.textTertiary,
                  size: AppSizes.iconMedium,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips(AppColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          _buildChip(
            AppStrings.libraryFilterAll,
            LibraryFilter.all,
            colorScheme,
          ),
          const SizedBox(width: AppSpacing.sm),
          _buildChip(
            AppStrings.libraryFilterRecent,
            LibraryFilter.recent,
            colorScheme,
          ),
          const SizedBox(width: AppSpacing.sm),
          _buildChip(
            AppStrings.libraryFilterFavorites,
            LibraryFilter.favorites,
            colorScheme,
          ),
        ],
      ),
    );
  }

  Widget _buildChip(
    String label,
    LibraryFilter filter,
    AppColorScheme colorScheme,
  ) {
    final isSelected = ref.watch(libraryProvider).filter == filter;
    return GestureDetector(
      onTap: () {
        ref.read(libraryProvider.notifier).setFilter(filter);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : colorScheme.surface,
          borderRadius: AppRadius.pillAll,
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.divider,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: isSelected
                ? colorScheme.onPrimary
                : colorScheme.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildContent(LibraryState state, AppColorScheme colorScheme) {
    if (state.isLoading && state.audios.isEmpty) {
      return const Center(child: CupertinoActivityIndicator());
    }

    if (state.error != null && state.audios.isEmpty) {
      return _buildError(state.error!, colorScheme);
    }

    if (state.audios.isEmpty) {
      return _buildEmptyState(colorScheme);
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(libraryProvider.notifier).refreshLibrary(),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: state.audios.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.audios.length) {
            return _buildLoadingMore(colorScheme, state.isLoadingMore);
          }
          return _buildAudioItem(state.audios[index], colorScheme);
        },
      ),
    );
  }

  Widget _buildLoadingMore(AppColorScheme colorScheme, bool isLoadingMore) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Center(
        child: isLoadingMore
            ? const CupertinoActivityIndicator()
            : Text(
                AppStrings.libraryLoadingMore,
                style: AppTypography.bodySmall.copyWith(
                  color: colorScheme.textTertiary,
                ),
              ),
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
              AppStrings.errorUnknown,
              style: AppTypography.body.copyWith(
                color: colorScheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            CupertinoButton(
              onPressed: () {
                ref.read(libraryProvider.notifier).loadLibrary(refresh: true);
              },
              color: colorScheme.primary,
              borderRadius: AppRadius.mediumAll,
              child: const Text(AppStrings.homeRetry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              AppIcons.audio,
              size: AppSizes.iconExtraLarge,
              color: colorScheme.textTertiary,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              AppStrings.libraryEmptyAudio,
              style: AppTypography.title.copyWith(
                color: colorScheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              AppStrings.libraryEmptyAudioHint,
              style: AppTypography.body.copyWith(
                color: colorScheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxl),
            CupertinoButton(
              onPressed: widget.onCreateFirst ?? () {},
              color: colorScheme.primary,
              borderRadius: AppRadius.mediumAll,
              child: Text(
                AppStrings.libraryCreateFirst,
                style: AppTypography.label.copyWith(
                  color: colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioItem(AudioAsset audio, AppColorScheme colorScheme) {
    return Dismissible(
      key: Key(audio.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        decoration: BoxDecoration(
          color: colorScheme.error,
          borderRadius: AppRadius.largeAll,
        ),
        child: Icon(
          AppIcons.delete,
          color: colorScheme.onError,
          size: AppSizes.iconLarge,
        ),
      ),
      confirmDismiss: (direction) async {
        _showDeleteDialog(audio);
        return false;
      },
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => AudioDetailScreen(audioId: audio.id),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: colorScheme.card,
            borderRadius: AppRadius.largeAll,
            border: Border.all(color: colorScheme.divider),
          ),
          child: Row(
            children: [
              _buildPlayButton(audio, colorScheme),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: _buildAudioInfo(audio, colorScheme)),
              _buildMenuButton(audio, colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayButton(AudioAsset audio, AppColorScheme colorScheme) {
    return Container(
      width: AppSizes.touchTarget,
      height: AppSizes.touchTarget,
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: AppRadius.mediumAll,
      ),
      child: Icon(
        AppIcons.play,
        color: colorScheme.primary,
        size: AppSizes.iconMedium,
      ),
    );
  }

  Widget _buildAudioInfo(AudioAsset audio, AppColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          audio.title,
          style: AppTypography.label.copyWith(color: colorScheme.textPrimary),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            Icon(
              AppIcons.waveform,
              size: AppSizes.iconSmall,
              color: colorScheme.textTertiary,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              _formatDuration(audio.durationMs),
              style: AppTypography.bodySmall.copyWith(
                color: colorScheme.textSecondary,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              _formatFileSize(audio.fileSize),
              style: AppTypography.bodySmall.copyWith(
                color: colorScheme.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            Icon(
              AppIcons.voice,
              size: AppSizes.iconSmall,
              color: colorScheme.textTertiary,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              AppStrings.libraryVoiceUnknown,
              style: AppTypography.bodySmall.copyWith(
                color: colorScheme.textTertiary,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              _formatDate(audio.createdAt),
              style: AppTypography.bodySmall.copyWith(
                color: colorScheme.textTertiary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMenuButton(AudioAsset audio, AppColorScheme colorScheme) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minSize: AppSizes.touchTarget,
      onPressed: () => _showAudioMenu(audio),
      child: Icon(
        AppIcons.more,
        color: colorScheme.textSecondary,
        size: AppSizes.iconMedium,
      ),
    );
  }
}
