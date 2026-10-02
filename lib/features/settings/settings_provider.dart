import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/constants/app_constants.dart';
import '../../data/datasources/local/app_database.dart' hide Voice;
import '../../data/datasources/local/settings_local_datasource.dart';
import '../../data/datasources/local/voice_local_datasource.dart';
import '../../data/models/app_settings.dart';
import '../../data/models/voice.dart';
import '../../data/repositories/audio_repository_impl.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../data/repositories/tts_repository_impl.dart';
import '../../data/repositories/voice_repository_impl.dart';
import '../../data/services/tts_provider.dart';
import '../audio_library/library_provider.dart';
import '../voice/voice_provider.dart'
    show mapTtsErrorKind, ttsProviderIdProvider, ttsRepositoryProvider;

class SettingsState {
  final AppSettings settings;
  final List<Voice> voices;
  final bool isLoading;
  final bool isConnected;
  final bool isTestingConnection;
  final bool hasApiKey;
  final String? error;
  final int storageUsed;

  /// Real usage from the active provider, null when it reports none.
  final TtsUsage? usage;
  final bool isUsageLoading;

  const SettingsState({
    this.settings = const AppSettings(),
    this.voices = const [],
    this.isLoading = false,
    this.isConnected = false,
    this.isTestingConnection = false,
    this.hasApiKey = false,
    this.error,
    this.storageUsed = 0,
    this.usage,
    this.isUsageLoading = false,
  });

  String get ttsProviderId => settings.ttsProvider;

  SettingsState copyWith({
    AppSettings? settings,
    List<Voice>? voices,
    bool? isLoading,
    bool? isConnected,
    bool? isTestingConnection,
    bool? hasApiKey,
    String? error,
    int? storageUsed,
    TtsUsage? usage,
    bool? isUsageLoading,
    bool clearError = false,
    bool clearUsage = false,
  }) {
    return SettingsState(
      settings: settings ?? this.settings,
      voices: voices ?? this.voices,
      isLoading: isLoading ?? this.isLoading,
      isConnected: isConnected ?? this.isConnected,
      isTestingConnection: isTestingConnection ?? this.isTestingConnection,
      hasApiKey: hasApiKey ?? this.hasApiKey,
      error: clearError ? null : (error ?? this.error),
      storageUsed: storageUsed ?? this.storageUsed,
      usage: clearUsage ? null : (usage ?? this.usage),
      isUsageLoading: isUsageLoading ?? this.isUsageLoading,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final SettingsRepositoryImpl _settingsRepository;
  final VoiceRepositoryImpl _voiceRepository;
  final AudioRepositoryImpl _audioRepository;

  /// Read at call time so provider calls always target the active provider.
  final TtsRepositoryImpl Function() _ttsRepository;

  /// Writes the selection to the shared provider-id notifier.
  final Future<void> Function(String providerId) _switchProvider;

  /// Current provider id, always in sync with the shared notifier.
  final String Function() _activeProviderId;
  final FlutterSecureStorage _secureStorage;

  SettingsNotifier(
    this._settingsRepository,
    this._voiceRepository,
    this._audioRepository,
    this._ttsRepository,
    this._switchProvider,
    this._activeProviderId,
    this._secureStorage,
  ) : super(const SettingsState());

  /// Switches the active TTS provider and reloads provider-scoped data.
  Future<bool> updateTtsProvider(String providerId) async {
    try {
      await _switchProvider(providerId);
      final settings = await _settingsRepository.getSettings();
      if (!mounted) return false;
      state = state.copyWith(
        settings: settings,
        isConnected: false,
        clearError: true,
        clearUsage: true,
      );
      await loadUsage();
      return true;
    } catch (e) {
      if (mounted) {
        state = state.copyWith(error: e.toString());
      }
      return false;
    }
  }

  Future<void> loadSettings() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final settings = await _settingsRepository.getSettings();
      final voices = await _voiceRepository.getAllVoices();
      final storageUsed = await _audioRepository.getTotalStorageUsed();
      final apiKey = await _secureStorage.read(
        key: AppConstants.secureStorageKeyApiToken,
      );
      if (!mounted) return;
      state = state.copyWith(
        settings: settings,
        voices: voices,
        isLoading: false,
        hasApiKey: apiKey != null && apiKey.isNotEmpty,
        storageUsed: storageUsed,
      );
      await loadUsage();
    } catch (e) {
      debugPrint('[VVT] loadSettings ERROR: $e');
      if (mounted) {
        state = state.copyWith(isLoading: false, error: e.toString());
      }
    }
  }

  /// Reads real usage for the active provider. Providers without quota data
  /// (Google TTS) simply show nothing instead of fake numbers.
  Future<void> loadUsage() async {
    state = state.copyWith(isUsageLoading: true, clearUsage: true);
    try {
      final usage = await _ttsRepository().getUsage();
      if (!mounted) return;
      state = state.copyWith(usage: usage, isUsageLoading: false);
    } catch (e) {
      debugPrint('[VVT] loadUsage unavailable: $e');
      if (mounted) {
        state = state.copyWith(isUsageLoading: false, clearUsage: true);
      }
    }
  }

