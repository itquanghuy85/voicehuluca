import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../../data/models/audio_asset.dart';
import '../../data/repositories/audio_repository_impl.dart';
import '../audio_library/library_provider.dart';

class AudioPlayerService {
  final AudioPlayer _player = AudioPlayer();

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<double> get speedStream => _player.speedStream;

  Future<void> loadFile(String path) async {
    await _player.setFilePath(path);
  }

  Future<void> play() => _player.play();
  Future<void> pause() => _player.pause();
  Future<void> seek(Duration position) => _player.seek(position);
  Future<void> setSpeed(double speed) => _player.setSpeed(speed);
  Future<void> stop() => _player.stop();

  void dispose() {
    _player.dispose();
  }
}

class AudioDetailState {
  final AudioAsset? audio;
  final bool isLoading;
  final String? error;
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final double speed;

  const AudioDetailState({
    this.audio,
    this.isLoading = false,
    this.error,
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.speed = 1.0,
  });

  AudioDetailState copyWith({
    AudioAsset? audio,
    bool? isLoading,
    String? error,
    bool? isPlaying,
    Duration? position,
    Duration? duration,
    double? speed,
  }) {
    return AudioDetailState(
      audio: audio ?? this.audio,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      speed: speed ?? this.speed,
    );
  }
}

class AudioDetailNotifier extends StateNotifier<AudioDetailState> {
  final AudioRepositoryImpl _repository;
  final AudioPlayerService _playerService;
  final int _audioId;

  AudioDetailNotifier(this._repository, this._playerService, this._audioId)
    : super(const AudioDetailState()) {
    _init();
  }

  Future<void> _init() async {
    _playerService.playerStateStream.listen((playerState) {
      state = state.copyWith(isPlaying: playerState.playing);
    });

    _playerService.positionStream.listen((position) {
      state = state.copyWith(position: position);
    });

    _playerService.durationStream.listen((duration) {
      if (duration != null) {
        state = state.copyWith(duration: duration);
      }
    });

    _playerService.speedStream.listen((speed) {
      state = state.copyWith(speed: speed);
    });

    await loadAudio();
  }

  Future<void> loadAudio() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final audios = await _repository.getAllAudio();
      final audio = audios.firstWhere((a) => a.id == _audioId);
      state = state.copyWith(audio: audio, isLoading: false);
      await _playerService.loadFile(audio.filePath);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateTitle(String newTitle) async {
    if (state.audio == null) return;
    try {
      final updated = state.audio!.copyWith(title: newTitle);
      await _repository.updateAudio(updated);
      state = state.copyWith(audio: updated);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> toggleFavorite() async {
    if (state.audio == null) return;
    try {
      final newFavorite = !state.audio!.isFavorite;
      await _repository.toggleFavorite(_audioId, newFavorite);
      state = state.copyWith(
        audio: state.audio!.copyWith(isFavorite: newFavorite),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> delete() async {
    try {
      await _repository.deleteAudio(_audioId);
      await _playerService.stop();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> play() => _playerService.play();
  Future<void> pause() => _playerService.pause();

  Future<void> seek(Duration position) => _playerService.seek(position);

  Future<void> setSpeed(double speed) => _playerService.setSpeed(speed);

  Future<void> skipForward() async {
    final newPosition = state.position + const Duration(seconds: 15);
    if (newPosition < state.duration) {
      await _playerService.seek(newPosition);
    } else {
      await _playerService.seek(state.duration);
    }
  }

  Future<void> skipBackward() async {
    final newPosition = state.position - const Duration(seconds: 15);
    if (newPosition > Duration.zero) {
      await _playerService.seek(newPosition);
    } else {
      await _playerService.seek(Duration.zero);
    }
  }

  @override
  void dispose() {
    _playerService.dispose();
    super.dispose();
  }
}

final audioPlayerServiceProvider = Provider<AudioPlayerService>((ref) {
  return AudioPlayerService();
});

final audioDetailProvider =
    StateNotifierProvider.family<AudioDetailNotifier, AudioDetailState, int>((
      ref,
      audioId,
    ) {
      final repository = ref.watch(audioRepositoryProvider);
      final playerService = ref.watch(audioPlayerServiceProvider);
      return AudioDetailNotifier(repository, playerService, audioId);
    });
