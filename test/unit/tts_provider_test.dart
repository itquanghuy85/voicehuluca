import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:voice_huluca/core/constants/app_constants.dart';
import 'package:voice_huluca/core/localization/app_strings.dart';
import 'package:voice_huluca/core/utils/connectivity_utils.dart';
import 'package:voice_huluca/data/datasources/remote/tts_remote_datasource.dart';
import 'package:voice_huluca/data/services/elevenlabs_provider.dart';
import 'package:voice_huluca/data/services/google_tts_provider.dart';
import 'package:voice_huluca/data/services/local_tts_provider.dart';
import 'package:voice_huluca/data/services/tts_provider.dart';
import 'package:voice_huluca/data/services/tts_provider_registry.dart';
import 'package:voice_huluca/features/voice/voice_provider.dart'
    show mapTtsErrorKind;

const String _testBaseUrl = 'https://backend.test/v1';

/// UTF-8 JSON response, so Vietnamese payloads are not mangled by latin1.
http.Response _json(Object body, int status) => http.Response.bytes(
  utf8.encode(jsonEncode(body)),
  status,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

TtsRemoteDatasource _datasource(
  MockClient client, {
  String provider = TtsProviderIds.google,
  String apiKey = '',
}) {
  return TtsRemoteDatasource(
    client: client,
    baseUrl: _testBaseUrl,
    apiKey: apiKey,
    provider: provider,
  );
}

void main() {
  group('TtsProviderRegistry', () {
    late GoogleTtsProvider google;
    late ElevenLabsProvider elevenLabs;
    late LocalTtsProvider local;
    late TtsProviderRegistry registry;

    setUp(() {
      final remote = _datasource(
        MockClient((_) async => http.Response('{}', 200)),
        provider: TtsProviderIds.google,
      );
      google = GoogleTtsProvider(remote);
      elevenLabs = ElevenLabsProvider(remote);
      local = LocalTtsProvider(remote);
      registry = TtsProviderRegistry([google, elevenLabs, local]);
    });

    test('registers and resolves providers by id', () {
      expect(registry.ids, TtsProviderIds.all);
      expect(registry.getById(TtsProviderIds.google), same(google));
      expect(registry.getById(TtsProviderIds.elevenLabs), same(elevenLabs));
      expect(registry.getById(TtsProviderIds.local), same(local));
      expect(registry.contains(TtsProviderIds.google), isTrue);
    });

    test('unknown id resolves to the Google default instead of throwing', () {
      expect(registry.resolve('does-not-exist'), same(google));
      expect(registry.resolve(null), same(google));
      expect(registry.getById('does-not-exist'), isNull);
    });

    test('resolve returns the provider matching the selected id', () {
      expect(registry.resolve(TtsProviderIds.elevenLabs), same(elevenLabs));
    });

    test('available lists every provider that can be selected', () {
      final availableIds = registry.available.map((p) => p.id).toList();
      expect(availableIds, TtsProviderIds.all);
    });

    test('re-registering the same id replaces the provider', () {
      final replacement = GoogleTtsProvider(
        _datasource(MockClient((_) async => http.Response('{}', 200))),
      );
      registry.register(replacement);
      expect(registry.getById(TtsProviderIds.google), same(replacement));
      expect(registry.ids.length, 3);
    });

    test('unregister and clear remove providers', () {
      registry.unregister(TtsProviderIds.elevenLabs);
      expect(registry.contains(TtsProviderIds.elevenLabs), isFalse);
      registry.clear();
      expect(registry.ids, isEmpty);
      expect(
        () => registry.resolve(null),
        throwsA(isA<TtsProviderUnavailableException>()),
      );
    });

    test('voice cloning is limited to the local and ElevenLabs providers', () {
      expect(registry.supportsVoiceCloning(TtsProviderIds.google), isFalse);
      expect(registry.supportsVoiceCloning(TtsProviderIds.elevenLabs), isTrue);
      expect(registry.supportsVoiceCloning(TtsProviderIds.local), isTrue);
      expect(TtsProviderIds.cloningProviders, [
        TtsProviderIds.elevenLabs,
        TtsProviderIds.local,
      ]);
    });
  });

  group('LocalTtsProvider is a real provider', () {
    late LocalTtsProvider local;

    setUp(() {
      local = LocalTtsProvider(
        _datasource(
          MockClient(
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
                  'voice_id': 'clone:abc',
                  'name': 'Giọng của tôi',
                  'category': 'cloned',
                  'labels': {'language': 'vi', 'gender': 'custom'},
                },
              ],
            }, 200),
          ),
          provider: TtsProviderIds.local,
        ),
      );
    });

    test('is selectable and supports cloning', () {
      expect(local.id, TtsProviderIds.local);
      expect(local.isAvailable, isTrue);
      expect(local.supportsVoiceCloning, isTrue);
    });

    test('lists Edge voices and local clones', () async {
      final voices = await local.getVoices();
      expect(voices.map((v) => v.providerVoiceId), [
        'vi-VN-HoaiMyNeural',
        'clone:abc',
      ]);
      expect(voices.first.isCloned, isFalse);
      expect(voices.last.isCloned, isTrue);
    });

    test('synthesizes through the backend and reports the provider', () async {
      final audio = Uint8List.fromList([1, 2, 3, 4, 5]);
      final provider = LocalTtsProvider(
        _datasource(
          MockClient((_) async => http.Response.bytes(audio, 200)),
          provider: TtsProviderIds.local,
        ),
      );

      final result = await provider.synthesize(
        voiceId: 'clone:abc',
        text: 'Xin chào',
      );

      expect(result.providerId, TtsProviderIds.local);
      expect(result.audio, audio);
    });

    test('clones from a sample file', () async {
      final file = File('${Directory.systemTemp.path}/vv_local_clone.wav');
      await file.writeAsBytes([1, 2, 3]);
      final provider = LocalTtsProvider(
        _datasource(
          MockClient((_) async => _json({'voice_id': 'clone:new'}, 200)),
          provider: TtsProviderIds.local,
        ),
      );

      final voice = await provider.cloneVoice(
        name: 'Giọng tôi',
        description: '',
        audioFiles: [file],
      );

      expect(voice.providerVoiceId, 'clone:new');
      expect(voice.isCloned, isTrue);
      await file.delete();
    });

    test('reports no usage numbers', () async {
      final provider = LocalTtsProvider(
        _datasource(
          MockClient(
            (_) async => _json({'provider': 'local', 'available': false}, 200),
          ),
          provider: TtsProviderIds.local,
        ),
      );
      expect(await provider.getUsage(), isNull);
    });
  });
  group('Provider capability contract', () {
    test(
      'Google does not claim cloning support and throws when asked',
      () async {
        final google = GoogleTtsProvider(
          _datasource(MockClient((_) async => http.Response('{}', 200))),
        );
        expect(google.supportsVoiceCloning, isFalse);
        await expectLater(
          google.cloneVoice(name: 'a', description: '', audioFiles: const []),
          throwsA(
            isA<TtsOperationNotSupportedException>().having(
              (e) => e.kind,
              'kind',
              TtsErrorKind.unsupported,
            ),
          ),
        );
      },
    );

    test('ElevenLabs claims cloning support and is available', () {
      final elevenLabs = ElevenLabsProvider(
        _datasource(
          MockClient((_) async => http.Response('{}', 200)),
          provider: TtsProviderIds.elevenLabs,
        ),
      );
      expect(elevenLabs.supportsVoiceCloning, isTrue);
      expect(elevenLabs.isAvailable, isTrue);
    });
  });

  group('Provider result mapping', () {
    test(
      'synthesize returns audio bytes, character count and provider id',
      () async {
        final audio = Uint8List.fromList([1, 2, 3, 4]);
        final provider = GoogleTtsProvider(
          _datasource(MockClient((_) async => http.Response.bytes(audio, 200))),
        );

        final result = await provider.synthesize(
          voiceId: 'google-vi-standard',
          text: 'Xin chào',
        );

        expect(result.audio, audio);
        expect(result.characterCount, 'Xin chào'.length);
        expect(result.providerId, TtsProviderIds.google);
      },
    );
  });

  group('Datasource request contract', () {
    test('sends the app API key and the selected provider', () async {
      late http.Request captured;
      final remote = _datasource(
        MockClient((request) async {
          captured = request;
          return _json({'voices': []}, 200);
        }),
        apiKey: 'vvt-key-123',
      );

      await remote.getVoices();

      expect(captured.headers['x-vvt-api-key'], 'vvt-key-123');
      expect(captured.url.path, '/v1/voices');
      expect(captured.url.queryParameters['provider'], TtsProviderIds.google);
    });

    test(
      'getVoices maps provider voices with the active provider id',
      () async {
        final remote = _datasource(
          MockClient(
            (_) async => _json({
              'provider': 'google',
              'voices': [
                {
                  'voice_id': 'google-vi-standard',
                  'name': 'Google Tiếng Việt',
                  'description': 'mô tả',
                  'category': 'premade',
                  'labels': {'language': 'vi', 'gender': 'female'},
                },
              ],
            }, 200),
          ),
        );

        final voices = await remote.getVoices();

        expect(voices, hasLength(1));
        expect(voices.first.provider, TtsProviderIds.google);
        expect(voices.first.providerVoiceId, 'google-vi-standard');
        expect(voices.first.name, 'Google Tiếng Việt');
        expect(voices.first.language, 'vi');
        expect(voices.first.gender, 'female');
        expect(voices.first.isCloned, isFalse);
      },
    );

    test(
      'synthesize posts provider, voiceId, text and options to /tts',
      () async {
        late http.Request captured;
        final remote = _datasource(
          MockClient((request) async {
            captured = request;
            return http.Response.bytes([9, 8, 7], 200);
          }),
          provider: TtsProviderIds.google,
        );

        final audio = await remote.synthesize(
          voiceId: 'google-vi-standard',
          text: 'Chào bạn',
          options: const TtsOptions(speed: 1.25),
        );

        expect(audio, [9, 8, 7]);
        expect(captured.method, 'POST');
        expect(captured.url.path, '/v1/tts');
        final body = jsonDecode(captured.body) as Map<String, dynamic>;
        expect(body['provider'], TtsProviderIds.google);
        expect(body['voiceId'], 'google-vi-standard');
        expect(body['text'], 'Chào bạn');
        expect((body['options'] as Map<String, dynamic>)['speed'], 1.25);
      },
    );

    test('cloneVoice posts to /voices/clone with the provider field', () async {
      late http.Request captured;
      final remote = _datasource(
        MockClient((request) async {
          captured = request;
          return _json({'voice_id': 'cloned-1'}, 200);
        }),
        provider: TtsProviderIds.elevenLabs,
      );
      final file = File('${Directory.systemTemp.path}/clone_sample.mp3');
      await file.writeAsBytes([1, 2, 3]);

      final voice = await remote.cloneVoice(
        name: 'Giọng của tôi',
        description: 'mẫu',
        audioFiles: [file],
        language: 'vi',
      );

      expect(voice.providerVoiceId, 'cloned-1');
      expect(voice.isCloned, isTrue);
      expect(captured.url.path, '/v1/voices/clone');
      expect(captured.body, contains('name="provider"'));
      expect(captured.body, contains(TtsProviderIds.elevenLabs));
      expect(captured.body, contains('name="name"'));
      expect(captured.body, contains('Giọng của tôi'));
      await file.delete();
    });

    test('deleteVoice targets the provider scoped endpoint', () async {
      late http.Request captured;
      final remote = _datasource(
        MockClient((request) async {
          captured = request;
          return _json({'success': true}, 200);
        }),
        provider: TtsProviderIds.elevenLabs,
      );

      await remote.deleteVoice('voice/1');

      expect(captured.method, 'DELETE');
      expect(
        captured.url.queryParameters['provider'],
        TtsProviderIds.elevenLabs,
      );
      expect(captured.url.path, contains('voice%2F1'));
    });
  });

  group('Datasource failure handling', () {
    test('401 maps to unauthorized', () async {
      final remote = _datasource(
        MockClient(
          (_) async => _json({
            'error': {'code': 'InvalidApiKey', 'message': 'sai key'},
          }, 401),
        ),
        apiKey: 'bad',
      );

      await expectLater(
        remote.getVoices(),
        throwsA(
          isA<TtsProviderException>()
              .having((e) => e.kind, 'kind', TtsErrorKind.unauthorized)
              .having((e) => e.providerId, 'providerId', TtsProviderIds.google),
        ),
      );
    });

    test('501 VoiceCloningNotSupported maps to unsupported', () async {
      final remote = _datasource(
        MockClient(
          (_) async => _json({
            'error': {
              'code': 'VoiceCloningNotSupported',
              'message': 'không hỗ trợ',
            },
          }, 501),
        ),
      );
      final file = File('${Directory.systemTemp.path}/clone_sample.mp3');
      await file.writeAsBytes([1]);

      await expectLater(
        remote.cloneVoice(name: 'a', description: '', audioFiles: [file]),
        throwsA(
          isA<TtsProviderException>().having(
            (e) => e.kind,
            'kind',
            TtsErrorKind.unsupported,
          ),
        ),
      );
      await file.delete();
    });

    test(
      '503 ServiceUnavailable maps to a retryable unavailable failure',
      () async {
        final remote = _datasource(
          MockClient(
            (_) async => _json({
              'error': {'code': 'ServiceUnavailable', 'message': 'gián đoạn'},
            }, 503),
          ),
        );

        await expectLater(
          remote.synthesize(voiceId: 'v', text: 't'),
          throwsA(
            isA<TtsProviderException>()
                .having((e) => e.kind, 'kind', TtsErrorKind.unavailable)
                .having((e) => e.isRetryable, 'isRetryable', isTrue),
          ),
        );
      },
    );

    test('plain 500 maps to a retryable server failure', () async {
      final remote = _datasource(
        MockClient(
          (_) async => _json({
            'error': {'code': 'InternalServerError', 'message': 'lỗi'},
          }, 500),
        ),
      );

      await expectLater(
        remote.synthesize(voiceId: 'v', text: 't'),
        throwsA(
          isA<TtsProviderException>()
              .having((e) => e.kind, 'kind', TtsErrorKind.server)
              .having((e) => e.isRetryable, 'isRetryable', isTrue),
        ),
      );
    });

    test('400 UnknownProvider maps to a validation error', () async {
      final remote = _datasource(
        MockClient(
          (_) async => _json({
            'error': {'code': 'UnknownProvider', 'message': 'sai'},
          }, 400),
        ),
      );

      await expectLater(
        remote.getVoices(),
        throwsA(
          isA<TtsProviderException>().having(
            (e) => e.kind,
            'kind',
            TtsErrorKind.validation,
          ),
        ),
      );
    });

    test(
      'unexpected HTML error body still produces a typed exception',
      () async {
        final remote = _datasource(
          MockClient((_) async => http.Response('<html>oops</html>', 500)),
        );

        await expectLater(
          remote.getVoices(),
          throwsA(
            isA<TtsProviderException>()
                .having((e) => e.kind, 'kind', TtsErrorKind.server)
                .having((e) => e.statusCode, 'statusCode', 500),
          ),
        );
      },
    );
  });

  group('Usage is only shown when the provider reports it', () {
    test('returns null when the provider has no usage data', () async {
      final remote = _datasource(
        MockClient(
          (_) async => _json({'provider': 'google', 'available': false}, 200),
        ),
      );

      expect(await remote.getUsage(), isNull);
    });

    test('parses real usage numbers when available', () async {
      final remote = _datasource(
        MockClient(
          (_) async => _json({
            'provider': 'elevenlabs',
            'available': true,
            'charactersUsed': 1200,
            'charactersLimit': 10000,
            'tier': 'creator',
            'resetAt': 1767225600,
          }, 200),
        ),
        provider: TtsProviderIds.elevenLabs,
      );

      final usage = await remote.getUsage();

      expect(usage, isNotNull);
      expect(usage!.charactersUsed, 1200);
      expect(usage.charactersLimit, 10000);
      expect(usage.charactersRemaining, 8800);
      expect(usage.usedRatio, closeTo(0.12, 0.0001));
      expect(usage.tier, 'creator');
      expect(usage.resetAt, isNotNull);
    });
  });

  group('Error kind to message mapping', () {
    test('every provider error kind has a user facing message', () {
      for (final kind in TtsErrorKind.values) {
        expect(mapTtsErrorKind(kind), isNotEmpty, reason: 'missing for $kind');
      }
      expect(
        mapTtsErrorKind(TtsErrorKind.unsupported),
        AppStrings.errorProviderUnsupported,
      );
      expect(
        mapTtsErrorKind(TtsErrorKind.unavailable),
        AppStrings.errorProviderUnavailable,
      );
      expect(mapTtsErrorKind(TtsErrorKind.network), AppStrings.errorNetwork);
    });
  });

  group('Offline detection', () {
    test('no connectivity result means offline', () {
      expect(isOfflineResult(const []), isTrue);
    });

    test('none means offline', () {
      expect(isOfflineResult(const [ConnectivityResult.none]), isTrue);
    });

    test('any usable transport means online', () {
      expect(isOfflineResult(const [ConnectivityResult.wifi]), isFalse);
      expect(isOfflineResult(const [ConnectivityResult.mobile]), isFalse);
      expect(isOfflineResult(const [ConnectivityResult.ethernet]), isFalse);
      expect(
        isOfflineResult(const [
          ConnectivityResult.none,
          ConnectivityResult.wifi,
        ]),
        isFalse,
      );
    });
  });

  group('Provider id constants', () {
    test('default provider is Google and fallback is ElevenLabs', () {
      expect(AppConstants.defaultTtsProvider, TtsProviderIds.google);
      expect(AppConstants.fallbackTtsProvider, TtsProviderIds.elevenLabs);
      expect(TtsProviderIds.defaultProvider, TtsProviderIds.google);
    });
  });
}
