import 'dart:io';

import 'package:collection/collection.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:voice_huluca/core/constants/app_constants.dart';
import 'package:voice_huluca/core/localization/app_strings.dart';
import 'package:voice_huluca/core/utils/connectivity_utils.dart';
import 'package:voice_huluca/data/datasources/local/app_database.dart'
    hide Voice;
import 'package:voice_huluca/data/datasources/local/settings_local_datasource.dart';
import 'package:voice_huluca/data/datasources/local/voice_local_datasource.dart';
import 'package:voice_huluca/data/datasources/remote/tts_remote_datasource.dart';
import 'package:voice_huluca/data/models/voice.dart';
import 'package:voice_huluca/data/repositories/tts_repository_impl.dart';
import 'package:voice_huluca/data/services/elevenlabs_provider.dart';
import 'package:voice_huluca/data/services/google_tts_provider.dart';
import 'package:voice_huluca/data/services/local_tts_provider.dart';
import 'package:voice_huluca/data/services/tts_provider.dart';
import 'package:voice_huluca/data/services/tts_provider_registry.dart';

enum VoiceFilter { all, mine, male, female, favorites }

class VoiceListState {
  final List<Voice> voices;
  final VoiceFilter filter;
  final String searchQuery;
  final bool isLoading;
  final bool isRefreshing;
  final String? error;
  final int? selectedVoiceId;
  final int? playingVoiceId;
  final String? previewError;

  const VoiceListState({
    this.voices = const [],
    this.filter = VoiceFilter.all,
    this.searchQuery = '',
    this.isLoading = false,
    this.isRefreshing = false,
    this.error,
    this.selectedVoiceId,
    this.playingVoiceId,
    this.previewError,
  });

  VoiceListState copyWith({
    List<Voice>? voices,
    VoiceFilter? filter,
    String? searchQuery,
    bool? isLoading,
    bool? isRefreshing,
    String? error,
    int? selectedVoiceId,
    int? playingVoiceId,
    String? previewError,
    bool clearError = false,
    bool clearPreviewError = false,
  }) {
    return VoiceListState(
      voices: voices ?? this.voices,
      filter: filter ?? this.filter,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      error: clearError ? null : (error ?? this.error),
      selectedVoiceId: selectedVoiceId ?? this.selectedVoiceId,
      playingVoiceId: playingVoiceId ?? this.playingVoiceId,
      previewError: clearPreviewError
          ? null
          : (previewError ?? this.previewError),
    );
  }

  List<Voice> get clonedVoices =>
      voices.where((voice) => voice.isCloned).toList();

  List<Voice> get providerVoices =>
      voices.where((voice) => !voice.isCloned).toList();

  List<Voice> applyFilter(List<Voice> source) {
    var result = source;
    switch (filter) {
      case VoiceFilter.all:
        break;
      case VoiceFilter.mine:
        result = result.where((voice) => voice.isCloned).toList();
      case VoiceFilter.male:
        result = result
            .where((voice) => voice.gender.toLowerCase() == 'male')
            .toList();
      case VoiceFilter.female:
        result = result
            .where((voice) => voice.gender.toLowerCase() == 'female')
            .toList();
      case VoiceFilter.favorites:
        result = result.where((voice) => voice.isFavorite).toList();
    }
    final query = searchQuery.trim().toLowerCase();
    if (query.isNotEmpty) {
      result = result
          .where(
            (voice) =>
                voice.name.toLowerCase().contains(query) ||
                (voice.description?.toLowerCase().contains(query) ?? false) ||
                voice.language.toLowerCase().contains(query),
          )
          .toList();
    }
    return result;
  }

  List<Voice> get filteredClonedVoices => applyFilter(clonedVoices);

  List<Voice> get filteredProviderVoices => applyFilter(providerVoices);
}

final voiceLocalDataSourceProvider = Provider<VoiceLocalDataSource>((ref) {
  return VoiceLocalDataSource(ref.watch(appDatabaseProvider));
});

final settingsLocalDataSourceProvider = Provider<SettingsLocalDataSource>((
  ref,
) {
  return SettingsLocalDataSource(ref.watch(appDatabaseProvider));
});

final apiKeyProvider = FutureProvider<String?>((ref) async {
  const storage = FlutterSecureStorage();
  return storage.read(key: AppConstants.secureStorageKeyApiToken);
});

/// Selected TTS provider id.
///
/// This is the single source of truth: the value is kept in memory so every
/// dependent (datasource, registry, UI) rebuilds immediately, and it is
/// mirrored to the settings table so the choice survives a restart.
final ttsProviderIdProvider = NotifierProvider<TtsProviderIdNotifier, String>(
  TtsProviderIdNotifier.new,
);

class TtsProviderIdNotifier extends Notifier<String> {
  bool _disposed = false;

