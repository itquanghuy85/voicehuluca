import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_huluca/core/constants/app_constants.dart';
import 'package:voice_huluca/core/design_system/design_tokens.dart';
import 'package:voice_huluca/core/localization/app_strings.dart';
import 'package:voice_huluca/data/models/voice.dart';
import 'package:voice_huluca/features/home/home_provider.dart';
import 'package:voice_huluca/features/script_editor/script_editor.dart';
import 'package:voice_huluca/features/script_editor/script_editor_provider.dart';
import 'package:voice_huluca/features/audio_library/library_screen.dart';
import 'package:voice_huluca/features/voice/voice_selector_screen.dart';
import 'package:voice_huluca/features/settings/settings_screen.dart';
import 'package:voice_huluca/features/generation/generation_screen.dart';
import 'package:voice_huluca/features/generation/generation_provider.dart';
import 'package:voice_huluca/features/generation/result_screen.dart';
import 'package:voice_huluca/features/voice/voice_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentTab = 0;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(Theme.of(context).brightness);

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: _currentTab,
          children: [
            const _HomeTabContent(),
            _LibraryTabContent(
              isActive: _currentTab == 1,
              onCreateFirst: () => setState(() => _currentTab = 0),
            ),
            const _VoicesTabContent(),
            const _SettingsTabContent(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(colors),
    );
  }

  Widget _buildBottomNav(AppColorScheme colors) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.divider)),
        boxShadow: AppShadows.card,
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: AppSizes.bottomNavHeight,
          child: Row(
            children: [
              _NavItem(
                icon: AppIcons.homeOutlined,
                activeIcon: AppIcons.home,
                label: AppStrings.navHome,
                isSelected: _currentTab == 0,
                onTap: () => setState(() => _currentTab = 0),
              ),
              _NavItem(
                icon: AppIcons.queueOutlined,
                activeIcon: AppIcons.queue,
                label: AppStrings.navLibrary,
                isSelected: _currentTab == 1,
                onTap: () => setState(() => _currentTab = 1),
              ),
              _NavItem(
                icon: AppIcons.voice,
                activeIcon: AppIcons.mic,
                label: AppStrings.navVoices,
                isSelected: _currentTab == 2,
                onTap: () => setState(() => _currentTab = 2),
              ),
              _NavItem(
                icon: AppIcons.settingsOutlined,
                activeIcon: AppIcons.settings,
                label: AppStrings.navSettings,
                isSelected: _currentTab == 3,
                onTap: () => setState(() => _currentTab = 3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(Theme.of(context).brightness);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          constraints: const BoxConstraints(minHeight: AppSizes.touchTarget),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSelected ? activeIcon : icon,
                color: isSelected ? colors.primary : colors.textTertiary,
                size: AppSizes.iconLarge,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                label,
                style: AppTypography.caption.copyWith(
                  color: isSelected ? colors.primary : colors.textTertiary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeTabContent extends ConsumerWidget {
  const _HomeTabContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColorScheme.of(Theme.of(context).brightness);
    final state = ref.watch(homeProvider);
    final scriptText = ref.watch(scriptEditorProvider).text;
    final voiceState = ref.watch(voiceListProvider);
    final selectedVoice = _findSelectedVoice(voiceState);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(colors),
                const SizedBox(height: AppSpacing.xl),
                _buildScriptCard(colors, ref, state),
                const SizedBox(height: AppSpacing.lg),
                _buildQuickActions(context, colors, ref, state),
                const SizedBox(height: AppSpacing.lg),
                _buildVoiceCard(
                  context,
                  colors,
                  ref,
                  voiceState,
                  selectedVoice,
                ),
                const SizedBox(height: AppSpacing.lg),
                _buildSpeedCard(colors, ref, state),
                const SizedBox(height: AppSpacing.xl),
                _buildGenerateButton(
                  context,
                  colors,
                  ref,
                  state,
                  selectedVoice,
                  scriptText,
                ),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Voice? _findSelectedVoice(VoiceListState voiceState) {
    final id = voiceState.selectedVoiceId;
    if (id == null) return null;
    for (final voice in voiceState.voices) {
      if (voice.id == id) return voice;
    }
    return null;
  }

  Widget _buildHeader(AppColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.homeTitle,
          style: AppTypography.headline.copyWith(color: colors.textPrimary),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          AppStrings.homeSubtitle,
          style: AppTypography.body.copyWith(color: colors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildScriptCard(
    AppColorScheme colors,
    WidgetRef ref,
    HomeState state,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: AppRadius.largeAll,
        border: Border.all(color: colors.divider),
        boxShadow: AppShadows.card,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  AppIcons.script,
                  color: colors.primary,
                  size: AppSizes.iconMedium,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  AppStrings.homeScriptLabel,
                  style: AppTypography.title.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            ScriptEditor(
              onTextChanged: (text) {
                ref.read(homeProvider.notifier).updateScriptText(text);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(
    BuildContext context,
    AppColorScheme colors,
    WidgetRef ref,
    HomeState state,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: AppRadius.largeAll,
        border: Border.all(color: colors.divider),
        boxShadow: AppShadows.card,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.homeQuickActions,
              style: AppTypography.title.copyWith(color: colors.textPrimary),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                _QuickActionButton(
                  icon: AppIcons.paste,
                  label: AppStrings.homePasteFromClipboard,
                  onTap: () => _pasteFromClipboard(context, ref),
                ),
                const SizedBox(width: AppSpacing.sm),
                _QuickActionButton(
                  icon: AppIcons.upload,
                  label: AppStrings.homeImportFile,
                  onTap: () => _importFile(context, ref),
                ),
                const SizedBox(width: AppSpacing.sm),
                _QuickActionButton(
                  icon: AppIcons.script,
                  label: AppStrings.homeSampleScript,
                  onTap: () => _loadSampleScript(ref),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceCard(
    BuildContext context,
    AppColorScheme colors,
    WidgetRef ref,
    VoiceListState voiceState,
    Voice? selectedVoice,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: AppRadius.largeAll,
        border: Border.all(color: colors.divider),
        boxShadow: AppShadows.card,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  AppIcons.voice,
                  color: colors.primary,
                  size: AppSizes.iconMedium,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  AppStrings.homeVoiceLabel,
                  style: AppTypography.title.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _buildVoiceSelector(
              context,
              colors,
              ref,
              voiceState,
              selectedVoice,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceSelector(
    BuildContext context,
    AppColorScheme colors,
    WidgetRef ref,
    VoiceListState voiceState,
    Voice? selectedVoice,
  ) {
    if (voiceState.isLoading) {
      return Container(
        height: AppSizes.touchTargetLarge,
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: AppSizes.iconMedium,
              height: AppSizes.iconMedium,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colors.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              AppStrings.homeLoadingVoices,
              style: AppTypography.body.copyWith(color: colors.textSecondary),
            ),
          ],
        ),
      );
    }

    if (voiceState.error != null && voiceState.voices.isEmpty) {
      // The notifier already mapped the failure, so the user sees whether the
      // backend is down, the key is wrong or it is a 5xx. That text is longer
      // than one line, so this block grows instead of clipping it.
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: colors.errorContainer,
          borderRadius: AppRadius.mediumAll,
          border: Border.all(color: colors.error.withValues(alpha: 0.35)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              AppIcons.errorOutlined,
              color: colors.error,
              size: AppSizes.iconMedium,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                voiceState.error!,
                style: AppTypography.bodySmall.copyWith(color: colors.error),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            TextButton(
              onPressed: () =>
                  ref.read(voiceListProvider.notifier).loadVoices(),
              child: const Text(AppStrings.homeRetry),
            ),
          ],
        ),
      );
    }

    final voice = selectedVoice;
    return GestureDetector(
      onTap: () => _showVoicePicker(context, ref, voiceState, selectedVoice),
      child: Container(
        height: AppSizes.touchTargetLarge,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: AppRadius.mediumAll,
          border: Border.all(color: colors.divider),
        ),
        child: Row(
          children: [
            Container(
              width: AppSizes.avatarMedium,
              height: AppSizes.avatarMedium,
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                borderRadius: AppRadius.pillAll,
              ),
              child: Icon(
                voice != null ? AppIcons.voice : AppIcons.micOff,
                color: colors.onPrimaryContainer,
                size: AppSizes.iconMedium,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    voice?.name ?? AppStrings.homeNoVoiceSelected,
                    style: AppTypography.label.copyWith(
                      color: colors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (voice != null)
                    Text(
                      voice.description ?? '',
                      style: AppTypography.caption.copyWith(
                        color: colors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            Icon(
              AppIcons.chevronRight,
              color: colors.textTertiary,
              size: AppSizes.iconMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpeedCard(
    AppColorScheme colors,
    WidgetRef ref,
    HomeState state,
  ) {
    final speeds = ref.watch(availableSpeedsProvider);

    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: AppRadius.largeAll,
        border: Border.all(color: colors.divider),
        boxShadow: AppShadows.card,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  AppIcons.speed,
                  color: colors.primary,
                  size: AppSizes.iconMedium,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  AppStrings.homeSpeedLabel,
                  style: AppTypography.title.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: speeds.map((speed) {
                final isSelected = state.speed == speed;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: speed != speeds.last ? AppSpacing.sm : 0,
                    ),
                    child: GestureDetector(
                      onTap: () =>
                          ref.read(homeProvider.notifier).setSpeed(speed),
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
      ),
    );
  }

  Widget _buildGenerateButton(
    BuildContext context,
    AppColorScheme colors,
    WidgetRef ref,
    HomeState state,
    Voice? selectedVoice,
    String scriptText,
  ) {
    final isOffline = ref.watch(isOfflineProvider).valueOrNull == true;
    final canGenerate =
        scriptText.trim().isNotEmpty &&
        selectedVoice != null &&
        !state.isGenerating &&
        !isOffline;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isOffline)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  AppIcons.warning,
                  size: AppSizes.iconSmall,
                  color: colors.error,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  AppStrings.offlineBadge,
                  style: AppTypography.caption.copyWith(color: colors.error),
                ),
              ],
            ),
          ),
        SizedBox(
          width: double.infinity,
          height: AppSizes.buttonLarge,
          child: ElevatedButton(
            onPressed: canGenerate ? () => _generateVoice(context, ref) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: colors.onPrimary,
              disabledBackgroundColor: colors.disabled,
              disabledForegroundColor: colors.surface,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: AppRadius.largeAll),
            ),
            child: state.isGenerating
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: AppSizes.iconMedium,
                        height: AppSizes.iconMedium,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colors.onPrimary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        AppStrings.homeGenerating,
                        style: AppTypography.label.copyWith(
                          color: colors.onPrimary,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        AppIcons.mic,
                        color: colors.onPrimary,
                        size: AppSizes.iconLarge,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        AppStrings.homeGenerate,
                        style: AppTypography.title.copyWith(
                          color: colors.onPrimary,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> _pasteFromClipboard(BuildContext context, WidgetRef ref) async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data == null || data.text == null || data.text!.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.homePasteFailed),
            duration: AppConstants.snackBarDuration,
          ),
        );
      }
      return;
    }
    ref.read(scriptEditorProvider.notifier).setText(data.text!);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(AppStrings.homePasteSuccess),
          duration: AppConstants.snackBarDuration,
        ),
      );
    }
  }

  Future<void> _importFile(BuildContext context, WidgetRef ref) async {
    String? content;
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) {
        return;
      }

      final file = result.files.first;
      if (file.bytes != null) {
        content = utf8.decode(file.bytes!, allowMalformed: true);
      } else if (file.path != null) {
        content = await File(file.path!).readAsString();
      }
    } catch (_) {
      content = null;
    }

    if (!context.mounted) return;

    if (content == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(AppStrings.homeFileImportFailed),
          duration: AppConstants.snackBarDuration,
        ),
      );
      return;
    }

    if (content.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(AppStrings.editorEmptyScript),
          duration: AppConstants.snackBarDuration,
        ),
      );
      return;
    }

    if (content.length > AppConstants.maxScriptLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(AppStrings.editorScriptTooLong),
          duration: AppConstants.snackBarDuration,
        ),
      );
      return;
    }

    ref.read(scriptEditorProvider.notifier).setText(content);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(AppStrings.homeFileImportSuccess),
        duration: AppConstants.snackBarDuration,
      ),
    );
  }

  void _loadSampleScript(WidgetRef ref) {
    ref
        .read(scriptEditorProvider.notifier)
        .setText(AppStrings.homeSampleScriptContent);
  }

  void _showVoicePicker(
    BuildContext context,
    WidgetRef ref,
    VoiceListState voiceState,
    Voice? selectedVoice,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _VoicePickerSheet(
        voices: voiceState.voices,
        selectedVoice: selectedVoice,
        onVoiceSelected: (voice) {
          ref.read(voiceListProvider.notifier).selectVoice(voice);
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _generateVoice(BuildContext context, WidgetRef ref) async {
    final state = ref.read(homeProvider);
    final scriptText = ref.read(scriptEditorProvider).text;
    final voiceState = ref.read(voiceListProvider);
    final selectedVoice = _findSelectedVoice(voiceState);

    if (scriptText.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(AppStrings.homeEmptyScriptError),
          duration: AppConstants.snackBarDuration,
        ),
      );
      return;
    }

    if (selectedVoice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(AppStrings.homeVoiceRequiredError),
          duration: AppConstants.snackBarDuration,
        ),
      );
      return;
    }

    final voice = selectedVoice;
    final voiceId = voice.providerVoiceId;
    final voiceName = voice.name;
    final speed = state.speed;

    if (!context.mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GenerationScreen(
          onComplete: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const ResultScreen()));
          },
          onCancel: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
    );

    await ref
        .read(generationProvider.notifier)
        .startGeneration(
          text: scriptText.trim(),
          voiceId: voiceId,
          voiceName: voiceName,
          localVoiceId: voice.id,
          speed: speed,
        );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(Theme.of(context).brightness);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          constraints: BoxConstraints(minHeight: AppSizes.buttonLarge),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xs,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: AppRadius.mediumAll,
            border: Border.all(color: colors.divider),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VoicePickerSheet extends StatelessWidget {
  const _VoicePickerSheet({
    required this.voices,
    required this.selectedVoice,
    required this.onVoiceSelected,
  });

  final List<Voice> voices;
  final Voice? selectedVoice;
  final ValueChanged<Voice> onVoiceSelected;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(Theme.of(context).brightness);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppRadius.extraLarge),
          topRight: Radius.circular(AppRadius.extraLarge),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppSpacing.md),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colors.divider,
              borderRadius: AppRadius.pillAll,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                AppStrings.voiceSelectorTitle,
                style: AppTypography.title.copyWith(color: colors.textPrimary),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              itemCount: voices.length,
              itemBuilder: (context, index) {
                final voice = voices[index];
                final isSelected = selectedVoice?.id == voice.id;
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: GestureDetector(
                    onTap: () => onVoiceSelected(voice),
                    child: Container(
                      height: AppSizes.listTileHeight,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colors.primaryContainer
                            : colors.card,
                        borderRadius: AppRadius.mediumAll,
                        border: Border.all(
                          color: isSelected ? colors.primary : colors.divider,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: AppSizes.avatarSmall,
                            height: AppSizes.avatarSmall,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? colors.primary
                                  : colors.secondaryContainer,
                              borderRadius: AppRadius.pillAll,
                            ),
                            child: Icon(
                              AppIcons.voice,
                              color: isSelected
                                  ? colors.onPrimary
                                  : colors.onSecondaryContainer,
                              size: AppSizes.iconSmall,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  voice.name,
                                  style: AppTypography.label.copyWith(
                                    color: colors.textPrimary,
                                  ),
                                ),
                                if (voice.description != null)
                                  Text(
                                    voice.description!,
                                    style: AppTypography.caption.copyWith(
                                      color: colors.textSecondary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              AppIcons.check,
                              color: colors.primary,
                              size: AppSizes.iconMedium,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

class _LibraryTabContent extends StatelessWidget {
  const _LibraryTabContent({
    required this.isActive,
    required this.onCreateFirst,
  });

  final bool isActive;
  final VoidCallback onCreateFirst;

  @override
  Widget build(BuildContext context) {
    return LibraryScreen(isActive: isActive, onCreateFirst: onCreateFirst);
  }
}

class _VoicesTabContent extends StatelessWidget {
  const _VoicesTabContent();

  @override
  Widget build(BuildContext context) {
    return const VoiceSelectorScreen();
  }
}

class _SettingsTabContent extends StatelessWidget {
  const _SettingsTabContent();

  @override
  Widget build(BuildContext context) {
    return const SettingsScreen();
  }
}
