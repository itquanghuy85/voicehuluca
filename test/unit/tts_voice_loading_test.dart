import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:voice_huluca/core/localization/app_strings.dart';
import 'package:voice_huluca/core/constants/app_constants.dart';
import 'package:voice_huluca/core/network/network_failure.dart';
import 'package:voice_huluca/data/datasources/local/app_database.dart';
import 'package:voice_huluca/data/datasources/local/settings_local_datasource.dart';
import 'package:voice_huluca/data/datasources/local/voice_local_datasource.dart';
import 'package:voice_huluca/data/datasources/remote/tts_remote_datasource.dart';
import 'package:voice_huluca/data/repositories/tts_repository_impl.dart';
import 'package:voice_huluca/data/services/tts_provider.dart'
    show TtsErrorKind, TtsProviderException, TtsProviderIds;
import 'package:voice_huluca/domain/entities/tts_request.dart';
import 'package:voice_huluca/features/voice/voice_provider.dart'
    show
        mapError,
        ttsProviderIdProvider,
        httpClientFactoryProvider,
        voiceListProvider,
        backendUrlProvider,
        BackendUrlNotifier,
        mapTtsErrorKind;

const String _baseUrl = 'https://backend.test/v1';

/// Pins the backend address so these tests exercise voice loading rather than
/// how an unconfigured build resolves its address.
class _FixedBackendUrl extends BackendUrlNotifier {
  _FixedBackendUrl(this.url);

  final String url;

  @override
  String build() => url;
}

