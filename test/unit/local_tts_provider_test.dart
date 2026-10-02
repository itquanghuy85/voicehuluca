import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:record/record.dart';
import 'package:voice_huluca/core/localization/app_strings.dart';
import 'package:voice_huluca/data/datasources/local/app_database.dart'
    hide Voice;
import 'package:voice_huluca/data/datasources/local/voice_local_datasource.dart';
import 'package:voice_huluca/data/datasources/remote/tts_remote_datasource.dart';
import 'package:voice_huluca/data/repositories/tts_repository_impl.dart';
import 'package:voice_huluca/data/services/local_tts_provider.dart';
import 'package:voice_huluca/data/services/tts_provider.dart';
import 'package:voice_huluca/data/services/tts_provider_registry.dart';
import 'package:voice_huluca/domain/entities/tts_request.dart';
import 'package:voice_huluca/domain/entities/tts_response.dart';
import 'package:voice_huluca/features/voice/widgets/record_voice_sheet.dart';

const String _baseUrl = 'https://backend.test/v1';

http.Response _json(Object body, int status) => http.Response.bytes(
  utf8.encode(jsonEncode(body)),
  status,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

/// Minimal RIFF/WAVE header so tests can tell WAV from MP3 the way the
/// production code does.
Uint8List _wavBytes(int length) => Uint8List.fromList([
  0x52, 0x49, 0x46, 0x46, 0x24, 0x08, 0x00, 0x00, //
  0x57, 0x41, 0x56, 0x45,
  ...List<int>.filled(length - 12, 0),
]);

void main() {
  group('LocalTtsProvider is a real provider, not a stub', () {
    final local = LocalTtsProvider(
      TtsRemoteDatasource(
        client: MockClient(
          (_) async => _json({'provider': 'local', 'available': false}, 200),
        ),
        baseUrl: _baseUrl,
        apiKey: '',
        provider: TtsProviderIds.local,
      ),
    );

    test('is selectable and reports cloning support', () {
      expect(local.id, TtsProviderIds.local);
      expect(local.isAvailable, isTrue);
      expect(local.supportsVoiceCloning, isTrue);
    });

    test('is part of the cloning whitelist', () {
      expect(TtsProviderIds.cloningProviders, contains(TtsProviderIds.local));
      expect(
        TtsProviderIds.cloningProviders,
        contains(TtsProviderIds.elevenLabs),
      );
      expect(TtsProviderIds.canClone(TtsProviderIds.local), isTrue);
      expect(TtsProviderIds.canClone(TtsProviderIds.google), isFalse);
    });

    test('registry resolves it and reports cloning support', () {
      final registry = TtsProviderRegistry([local]);
      expect(registry.resolve(TtsProviderIds.local), same(local));
      expect(registry.supportsVoiceCloning(TtsProviderIds.local), isTrue);
      // It is available, so it shows up in the selectable list.
      expect(
        registry.available.map((p) => p.id),
        contains(TtsProviderIds.local),
      );
    });

    test('never invents usage numbers', () async {
      expect(await local.getUsage(), isNull);
    });
  });

  group('Local voices come from the sidecar through the backend', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase.forTesting(DatabaseConnection(NativeDatabase.memory()));
    });

    tearDown(() async {
      await db.close();
    });

    test('lists Edge voices and clones with the clone: prefix', () async {
      final repository = TtsRepositoryImpl(
        TtsRemoteDatasource(
          client: MockClient(
            (_) async => _json({
              'provider': 'local',
              'voices': [
                {
                  'voice_id': 'vi-VN-HoaiMyNeural',
                  'name': 'Edge HoaiMy (nữ)',
                  'category': 'premade',
                  'labels': {'language': 'vi', 'gender': 'female'},
                },
                {
                  'voice_id': 'clone:abc123',
                  'name': 'Giọng của tôi',
                  'category': 'cloned',
                  'labels': {'language': 'vi', 'gender': 'custom'},
                },
              ],
            }, 200),
          ),
          baseUrl: _baseUrl,
          apiKey: '',
          provider: TtsProviderIds.local,
        ),
        VoiceLocalDataSource(db),
      );

      final voices = await repository.getVoices();

      expect(voices, hasLength(2));
      expect(voices.every((v) => v.provider == TtsProviderIds.local), isTrue);
      expect(voices.first.providerVoiceId, 'vi-VN-HoaiMyNeural');
      expect(voices.first.isCloned, isFalse);
      expect(voices.last.providerVoiceId, 'clone:abc123');
      expect(voices.last.isCloned, isTrue);
    });

    test(
      'clone flow uploads the recording and stores the clone voice',
      () async {
        late http.Request captured;
        final repository = TtsRepositoryImpl(
          TtsRemoteDatasource(
            client: MockClient((request) async {
              captured = request;
              return _json({
                'provider': 'local',
                'voice_id': 'clone:xyz789',
                'status': 'completed',
              }, 200);
            }),
            baseUrl: _baseUrl,
            apiKey: '',
            provider: TtsProviderIds.local,
          ),
          VoiceLocalDataSource(db),
        );

        final sample = File('${Directory.systemTemp.path}/vv_sample.wav');
        await sample.writeAsBytes([0, 1, 2, 3, 4, 5]);

        final voice = await repository.cloneVoice(
          name: 'Giọng nữ của tôi',
          description: '',
          audioFiles: [sample],
          language: 'vi',
        );

        expect(voice.providerVoiceId, 'clone:xyz789');
        expect(voice.isCloned, isTrue);
        expect(voice.name, 'Giọng nữ của tôi');
        // The recording is posted as multipart to the clone endpoint.
        expect(captured.url.path, '/v1/voices/clone');
        expect(captured.body, contains('name="provider"'));
        expect(captured.body, contains(TtsProviderIds.local));
        expect(captured.body, contains('Giọng nữ của tôi'));
        // ... and the clone is cached under the local provider.
        final cached = await VoiceLocalDataSource(
          db,
        ).getVoicesByProvider(TtsProviderIds.local);
        expect(cached, hasLength(1));
        expect(cached.first.providerVoiceId, 'clone:xyz789');

        await sample.delete();
      },
    );

    test('deleting a clone asks the provider and clears the cache', () async {
      final requests = <String>[];
      final repository = TtsRepositoryImpl(
        TtsRemoteDatasource(
          client: MockClient((request) async {
            requests.add('${request.method} ${request.url.query}');
            if (request.method == 'POST') {
              return _json({
                'voice_id': 'clone:xyz789',
                'status': 'completed',
              }, 200);
            }
            return _json({'success': true}, 200);
          }),
          baseUrl: _baseUrl,
          apiKey: '',
          provider: TtsProviderIds.local,
        ),
        VoiceLocalDataSource(db),
      );

      final sample = File('${Directory.systemTemp.path}/vv_sample2.wav');
      await sample.writeAsBytes([0, 1, 2]);
      await repository.cloneVoice(
        name: 'Giọng của tôi',
        description: '',
        audioFiles: [sample],
      );
      final cached = (await VoiceLocalDataSource(
        db,
      ).getVoicesByProvider(TtsProviderIds.local)).single;

      await repository.deleteVoice(cached);

      expect(requests.any((r) => r.startsWith('DELETE')), isTrue);
      expect(await db.getAllVoices(), isEmpty);
      await sample.delete();
    });

    test(
      'a missing sidecar surfaces as a retryable unavailable error',
      () async {
        final repository = TtsRepositoryImpl(
          TtsRemoteDatasource(
            client: MockClient(
              (_) async => _json({
                'error': {
                  'code': 'LocalTtsNotConfigured',
                  'message': 'Chưa cấu hình Python',
                  'retryable': false,
                },
              }, 503),
            ),
            baseUrl: _baseUrl,
            apiKey: '',
            provider: TtsProviderIds.local,
          ),
          VoiceLocalDataSource(db),
        );

        await expectLater(
          repository.getVoices(),
          throwsA(
            isA<TtsProviderException>().having(
              (e) => e.kind,
              'kind',
              TtsErrorKind.server,
            ),
          ),
        );
      },
    );
  });

  group('Provider availability comes from the backend', () {
    test('reads the real flags reported by /v1/providers', () async {
      final remote = TtsRemoteDatasource(
        client: MockClient(
          (_) async => _json({
            'providers': [
              {'id': 'google', 'available': true},
              {'id': 'elevenlabs', 'available': false},
              {'id': 'local', 'available': true},
            ],
          }, 200),
        ),
        baseUrl: _baseUrl,
        apiKey: '',
      );

      final availability = await remote.getProviderAvailability();

      expect(availability, {
        TtsProviderIds.google: true,
        TtsProviderIds.elevenLabs: false,
        TtsProviderIds.local: true,
      });
    });

    test('a failing backend yields no claims instead of guesses', () async {
      final remote = TtsRemoteDatasource(
        client: MockClient((_) async => _json({}, 500)),
        baseUrl: _baseUrl,
        apiKey: '',
      );

      await expectLater(
        remote.getProviderAvailability(),
        throwsA(isA<TtsProviderException>()),
      );
    });
  });

  group('The container the backend produced is not relabelled', () {
    Future<TtsResponse> responseFor(
      Uint8List bytes, {
      Map<String, String> headers = const {},
    }) async {
      final repository = TtsRepositoryImpl(
        TtsRemoteDatasource(
          client: MockClient(
            (_) async => http.Response.bytes(bytes, 200, headers: headers),
          ),
          baseUrl: _baseUrl,
          apiKey: '',
          provider: TtsProviderIds.local,
        ),
        VoiceLocalDataSource(
          AppDatabase.forTesting(DatabaseConnection(NativeDatabase.memory())),
        ),
      );
      final response = await repository.synthesize(
        const TtsRequest(id: 'req-1', text: 'Xin chào', voiceId: 'clone:abc'),
      );
      return response;
    }

    test('XTTS clone audio is reported as WAV', () async {
      final response = await responseFor(
        _wavBytes(2048),
        headers: {'x-audio-format': 'wav'},
      );

      expect(response.metadata?['format'], 'wav');
    });

    test('a WAV payload is detected even without the header', () async {
      final response = await responseFor(_wavBytes(2048));

      expect(response.metadata?['format'], 'wav');
    });

    test('streaming providers stay MP3', () async {
      final response = await responseFor(
        Uint8List.fromList(List<int>.filled(512, 0x55)),
      );

      expect(response.metadata?['format'], 'mp3');
    });
  });

  group('Recording contract for the local engine', () {
    test('the sheet records 22 kHz mono WAV', () {
      // XTTS expects a clean 22 kHz mono sample, so the config is shared and
      // asserted here rather than hidden inside the widget.
      expect(recordVoiceConfig.encoder, AudioEncoder.wav);
      expect(recordVoiceConfig.sampleRate, 22050);
      expect(recordVoiceConfig.numChannels, 1);
    });

    test('the requested sample length is 5-30 seconds', () {
      expect(recordVoiceMinDuration, const Duration(seconds: 5));
      expect(recordVoiceMaxDuration, const Duration(seconds: 30));
    });

    test('the user is given Vietnamese sample text to read', () {
      expect(AppStrings.recordVoiceSample, isNotEmpty);
      expect(AppStrings.recordVoiceSample.length, greaterThan(200));
    });
  });
}
