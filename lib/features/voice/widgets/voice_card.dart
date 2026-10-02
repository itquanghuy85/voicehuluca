import 'package:flutter/material.dart';
import 'package:voice_huluca/core/design_system/design_tokens.dart';
import 'package:voice_huluca/core/localization/app_strings.dart';
import 'package:voice_huluca/data/models/voice.dart';

enum VoiceCardMenuAction { select, preview, favorite, delete }

class VoiceCard extends StatelessWidget {
  const VoiceCard({
    super.key,
    required this.voice,
    required this.isSelected,
    required this.isPlaying,
    this.isLoadingPreview = false,
    required this.onTap,
    required this.onPreviewPressed,
    required this.onFavoritePressed,
    required this.onMenuSelected,
    this.onDeletePressed,
    this.showClonedBadge = true,
  });

  final Voice voice;
  final bool isSelected;
  final bool isPlaying;
  final bool isLoadingPreview;
  final VoidCallback onTap;
  final VoidCallback onPreviewPressed;
  final VoidCallback onFavoritePressed;
  final ValueChanged<VoiceCardMenuAction> onMenuSelected;
  final VoidCallback? onDeletePressed;

  /// Off when the card already sits under a "Giọng của tôi" header: the row is
  /// narrow, and the badge would only squeeze the name.
  final bool showClonedBadge;

  Color _avatarColor(Brightness brightness) {
    final scheme = AppColorScheme.of(brightness);
    final gender = voice.gender.toLowerCase();
    if (gender == 'male') return scheme.info;
    if (gender == 'female') return scheme.secondary;
    return scheme.primary;
  }

  String get _initial =>
      voice.name.trim().isEmpty ? '?' : voice.name.trim()[0].toUpperCase();

