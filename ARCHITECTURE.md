# Architecture

VietVoice Studio follows **Clean Architecture** principles with clear separation of concerns across three layers.

---

## Overview

```
┌─────────────────────────────────────────────────────┐
│                  Presentation Layer                   │
│  (Screens, Widgets, Providers/State Management)      │
├─────────────────────────────────────────────────────┤
│                    Domain Layer                       │
│  (Entities, Repository Interfaces, Use Cases)        │
├─────────────────────────────────────────────────────┤
│                     Data Layer                        │
│  (Repository Implementations, Data Sources, Models)  │
└─────────────────────────────────────────────────────┘
```

**Dependency Rule:** Dependencies point inward. The domain layer has no dependencies on outer layers.

---

## Clean Architecture Layers

### 1. Presentation Layer (`lib/features/`)

Contains UI screens, widgets, and state management providers.

```
lib/features/
├── home/                    # Home screen
│   ├── home_screen.dart
│   └── home_provider.dart
├── script_editor/           # Script editing
│   ├── script_editor.dart
│   └── script_editor_provider.dart
├── voice/                   # Voice selection & cloning
│   ├── voice_selector_screen.dart
│   ├── voice_cloning_screen.dart
│   ├── voice_provider.dart
│   ├── voice_cloning_provider.dart
│   └── widgets/
│       └── voice_card.dart
├── generation/              # Audio generation
│   ├── generation_screen.dart
│   ├── segment_editor_screen.dart
│   ├── result_screen.dart
│   └── generation_provider.dart
├── audio_library/           # Audio file management
│   ├── library_screen.dart
│   └── library_provider.dart
├── audio_detail/            # Audio playback & details
│   ├── audio_detail_screen.dart
│   └── audio_detail_provider.dart
└── settings/                # App settings
    ├── settings_screen.dart
    └── settings_provider.dart
```

**Key Principles:**
- Widgets are stateless where possible; state lives in Riverpod providers
- Providers call use cases, never repositories directly
- Navigation uses Flutter's built-in `Navigator`

### 2. Domain Layer (`lib/domain/`)

Contains business logic, entities, and repository contracts.

```
lib/domain/
├── entities/                # Immutable data models (freezed)
│   ├── voice.dart
│   ├── tts_request.dart
│   ├── tts_response.dart
│   ├── script.dart
│   ├── project.dart
│   ├── generation_job.dart
│   ├── audio_asset.dart
│   └── app_settings.dart
├── repositories/            # Abstract interfaces
│   ├── tts_repository.dart
│   ├── voice_repository.dart
│   ├── audio_repository.dart
│   └── settings_repository.dart
└── usecases/                # Single-responsibility actions
    ├── synthesize_text.dart
    ├── get_voices.dart
    ├── clone_voice.dart
    ├── get_usage.dart
    └── test_connection.dart
```

**Entity Example:**

```dart
// lib/domain/entities/voice.dart
@freezed
class Voice with _$Voice {
  const factory Voice({
    required int id,
    required String provider,
    required String providerVoiceId,
    required String name,
    String? description,
    required String language,
    required String gender,
    String? accent,
    @Default(false) bool isCloned,
    @Default(false) bool isFavorite,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Voice;
}
```

### 3. Data Layer (`lib/data/`)

Contains implementations of repository interfaces, data sources, and models.

```
lib/data/
├── models/                  # Drift table definitions + data classes
│   ├── voice.dart
│   ├── project.dart
│   ├── script.dart
│   ├── script_segment.dart
│   ├── voice_reference.dart
│   ├── audio_asset.dart
│   ├── generation_job.dart
│   └── app_settings.dart
├── datasources/
│   ├── local/               # Local storage (Drift/SharedPreferences)
│   │   ├── app_database.dart
│   │   ├── voice_local_datasource.dart
│   │   ├── settings_local_datasource.dart
│   │   └── audio_local_datasource.dart
│   └── remote/              # Remote API calls
│       └── tts_remote_datasource.dart
├── repositories/            # Repository implementations
│   ├── tts_repository_impl.dart
│   ├── voice_repository_impl.dart
│   ├── audio_repository_impl.dart
│   └── settings_repository_impl.dart
└── services/                # External service integrations
    ├── tts_provider.dart    # Abstract TTS provider interface
    └── elevenlabs_provider.dart  # ElevenLabs implementation
```

---

## Provider Abstraction

The TTS provider abstraction allows swapping TTS engines without changing business logic.

### Interface Definition

