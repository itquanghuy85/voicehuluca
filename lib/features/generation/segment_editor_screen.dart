import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:uuid/uuid.dart';
import 'package:voice_huluca/core/constants/app_constants.dart';
import 'package:voice_huluca/core/design_system/design_tokens.dart';
import 'package:voice_huluca/core/localization/app_strings.dart';
import 'package:voice_huluca/data/services/tts_provider.dart';
import 'package:voice_huluca/domain/usecases/synthesize_text.dart';
import 'package:voice_huluca/features/generation/generation_provider.dart';
import 'package:voice_huluca/features/voice/voice_provider.dart';

enum SegmentStatus { idle, generating, ready, error }

class ScriptSegment {
  final String id;
  final int sortOrder;
  final String text;
  final Duration duration;
  final SegmentStatus status;
  final String? errorMessage;
  final String? audioFilePath;

  const ScriptSegment({
    required this.id,
    required this.sortOrder,
    required this.text,
    this.duration = Duration.zero,
    this.status = SegmentStatus.idle,
    this.errorMessage,
    this.audioFilePath,
  });

  ScriptSegment copyWith({
    String? id,
    int? sortOrder,
    String? text,
    Duration? duration,
    SegmentStatus? status,
    String? errorMessage,
    String? audioFilePath,
    bool clearError = false,
    bool clearAudio = false,
  }) {
    return ScriptSegment(
      id: id ?? this.id,
      sortOrder: sortOrder ?? this.sortOrder,
      text: text ?? this.text,
      duration: duration ?? this.duration,
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      audioFilePath: clearAudio ? null : (audioFilePath ?? this.audioFilePath),
    );
  }
}

class SegmentEditorState {
  final String fullText;
  final List<ScriptSegment> segments;
  final bool autoSplit;
  final bool isProcessing;
  final String? errorMessage;
  final int? playingSegmentIndex;

  const SegmentEditorState({
    this.fullText = '',
    this.segments = const [],
    this.autoSplit = false,
    this.isProcessing = false,
    this.errorMessage,
    this.playingSegmentIndex,
  });

  SegmentEditorState copyWith({
    String? fullText,
    List<ScriptSegment>? segments,
    bool? autoSplit,
    bool? isProcessing,
    String? errorMessage,
    int? playingSegmentIndex,
    bool clearError = false,
  }) {
    return SegmentEditorState(
      fullText: fullText ?? this.fullText,
      segments: segments ?? this.segments,
      autoSplit: autoSplit ?? this.autoSplit,
      isProcessing: isProcessing ?? this.isProcessing,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      playingSegmentIndex: playingSegmentIndex ?? this.playingSegmentIndex,
    );
  }

  int get totalCharacters =>
      segments.fold(0, (sum, segment) => sum + segment.text.length);

  Duration get totalDuration =>
      segments.fold(Duration.zero, (sum, segment) => sum + segment.duration);
}

final segmentEditorProvider =
    StateNotifierProvider<SegmentEditorNotifier, SegmentEditorState>(
      (ref) => SegmentEditorNotifier(ref.read(synthesizeTextProvider)),
    );

class SegmentEditorNotifier extends StateNotifier<SegmentEditorState> {
  final SynthesizeText _synthesize;
  final AudioPlayer _player = AudioPlayer();
  StreamSubscription<PlayerState>? _playerStateSubscription;

