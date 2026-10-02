import 'package:flutter_test/flutter_test.dart';
import 'package:voice_huluca/features/generation/generation_provider.dart';

void main() {
  group('GenerationState', () {
    test('has correct default values', () {
      const state = GenerationState();
      expect(state.status, GenerationStatus.idle);
      expect(state.text, '');
      expect(state.voiceId, '');
      expect(state.voiceName, '');
      expect(state.speed, 1.0);
      expect(state.progress, 0.0);
      expect(state.errorMessage, isNull);
      expect(state.audioAsset, isNull);
      expect(state.ttsRequestId, isNull);
      expect(state.startedAt, isNull);
      expect(state.completedAt, isNull);
    });

    test('isBusy returns true for validating status', () {
      const state = GenerationState(status: GenerationStatus.validating);
      expect(state.isBusy, isTrue);
    });

    test('isBusy returns true for uploading status', () {
      const state = GenerationState(status: GenerationStatus.uploading);
      expect(state.isBusy, isTrue);
    });

    test('isBusy returns true for generating status', () {
      const state = GenerationState(status: GenerationStatus.generating);
      expect(state.isBusy, isTrue);
    });

    test('isBusy returns true for downloading status', () {
      const state = GenerationState(status: GenerationStatus.downloading);
      expect(state.isBusy, isTrue);
    });

    test('isBusy returns true for processing status', () {
      const state = GenerationState(status: GenerationStatus.processing);
      expect(state.isBusy, isTrue);
    });

    test('isBusy returns false for idle status', () {
      const state = GenerationState(status: GenerationStatus.idle);
      expect(state.isBusy, isFalse);
    });

    test('isBusy returns false for success status', () {
      const state = GenerationState(status: GenerationStatus.success);
      expect(state.isBusy, isFalse);
    });

    test('isTerminal returns true for success status', () {
      const state = GenerationState(status: GenerationStatus.success);
      expect(state.isTerminal, isTrue);
    });

    test('isTerminal returns true for error status', () {
      const state = GenerationState(status: GenerationStatus.error);
      expect(state.isTerminal, isTrue);
    });

    test('isTerminal returns true for cancelled status', () {
      const state = GenerationState(status: GenerationStatus.cancelled);
      expect(state.isTerminal, isTrue);
    });

    test('isTerminal returns false for idle status', () {
      const state = GenerationState(status: GenerationStatus.idle);
      expect(state.isTerminal, isFalse);
    });

    test('isTerminal returns false for generating status', () {
      const state = GenerationState(status: GenerationStatus.generating);
      expect(state.isTerminal, isFalse);
    });

    test('characterCount returns text length', () {
      const state = GenerationState(text: 'hello world');
      expect(state.characterCount, 11);
    });

    test('characterCount returns 0 for empty text', () {
      const state = GenerationState(text: '');
      expect(state.characterCount, 0);
    });

    test('statusText returns empty string for idle', () {
      const state = GenerationState(status: GenerationStatus.idle);
      expect(state.statusText, '');
    });

    test('statusText returns success message for success', () {
      const state = GenerationState(status: GenerationStatus.success);
      expect(state.statusText, isNotEmpty);
    });

    test('statusText returns error message for error', () {
      const state = GenerationState(status: GenerationStatus.error);
      expect(state.statusText, isNotEmpty);
    });

    test('copyWith updates specified fields', () {
      const state = GenerationState(text: 'hello');
      final updated = state.copyWith(text: 'world', progress: 0.5);
      expect(updated.text, 'world');
      expect(updated.progress, 0.5);
      expect(updated.status, state.status);
    });

    test('copyWith clearError sets errorMessage to null', () {
      const state = GenerationState(errorMessage: 'Some error');
      final updated = state.copyWith(clearError: true);
      expect(updated.errorMessage, isNull);
    });

    test('copyWith clearAudio sets audioAsset to null', () {
      const state = GenerationState();
      final updated = state.copyWith(clearAudio: true);
      expect(updated.audioAsset, isNull);
    });

    test('copyWith preserves fields when not specified', () {
      const state = GenerationState(
        text: 'hello',
        voiceId: 'voice1',
        progress: 0.5,
      );
      final updated = state.copyWith(status: GenerationStatus.generating);
      expect(updated.text, 'hello');
      expect(updated.voiceId, 'voice1');
      expect(updated.progress, 0.5);
      expect(updated.status, GenerationStatus.generating);
    });
  });

  group('GenerationStatus', () {
    test('has all expected values', () {
      expect(GenerationStatus.values, contains(GenerationStatus.idle));
      expect(GenerationStatus.values, contains(GenerationStatus.validating));
      expect(GenerationStatus.values, contains(GenerationStatus.uploading));
      expect(GenerationStatus.values, contains(GenerationStatus.generating));
      expect(GenerationStatus.values, contains(GenerationStatus.downloading));
      expect(GenerationStatus.values, contains(GenerationStatus.processing));
      expect(GenerationStatus.values, contains(GenerationStatus.success));
      expect(GenerationStatus.values, contains(GenerationStatus.error));
      expect(GenerationStatus.values, contains(GenerationStatus.cancelled));
    });

    test('has exactly 9 values', () {
      expect(GenerationStatus.values.length, 9);
    });
  });
}