```dart
// lib/data/services/tts_provider.dart
abstract class TtsProvider {
  Future<List<Voice>> getVoices();

  Future<Uint8List> synthesize({
    required String voiceId,
    required String text,
    String? modelId,
    double? stability,
    double? similarityBoost,
    double? style,
    bool? useSpeakerBoost,
  });

  Future<Uint8List> synthesizeWithStream({
    required String voiceId,
    required String text,
    String? modelId,
    double? stability,
    double? similarityBoost,
    double? style,
    bool? useSpeakerBoost,
  });

  Future<Voice> cloneVoice({
    required String name,
    required String description,
    required List<File> audioFiles,
    String? language,
  });

  Future<void> deleteVoice(String voiceId);
  Future<Map<String, dynamic>> getUsage();
  Future<bool> testConnection();
}
```

### Provider Flow

```
UI (Screen)
  ↓
Riverpod Provider (State)
  ↓
Use Case (Business Logic)
  ↓
Repository Interface (Domain)
  ↓
Repository Implementation (Data)
  ↓
TtsProvider Interface
  ↓
ElevenLabsProvider (Concrete)
  ↓
ElevenLabs API
```

### Adding a New Provider

1. Implement the provider (usually by extending `BackendTtsProvider` so it talks to the
   backend with the `provider` field):

```dart
class AcmeTtsProvider extends BackendTtsProvider {
  AcmeTtsProvider(super.remote);

  @override
  String get id => 'acme';

  @override
  String get name => AppStrings.providerAcmeName;
}
```

2. Add the id to `TtsProviderIds` in `lib/data/services/tts_provider.dart`
3. Register it in `ttsProviderRegistryProvider` (`lib/features/voice/voice_provider.dart`)
4. Handle the id in the backend `providerRouter` + a service in `backend/src/services/`
5. Add the label strings to `AppStrings` and a row in the settings provider list
6. Add tests in `test/unit/tts_provider_test.dart`

---

## State Management with Riverpod

VietVoice Studio uses **Flutter Riverpod** for state management.

### Provider Types

| Type | Use Case | Example |
|------|----------|---------|
| `StateNotifierProvider` | Complex mutable state | `generationProvider` |
| `FutureProvider` | Async data fetching | `voicesProvider` |
| `StreamProvider` | Reactive data streams | `projectsStreamProvider` |
| `Provider` | Simple dependency injection | `databaseProvider` |
| `StateProvider` | Simple mutable state | `selectedVoiceProvider` |

### Provider Example

```dart
// lib/features/generation/generation_provider.dart
class GenerationNotifier extends StateNotifier<GenerationState> {
  GenerationNotifier(this._ttsRepository) : super(const GenerationState.idle());

  final TtsRepository _ttsRepository;

  Future<void> generate({
    required String text,
    required String voiceId,
    required TtsRequest request,
  }) async {
    state = const GenerationState.loading();
    try {
      final response = await _ttsRepository.synthesize(request);
      state = GenerationState.success(response);
    } catch (e) {
      state = GenerationState.error(e.toString());
    }
  }
}

final generationProvider =
    StateNotifierProvider<GenerationNotifier, GenerationState>((ref) {
  final repo = ref.watch(ttsRepositoryProvider);
  return GenerationNotifier(repo);
});
```

### Repository Injection

```dart
// Repository providers
final databaseProvider = Provider<AppDatabase>((ref) => AppDatabase());

final ttsRepositoryProvider = Provider<TtsRepository>((ref) {
  final db = ref.watch(databaseProvider);
  final apiKey = ref.watch(apiKeyProvider);
  return TtsRepositoryImpl(
    remoteDatasource: TtsRemoteDatasource(
      baseUrl: AppConstants.apiBaseUrl,
      apiKey: apiKey,
    ),
    localDatasource: VoiceLocalDatasource(db),
  );
});
```

---

## Local Storage with Drift

### Database Setup

```dart
// lib/data/datasources/local/app_database.dart
@DriftDatabase(
  tables: [
    Projects,
    Scripts,
    ScriptSegments,
    Voices,
    VoiceReferences,
    AudioAssets,
    GenerationJobs,
    AppSettingsTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          // Insert default settings
          await into(appSettingsTable).insert(
            const AppSettingsTableCompanion(
              id: Value(1),
              themeMode: Value('system'),
              defaultSpeed: Value(1.0),
              defaultFormat: Value('mp3'),
              autoNormalize: Value(true),
              autoSplit: Value(true),
              warningThreshold: Value(1000),
            ),
          );
        },
      );
}
```

### Database Location

- **iOS:** `Documents/vietvoice_studio.db`
- **Android:** `app_flutter/vietvoice_studio.db`

### Reactive Queries

```dart
// Stream that auto-updates when data changes
Stream<List<Project>> watchAllProjects() => select(projects).watch();

// One-time fetch
Future<List<Project>> getAllProjects() => select(projects).get();
```

See [LOCAL_STORAGE.md](LOCAL_STORAGE.md) for full schema details.