  SegmentEditorNotifier(this._synthesize) : super(const SegmentEditorState()) {
    _playerStateSubscription = _player.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed &&
          state.playingSegmentIndex != null) {
        state = state.copyWith(playingSegmentIndex: null);
      }
    });
  }

  void setText(String text) {
    state = state.copyWith(fullText: text, clearError: true);
  }

  void toggleAutoSplit() {
    final newAutoSplit = !state.autoSplit;
    state = state.copyWith(autoSplit: newAutoSplit);
    if (newAutoSplit) {
      _autoSplit();
    }
  }

  void _autoSplit() {
    final text = state.fullText.trim();
    if (text.isEmpty) {
      state = state.copyWith(
        isProcessing: false,
        errorMessage: AppStrings.editorEmptyScript,
      );
      return;
    }

    final sentences = text
        .split(RegExp(r'(?<=[.!?…])\s+'))
        .where((s) => s.trim().isNotEmpty)
        .toList();

    if (sentences.isEmpty) {
      state = state.copyWith(
        isProcessing: false,
        errorMessage: AppStrings.editorEmptyScript,
      );
      return;
    }

    final segments = <ScriptSegment>[];
    for (var i = 0; i < sentences.length; i++) {
      final sentence = sentences[i].trim();
      final estimatedDuration = Duration(
        milliseconds:
            (sentence.length / AppConstants.vietnameseCharsPerSecond * 1000)
                .round(),
      );
      segments.add(
        ScriptSegment(
          id: const Uuid().v4(),
          sortOrder: i,
          text: sentence,
          duration: estimatedDuration,
          status: SegmentStatus.ready,
        ),
      );
    }

    state = state.copyWith(
      segments: segments,
      isProcessing: false,
      clearError: true,
    );
  }

  void addSegment() {
    final newSegment = ScriptSegment(
      id: const Uuid().v4(),
      sortOrder: state.segments.length,
      text: '',
      status: SegmentStatus.idle,
    );
    state = state.copyWith(
      segments: [...state.segments, newSegment],
      clearError: true,
    );
  }

  void updateSegmentText(String segmentId, String text) {
    state = state.copyWith(
      segments: state.segments
          .map(
            (segment) => segment.id == segmentId
                ? segment.copyWith(text: text, clearError: true)
                : segment,
          )
          .toList(),
      clearError: true,
    );
  }

  void deleteSegment(String segmentId) {
    final updated = state.segments
        .where((segment) => segment.id != segmentId)
        .toList();
    final reindexed = <ScriptSegment>[];
    for (var i = 0; i < updated.length; i++) {
      reindexed.add(updated[i].copyWith(sortOrder: i));
    }
    state = state.copyWith(segments: reindexed, clearError: true);
  }

  Future<void> playSegment(int index) async {
    if (index < 0 || index >= state.segments.length) return;
    final segment = state.segments[index];
    if (segment.audioFilePath == null || segment.audioFilePath!.isEmpty) return;

    if (state.playingSegmentIndex == index) {
      await _player.pause();
      state = state.copyWith(playingSegmentIndex: null);
      return;
    }

    try {
      await _player.setFilePath(segment.audioFilePath!);
      await _player.play();
      state = state.copyWith(playingSegmentIndex: index, clearError: true);
    } catch (_) {
      state = state.copyWith(
        playingSegmentIndex: null,
        errorMessage: AppStrings.errorPlaybackFailed,
      );
    }
  }

  Future<void> regenerateSegment(String segmentId) async {
    final index = state.segments.indexWhere(
      (segment) => segment.id == segmentId,
    );
    if (index < 0) return;

    final segment = state.segments[index];
    if (segment.text.trim().isEmpty) {
      state = state.copyWith(
        segments: state.segments
            .map(
              (s) => s.id == segmentId
                  ? s.copyWith(
                      status: SegmentStatus.error,
                      errorMessage: AppStrings.editorEmptyScript,
                    )
                  : s,
            )
            .toList(),
      );
      return;
    }

    state = state.copyWith(
      segments: state.segments
          .map(
            (s) => s.id == segmentId
                ? s.copyWith(status: SegmentStatus.generating)
                : s,
          )
          .toList(),
      clearError: true,
    );

    try {
      final response = await _synthesize.execute(
        text: segment.text,
        voiceId: 'default',
      );
      state = state.copyWith(
        segments: state.segments
            .map(
              (s) => s.id == segmentId
                  ? s.copyWith(
                      status: SegmentStatus.ready,
                      duration: response.duration ?? s.duration,
                      audioFilePath: response.audioUrl,
                      clearError: true,
                    )
                  : s,
            )
            .toList(),
      );
    } catch (error) {
      state = state.copyWith(
        segments: state.segments
            .map(
              (s) => s.id == segmentId
                  ? s.copyWith(
                      status: SegmentStatus.error,
                      errorMessage: _mapError(error),
                    )
                  : s,
            )
            .toList(),
      );
    }
  }

  Future<void> generateAllSegments(String voiceId) async {
    if (state.isProcessing) return;
    if (state.segments.isEmpty) {
      state = state.copyWith(errorMessage: AppStrings.segmentEmpty);
      return;
    }

    state = state.copyWith(isProcessing: true, clearError: true);

    for (var i = 0; i < state.segments.length; i++) {
      final segment = state.segments[i];
      if (segment.text.trim().isEmpty) continue;

      state = state.copyWith(
        segments: state.segments
            .map(
              (s) => s.id == segment.id
                  ? s.copyWith(status: SegmentStatus.generating)
                  : s,
            )
            .toList(),
      );

      try {
        final response = await _synthesize.execute(
          text: segment.text,
          voiceId: voiceId,
        );
        state = state.copyWith(
          segments: state.segments
              .map(
                (s) => s.id == segment.id
                    ? s.copyWith(
                        status: SegmentStatus.ready,
                        duration: response.duration ?? s.duration,
                        audioFilePath: response.audioUrl,
                        clearError: true,
                      )
                    : s,
              )
              .toList(),
        );
      } catch (error) {
        state = state.copyWith(
          segments: state.segments
              .map(
                (s) => s.id == segment.id
                    ? s.copyWith(
                        status: SegmentStatus.error,
                        errorMessage: _mapError(error),
                      )
                    : s,
              )
              .toList(),
        );
      }
    }

    state = state.copyWith(isProcessing: false);
  }

  String _mapError(Object error) {
    if (error is SocketException) {
      return AppStrings.errorNetwork;
    }
    if (error is TtsProviderException) {
      return error.voiceStudioMessage ?? mapTtsErrorKind(error.kind);
    }
    return AppStrings.errorUnknown;
  }

  @override
  void dispose() {
    _playerStateSubscription?.cancel();
    _player.dispose();
    super.dispose();
  }
}

