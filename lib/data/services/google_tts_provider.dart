import '../../core/localization/app_strings.dart';
import 'backend_tts_provider.dart';
import 'tts_provider.dart';

/// Google Text-to-Speech (default provider).
///
/// Works without any user API key. Google TTS has no voice cloning feature,
/// so [supportsVoiceCloning] is false and the UI explains it instead of
/// pretending the feature exists.
class GoogleTtsProvider extends BackendTtsProvider {
  GoogleTtsProvider(super.remote);

  @override
  String get id => TtsProviderIds.google;

  @override
  String get name => AppStrings.providerGoogleName;

  @override
  bool get supportsVoiceCloning => false;
}