  @override
  String build() {
    _disposed = false;
    final settings = ref.read(settingsLocalDataSourceProvider);
    ref.onDispose(() => _disposed = true);
    // Deferred so the stored choice is never written during the build phase.
    Future<void>.delayed(Duration.zero, () => _loadFromSettings(settings));
    return AppConstants.defaultTtsProvider;
  }

  Future<void> _loadFromSettings(SettingsLocalDataSource settings) async {
    final stored = (await settings.getSettings()).ttsProvider;
    if (_disposed || stored.isEmpty || stored == state) {
      return;
    }
    state = stored;
  }

  /// Switches provider immediately, then persists the choice.
  Future<void> setProvider(String providerId) async {
    if (providerId == state) return;
    state = providerId;
    await ref.read(settingsLocalDataSourceProvider).setTtsProvider(providerId);
  }

  /// Restores the default (used when the user wipes all data).
  Future<void> reset() => setProvider(AppConstants.defaultTtsProvider);
}

/// Injectable HTTP client factory (overridden in tests).
final httpClientFactoryProvider = Provider<http.Client Function()>((ref) {
  return () => http.Client();
});

/// Backend gateway bound to the active provider.
final ttsRemoteDataSourceProvider = Provider<TtsRemoteDatasource>((ref) {
  final apiKey = ref.watch(apiKeyProvider).valueOrNull ?? '';
  final provider = ref.watch(ttsProviderIdProvider);
  return TtsRemoteDatasource(
    client: ref.watch(httpClientFactoryProvider)(),
    baseUrl: AppConstants.apiBaseUrl,
    apiKey: apiKey,
    provider: provider,
  );
});

/// Every provider the app can use. Secrets stay on the backend.
final ttsProviderRegistryProvider = Provider<TtsProviderRegistry>((ref) {
  final remote = ref.watch(ttsRemoteDataSourceProvider);
  return TtsProviderRegistry([
    GoogleTtsProvider(remote),
    ElevenLabsProvider(remote),
    LocalTtsProvider(remote),
  ]);
});

final activeTtsProviderProvider = Provider<TtsProvider>((ref) {
  final registry = ref.watch(ttsProviderRegistryProvider);
  return registry.resolve(ref.watch(ttsProviderIdProvider));
});

/// Whether the active provider can clone a voice.
final activeProviderSupportsCloningProvider = Provider<bool>((ref) {
  return TtsProviderIds.canClone(ref.watch(ttsProviderIdProvider));
});

/// Real availability reported by the backend (`GET /v1/providers`).
///
/// Used to tell the truth in Settings: the local provider is free and usable,
/// but it only works once the Python sidecar is configured on the server.
final providerAvailabilityProvider =
    FutureProvider.autoDispose<Map<String, bool>>((ref) async {
      final remote = TtsRemoteDatasource(
        baseUrl: AppConstants.apiBaseUrl,
        apiKey: ref.watch(apiKeyProvider).valueOrNull ?? '',
        // Availability is provider agnostic; the default id is enough.
        provider: AppConstants.defaultTtsProvider,
      );
      try {
        return await remote.getProviderAvailability();
      } catch (_) {
        // Offline or backend down: report nothing rather than guessing.
        return const {};
      }
    });

/// True while the device has no network connection.
final isOfflineProvider = StreamProvider<bool>((ref) {
  final connectivity = Connectivity();
  return connectivity.onConnectivityChanged
      .map(isOfflineResult)
      .asBroadcastStream();
});

final ttsRepositoryProvider = Provider<TtsRepositoryImpl>((ref) {
  return TtsRepositoryImpl(
    ref.watch(ttsRemoteDataSourceProvider),
    ref.watch(voiceLocalDataSourceProvider),
  );
});

final voiceListProvider = NotifierProvider<VoiceListNotifier, VoiceListState>(
  VoiceListNotifier.new,
);

class VoiceListNotifier extends Notifier<VoiceListState> {
  AudioPlayer? _player;

  VoiceLocalDataSource get _local => ref.read(voiceLocalDataSourceProvider);
  TtsRepositoryImpl get _tts => ref.read(ttsRepositoryProvider);
  TtsRemoteDatasource get _remote => ref.read(ttsRemoteDataSourceProvider);
  SettingsLocalDataSource get _settings =>
      ref.read(settingsLocalDataSourceProvider);

  @override
  VoiceListState build() {
    ref.onDispose(() async {
      await _player?.dispose();
      _player = null;
    });
    // Depend on the gateway: when the user switches provider Riverpod rebuilds
    // this notifier and the list is loaded again for the new provider.
    ref.watch(ttsRemoteDataSourceProvider);
    Future.microtask(() => loadVoices());
    return const VoiceListState();
  }