class SegmentEditorScreen extends ConsumerStatefulWidget {
  const SegmentEditorScreen({super.key});

  @override
  ConsumerState<SegmentEditorScreen> createState() =>
      _SegmentEditorScreenState();
}

class _SegmentEditorScreenState extends ConsumerState<SegmentEditorScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final TextEditingController _textController;
  final Map<String, TextEditingController> _segmentControllers = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _textController = TextEditingController();
    _textController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _textController.dispose();
    for (final controller in _segmentControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onTextChanged() {
    ref.read(segmentEditorProvider.notifier).setText(_textController.text);
  }

  TextEditingController _controllerFor(ScriptSegment segment) {
    return _segmentControllers.putIfAbsent(
      segment.id,
      () => TextEditingController(text: segment.text),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration == Duration.zero) return '--:--';
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(Theme.of(context).brightness);
    final state = ref.watch(segmentEditorProvider);

    if (_textController.text != state.fullText) {
      _textController.value = TextEditingValue(
        text: state.fullText,
        selection: TextSelection.collapsed(offset: state.fullText.length),
      );
    }

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            _Header(),
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: AppStrings.segmentTabText),
                Tab(text: AppStrings.segmentTabSegments),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _TextTab(
                    controller: _textController,
                    characterCount: state.fullText.length,
                  ),
                  _SegmentsTab(
                    state: state,
                    formatDuration: _formatDuration,
                    controllerFor: _controllerFor,
                  ),
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
                AppStrings.segmentEditorTitle,
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

class _TextTab extends StatelessWidget {
  const _TextTab({required this.controller, required this.characterCount});

  final TextEditingController controller;
  final int characterCount;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(Theme.of(context).brightness);
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: AppRadius.largeAll,
                border: Border.all(color: colors.divider),
                boxShadow: AppShadows.card,
              ),
              child: TextField(
                controller: controller,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: AppTypography.body.copyWith(color: colors.textPrimary),
                decoration: InputDecoration(
                  hintText: AppStrings.editorHint,
                  hintStyle: AppTypography.body.copyWith(
                    color: colors.textTertiary,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(AppSpacing.lg),
                ),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(
                    AppConstants.maxScriptLength,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '$characterCount/${AppConstants.maxScriptLength} ${AppStrings.homeCharactersLabel}',
            style: AppTypography.caption.copyWith(color: colors.textTertiary),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }
}

class _SegmentsTab extends ConsumerWidget {
  const _SegmentsTab({
    required this.state,
    required this.formatDuration,
    required this.controllerFor,
  });

  final SegmentEditorState state;
  final String Function(Duration) formatDuration;
  final TextEditingController Function(ScriptSegment) controllerFor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(segmentEditorProvider.notifier);

    return Column(
      children: [
        _AutoSplitToggle(
          value: state.autoSplit,
          onChanged: (_) => notifier.toggleAutoSplit(),
        ),
        Expanded(
          child: state.segments.isEmpty
              ? _EmptyState(onAdd: notifier.addSegment)
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.sm,
                    AppSpacing.lg,
                    AppSpacing.xxl,
                  ),
                  itemCount: state.segments.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final segment = state.segments[index];
                    return _SegmentCard(
                      segment: segment,
                      index: index,
                      formatDuration: formatDuration,
                      controller: controllerFor(segment),
                      isPlaying: state.playingSegmentIndex == index,
                      onPlay: () => notifier.playSegment(index),
                      onEdit: () => _showEditDialog(context, ref, segment),
                      onRetry: () => notifier.regenerateSegment(segment.id),
                      onDelete: () => _confirmDelete(context, ref, segment),
                      onTextChanged: (text) =>
                          notifier.updateSegmentText(segment.id, text),
                    );
                  },
                ),
        ),
        _BottomBar(
          segmentCount: state.segments.length,
          totalDuration: state.totalDuration,
          formatDuration: formatDuration,
          onAdd: notifier.addSegment,
        ),
      ],
    );
  }

  void _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    ScriptSegment segment,
  ) {
    final editController = TextEditingController(text: segment.text);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(AppStrings.segmentEdit),
        content: TextField(
          controller: editController,
          maxLines: 5,
          minLines: 3,
          style: AppTypography.body,
          decoration: const InputDecoration(
            hintText: AppStrings.segmentTextHint,
          ),
          inputFormatters: [
            LengthLimitingTextInputFormatter(AppConstants.maxScriptLength),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(AppStrings.segmentCancel),
          ),
          ElevatedButton(
            onPressed: () {
              ref
                  .read(segmentEditorProvider.notifier)
                  .updateSegmentText(segment.id, editController.text);
              Navigator.of(dialogContext).pop();
            },
            child: const Text(AppStrings.segmentSave),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    ScriptSegment segment,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(AppStrings.segmentDeleteConfirmTitle),
        content: const Text(AppStrings.segmentDeleteConfirmDesc),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(AppStrings.segmentCancel),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(segmentEditorProvider.notifier)
                  .deleteSegment(segment.id);
              Navigator.of(dialogContext).pop();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColorScheme.of(
                Theme.of(context).brightness,
              ).error,
            ),
            child: const Text(AppStrings.segmentDelete),
          ),
        ],
      ),
    );
  }
}

