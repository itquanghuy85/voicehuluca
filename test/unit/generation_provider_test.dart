import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:voice_huluca/core/constants/app_constants.dart';
import 'package:voice_huluca/core/localization/app_strings.dart';
import 'package:voice_huluca/data/datasources/local/app_database.dart'
    hide Voice;
import 'package:voice_huluca/data/datasources/local/audio_local_datasource.dart';
import 'package:voice_huluca/data/datasources/local/voice_local_datasource.dart';
import 'package:voice_huluca/data/datasources/remote/tts_remote_datasource.dart';
import 'package:voice_huluca/data/models/voice.dart';
import 'package:voice_huluca/data/repositories/audio_repository_impl.dart';
import 'package:voice_huluca/data/repositories/tts_repository_impl.dart';
import 'package:voice_huluca/data/services/tts_provider.dart';
import 'package:voice_huluca/domain/entities/tts_request.dart';
import 'package:voice_huluca/domain/entities/tts_response.dart';
import 'package:voice_huluca/domain/repositories/tts_repository.dart';
import 'package:voice_huluca/domain/usecases/synthesize_text.dart';
import 'package:voice_huluca/features/generation/generation_provider.dart';

/// Repository stub so generation tests never touch the network.
class _FakeTtsRepository implements TtsRepository {
  _FakeTtsRepository(this.onSynthesize);

  final Future<void> Function(TtsRequest request) onSynthesize;

  @override
  Future<TtsResponse> synthesize(TtsRequest request) async {
    await onSynthesize(request);
    return TtsResponse(
      id: request.id,
      status: 'completed',
      createdAt: DateTime.now(),
    );
  }

  @override
  Stream<TtsResponse> synthesizeWithProgress(TtsRequest request) async* {
    yield TtsResponse(
      id: request.id,
      status: 'generating',
      createdAt: DateTime.now(),
    );
    await onSynthesize(request);
    yield TtsResponse(
      id: request.id,
      status: 'completed',
      createdAt: DateTime.now(),
      metadata: {
        'bytes': 3,
        'provider': 'google',
        'audio': Uint8List.fromList([1, 2, 3]),
      },
    );
  }

  @override
  Future<TtsResponse> getStatus(String requestId) async => TtsResponse(
    id: requestId,
    status: 'completed',
    createdAt: DateTime.now(),
  );

  @override
  Future<List<TtsResponse>> getHistory({
    int limit = 50,
    int offset = 0,
  }) async => const [];

  @override
  Future<void> cancelGeneration(String requestId) async {}

  @override
  Future<Voice> cloneVoice({
    required String name,
    required String description,
    required List<File> audioFiles,
    String? language,
  }) => throw UnimplementedError();

  @override
  Future<TtsUsage?> getUsage() async => null;

  @override
  Future<BackendHealth> checkHealth() async => const BackendHealth(
    service: 'vietvoice-backend',
    version: 'test',
    providers: {},
  );
}

/// Yields a completed response with no audio payload.
class _SilentTtsRepository extends _FakeTtsRepository {
  _SilentTtsRepository() : super((_) async {});

