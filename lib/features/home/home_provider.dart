import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_huluca/core/constants/app_constants.dart';

class HomeState {
  final String scriptText;
  final double speed;
  final bool isGenerating;
  final String? generationError;

  const HomeState({
    this.scriptText = '',
    this.speed = 1.0,
    this.isGenerating = false,
    this.generationError,
  });

  int get characterCount => scriptText.length;

  int get wordCount {
    final trimmed = scriptText.trim();
    if (trimmed.isEmpty) return 0;
    return trimmed.split(RegExp(r'\s+')).length;
  }

  double get estimatedDurationSeconds {
    if (scriptText.isEmpty) return 0;
    final baseDuration =
        characterCount / (AppConstants.vietnameseCharsPerSecond * speed);
    return baseDuration.clamp(
      AppConstants.minEstimatedDurationSeconds,
      AppConstants.maxEstimatedDurationSeconds,
    );
  }

  HomeState copyWith({
    String? scriptText,
    double? speed,
    bool? isGenerating,
    String? generationError,
    bool clearGenerationError = false,
  }) {
    return HomeState(
      scriptText: scriptText ?? this.scriptText,
      speed: speed ?? this.speed,
      isGenerating: isGenerating ?? this.isGenerating,
      generationError: clearGenerationError
          ? null
          : generationError ?? this.generationError,
    );
  }
}

class HomeNotifier extends StateNotifier<HomeState> {
  HomeNotifier() : super(const HomeState());

  void updateScriptText(String text) {
    state = state.copyWith(scriptText: text);
  }

  void setSpeed(double speed) {
    state = state.copyWith(speed: speed);
  }

  void setGenerating(bool generating) {
    state = state.copyWith(
      isGenerating: generating,
      clearGenerationError: generating,
    );
  }

  void setGenerationError(String? error) {
    state = state.copyWith(
      generationError: error,
      isGenerating: false,
      clearGenerationError: error == null,
    );
  }
}

final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>(
  (ref) => HomeNotifier(),
);

final availableSpeedsProvider = Provider<List<double>>(
  (ref) => [0.75, 1.0, 1.25, 1.5],
);