  Future<List<Voice>> loadVoices({bool isRefresh = false}) async {
    state = state.copyWith(
      isLoading: !isRefresh && state.voices.isEmpty,
      isRefreshing: isRefresh,
      clearError: true,
    );
    try {
      final voices = await _tts.getVoices(forceRefresh: isRefresh);
      final settings = await _settings.getSettings();
      final savedId = settings.defaultVoiceId;
      final savedIsValid =
          savedId != null && voices.any((v) => v.id == savedId);
      state = state.copyWith(
        voices: voices,
        isLoading: false,
        isRefreshing: false,
        selectedVoiceId: savedIsValid ? savedId : _pickDefaultVoice(voices)?.id,
      );
      return voices;
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        error: mapError(error),
      );
      return const [];
    }
  }

  /// Own clone first, then any Vietnamese voice, so a fresh install never
  /// starts on an Afrikaans or Japanese voice.
  Voice? _pickDefaultVoice(List<Voice> voices) {
    if (voices.isEmpty) return null;
    return voices.firstWhereOrNull((v) => v.isCloned) ??
        voices.firstWhereOrNull(
          (v) => v.language.toLowerCase().startsWith('vi'),
        ) ??
        voices.first;
  }

  Future<void> toggleFavorite(Voice voice) async {
    final updated = voice.copyWith(isFavorite: !voice.isFavorite);
    await _local.updateVoice(updated);
    state = state.copyWith(
      voices: state.voices
          .map((item) => item.id == voice.id ? updated : item)
          .toList(),
    );
  }

  Future<void> selectVoice(Voice voice) async {
    state = state.copyWith(selectedVoiceId: voice.id);
    await _settings.setDefaultVoiceId(voice.id);
  }

  Future<void> deleteVoice(Voice voice) async {
    await _tts.deleteVoice(voice);
    state = state.copyWith(
      voices: state.voices.where((item) => item.id != voice.id).toList(),
      selectedVoiceId: state.selectedVoiceId == voice.id
          ? null
          : state.selectedVoiceId,
    );
  }

  Future<void> togglePreview(Voice voice) async {
    if (state.playingVoiceId == voice.id) {
      await _stopPreview();
      return;
    }
    await _stopPreview();
    state = state.copyWith(playingVoiceId: voice.id, clearPreviewError: true);
    try {
      final audioBytes = await _remote.synthesize(
        voiceId: voice.providerVoiceId,
        text: AppStrings.voiceSelectorPreviewSample,
      );
      final directory = await getTemporaryDirectory();
      final file = File(
        p.join(directory.path, 'voice_preview_${voice.id}.mp3'),
      );
      await file.writeAsBytes(audioBytes);
      _player ??= AudioPlayer();
      await _player!.setFilePath(file.path);
      _player!.playerStateStream.listen((playerState) {
        if (playerState.processingState == ProcessingState.completed &&
            state.playingVoiceId == voice.id) {
          state = state.copyWith(playingVoiceId: null);
        }
      });
      await _player!.play();
    } catch (error) {
      state = state.copyWith(
        playingVoiceId: null,
        previewError: mapError(error),
      );
    }
  }

  Future<void> _stopPreview() async {
    await _player?.stop();
    if (state.playingVoiceId != null) {
      state = state.copyWith(playingVoiceId: null);
    }
  }

  void setFilter(VoiceFilter filter) {
    state = state.copyWith(filter: filter);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  String mapError(Object error) {
    if (error is SocketException) {
      return AppStrings.errorNetwork;
    }
    if (error is TtsProviderException) {
      return mapTtsErrorKind(error.kind);
    }
    return AppStrings.errorUnknown;
  }
}

/// Single mapping from provider error kind to user-facing text.
String mapTtsErrorKind(TtsErrorKind kind) {
  switch (kind) {
    case TtsErrorKind.network:
      return AppStrings.errorNetwork;
    case TtsErrorKind.unauthorized:
      return AppStrings.errorUnauthorized;
    case TtsErrorKind.paymentRequired:
      return AppStrings.errorPaymentRequired;
    case TtsErrorKind.voiceNotFound:
      return AppStrings.errorVoiceNotFound;
    case TtsErrorKind.fileTooLarge:
      return AppStrings.errorFileTooLarge;
    case TtsErrorKind.rateLimit:
      return AppStrings.errorRateLimit;
    case TtsErrorKind.server:
      return AppStrings.errorServer;
    case TtsErrorKind.unsupported:
      return AppStrings.errorProviderUnsupported;
    case TtsErrorKind.unavailable:
      return AppStrings.errorProviderUnavailable;
    case TtsErrorKind.validation:
      return AppStrings.errorInvalidRequest;
    case TtsErrorKind.unknown:
      return AppStrings.errorUnknown;
  }
}
