import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_huluca/core/constants/app_constants.dart';
import 'package:voice_huluca/core/design_system/design_tokens.dart';
import 'package:voice_huluca/core/localization/app_strings.dart';
import 'package:voice_huluca/features/script_editor/script_editor_provider.dart';

class ScriptEditor extends ConsumerStatefulWidget {
  const ScriptEditor({
    super.key,
    this.onTextChanged,
    this.hintText,
    this.minLines = 5,
    this.maxLines = 15,
    this.showStats = true,
    this.showActions = true,
  });

  final ValueChanged<String>? onTextChanged;
  final String? hintText;
  final int minLines;
  final int maxLines;
  final bool showStats;
  final bool showActions;

  @override
  ConsumerState<ScriptEditor> createState() => _ScriptEditorState();
}

class _ScriptEditorState extends ConsumerState<ScriptEditor> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final text = _controller.text;
    // Writing to the controller from build (for example when the text is
    // replaced by the sample script) fires this listener too. Updating
    // providers straight away would mutate state during build, so both the
    // editor state and the parent callback run after the frame instead.
    final alreadyInSync = text == ref.read(scriptEditorProvider).text;
    Future<void>.delayed(Duration.zero, () {
      if (!mounted) return;
      if (!alreadyInSync) {
        ref.read(scriptEditorProvider.notifier).updateText(text);
      }
      widget.onTextChanged?.call(text);
    });
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data == null || data.text == null || data.text!.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.homePasteFailed),
            duration: AppConstants.snackBarDuration,
          ),
        );
      }
      return;
    }
    final currentText = _controller.text;
    final selection = _controller.selection;
    final newText = currentText.replaceRange(
      selection.start,
      selection.end,
      data.text!,
    );
    final truncated = newText.length > AppConstants.maxScriptLength
        ? newText.substring(0, AppConstants.maxScriptLength)
        : newText;
    _controller.value = TextEditingValue(
      text: truncated,
      selection: TextSelection.collapsed(
        offset: selection.start + data.text!.length,
      ),
    );
  }

  void _clearText() {
    _controller.clear();
    ref.read(scriptEditorProvider.notifier).clear();
    widget.onTextChanged?.call('');
  }

  String _formatDuration(double seconds) {
    if (seconds <= 0) return '0 ${AppStrings.homeSecondsLabel}';
    final totalSeconds = seconds.round();
    final minutes = totalSeconds ~/ 60;
    final secs = totalSeconds % 60;
    if (minutes > 0 && secs > 0) {
      return '$minutes ${AppStrings.homeMinutesLabel} $secs ${AppStrings.homeSecondsLabel}';
    } else if (minutes > 0) {
      return '$minutes ${AppStrings.homeMinutesLabel}';
    }
    return '$secs ${AppStrings.homeSecondsLabel}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(Theme.of(context).brightness);
    final state = ref.watch(scriptEditorProvider);

    if (_controller.text != state.text) {
      _controller.value = TextEditingValue(
        text: state.text,
        selection: TextSelection.collapsed(offset: state.text.length),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: AppRadius.largeAll,
            border: Border.all(color: colors.divider),
            boxShadow: AppShadows.card,
          ),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            maxLines: widget.maxLines,
            minLines: widget.minLines,
            textInputAction: TextInputAction.newline,
            keyboardType: TextInputType.multiline,
            style: AppTypography.body.copyWith(color: colors.textPrimary),
            decoration: InputDecoration(
              hintText: widget.hintText ?? AppStrings.homeScriptHint,
              hintStyle: AppTypography.body.copyWith(
                color: colors.textTertiary,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(AppSpacing.lg),
              suffixIcon: widget.showActions && state.text.isNotEmpty
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            AppIcons.paste,
                            color: colors.textSecondary,
                            size: AppSizes.iconMedium,
                          ),
                          onPressed: _pasteFromClipboard,
                          tooltip: AppStrings.editorPaste,
                          constraints: const BoxConstraints(
                            minWidth: AppSizes.touchTarget,
                            minHeight: AppSizes.touchTarget,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            AppIcons.close,
                            color: colors.textSecondary,
                            size: AppSizes.iconMedium,
                          ),
                          onPressed: _clearText,
                          tooltip: AppStrings.editorClear,
                          constraints: const BoxConstraints(
                            minWidth: AppSizes.touchTarget,
                            minHeight: AppSizes.touchTarget,
                          ),
                        ),
                      ],
                    )
                  : null,
            ),
            inputFormatters: [
              LengthLimitingTextInputFormatter(AppConstants.maxScriptLength),
            ],
          ),
        ),
        if (widget.showStats) ...[
          const SizedBox(height: AppSpacing.md),
          _buildStatsBar(colors, state),
        ],
      ],
    );
  }

  Widget _buildStatsBar(AppColorScheme colors, ScriptEditorState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: Row(
        children: [
          _StatChip(
            icon: AppIcons.text,
            label: '${state.characterCount}/${AppConstants.maxScriptLength}',
            color: colors.textSecondary,
          ),
          const SizedBox(width: AppSpacing.sm),
          _StatChip(
            icon: AppIcons.script,
            label: '${state.wordCount} ${AppStrings.homeWordsLabel}',
            color: colors.textSecondary,
          ),
          const SizedBox(width: AppSpacing.sm),
          _StatChip(
            icon: AppIcons.speed,
            label: _formatDuration(state.estimatedDurationSeconds()),
            color: colors.textSecondary,
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: AppSizes.iconSmall, color: color),
        const SizedBox(width: AppSpacing.xs),
        Text(label, style: AppTypography.caption.copyWith(color: color)),
      ],
    );
  }
}
