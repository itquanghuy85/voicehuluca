import '../../core/localization/app_strings.dart';
import 'backend_tts_provider.dart';
import 'tts_provider.dart';

/// VoiceStudio running on a GPU PC in the same network.
///
/// The phone never talks to VoiceStudio: the backend holds its address and PIN
/// and forwards clone and speech requests, so this provider is reached exactly
/// like the others. A clone needs the transcript of the sample (`refText`).
class VoiceStudioTtsProvider extends BackendTtsProvider {
  VoiceStudioTtsProvider(super.remote);

  @override
  String get id => TtsProviderIds.voiceStudio;

  @override
  String get name => AppStrings.providerVoiceStudioName;

  @override
  bool get supportsVoiceCloning => true;

  /// Readiness comes from the backend (`GET /v1/providers`), like the local one.
  @override
  bool get isAvailable => true;
}
