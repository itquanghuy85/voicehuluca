import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_huluca/core/constants/app_constants.dart';

class ScriptEditorState {
  final String text;
  final int cursorPosition;
  final bool isDirty;

  const ScriptEditorState({
    this.text = '',
    this.cursorPosition = 0,
    this.isDirty = false,
  });

  int get characterCount => text.length;

  int get wordCount {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return 0;
    return trimmed.split(RegExp(r'\s+')).length;
  }

  double estimatedDurationSeconds({double speed = 1.0}) {
    if (text.isEmpty) return 0;
    final effectiveSpeed = speed <= 0 ? 1.0 : speed;
    final baseDuration =
        characterCount /
        (AppConstants.vietnameseCharsPerSecond * effectiveSpeed);
    return baseDuration.clamp(
      AppConstants.minEstimatedDurationSeconds,
      AppConstants.maxEstimatedDurationSeconds,
    );
  }

  bool get isValid =>
      text.trim().isNotEmpty && text.length <= AppConstants.maxScriptLength;

  ScriptEditorState copyWith({
    String? text,
    int? cursorPosition,
    bool? isDirty,
  }) {
    return ScriptEditorState(
      text: text ?? this.text,
      cursorPosition: cursorPosition ?? this.cursorPosition,
      isDirty: isDirty ?? this.isDirty,
    );
  }
}

class ScriptEditorNotifier extends StateNotifier<ScriptEditorState> {
  ScriptEditorNotifier() : super(const ScriptEditorState());

  void updateText(String newText) {
    final truncated = newText.length > AppConstants.maxScriptLength
        ? newText.substring(0, AppConstants.maxScriptLength)
        : newText;
    state = state.copyWith(text: truncated, isDirty: true);
  }

  void setText(String text) {
    final truncated = text.length > AppConstants.maxScriptLength
        ? text.substring(0, AppConstants.maxScriptLength)
        : text;
    state = state.copyWith(text: truncated, isDirty: true);
  }

  void clear() {
    state = const ScriptEditorState();
  }

  void setCursorPosition(int position) {
    state = state.copyWith(cursorPosition: position);
  }
}

final scriptEditorProvider =
    StateNotifierProvider<ScriptEditorNotifier, ScriptEditorState>(
      (ref) => ScriptEditorNotifier(),
    );
