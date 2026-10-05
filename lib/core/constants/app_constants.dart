class AppConstants {
  AppConstants._();

  static const String appName = 'VietVoice Studio';
  static const String appVersion = '1.0.0';

  static const int maxScriptLength = 5000;
  static const int minScriptLength = 1;
  static const int maxFileNameLength = 100;
  static const int maxConcurrentGenerations = 3;
  static const int defaultAudioBitrate = 128000;
  static const int maxAudioFileSizeBytes = 50 * 1024 * 1024;
  static const int audioChunkSizeBytes = 8192;

  /// Longer than [generationTimeout] so a slow local model (XTTS on CPU can
  /// take minutes for a cloned voice) is never cut off by the HTTP client.
  static const Duration apiTimeout = Duration(minutes: 6);
  static const Duration connectionTimeout = Duration(seconds: 10);

  /// Budget for one generation with a streaming provider.
  ///
  /// Google, Edge and ElevenLabs answer in seconds, so five minutes is already
  /// generous and a wedged call still ends in a retryable error.
  static const Duration generationTimeout = Duration(minutes: 5);

  /// VoiceStudio renders a whole script in one request; the backend waits up to
  /// 15 minutes for it, so the app waits a little longer than that.
  static const Duration voiceStudioGenerationTimeout = Duration(minutes: 16);

  /// Floor for a local generation, on top of the per-character allowance below.
  static const Duration localGenerationBaseTimeout = Duration(minutes: 10);

  /// How fast the local engine renders a clone, in characters per second.
  ///
  /// Measured on the reference machine (Core Ultra 5, no GPU): 209 characters
  /// took 190s, so roughly 1.1. The flat [generationTimeout] was shorter than
  /// this rate allows — a request the backend answered with 200 after 313s was
  /// abandoned by the app 13 seconds before the audio arrived, which is what the
  /// user saw as "Tạo giọng nói thất bại".
  static const double localGenerationCharsPerSecond = 1.1;

  /// Ceiling for a local generation, so a genuinely stuck request still ends.
  ///
  /// Sized for the longest script the editor accepts: 5000 characters at the
  /// measured rate needs about 76 minutes, plus the base budget.
  static const Duration localGenerationMaxTimeout = Duration(minutes: 90);
  static const Duration splashDuration = Duration(seconds: 2);
  static const Duration debounceDuration = Duration(milliseconds: 300);
  static const Duration snackBarDuration = Duration(seconds: 4);

  static const List<String> supportedAudioFormats = [
    'mp3',
    'wav',
    'ogg',
    'm4a',
  ];
  static const List<String> supportedExportFormats = ['mp3', 'wav', 'ogg'];
  static const List<String> supportedImportFormats = ['txt', 'md', 'docx'];

  static const List<String> vietnameseVoiceIds = [
    'vn_female_01',
    'vn_male_01',
    'vn_female_02',
    'vn_male_02',
    'vn_female_03',
    'vn_male_03',
  ];

  static const List<double> supportedSpeechRates = [
    0.5,
    0.75,
    1.0,
    1.25,
    1.5,
    2.0,
  ];

  /// Backend address compiled into the build. Empty means "not configured": the
  /// app is self-hosted, so there is no sensible public default to fall back on
  /// and a placeholder host only produced DNS timeouts. An empty value makes the
  /// app find the backend on the LAN or ask for its address instead.
  static const String apiBaseUrl = String.fromEnvironment('API_BASE_URL');
  static const String websocketUrl = 'wss://stream.vietvoice.studio';

  /// Provider used until the user picks another one in Settings.
  static const String defaultTtsProvider = 'google';

  /// Provider that supports cloning and is used as a paid fallback.
  static const String fallbackTtsProvider = 'elevenlabs';

  static const String secureStorageKeyApiToken = 'api_token';
  static const String secureStorageKeyRefreshToken = 'refresh_token';
  static const String secureStorageKeyUserId = 'user_id';
  static const String secureStorageKeyClonedVoiceData = 'cloned_voice_data';

  static const String prefsKeyThemeMode = 'theme_mode';
  static const String prefsKeyLanguage = 'language';
  static const String prefsKeyDefaultVoiceId = 'default_voice_id';
  static const String prefsKeyDefaultSpeechRate = 'default_speech_rate';
  static const String prefsKeyAutoPlay = 'auto_play';
  static const String prefsKeyDownloadOnGenerate = 'download_on_generate';

  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  static const double vietnameseCharsPerSecond = 15.0;
  static const double minEstimatedDurationSeconds = 0.5;
  static const double maxEstimatedDurationSeconds = 600.0;
}