http.Response _json(Object body, int status) => http.Response.bytes(
  utf8.encode(jsonEncode(body)),
  status,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

/// Voice list as returned by the Google provider.
List<Map<String, dynamic>> _googleVoicePayload() => [
  {
    'voice_id': 'google-vi-standard',
    'name': 'Google Tiếng Việt',
    'category': 'premade',
    'labels': {'language': 'vi', 'gender': 'female'},
  },
];

/// Voice list as returned by the ElevenLabs provider.
List<Map<String, dynamic>> _elevenLabsVoicePayload() => [
  {
    'voice_id': 'el-voice-1',
    'name': 'Rachel',
    'category': 'premade',
    'labels': {'language': 'vi', 'gender': 'female'},
  },
  {
    'voice_id': 'el-cloned-1',
    'name': 'Giọng của tôi',
    'category': 'cloned',
    'labels': {'language': 'vi', 'gender': 'male'},
  },
];

TtsRepositoryImpl _repository(
  AppDatabase db,
  MockClient client, {
  String provider = TtsProviderIds.google,
}) {
  return TtsRepositoryImpl(
    TtsRemoteDatasource(
      client: client,
      baseUrl: _baseUrl,
      apiKey: '',
      provider: provider,
    ),
    VoiceLocalDataSource(db),
  );
}

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(DatabaseConnection(NativeDatabase.memory()));
  });

  tearDown(() async {
    await db.close();
  });

  group('Voice loading is scoped to the active provider', () {
    test('loads and caches provider voices on first call', () async {
      final repository = _repository(
        db,
        MockClient(
          (_) async => _json({
            'provider': 'google',
            'voices': _googleVoicePayload(),
          }, 200),
        ),
      );

      final voices = await repository.getVoices();

      expect(voices, hasLength(1));
      expect(voices.first.provider, TtsProviderIds.google);
      expect(voices.first.providerVoiceId, 'google-vi-standard');
      // Cached with a real local id so selection and favourites work.
      expect(voices.first.id, greaterThan(0));
      expect(repository.providerId, TtsProviderIds.google);
    });

    test(
      'serves the cache on later calls without hitting the provider',
      () async {
        var calls = 0;
        final repository = _repository(
          db,
          MockClient((_) async {
            calls += 1;
            return _json({
              'provider': 'google',
              'voices': _googleVoicePayload(),
            }, 200);
          }),
        );

        await repository.getVoices();
        await repository.getVoices();

        expect(calls, 1);
      },
    );

    test('force refresh re-reads the provider and keeps favourites', () async {
      final repository = _repository(
        db,
        MockClient(
          (_) async => _json({
            'provider': 'google',
            'voices': _googleVoicePayload(),
          }, 200),
        ),
      );

      final first = await repository.getVoices();
      await VoiceLocalDataSource(db).toggleFavorite(first.first.id, true);

      final refreshed = await repository.getVoices(forceRefresh: true);

      expect(refreshed, hasLength(1));
      expect(refreshed.first.id, first.first.id);
      expect(refreshed.first.isFavorite, isTrue);
    });

    test('switching provider returns that provider voices only', () async {
      final googleRepo = _repository(
        db,
        MockClient(
          (_) async => _json({
            'provider': 'google',
            'voices': _googleVoicePayload(),
          }, 200),
        ),
      );
      final elevenLabsRepo = _repository(
        db,
        MockClient(
          (_) async => _json({
            'provider': 'elevenlabs',
            'voices': _elevenLabsVoicePayload(),
          }, 200),
        ),
        provider: TtsProviderIds.elevenLabs,
      );

      final googleVoices = await googleRepo.getVoices();
      final elevenLabsVoices = await elevenLabsRepo.getVoices();

      expect(googleVoices.map((v) => v.provider), everyElement('google'));
      expect(
        elevenLabsVoices.map((v) => v.provider),
        everyElement(TtsProviderIds.elevenLabs),
      );
      expect(
        elevenLabsVoices.where((v) => v.isCloned).map((v) => v.name),
        contains('Giọng của tôi'),
      );
      // Both lists stay in the local cache side by side.
      expect(await db.getAllVoices(), hasLength(3));
    });

    test('switching back to the previous provider reuses its cache', () async {
      var googleCalls = 0;
      MockClient googleClient() => MockClient((_) async {
        googleCalls += 1;
        return _json({
          'provider': 'google',
          'voices': _googleVoicePayload(),
        }, 200);
      });

      final googleRepo = _repository(db, googleClient());
      await googleRepo.getVoices();
      final elevenLabsRepo = _repository(
        db,
        MockClient(
          (_) async => _json({
            'provider': 'elevenlabs',
            'voices': _elevenLabsVoicePayload(),
          }, 200),
        ),
        provider: TtsProviderIds.elevenLabs,
      );
      await elevenLabsRepo.getVoices();

      final backToGoogle = await _repository(db, googleClient()).getVoices();

      expect(googleCalls, 1);
      expect(backToGoogle.single.providerVoiceId, 'google-vi-standard');
    });

    test('provider failure surfaces as a typed exception', () async {
      final repository = _repository(
        db,
        MockClient(
          (_) async => _json({
            'error': {'code': 'InvalidApiKey', 'message': 'chưa cấu hình'},
          }, 401),
        ),
      );

      await expectLater(
        repository.getVoices(),
        throwsA(
          isA<TtsProviderException>().having(
            (e) => e.kind,
            'kind',
            TtsErrorKind.unauthorized,
          ),
        ),
      );
    });
  });

  group('Cloned voices are stored per provider', () {
    test('clone inserts the voice for the active provider only', () async {
      final repository = _repository(
        db,
        MockClient((_) async => _json({'voice_id': 'cloned-9'}, 200)),
        provider: TtsProviderIds.elevenLabs,
      );
      final file = VoiceCloningFileHelper.createTempFile();

      final voice = await repository.cloneVoice(
        name: 'Giọng mới',
        description: 'mẫu tiếng Việt',
        audioFiles: [file],
        language: 'vi',
      );

      expect(voice.provider, TtsProviderIds.elevenLabs);
      expect(voice.isCloned, isTrue);

      final stored = await db.getVoicesByProvider(TtsProviderIds.elevenLabs);
      expect(stored, hasLength(1));
      expect(stored.first.name, 'Giọng mới');
      expect(await db.getVoicesByProvider(TtsProviderIds.google), isEmpty);

      file.deleteSync();
    });

    test(
      'deleteVoice removes the cloned voice from cache and provider',
      () async {
        final deleted = <String>[];
        final repository = _repository(
          db,
          MockClient((request) async {
            if (request.method == 'DELETE') {
              deleted.add(request.url.queryParameters['provider'] ?? '');
              return _json({'success': true}, 200);
            }
            return _json({'voice_id': 'cloned-9'}, 200);
          }),
          provider: TtsProviderIds.elevenLabs,
        );
        final file = VoiceCloningFileHelper.createTempFile();
        await repository.cloneVoice(
          name: 'Giọng mới',
          description: '',
          audioFiles: [file],
        );
        final voiceRepository = VoiceLocalDataSource(db);
        final cached = (await voiceRepository.getVoicesByProvider(
          TtsProviderIds.elevenLabs,
        )).single;

        await repository.deleteVoice(cached);

        expect(deleted, [TtsProviderIds.elevenLabs]);
        expect(await db.getAllVoices(), isEmpty);
        file.deleteSync();
      },
    );
  });

  group('Settings store the selected provider', () {
    test('default is Google and can be switched to ElevenLabs', () async {
      final settings = await db.getSettings();
      expect(settings.ttsProvider, TtsProviderIds.google);

      final dataSource = SettingsLocalDataSource(db);
      expect(
        await dataSource.setTtsProvider(TtsProviderIds.elevenLabs),
        isTrue,
      );

      final updated = await db.getSettings();
      expect(updated.ttsProvider, TtsProviderIds.elevenLabs);
      expect(updated.copyWith().ttsProvider, TtsProviderIds.elevenLabs);
    });

    test('every settings write goes through the datasource', () async {
      final dataSource = SettingsLocalDataSource(db);

      expect(await dataSource.setDefaultSpeed(1.25), isTrue);
      expect(await dataSource.setThemeMode('dark'), isTrue);
      expect(await dataSource.setWarningThreshold(500), isTrue);
      expect(await dataSource.setAutoNormalize(false), isTrue);
      expect(await dataSource.setDefaultVoiceId(7), isTrue);

      final settings = await db.getSettings();
      expect(settings.defaultSpeed, 1.25);
      expect(settings.themeMode, 'dark');
      expect(settings.warningThreshold, 500);
      expect(settings.autoNormalize, isFalse);
      expect(settings.defaultVoiceId, 7);
      // Untouched fields keep their values.
      expect(settings.ttsProvider, TtsProviderIds.google);
      expect(settings.defaultFormat, 'mp3');
    });

    test('favourite toggling updates the cached voice', () async {
      final repository = _repository(
        db,
        MockClient(
          (_) async => _json({
            'provider': 'google',
            'voices': _googleVoicePayload(),
          }, 200),
        ),
      );
      final voice = (await repository.getVoices()).single;

      expect(
        await VoiceLocalDataSource(db).toggleFavorite(voice.id, true),
        isTrue,
      );
      final stored = (await VoiceLocalDataSource(
        db,
      ).getVoicesByProvider(TtsProviderIds.google)).single;
      expect(stored.isFavorite, isTrue);
    });
  });

  group('Provider selection is applied immediately and persisted', () {
    /// Lets the notifier's deferred read of the stored value finish so it does
    /// not outlive the database of the current test.
    Future<void> settle(ProviderContainer container) async {
      container.read(ttsProviderIdProvider);
      await Future<void>.delayed(const Duration(milliseconds: 30));
    }

    test('defaults to Google before settings are read', () async {
      final container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);

      expect(container.read(ttsProviderIdProvider), TtsProviderIds.google);
      await settle(container);
    });

    test('switching updates the value in memory and the database', () async {
      final container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);

      await container
          .read(ttsProviderIdProvider.notifier)
          .setProvider(TtsProviderIds.elevenLabs);

      // In memory (what the datasource and registry read) ...
      expect(container.read(ttsProviderIdProvider), TtsProviderIds.elevenLabs);
      // ... and persisted for the next launch.
      expect((await db.getSettings()).ttsProvider, TtsProviderIds.elevenLabs);
      await settle(container);
    });

    test('a fresh container restores the stored provider', () async {
      await SettingsLocalDataSource(
        db,
      ).setTtsProvider(TtsProviderIds.elevenLabs);

      final container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);
      // The stored value arrives on the next event loop turn.
      await settle(container);

      expect(container.read(ttsProviderIdProvider), TtsProviderIds.elevenLabs);
    });

    test('reset returns to the default provider', () async {
      final container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);
      await container
          .read(ttsProviderIdProvider.notifier)
          .setProvider(TtsProviderIds.elevenLabs);

      await container.read(ttsProviderIdProvider.notifier).reset();

      expect(container.read(ttsProviderIdProvider), TtsProviderIds.google);
      expect((await db.getSettings()).ttsProvider, TtsProviderIds.google);
      await settle(container);
    });
  });
  group('Voice list follows the active provider', () {
    test('switching provider reloads the list for the new provider', () async {
      final requested = <String>[];
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          backendUrlProvider.overrideWith(() => _FixedBackendUrl(_baseUrl)),
          httpClientFactoryProvider.overrideWithValue(
            () => MockClient((request) async {
              requested.add(request.url.queryParameters['provider'] ?? '');
              return _json({
                'provider': 'local',
                'voices': [
                  {
                    'voice_id': 'vi-VN-HoaiMyNeural',
                    'name': 'Edge HoaiMy',
                    'category': 'premade',
                    'labels': {'language': 'vi'},
                  },
                ],
              }, 200);
            }),
          ),
        ],
      );
      addTearDown(container.dispose);

      // Keep the notifier alive, like the home screen does.
      final subscription = container.listen(voiceListProvider, (_, _) {});
      addTearDown(subscription.close);
      await Future<void>.delayed(const Duration(milliseconds: 40));

      await container
          .read(ttsProviderIdProvider.notifier)
          .setProvider(TtsProviderIds.local);
      await Future<void>.delayed(const Duration(milliseconds: 80));

      expect(
        requested,
        contains(TtsProviderIds.local),
        reason: 'voice list must reload for the newly selected provider',
      );
      final state = container.read(voiceListProvider);
      expect(state.voices.single.providerVoiceId, 'vi-VN-HoaiMyNeural');
    });

    test(
      'a fresh install picks a Vietnamese voice, not the first one',
      () async {
        final container = ProviderContainer(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            backendUrlProvider.overrideWith(() => _FixedBackendUrl(_baseUrl)),
            httpClientFactoryProvider.overrideWithValue(
              () => MockClient(
                (_) async => _json({
                  'provider': 'local',
                  'voices': [
                    {
                      'voice_id': 'af-ZA-WillemNeural',
                      'name': 'Edge Willem (nam)',
                      'category': 'premade',
                      'labels': {'language': 'af-ZA', 'gender': 'male'},
                    },
                    {
                      'voice_id': 'ja-JP-NanamiNeural',
                      'name': 'Edge Nanami (nữ)',
                      'category': 'premade',
                      'labels': {'language': 'ja-JP', 'gender': 'female'},
                    },
                    {
                      'voice_id': 'vi-VN-HoaiMyNeural',
                      'name': 'Edge HoaiMy (nữ)',
                      'category': 'premade',
                      'labels': {'language': 'vi', 'gender': 'female'},
                    },
                  ],
                }, 200),
              ),
            ),
          ],
        );
        addTearDown(container.dispose);
        final subscription = container.listen(voiceListProvider, (_, _) {});
        addTearDown(subscription.close);
        await Future<void>.delayed(const Duration(milliseconds: 60));

        final state = container.read(voiceListProvider);
        expect(
          state.voices.where((v) => v.providerVoiceId == 'vi-VN-HoaiMyNeural'),
          isNotEmpty,
        );
        expect(
          state.voices
              .firstWhere((v) => v.id == state.selectedVoiceId)
              .providerVoiceId,
          'vi-VN-HoaiMyNeural',
          reason: 'nothing is stored yet, so Vietnamese must win over af-ZA',
        );
      },
    );

    test(
      'a stored voice that no longer exists falls back to Vietnamese',
      () async {
        // The clone was deleted on the machine, but the id is still in settings.
        await SettingsLocalDataSource(db).setDefaultVoiceId(999);
        final container = ProviderContainer(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            backendUrlProvider.overrideWith(() => _FixedBackendUrl(_baseUrl)),
            httpClientFactoryProvider.overrideWithValue(
              () => MockClient(
                (_) async => _json({
                  'provider': 'local',
                  'voices': [
                    {
                      'voice_id': 'af-ZA-WillemNeural',
                      'name': 'Edge Willem (nam)',
                      'category': 'premade',
                      'labels': {'language': 'af-ZA', 'gender': 'male'},
                    },
                    {
                      'voice_id': 'vi-VN-NamMinhNeural',
                      'name': 'Edge NamMinh (nam)',
                      'category': 'premade',
                      'labels': {'language': 'vi', 'gender': 'male'},
                    },
                  ],
                }, 200),
              ),
            ),
          ],
        );
        addTearDown(container.dispose);
        final subscription = container.listen(voiceListProvider, (_, _) {});
        addTearDown(subscription.close);
        await Future<void>.delayed(const Duration(milliseconds: 60));

        final state = container.read(voiceListProvider);
        expect(
          state.voices
              .firstWhere((v) => v.id == state.selectedVoiceId)
              .providerVoiceId,
          'vi-VN-NamMinhNeural',
        );
      },
    );
  });

  group('An unreachable backend is reported as such', () {
    test('a refused connection becomes a network kind error', () async {
      final repository = _repository(
        db,
        MockClient(
          (_) async => throw const SocketException('Connection refused'),
        ),
      );

      await expectLater(
        repository.getVoices(forceRefresh: true),
        throwsA(
          isA<TtsProviderException>().having(
            (error) => error.kind,
            'kind',
            TtsErrorKind.network,
          ),
        ),
      );
    });

    test(
      'the voice list explains the backend instead of saying "unknown"',
      () async {
        final container = ProviderContainer(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            backendUrlProvider.overrideWith(() => _FixedBackendUrl(_baseUrl)),
            httpClientFactoryProvider.overrideWithValue(
              () => MockClient(
                (_) async => throw const SocketException('Connection refused'),
              ),
            ),
          ],
        );
        addTearDown(container.dispose);
        final subscription = container.listen(voiceListProvider, (_, _) {});
        addTearDown(subscription.close);
        await Future<void>.delayed(const Duration(milliseconds: 60));

        final state = container.read(voiceListProvider);
        expect(state.voices, isEmpty);
        // "Connection refused" is its own failure with its own fix, and the
        // message names the address that was dialled.
        expect(state.error, contains('từ chối kết nối'));
        expect(state.error, contains(_baseUrl));
      },
    );

    test('an unconfigured app asks for an address instead of dialling', () async {
      var called = false;
      final datasource = TtsRemoteDatasource(
        client: MockClient((_) async {
          called = true;
          return _json({'voices': <Map<String, dynamic>>[]}, 200);
        }),
        // What a fresh install looks like: no stored address, no dart-define.
        baseUrl: AppConstants.apiBaseUrl,
        apiKey: '',
        provider: TtsProviderIds.google,
      );

      await expectLater(
        datasource.getVoices(),
        throwsA(
          isA<TtsProviderException>().having(
            (error) => error.kind,
            'kind',
            TtsErrorKind.unconfigured,
          ),
        ),
      );
      expect(called, isFalse, reason: 'nothing should reach the network');
      expect(
        mapTtsErrorKind(TtsErrorKind.unconfigured),
        AppStrings.errorBackendNotConfigured,
      );
    });

    test('each way of failing to reach the backend says something different', () {
      // A refused connection, an unreachable network and a bad name all used to
      // produce one "không kết nối được" line, and all three need a different
      // thing changed.
      expect(
        mapError(const SocketException('Connection refused')),
        AppStrings.errorBackendRefused('máy chủ giọng nói'),
      );
      expect(
        mapError(const SocketException('Failed host lookup: vietvoice')),
        contains('Không phân giải được tên máy chủ'),
      );
      expect(
        mapError(
          const TtsProviderException(
            'down',
            kind: TtsErrorKind.network,
            failure: NetworkFailure.unreachable,
          ),
        ),
        contains('Không có đường tới'),
      );
      expect(
        mapError(
          const TtsProviderException(
            'down',
            kind: TtsErrorKind.network,
            endpoint: 'http://192.168.1.139:3000/v1',
          ),
        ),
        contains('192.168.1.139:3000'),
      );
expect(
        mapError(
          const TtsProviderException(
            'Mẫu âm thanh dài 2.0s, cần ít nhất 5s.',
            kind: TtsErrorKind.validation,
            statusCode: 422,
          ),
        ),
        allOf(contains('HTTP 422'), contains('cần ít nhất 5s')),
      );
      expect(
        mapError(
          const TtsProviderException(
            'Mẫu âm thanh dài 2.0s, cần ít nhất 5s.',
            kind: TtsErrorKind.validation,
            statusCode: 422,
          ),
        ),
        allOf(contains('HTTP 422'), contains('cần ít nhất 5s')),
      );
      expect(
        mapError(const TtsProviderException('boom', kind: TtsErrorKind.server)),
        AppStrings.errorServer,
      );
    });
  });
  group('Progress stream reports real provider work', () {
    test('emits generating, downloading, processing then completed', () async {
      final repository = _repository(
        db,
        MockClient((_) async => http.Response.bytes([1, 2, 3], 200)),
      );

      final statuses = <String>[];
      await for (final response in repository.synthesizeWithProgress(
        TtsRequestBuilder.build(
          text: 'Xin chào',
          voiceId: 'google-vi-standard',
        ),
      )) {
        statuses.add(response.status);
      }

      expect(statuses, [
        'generating',
        'downloading',
        'processing',
        'completed',
      ]);
    });

    test('completed response reports the audio size and provider', () async {
      final repository = _repository(
        db,
        MockClient((_) async => http.Response.bytes([1, 2, 3, 4], 200)),
      );

      final responses = <String, dynamic>{};
      await for (final response in repository.synthesizeWithProgress(
        TtsRequestBuilder.build(
          text: 'Xin chào',
          voiceId: 'google-vi-standard',
        ),
      )) {
        if (response.status == 'completed') {
          responses['bytes'] = response.metadata?['bytes'];
          responses['provider'] = response.metadata?['provider'];
        }
      }

      expect(responses['bytes'], 4);
      expect(responses['provider'], TtsProviderIds.google);
    });
  });
}

/// Builds a TtsRequest without pulling in the full entity API in tests.
class TtsRequestBuilder {
  static TtsRequest build({required String text, required String voiceId}) {
    return TtsRequest(id: 'req_test', text: text, voiceId: voiceId, speed: 1.0);
  }
}

/// Small helper so tests do not repeat temp file boilerplate.
class VoiceCloningFileHelper {
  static File createTempFile() {
    final file = File(
      '${Directory.systemTemp.path}/vv_test_${DateTime.now().microsecondsSinceEpoch}.mp3',
    );
    file.writeAsBytesSync([0, 1, 2, 3]);
    return file;
  }
}
