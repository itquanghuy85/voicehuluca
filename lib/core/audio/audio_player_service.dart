import 'dart:async';
import 'dart:io';

import 'package:just_audio/just_audio.dart';
import 'package:voice_huluca/core/errors/app_error.dart';
import 'package:voice_huluca/core/errors/error_mapper.dart';

class AudioPlayerService {
  final AudioPlayer _player;

  AudioPlayerService({AudioPlayer? player}) : _player = player ?? AudioPlayer();

  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<double> get speedStream => _player.speedStream;

  Duration get position => _player.position;
  Duration? get duration => _player.duration;
  bool get isPlaying => _player.playing;
  double get speed => _player.speed;

  Future<void> playFile(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw const InvalidAudioError(message: 'Tệp âm thanh không tồn tại.');
    }
    try {
      await _player.setFilePath(filePath);
      await _player.play();
    } catch (e) {
      throw mapError(e);
    }
  }

  Future<void> playUrl(String url) async {
    try {
      await _player.setUrl(url);
      await _player.play();
    } catch (e) {
      throw mapError(e);
    }
  }

  Future<void> playBytes(List<int> bytes) async {
    try {
      final tempDir = Directory.systemTemp;
      final tempFile = File(
        '${tempDir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.mp3',
      );
      await tempFile.writeAsBytes(bytes);
      await _player.setFilePath(tempFile.path);
      await _player.play();
    } catch (e) {
      throw mapError(e);
    }
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> resume() async {
    await _player.play();
  }

  Future<void> stop() async {
    await _player.stop();
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  Future<void> setSpeed(double speed) async {
    await _player.setSpeed(speed);
  }

  Future<void> setVolume(double volume) async {
    await _player.setVolume(volume.clamp(0.0, 1.0));
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}