  String _genderLabel(Brightness brightness) {
    final gender = voice.gender.toLowerCase();
    if (gender == 'male') return AppStrings.voiceSelectorMale;
    if (gender == 'female') return AppStrings.voiceSelectorFemale;
    return voice.language.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final scheme = AppColorScheme.of(brightness);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.card,
        borderRadius: AppRadius.largeAll,
        border: Border.all(
          color: isSelected ? scheme.primary : scheme.divider,
          width: isSelected ? AppSizes.borderWidthThick : AppSizes.borderWidth,
        ),
        boxShadow: brightness == Brightness.dark
            ? AppShadows.cardDark
            : AppShadows.card,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.largeAll,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                _buildAvatar(brightness),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: _buildInfo(brightness)),
                const SizedBox(width: AppSpacing.sm),
                _buildActions(brightness),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(Brightness brightness) {
    final scheme = AppColorScheme.of(brightness);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: AppSizes.avatarLarge,
          height: AppSizes.avatarLarge,
          decoration: BoxDecoration(
            color: _avatarColor(brightness).withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            _initial,
            style: AppTypography.title.copyWith(
              color: _avatarColor(brightness),
            ),
          ),
        ),
        if (isSelected)
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              width: AppSizes.iconMedium + 4,
              height: AppSizes.iconMedium + 4,
              decoration: BoxDecoration(
                color: scheme.primary,
                shape: BoxShape.circle,
                border: Border.all(color: scheme.card, width: 2),
              ),
              child: const Icon(
                AppIcons.check,
                size: AppSizes.iconSmall,
                color: AppColors.onPrimary,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfo(Brightness brightness) {
    final scheme = AppColorScheme.of(brightness);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // The avatar already shows a check when selected, so the name gets the
        // full width instead of competing with a label.
        Text(
          voice.name,
          style: AppTypography.label.copyWith(color: scheme.textPrimary),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (voice.description != null && voice.description!.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            voice.description!,
            style: AppTypography.bodySmall.copyWith(
              color: scheme.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.xs,
          children: [
            _buildTag(
              brightness,
              AppIcons.language,
              voice.language.toUpperCase(),
            ),
            _buildTag(brightness, null, _genderLabel(brightness)),
            if (voice.isCloned && showClonedBadge)
              _buildTag(
                brightness,
                AppIcons.voice,
                AppStrings.voiceSelectorClonedBadge,
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildTag(Brightness brightness, IconData? icon, String label) {
    final scheme = AppColorScheme.of(brightness);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: AppRadius.pillAll,
        border: Border.all(color: scheme.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: scheme.textTertiary),
            const SizedBox(width: AppSpacing.xs),
          ],
          // A narrow card must ellipsize the label, never overflow.
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.caption.copyWith(color: scheme.textTertiary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(Brightness brightness) {
    final scheme = AppColorScheme.of(brightness);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _IconButton(
          icon: isPlaying ? AppIcons.pause : AppIcons.play,
          color: isPlaying ? scheme.primary : scheme.textSecondary,
          tooltip: isPlaying
              ? AppStrings.generationPause
              : AppStrings.voiceSelectorPreview,
          onPressed: isLoadingPreview ? null : onPreviewPressed,
          showSpinner: isLoadingPreview,
        ),
        _IconButton(
          icon: voice.isFavorite
              ? AppIcons.favorite
              : AppIcons.favoriteOutlined,
          color: voice.isFavorite ? scheme.error : scheme.textSecondary,
          tooltip: voice.isFavorite
              ? AppStrings.voiceSelectorMenuUnfavorite
              : AppStrings.voiceSelectorMenuFavorite,
          onPressed: onFavoritePressed,
        ),
        PopupMenuButton<VoiceCardMenuAction>(
          icon: Icon(AppIcons.more, color: scheme.textSecondary),
          tooltip: AppStrings.voiceSelectorMenuSelect,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.mediumAll),
          onSelected: onMenuSelected,
          itemBuilder: (context) => [
            PopupMenuItem(
              value: VoiceCardMenuAction.select,
              child: Row(
                children: [
                  Icon(
                    AppIcons.check,
                    size: AppSizes.iconMedium,
                    color: scheme.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    AppStrings.voiceSelectorMenuSelect,
                    style: AppTypography.body,
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: VoiceCardMenuAction.preview,
              child: Row(
                children: [
                  Icon(
                    AppIcons.play,
                    size: AppSizes.iconMedium,
                    color: scheme.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    AppStrings.voiceSelectorMenuPreview,
                    style: AppTypography.body,
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: VoiceCardMenuAction.favorite,
              child: Row(
                children: [
                  Icon(
                    voice.isFavorite
                        ? AppIcons.favoriteOutlined
                        : AppIcons.favorite,
                    size: AppSizes.iconMedium,
                    color: scheme.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    voice.isFavorite
                        ? AppStrings.voiceSelectorMenuUnfavorite
                        : AppStrings.voiceSelectorMenuFavorite,
                    style: AppTypography.body,
                  ),
                ],
              ),
            ),
            if (voice.isCloned && onDeletePressed != null)
              PopupMenuItem(
                value: VoiceCardMenuAction.delete,
                child: Row(
                  children: [
                    Icon(
                      AppIcons.delete,
                      size: AppSizes.iconMedium,
                      color: scheme.error,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Text(
                      AppStrings.voiceSelectorMenuDelete,
                      style: AppTypography.body.copyWith(color: scheme.error),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onPressed,
    this.showSpinner = false,
  });

  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool showSpinner;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: showSpinner
          ? SizedBox(
              width: AppSizes.touchTarget - AppSpacing.sm,
              height: AppSizes.touchTarget - AppSpacing.sm,
              child: CircularProgressIndicator(strokeWidth: 2.5, color: color),
            )
          : Icon(icon),
      color: color,
      iconSize: AppSizes.iconMedium,
      constraints: const BoxConstraints(
        minWidth: AppSizes.touchTarget,
        minHeight: AppSizes.touchTarget,
      ),
      padding: EdgeInsets.zero,
      tooltip: tooltip,
      onPressed: onPressed,
    );
  }
}