---

## Audio Service Architecture

### Audio Playback

Uses `just_audio` package for robust audio playback:

```
AudioDetailScreen
  ↓
AudioDetailProvider (StateNotifier)
  ↓
AudioRepository (Interface)
  ↓
AudioRepositoryImpl
  ↓
AudioLocalDatasource (file path resolution)
  ↓
just_audio Player
```

### Audio Recording

Uses `record` package for voice cloning input:

```
VoiceCloningScreen
  ↓
VoiceCloningProvider
  ↓
record package → Audio File
  ↓
TtsProvider.cloneVoice(audioFiles)
```

### Audio File Storage

Audio files are stored in the app's documents directory:

```
Documents/
├── audio/
│   ├── generated/     # TTS output files
│   │   ├── {uuid}.mp3
│   │   └── {uuid}.wav
│   └── recordings/    # User recordings for cloning
│       └── {uuid}.m4a
└── vietvoice_studio.db  # Drift database
```

---

## Backend Proxy Architecture

### Why Use a Backend Proxy?

| Reason | Description |
|--------|-------------|
| **API Key Security** | Keep API keys server-side |
| **Rate Limiting** | Control usage per user |
| **Usage Analytics** | Track consumption |
| **Caching** | Reduce API calls |
| **Cost Control** | Prevent abuse |

### Architecture

```
Flutter App
  ↓ HTTP (Dio)
Backend Proxy (api.vietvoice.studio)
  ↓ HTTP
ElevenLabs API
```

### Request Flow

1. App sends request to backend with user token
2. Backend validates token and checks rate limits
3. Backend forwards request to ElevenLabs with server-side API key
4. Backend caches response if applicable
5. Response returned to app

### Backend Configuration

```dart
// In app settings
static const String apiBaseUrl = 'https://api.vietvoice.studio/v1';
```

See [BACKEND.md](BACKEND.md) for full API documentation.

---

## Security Considerations

### API Key Storage

```dart
// API keys are NEVER stored in SharedPreferences
// They use flutter_secure_storage:

// iOS: Keychain
// Android: EncryptedSharedPreferences

const storage = FlutterSecureStorage(
  aOptions: AndroidOptions(
    encryptedSharedPreferences: true,
  ),
  iOptions: IOSOptions(
    accessibility: KeychainItemAccessibility.first_unlock_this_device,
  ),
);
```

### Network Security

- All API calls use HTTPS
- Certificate pinning recommended for production
- Backend proxy mode hides API keys from client

### Data Protection

| Data | Storage | Protection |
|------|---------|------------|
| API Keys | flutter_secure_storage | Keychain / EncryptedSharedPreferences |
| User Data | Drift (SQLite) | App sandbox |
| Audio Files | File system | App sandbox |
| Settings | Drift (SQLite) | App sandbox |

### Best Practices

1. **Never hardcode API keys** in source code
2. **Use backend proxy** in production to hide keys
3. **Validate all inputs** before sending to API
4. **Implement rate limiting** on backend
5. **Use short-lived tokens** with refresh mechanism
6. **Encrypt sensitive data** at rest
7. **Clear sensitive data** on logout/reset

---

## Project Dependencies

| Package | Purpose |
|---------|---------|
| `flutter_riverpod` | State management |
| `drift` | SQLite ORM |
| `dio` | HTTP client |
| `just_audio` | Audio playback |
| `record` | Audio recording |
| `flutter_secure_storage` | Secure key storage |
| `freezed` | Immutable data classes |
| `json_serializable` | JSON serialization |
| `google_fonts` | Typography |
| `file_picker` | File selection |
| `share_plus` | Share functionality |
| `path_provider` | File system paths |
| `uuid` | Unique ID generation |
| `intl` | Internationalization |

---

## Folder Structure Summary

```
lib/
├── main.dart                          # App entry point
├── core/
│   ├── constants/                     # App-wide constants
│   ├── design_system/                 # Theme, colors, typography
│   └── localization/                  # i18n strings
├── domain/
│   ├── entities/                      # Business models (freezed)
│   ├── repositories/                  # Abstract contracts
│   └── usecases/                      # Business actions
├── data/
│   ├── models/                        # Drift tables + data classes
│   ├── datasources/
│   │   ├── local/                     # Local DB & prefs
│   │   └── remote/                    # API clients
│   ├── repositories/                  # Repository implementations
│   └── services/                      # External service integrations
└── features/
    ├── home/                          # Home screen
    ├── script_editor/                 # Script editing
    ├── voice/                         # Voice selection & cloning
    ├── generation/                    # Audio generation
    ├── audio_library/                 # Audio file management
    ├── audio_detail/                  # Audio playback
    └── settings/                      # App settings
```
