import 'dart:async';
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
import 'package:voice_huluca/core/network/backend_discovery.dart';
import 'package:voice_huluca/core/network/backend_endpoint.dart';
import 'package:voice_huluca/core/network/network_failure.dart';
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

  /// Voice whose preview is still being synthesised. A cloned voice can take a
  /// minute on the local model, so the card needs to show progress.
  final int? previewLoadingVoiceId;
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
    this.previewLoadingVoiceId,
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
    int? previewLoadingVoiceId,
    String? previewError,
    bool clearError = false,
    bool clearPreviewError = false,
    bool clearPreviewLoading = false,
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
      previewLoadingVoiceId: clearPreviewLoading
          ? null
          : (previewLoadingVoiceId ?? this.previewLoadingVoiceId),
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

/// Base URL of the backend the app talks to.
///
/// Stored in settings so one build works on any machine: the user either types
/// an address or picks one found on the LAN. Empty means "not configured yet",
/// which is what a fresh install looks like.
final backendUrlProvider = NotifierProvider<BackendUrlNotifier, String>(
  BackendUrlNotifier.new,
);

class BackendUrlNotifier extends Notifier<String> {
  bool _disposed = false;

  @override
  String build() {
    ref.watch(settingsLocalDataSourceProvider);
    ref.onDispose(() => _disposed = true);
    Future.microtask(_restore);
    return AppConstants.apiBaseUrl;
  }

  Future<void> _restore() async {
    final stored =
        (await ref.read(settingsLocalDataSourceProvider).getSettings())
            .backendUrl;
    if (_disposed) return;
    final url = BackendEndpoint.resolve(stored);
    if (url != state) {
      state = url;
    }
    if (url.isNotEmpty) return;

    // Nothing configured yet, and this build carries no address. Rather than
    // leave the app pointing at a placeholder host, look for the backend on the
    // Wi-Fi the phone is already on. This is the same scan the Settings button
    // runs, done once in the background.
    await _adoptDiscoveredBackend();
  }

  /// Scans the LAN once and remembers the fastest backend that answers. Returns
  /// the address that was stored, or null when none was found.
  Future<String?> _adoptDiscoveredBackend() async {
    try {
      final found = await const LanBackendScanner().scan(
        timeout: const Duration(milliseconds: 400),
      );
      if (_disposed) return null;
      final best = found.isEmpty ? null : found.first.baseUrl;
      if (best == null) return null;
      await setUrl(best);
      return best;
    } on Object {
      // Discovery is a convenience: a phone with no LAN, or a platform channel
      // that is unavailable in tests, must leave the app usable.
      return null;
    }
  }

  /// Saves a new address and rebuilds everything that talks to the backend.
  Future<void> setUrl(String url) async {
    final normalized = BackendEndpoint.parse(url).url;
    if (normalized == null) {
      return;
    }
    await ref.read(settingsLocalDataSourceProvider).setBackendUrl(normalized);
    if (normalized != state) {
      state = normalized;
    }
  }

  /// Back to the address this build was compiled with.
  Future<void> reset() async {
    await ref.read(settingsLocalDataSourceProvider).setBackendUrl(null);
    state = AppConstants.apiBaseUrl;
  }
}

/// Backend gateway bound to the active provider.
final ttsRemoteDataSourceProvider = Provider<TtsRemoteDatasource>((ref) {
  final apiKey = ref.watch(apiKeyProvider).valueOrNull ?? '';
  final provider = ref.watch(ttsProviderIdProvider);
  return TtsRemoteDatasource(
    client: ref.watch(httpClientFactoryProvider)(),
    baseUrl: ref.watch(backendUrlProvider),
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
        baseUrl: ref.watch(backendUrlProvider),
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
    if (state.previewLoadingVoiceId == voice.id) return;
    await _stopPreview();
    state = state.copyWith(
      playingVoiceId: voice.id,
      previewLoadingVoiceId: voice.id,
      clearPreviewError: true,
    );
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
    } finally {
      if (state.previewLoadingVoiceId == voice.id) {
        state = state.copyWith(clearPreviewLoading: true);
      }
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
}

/// Voice-list failures in the user's language.
String mapError(Object error) {
  if (error is TtsProviderException) {
    return mapTtsErrorKind(
      error.kind,
      endpoint: error.endpoint,
      failure: error.failure,
      statusCode: error.statusCode,
      detail: _detailOf(error),
    );
  }
  // A transport error that reached this far still means the voice server is
  // unreachable, so say that instead of a generic failure.
  if (error is SocketException ||
      error is http.ClientException ||
      error is TimeoutException) {
    return _networkMessage('', classifyNetworkFailure(error));
  }
  return AppStrings.errorUnknown;
}

/// The server's own explanation, when it sent one, so the user sees the real
/// reason ("Mẫu âm thanh dài 2.0s") instead of a status code.
String _detailOf(TtsProviderException error) {
  if (error.statusCode == 0) return '';
  final body = error.message;
  if (body.isEmpty || body.startsWith('Failed to ')) return '';
  return body;
}

/// Single mapping from provider error kind to user-facing text.
///
/// [endpoint] is the address the call was aimed at. A self-hosted backend is
/// reached by IP, so a wrong or missing address is the most common failure and
/// the message has to name it.
String mapTtsErrorKind(
  TtsErrorKind kind, {
  String endpoint = '',
  NetworkFailure failure = NetworkFailure.unknown,
  int statusCode = 0,
  String detail = '',
}) {
  switch (kind) {
    case TtsErrorKind.unconfigured:
      return AppStrings.errorBackendNotConfigured;
    case TtsErrorKind.network:
      return _networkMessage(endpoint, failure);
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
      return statusCode > 0
          ? AppStrings.errorBackendServer(statusCode, detail)
          : AppStrings.errorServer;
    case TtsErrorKind.unsupported:
      return AppStrings.errorProviderUnsupported;
    case TtsErrorKind.unavailable:
      return AppStrings.errorProviderUnavailable;
    case TtsErrorKind.validation:
      return statusCode > 0
          ? AppStrings.errorBackendClient(statusCode, detail)
          : AppStrings.errorInvalidRequest;
    case TtsErrorKind.unknown:
      return AppStrings.errorUnknown;
  }
}

/// Each way of failing to reach the backend needs a different fix, so each is
/// named instead of being collapsed into "không kết nối được".
String _networkMessage(String endpoint, NetworkFailure failure) {
  final target = endpoint.isEmpty ? 'máy chủ giọng nói' : endpoint;
  return switch (failure) {
    NetworkFailure.refused => AppStrings.errorBackendRefused(target),
    NetworkFailure.timedOut => AppStrings.errorBackendTimedOut(target),
    NetworkFailure.unreachable => AppStrings.errorBackendUnreachableRoute(
      target,
    ),
    NetworkFailure.dns => AppStrings.errorBackendDns(target),
    NetworkFailure.tls => AppStrings.errorBackendTls(target),
    NetworkFailure.unknown => endpoint.isEmpty
        ? AppStrings.errorBackendUnreachable
        : AppStrings.errorBackendUnreachableAt(endpoint),
  };
}
