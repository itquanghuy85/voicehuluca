import 'tts_provider.dart';

/// Holds every known TTS provider and resolves the active one.
///
/// The registry is the only place the app looks providers up by id, which
/// keeps provider switching explicit and easy to test.
class TtsProviderRegistry {
  final Map<String, TtsProvider> _providers = {};

  TtsProviderRegistry([Iterable<TtsProvider> providers = const []]) {
    for (final provider in providers) {
      register(provider);
    }
  }

  /// Registers a provider, replacing any previous one with the same id.
  void register(TtsProvider provider) {
    _providers[provider.id] = provider;
  }

  void unregister(String id) {
    _providers.remove(id);
  }

  /// All registered providers, in registration order.
  List<TtsProvider> get all => List.unmodifiable(_providers.values);

  List<String> get ids => List.unmodifiable(_providers.keys);

  TtsProvider? getById(String id) => _providers[id];

  bool contains(String id) => _providers.containsKey(id);

  /// Providers that can be used right now (excludes "coming soon" ones).
  List<TtsProvider> get available =>
      all.where((provider) => provider.isAvailable).toList();

  /// Resolves the provider to use, falling back to the default and finally
  /// to any available provider. Never throws.
  TtsProvider resolve(String? id) {
    if (id != null) {
      final provider = _providers[id];
      if (provider != null) {
        return provider;
      }
    }
    final fallback = _providers[TtsProviderIds.defaultProvider];
    if (fallback != null) {
      return fallback;
    }
    final candidates = available;
    if (candidates.isNotEmpty) {
      return candidates.first;
    }
    throw TtsProviderUnavailableException('No TTS provider registered');
  }

  /// Whether the given provider can clone a voice.
  bool supportsVoiceCloning(String id) =>
      _providers[id]?.supportsVoiceCloning ?? false;

  void clear() {
    _providers.clear();
  }
}