  @override
  Stream<TtsResponse> synthesizeWithProgress(TtsRequest request) async* {
    yield TtsResponse(
      id: request.id,
      status: 'generating',
      createdAt: DateTime.now(),
    );
    yield TtsResponse(
      id: request.id,
      status: 'completed',
      createdAt: DateTime.now(),
      metadata: {'bytes': 0, 'provider': 'google', 'audio': Uint8List(0)},
    );
  }
}

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(DatabaseConnection(NativeDatabase.memory()));
  });

  tearDown(() async {
    await db.close();
  });

  GenerationNotifier buildNotifier({
    required bool isOffline,
    required String activeProvider,
    required Future<void> Function() onSynthesize,
    AudioFileWriter? writeAudio,
    AudioDurationReader? readDuration,
  }) {
    return GenerationNotifier(
      SynthesizeText(_FakeTtsRepository((_) => onSynthesize())),
      AudioRepositoryImpl(AudioLocalDataSource(db)),
      isOffline: () => isOffline,
      activeProviderId: () => activeProvider,
      writeAudio: writeAudio,
      readDuration: readDuration,
    );
  }

  group('Generation is blocked while offline', () {
    test('does not call the provider and explains why', () async {
      var called = false;
      final notifier = buildNotifier(
        isOffline: true,
        activeProvider: TtsProviderIds.google,
        onSynthesize: () async => called = true,
      );

      await notifier.startGeneration(
        text: 'Xin chào các bạn',
        voiceId: 'google-vi-standard',
        voiceName: 'Google Tiếng Việt',
      );

      expect(called, isFalse);
      expect(notifier.state.status, GenerationStatus.error);
      expect(notifier.state.errorMessage, AppStrings.offlineGenerateDisabled);
      notifier.dispose();
    });

    test('runs normally once the device is online', () async {
      var called = false;
      final notifier = buildNotifier(
        isOffline: false,
        activeProvider: TtsProviderIds.google,
        onSynthesize: () async => called = true,
        writeAudio: (bytes, fileName) async => '/tmp/$fileName',
        readDuration: (_) async => const Duration(seconds: 12),
      );

      await notifier.startGeneration(
        text: 'Xin chào các bạn',
        voiceId: 'google-vi-standard',
        voiceName: 'Google Tiếng Việt',
      );
      // Let the stream finish.
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(called, isTrue);
      expect(notifier.state.status, GenerationStatus.success);
      final asset = notifier.state.audioAsset!;
      expect(asset.fileSizeBytes, 3);
      expect(asset.filePath, endsWith('.mp3'));
      expect(asset.duration, const Duration(seconds: 12));
      notifier.dispose();
    });

    test(
      'a slow save is not reported as a failure when the stream ends',
      () async {
        // Regression: onDone used to overwrite the success state while the file
        // was still being written, so a finished generation showed an error.
        final notifier = buildNotifier(
          isOffline: false,
          activeProvider: TtsProviderIds.google,
          onSynthesize: () async {},
          writeAudio: (bytes, fileName) async {
            await Future<void>.delayed(const Duration(milliseconds: 120));
            return '/tmp/$fileName';
          },
          readDuration: (_) async => const Duration(seconds: 3),
        );

        await notifier.startGeneration(
          text: 'Xin chào các bạn',
          voiceId: 'google-vi-standard',
          voiceName: 'Google Tiếng Việt',
        );

        // Right after the stream closes the save is still running.
        await Future<void>.delayed(const Duration(milliseconds: 30));
        expect(notifier.state.errorMessage, isNull);

        await Future<void>.delayed(const Duration(milliseconds: 250));
        expect(notifier.state.status, GenerationStatus.success);
        expect(notifier.state.errorMessage, isNull);
        expect(notifier.state.audioAsset, isNotNull);
        notifier.dispose();
      },
    );

    test('writes the real audio bytes to disk', () async {
      Uint8List? written;
      final notifier = buildNotifier(
        isOffline: false,
        activeProvider: TtsProviderIds.google,
        onSynthesize: () async {},
        writeAudio: (bytes, fileName) async {
          written = bytes;
          return '/tmp/$fileName';
        },
        readDuration: (_) async => Duration.zero,
      );

      await notifier.startGeneration(
        text: 'Chào bạn',
        voiceId: 'google-vi-standard',
        voiceName: 'Google Tiếng Việt',
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(written, Uint8List.fromList([1, 2, 3]));
      notifier.dispose();
    });

    test('an empty audio payload is reported, not faked as success', () async {
      final notifier = GenerationNotifier(
        SynthesizeText(_SilentTtsRepository()),
        AudioRepositoryImpl(AudioLocalDataSource(db)),
        isOffline: () => false,
        activeProviderId: () => TtsProviderIds.google,
        writeAudio: (bytes, fileName) async => '/tmp/$fileName',
        readDuration: (_) async => Duration.zero,
      );

      await notifier.startGeneration(
        text: 'Chào bạn',
        voiceId: 'google-vi-standard',
        voiceName: 'Google Tiếng Việt',
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(notifier.state.status, GenerationStatus.error);
      expect(notifier.state.errorMessage, AppStrings.errorEmptyAudio);
      notifier.dispose();
    });
  });

  group(
    'Provider failure suggests ElevenLabs, but only after confirmation',
    () {
      test('suggests the fallback when Google fails', () async {
        final notifier = buildNotifier(
          isOffline: false,
          activeProvider: TtsProviderIds.google,
          onSynthesize: () async => throw TtsProviderException(
            'Google lỗi',
            statusCode: 503,
            kind: TtsErrorKind.unavailable,
            providerId: TtsProviderIds.google,
          ),
        );

        await notifier.startGeneration(
          text: 'Kịch bản TikTok',
          voiceId: 'google-vi-standard',
          voiceName: 'Google Tiếng Việt',
        );
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(notifier.state.status, GenerationStatus.error);
        expect(
          notifier.state.fallbackProviderId,
          AppConstants.fallbackTtsProvider,
        );
        notifier.dispose();
      });

      test('does not suggest a fallback when the key is wrong', () async {
        final notifier = buildNotifier(
          isOffline: false,
          activeProvider: TtsProviderIds.google,
          onSynthesize: () async => throw TtsProviderException(
            'sai key',
            statusCode: 401,
            kind: TtsErrorKind.unauthorized,
            providerId: TtsProviderIds.google,
          ),
        );

        await notifier.startGeneration(
          text: 'Kịch bản TikTok',
          voiceId: 'google-vi-standard',
          voiceName: 'Google Tiếng Việt',
        );
        await Future<void>.delayed(const Duration(milliseconds: 50));

        // Switching provider would not fix an auth problem, so no dialog.
        expect(notifier.state.fallbackProviderId, isNull);
        notifier.dispose();
      });

      test('does not suggest a fallback when already on ElevenLabs', () async {
        final notifier = buildNotifier(
          isOffline: false,
          activeProvider: TtsProviderIds.elevenLabs,
          onSynthesize: () async => throw TtsProviderException(
            'lỗi',
            statusCode: 500,
            kind: TtsErrorKind.server,
            providerId: TtsProviderIds.elevenLabs,
          ),
        );

        await notifier.startGeneration(
          text: 'Kịch bản TikTok',
          voiceId: 'el-voice-1',
          voiceName: 'Rachel',
        );
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(notifier.state.fallbackProviderId, isNull);
        notifier.dispose();
      });

      test('clearing the suggestion removes it from state', () async {
        final notifier = buildNotifier(
          isOffline: false,
          activeProvider: TtsProviderIds.google,
          onSynthesize: () async => throw TtsProviderException(
            'lỗi',
            statusCode: 502,
            kind: TtsErrorKind.unavailable,
            providerId: TtsProviderIds.google,
          ),
        );

        await notifier.startGeneration(
          text: 'Kịch bản',
          voiceId: 'google-vi-standard',
          voiceName: 'Google',
        );
        await Future<void>.delayed(const Duration(milliseconds: 50));
        expect(notifier.state.fallbackProviderId, isNotNull);

        notifier.clearFallbackSuggestion();
        expect(notifier.state.fallbackProviderId, isNull);
        notifier.dispose();
      });

      test(
        'an Edge rate limit explains itself instead of saying "server"',
        () async {
          final notifier = buildNotifier(
            isOffline: false,
            activeProvider: TtsProviderIds.local,
            onSynthesize: () async => throw TtsProviderException(
              'No audio was received',
              statusCode: 502,
              kind: TtsErrorKind.unavailable,
              providerId: TtsProviderIds.local,
            ),
          );

          await notifier.startGeneration(
            text: 'Kịch bản',
            voiceId: 'vi-VN-NamMinhNeural',
            voiceName: 'Edge NamMinh',
          );
          await Future<void>.delayed(const Duration(milliseconds: 50));

          expect(notifier.state.status, GenerationStatus.error);
          expect(notifier.state.errorMessage, AppStrings.errorEdgeUnavailable);
          expect(notifier.state.errorMessage, isNot(AppStrings.errorServer));
          notifier.dispose();
        },
      );

      test('other providers keep their own error message', () async {
        final notifier = buildNotifier(
          isOffline: false,
          activeProvider: TtsProviderIds.google,
          onSynthesize: () async => throw TtsProviderException(
            'boom',
            statusCode: 502,
            kind: TtsErrorKind.unavailable,
            providerId: TtsProviderIds.google,
          ),
        );

        await notifier.startGeneration(
          text: 'Kịch bản',
          voiceId: 'google-vi-standard',
          voiceName: 'Google',
        );
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(
          notifier.state.errorMessage,
          AppStrings.errorProviderUnavailable,
        );
        notifier.dispose();
      });
    },
  );

  group('Generation retries with a voice from the new provider', () {
    test('retryGenerationWithVoice uses the given provider voice', () async {
      final used = <String>[];
      final notifier = GenerationNotifier(
        SynthesizeText(
          _FakeTtsRepository((request) async {
            used.add(request.voiceId);
          }),
        ),
        AudioRepositoryImpl(AudioLocalDataSource(db)),
        isOffline: () => false,
        activeProviderId: () => TtsProviderIds.elevenLabs,
        writeAudio: (bytes, fileName) async => '/tmp/$fileName',
        readDuration: (_) async => Duration.zero,
      );

      await notifier.startGeneration(
        text: 'Kịch bản',
        voiceId: 'google-vi-standard',
        voiceName: 'Google Tiếng Việt',
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(used, ['google-vi-standard']);

      await notifier.retryGenerationWithVoice(
        voiceId: 'el-voice-1',
        voiceName: 'Rachel',
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(used, ['google-vi-standard', 'el-voice-1']);
      expect(notifier.state.status, GenerationStatus.success);
      notifier.dispose();
    });
  });

  group('Repository keeps provider metadata on responses', () {
    test('synthesize reports which provider produced the audio', () async {
      final repository = TtsRepositoryImpl(
        TtsRemoteDatasource(
          client: MockClient((_) async => http.Response.bytes([1, 2], 200)),
          baseUrl: 'https://backend.test/v1',
          apiKey: '',
          provider: TtsProviderIds.google,
        ),
        VoiceLocalDataSource(db),
      );

      final response = await repository.synthesize(
        TtsRequest(id: 'req_1', text: 'Chào', voiceId: 'google-vi-standard'),
      );

      expect(response.metadata?['provider'], TtsProviderIds.google);
      expect(response.metadata?['bytes'], 2);
    });
  });
}
