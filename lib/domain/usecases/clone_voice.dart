import 'dart:io';

import '../../data/models/voice.dart';
import '../repositories/tts_repository.dart';

class CloneVoice {
  final TtsRepository _repository;

  CloneVoice(this._repository);

  Future<Voice> execute({
    required String name,
    required String description,
    required List<String> audioFilePaths,
    String provider = 'default',
  }) async {
    if (name.trim().isEmpty) {
      throw ArgumentError('Voice name cannot be empty');
    }

    if (audioFilePaths.isEmpty) {
      throw ArgumentError(
        'At least one audio file is required for voice cloning',
      );
    }

    final audioFiles = audioFilePaths.map((path) => File(path)).toList();
    return _repository.cloneVoice(
      name: name.trim(),
      description: description.trim(),
      audioFiles: audioFiles,
    );
  }
}
