import '../../core/localization/app_strings.dart';
import 'backend_tts_provider.dart';
import 'tts_provider.dart';

/// ElevenLabs provider: premium quality and the only one that can clone a
/// voice. The ElevenLabs API key lives on the backend only, never in the app.
class ElevenLabsProvider extends BackendTtsProvider {
  ElevenLabsProvider(super.remote);

  @override
  String get id => TtsProviderIds.elevenLabs;

  @override
  String get name => AppStrings.providerElevenLabsName;

  @override
  bool get supportsVoiceCloning => true;
}