class _AutoSplitToggle extends StatelessWidget {
  const _AutoSplitToggle({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(Theme.of(context).brightness);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        0,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: AppRadius.largeAll,
          border: Border.all(color: colors.divider),
        ),
        child: Row(
          children: [
            Icon(
              AppIcons.tune,
              size: AppSizes.iconMedium,
              color: colors.primary,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.segmentAutoSplit,
                    style: AppTypography.label.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    AppStrings.segmentAutoSplitDesc,
                    style: AppTypography.caption.copyWith(
                      color: colors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            Switch(value: value, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}

class _SegmentCard extends StatelessWidget {
  const _SegmentCard({
    required this.segment,
    required this.index,
    required this.formatDuration,
    required this.controller,
    required this.isPlaying,
    required this.onPlay,
    required this.onEdit,
    required this.onRetry,
    required this.onDelete,
    required this.onTextChanged,
  });

  final ScriptSegment segment;
  final int index;
  final String Function(Duration) formatDuration;
  final TextEditingController controller;
  final bool isPlaying;
  final VoidCallback onPlay;
  final VoidCallback onEdit;
  final VoidCallback onRetry;
  final VoidCallback onDelete;
  final ValueChanged<String> onTextChanged;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(Theme.of(context).brightness);

    return Container(
      padding: AppSpacing.lgAll,
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: AppRadius.largeAll,
        border: Border.all(color: colors.divider),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: AppSizes.avatarSmall,
                height: AppSizes.avatarSmall,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: AppRadius.pillAll,
                ),
                child: Text(
                  '${index + 1}',
                  style: AppTypography.label.copyWith(
                    color: colors.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  '${AppStrings.segmentNumber} ${index + 1}',
                  style: AppTypography.label.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
              ),
              _StatusChip(status: segment.status),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: controller,
            maxLines: 3,
            minLines: 2,
            style: AppTypography.body.copyWith(color: colors.textPrimary),
            decoration: InputDecoration(
              hintText: AppStrings.segmentTextHint,
              hintStyle: AppTypography.body.copyWith(
                color: colors.textTertiary,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              isDense: true,
            ),
            onChanged: onTextChanged,
            inputFormatters: [
              LengthLimitingTextInputFormatter(AppConstants.maxScriptLength),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Icon(
                AppIcons.history,
                size: AppSizes.iconSmall,
                color: colors.textTertiary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                formatDuration(segment.duration),
                style: AppTypography.caption.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              const Spacer(),
              _SegmentActionButton(
                icon: isPlaying ? AppIcons.pause : AppIcons.play,
                label: AppStrings.segmentPlay,
                onPressed: segment.audioFilePath != null ? onPlay : null,
              ),
              const SizedBox(width: AppSpacing.xs),
              _SegmentActionButton(
                icon: AppIcons.edit,
                label: AppStrings.segmentEdit,
                onPressed: onEdit,
              ),
              const SizedBox(width: AppSpacing.xs),
              if (segment.status == SegmentStatus.error)
                _SegmentActionButton(
                  icon: AppIcons.refresh,
                  label: AppStrings.segmentRetry,
                  onPressed: onRetry,
                ),
              if (segment.status == SegmentStatus.error)
                const SizedBox(width: AppSpacing.xs),
              _SegmentActionButton(
                icon: AppIcons.delete,
                label: AppStrings.segmentDelete,
                onPressed: onDelete,
                color: colors.error,
              ),
            ],
          ),
          if (segment.status == SegmentStatus.error &&
              segment.errorMessage != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              segment.errorMessage!,
              style: AppTypography.caption.copyWith(color: colors.error),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final SegmentStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(Theme.of(context).brightness);
    late final String label;
    late final Color color;
    late final IconData icon;

    switch (status) {
      case SegmentStatus.idle:
        label = AppStrings.segmentReady;
        color = colors.textTertiary;
        icon = AppIcons.tune;
      case SegmentStatus.generating:
        label = AppStrings.segmentGenerating;
        color = colors.info;
        icon = AppIcons.tune;
      case SegmentStatus.ready:
        label = AppStrings.segmentReady;
        color = colors.success;
        icon = AppIcons.check;
      case SegmentStatus.error:
        label = AppStrings.segmentFailed;
        color = colors.error;
        icon = AppIcons.errorOutlined;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadius.pillAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (status == SegmentStatus.generating)
            SizedBox(
              width: AppSizes.iconSmall,
              height: AppSizes.iconSmall,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            )
          else
            Icon(icon, size: AppSizes.iconSmall, color: color),
          const SizedBox(width: AppSpacing.xs),
          Text(label, style: AppTypography.caption.copyWith(color: color)),
        ],
      ),
    );
  }
}

class _SegmentActionButton extends StatelessWidget {
  const _SegmentActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(Theme.of(context).brightness);
    final effectiveColor = color ?? colors.textSecondary;
    return SizedBox(
      width: AppSizes.touchTarget,
      height: AppSizes.touchTarget,
      child: IconButton(
        icon: Icon(icon, size: AppSizes.iconMedium, color: effectiveColor),
        onPressed: onPressed,
        tooltip: label,
        constraints: const BoxConstraints(
          minWidth: AppSizes.touchTarget,
          minHeight: AppSizes.touchTarget,
        ),
        padding: EdgeInsets.zero,
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(Theme.of(context).brightness);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              AppIcons.scriptOutlined,
              size: AppSizes.iconExtraLarge * 1.5,
              color: colors.textTertiary,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              AppStrings.segmentEmpty,
              style: AppTypography.body.copyWith(color: colors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              AppStrings.segmentEmptyHint,
              style: AppTypography.caption.copyWith(color: colors.textTertiary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(AppIcons.add, size: AppSizes.iconMedium),
              label: const Text(AppStrings.segmentAdd),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.segmentCount,
    required this.totalDuration,
    required this.formatDuration,
    required this.onAdd,
  });

  final int segmentCount;
  final Duration totalDuration;
  final String Function(Duration) formatDuration;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(Theme.of(context).brightness);
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.divider)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$segmentCount ${AppStrings.segmentNumber.toLowerCase()}',
                  style: AppTypography.caption.copyWith(
                    color: colors.textTertiary,
                  ),
                ),
                Text(
                  formatDuration(totalDuration),
                  style: AppTypography.label.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(AppIcons.add, size: AppSizes.iconMedium),
            label: const Text(AppStrings.segmentAdd),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(0, AppSizes.buttonMedium),
            ),
          ),
        ],
      ),
    );
  }
}