  Future<void> updateTheme(String theme) async {
    try {
      final updated = state.settings.copyWith(
        ttsProvider: _activeProviderId(),
        themeMode: theme,
      );
      await _settingsRepository.updateSettings(updated);
      state = state.copyWith(settings: updated);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateDefaultVoice(int? voiceId) async {
    try {
      final updated = state.settings.copyWith(
        ttsProvider: _activeProviderId(),
        defaultVoiceId: voiceId,
      );
      await _settingsRepository.updateSettings(updated);
      state = state.copyWith(settings: updated);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateDefaultSpeed(double speed) async {
    try {
      final updated = state.settings.copyWith(
        ttsProvider: _activeProviderId(),
        defaultSpeed: speed,
      );
      await _settingsRepository.updateSettings(updated);
      state = state.copyWith(settings: updated);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateDefaultFormat(String format) async {
    try {
      final updated = state.settings.copyWith(
        ttsProvider: _activeProviderId(),
        defaultFormat: format,
      );
      await _settingsRepository.updateSettings(updated);
      state = state.copyWith(settings: updated);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateAutoNormalize(bool value) async {
    try {
      final updated = state.settings.copyWith(
        ttsProvider: _activeProviderId(),
        autoNormalize: value,
      );
      await _settingsRepository.updateSettings(updated);
      state = state.copyWith(settings: updated);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateWarningThreshold(int threshold) async {
    try {
      final updated = state.settings.copyWith(
        ttsProvider: _activeProviderId(),
        warningThreshold: threshold,
      );
      await _settingsRepository.updateSettings(updated);
      state = state.copyWith(settings: updated);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> clearCache() async {
    try {
      await _audioRepository.cleanupOrphanedAudio();
      final storageUsed = await _audioRepository.getTotalStorageUsed();
      state = state.copyWith(storageUsed: storageUsed);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteAllData() async {
    try {
      final allAudio = await _audioRepository.getAllAudio();
      for (final audio in allAudio) {
        await _audioRepository.deleteAudio(audio.id);
      }
      const defaultSettings = AppSettings();
      await _settingsRepository.updateSettings(defaultSettings);
      // Wiping data also returns the provider to its default.
      await _switchProvider(AppConstants.defaultTtsProvider);
      final settings = await _settingsRepository.getSettings();
      state = state.copyWith(settings: settings, storageUsed: 0);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<bool> testConnection() async {
    state = state.copyWith(isTestingConnection: true, clearError: true);
    try {
      final isConnected = await _ttsRepository().testConnection();
      state = state.copyWith(
        isTestingConnection: false,
        isConnected: isConnected,
      );
      return isConnected;
    } catch (e) {
      debugPrint('testConnection: exception $e');
      state = state.copyWith(
        isTestingConnection: false,
        isConnected: false,
        error: mapTtsErrorKind(TtsErrorKind.unknown),
      );
      return false;
    }
  }

  Future<void> saveApiKey(String apiKey) async {
    try {
      await _secureStorage.write(
        key: AppConstants.secureStorageKeyApiToken,
        value: apiKey,
      );
      state = state.copyWith(hasApiKey: true);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteApiKey() async {
    try {
      await _secureStorage.delete(key: AppConstants.secureStorageKeyApiToken);
      state = state.copyWith(hasApiKey: false, isConnected: false);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final settingsRepositoryProvider = Provider<SettingsRepositoryImpl>((ref) {
  final database = ref.watch(appDatabaseProvider);
  final dataSource = SettingsLocalDataSource(database);
  return SettingsRepositoryImpl(dataSource);
});

final voiceRepositoryProvider = Provider<VoiceRepositoryImpl>((ref) {
  final database = ref.watch(appDatabaseProvider);
  final dataSource = VoiceLocalDataSource(database);
  return VoiceRepositoryImpl(dataSource);
});

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) {
    final settingsRepo = ref.watch(settingsRepositoryProvider);
    final voiceRepo = ref.watch(voiceRepositoryProvider);
    final audioRepo = ref.watch(audioRepositoryProvider);
    // Read lazily so provider calls always use the active provider.
    TtsRepositoryImpl ttsRepo() => ref.read(ttsRepositoryProvider);
    final switchProvider = ref.read(ttsProviderIdProvider.notifier).setProvider;
    final secureStorage = ref.watch(secureStorageProvider);
    return SettingsNotifier(
      settingsRepo,
      voiceRepo,
      audioRepo,
      ttsRepo,
      switchProvider,
      () => ref.read(ttsProviderIdProvider),
      secureStorage,
    );
  },
);
