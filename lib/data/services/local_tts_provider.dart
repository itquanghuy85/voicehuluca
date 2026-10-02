import '../../core/localization/app_strings.dart';
import 'backend_tts_provider.dart';
import 'tts_provider.dart';

/// On-device TTS: free, no API key, no per-character cost.
///
/// The engines (Edge TTS for speech, XTTS-v2 for cloning) run in a Python
/// sidecar owned by the backend, so from the app's point of view this provider
/// is reached exactly like the others. Cloned voices come back with a
/// `clone:<id>` voice id and are rendered as WAV.
class LocalTtsProvider extends BackendTtsProvider {
  LocalTtsProvider(super.remote);

  @override
  String get id => TtsProviderIds.local;

  @override
  String get name => AppStrings.providerLocalName;

  @override
  bool get supportsVoiceCloning => true;

  /// Selectable from settings: readiness is reported by the backend
  /// (`GET /v1/providers`) so an unconfigured machine gets a clear setup hint
  /// instead of a provider that silently cannot be picked.
  @override
  bool get isAvailable => true;
}
