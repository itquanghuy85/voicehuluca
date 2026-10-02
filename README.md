# VietVoice Studio

**AI Voice Generation for TikTok Content** — Giọng nói AI cho nội dung TikTok

VietVoice Studio is a Flutter application that empowers content creators to generate high-quality Vietnamese AI voices for TikTok videos, podcasts, and other media. It supports multiple TTS providers — Google TTS by default (free, no account) and ElevenLabs for premium quality and voice cloning — through a VietVoice backend proxy that keeps all provider keys server-side.

---

## Table of Contents

- [Features](#features)
- [Screenshots](#screenshots)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Running the Flutter App](#running-the-flutter-app)
  - [Running the Backend](#running-the-backend)
  - [Configuring Secrets](#configuring-secrets)
- [Development Mode](#development-mode)
- [Production Configuration](#production-configuration)
- [Building for iOS](#building-for-ios)
- [Changing TTS Provider](#changing-tts-provider)
- [Resetting the App](#resetting-the-app)
- [Documentation](#documentation)
- [License](#license)

---

## Features

### Core Features

| Feature | Description | Mô tả |
|---------|-------------|-------|
| **AI Voice Synthesis** | Generate natural-sounding Vietnamese speech from text | Tạo giọng nói tiếng Việt tự nhiên từ văn bản |
| **Voice Cloning** | Clone your voice or any voice from audio samples | Nhân bản giọng nói từ mẫu âm thanh |
| **Script Editor** | Write, edit, and manage scripts with segment support | Viết và quản lý kịch bản theo từng đoạn |
| **Audio Library** | Organize, search, and manage generated audio files | Thư viện âm thanh với tìm kiếm và phân loại |
| **Project Management** | Group scripts and audio into projects | Quản lý dự án theo nhóm |
| **Multi-provider Support** | Pluggable TTS provider architecture | Hỗ trợ nhiều nhà cung cấp TTS |
| **Dark/Light Theme** | System-aware theme with custom design system | Giao diện sáng/tối theo hệ thống |
| **Local Storage** | Offline-first with Drift (SQLite) database | Lưu trữ offline với cơ sở dữ liệu SQLite |
| **Audio Recording** | Record audio directly in the app for voice cloning | Ghi âm trực tiếp trong ứng dụng |
| **Export & Share** | Export audio in multiple formats and share | Xuất và chia sẻ âm thanh nhiều định dạng |

### Voice Features

- **Stability Control** — Điều chỉnh độ ổn định giọng nói
- **Similarity Boost** — Tăng độ tương đồng với gốc
- **Style Exaggeration** — Điều chỉnh phong cách nói
- **Speaker Boost** — Tăng cường chất lượng loa
- **Speech Rate** — 0.5x to 2.0x speed control (ElevenLabs and Google Cloud TTS honour it;
  the free Google voice keeps its natural rate)
- **Provider Choice** — Google TTS (default), ElevenLabs, or Local TTS (free, on the
  backend machine, with voice cloning)
- **Quick Voice Clone** — Record 5–30s in the voice selector, get a reusable voice
  (XTTS-v2, free and offline after the first ~1.8GB model download)

---

## Screenshots

> Screenshots will be added here. Place images in `docs/screenshots/`.

| Home | Script Editor | Voice Selector | Generation |
|------|--------------|----------------|------------|
| ![Home](docs/screenshots/home.png) | ![Script](docs/screenshots/script.png) | ![Voices](docs/screenshots/voices.png) | ![Generate](docs/screenshots/generate.png) |

| Voice Cloning | Audio Library | Settings | Audio Detail |
|---------------|---------------|----------|--------------|
| ![Clone](docs/screenshots/clone.png) | ![Library](docs/screenshots/library.png) | ![Settings](docs/screenshots/settings.png) | ![Detail](docs/screenshots/detail.png) |

---

## Getting Started

### Prerequisites

- **Flutter SDK** >= 3.11.1
- **Dart SDK** >= 3.0.0
- **Xcode** (for iOS development)
- **Android Studio** (for Android development)
- **ElevenLabs API Key** *(optional)* — only needed for the ElevenLabs provider and
  voice cloning. Get yours at [elevenlabs.io](https://elevenlabs.io). Google TTS works
  without any key.

### Running the Flutter App

```bash
# Clone the repository
git clone https://github.com/your-org/vietvoice-studio.git
cd vietvoice-studio

# Install dependencies
flutter pub get

# Run code generation (freezed, drift, json_serializable)
flutter pub run build_runner build --delete-conflicting-outputs

# Run on connected device
flutter run

# Run on specific device
flutter run -d <device-id>

# Run in debug mode with hot reload
flutter run --debug
```

### Building for iOS (macOS required)

Minimum deployment target is **iOS 15.0**, already set in
`ios/Runner.xcodeproj` and pinned by `platform :ios, '15.0'` in `ios/Podfile`.

```bash
# On a Mac with Xcode and CocoaPods installed
flutter pub get
cd ios && pod install && cd ..    # Podfile pins iOS 15.0 for the app and every pod
flutter build ios --debug --no-codesign      # simulator / unsigned build
flutter build ipa --no-codesign              # archive without signing
open ios/Runner.xcworkspace                  # then pick your Team to run on a device
```

If the pods were installed before, clear them once so the `post_install` hook
that pins every pod to iOS 15.0 takes effect:

```bash
flutter clean
cd ios && rm -rf Pods Podfile.lock && pod install && cd ..
```

Notes:

- Use the **workspace** (`Runner.xcworkspace`), not the project, or the pods
  are not compiled.
- Set your signing team once: Xcode → *Runner* → *Signing & Capabilities*.
- The microphone permission text lives in `ios/Runner/Info.plist`
  (`NSMicrophoneUsageDescription`). Without it the app is rejected at runtime
  when recording.
- `UIFileSharingEnabled` and `LSSupportsOpeningDocumentsInPlace` are on, so
  exported audio is reachable through Finder/Files. On iOS the app cannot write
  to a public Downloads folder like Android does; it exports to its own
  Documents folder.
- Plain HTTP to a LAN backend (for example `http://192.168.1.20:3000/v1`) is
  allowed through `NSAllowsLocalNetworking` in `Info.plist`. Add the address in
  *Cài đặt → Máy chủ*, or let the LAN scan find it.
- On the iOS simulator, `127.0.0.1` is the Mac itself, so a backend running on
  the same Mac is reachable at `http://127.0.0.1:3000/v1`.

### Running the Backend

The app can work in two modes:

1. **Direct API Mode** — Connects directly to ElevenLabs API
2. **Backend Proxy Mode** — Routes through a backend proxy for added security

#### Direct API Mode (Default)

No backend required. The app connects directly to ElevenLabs using your API key stored in secure storage.

#### Backend Proxy Mode

If you have a backend server, configure the proxy URL in the app settings:

```
Settings → API Configuration → Backend URL
```

See [BACKEND.md](BACKEND.md) for backend setup instructions.

### Pointing the App at Your Machine (LAN)

The app never hardcodes the backend address at runtime. **Cài đặt → Máy chủ giọng nói**
has three ways to set it:

1. **Dò mạng LAN** — the app takes the Wi-Fi address the phone already has, walks
   that `/24` (254 hosts, 32 at a time) and asks each one for `GET /v1/health`.
   Anything answering with the VietVoice signature is listed with its latency;
   tap one to use it.
2. **Type the address** — `192.168.1.20:3000` is enough. The app fills in
   `http://` and `/v1` for you, so `192.168.1.20:3000`,
   `http://192.168.1.20:3000/` and `http://192.168.1.20:3000/v1` all work.
3. **Kiểm tra** — pings the address in the field without saving it.

Notes for a home or office network:

- Phone and server must be on the **same subnet**. Guest Wi-Fi, mobile data or a
  phone hotspot usually isolates the phone, so discovery finds nothing — type the
  address by hand in that case.
- The backend listens on `0.0.0.0`, so allow port `3000` through the Windows
  firewall if the phone cannot reach it.
- Android builds allow plain HTTP on purpose (`usesCleartextTraffic`), because a
  LAN backend is served over `http://`.
- The address is stored per device, so the same APK works on any machine.

### Configuring Secrets

#### API Key Setup (optional)

Provider keys are **never** entered in the app. Only the backend holds them:

| Key | Where | Needed for |
|-----|-------|-----------|
| `ELEVENLABS_API_KEY` | `backend/.env` | ElevenLabs voices, synthesis, cloning |
| `GOOGLE_TTS_API_KEY` | `backend/.env` | Optional: switches Google to the official Cloud TTS API |
| `VVT_API_KEYS` | `backend/.env` | Optional: app API keys accepted by the backend |

The app can store a VietVoice Studio API key (Settings → **Kết nối dịch vụ**) which is
sent as `x-vvt-api-key`. It is kept with `flutter_secure_storage` (Keychain on iOS,
EncryptedSharedPreferences on Android) and is not a provider key.

#### Environment Variables (Development)

Create a `.env` file in the project root for development:

```env
# backend/.env
ELEVENLABS_API_KEY=your_api_key_here
GOOGLE_TTS_API_KEY=
GOOGLE_TTS_VOICE=vi-VN-Standard-A
VVT_API_KEYS=
PORT=3000
```

> **Security Note:** Never commit your `.env` file or API keys to version control. The `.env` file is already in `.gitignore`.

#### Secure Storage Keys

| Key | Purpose |
|-----|---------|
| `api_token` | VietVoice Studio API key (not a provider key) |
| `refresh_token` | Backend refresh token |
| `user_id` | Backend user ID |
| `cloned_voice_data` | Cached voice clone metadata |

---

## Development Mode

### Enabling Dev Mode

Dev mode enables additional debugging features:

```bash
# Run with dev flags
flutter run --dart-define=DEV_MODE=true --dart-define=ENABLE_LOGGING=true
```

### Dev Mode Features

- **Verbose Logging** — Detailed API request/response logs
- **Network Inspector** — View all HTTP requests
- **Database Inspector** — Browse local database tables
- **Mock Data** — Use mock TTS responses for testing
- **Performance Overlay** — Show rendering performance

### Code Generation

After modifying any model with `@freezed`, `@JsonSerializable`, or Drift tables:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Running Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test
flutter test test/widget_test.dart
```

---

## Production Configuration

### Building for Release

```bash
# Android APK
flutter build apk --release

# Android App Bundle (for Play Store)
flutter build appbundle --release

# iOS (requires macOS + Xcode)
flutter build ios --release

# Web
flutter build web --release
```

### Production Checklist

- [ ] Remove all `print()` statements
- [ ] Set `debugShowCheckedModeBanner: false` (already set in `main.dart`)
- [ ] Configure production API base URL
- [ ] Enable crash reporting (Firebase Crashlytics recommended)
- [ ] Set up analytics
- [ ] Review `AndroidManifest.xml` permissions
- [ ] Review `Info.plist` permissions
- [ ] Configure app signing
- [ ] Test on physical devices

### Environment Configuration

```dart
// lib/core/constants/app_constants.dart
static const String apiBaseUrl = 'https://api.vietvoice.studio/v1';
static const String websocketUrl = 'wss://stream.vietvoice.studio';
```

Override at build time:

```bash
flutter build apk --release --dart-define=API_BASE_URL=https://api.vietvoice.studio/v1
```

---

## Building for iOS

### Prerequisites

- macOS with Xcode 15+
- Apple Developer Account
- CocoaPods installed

### Steps

```bash
# 1. Install dependencies
flutter pub get

# 2. Install iOS pods
cd ios && pod install && cd ..

# 3. Open in Xcode (configure signing)
open ios/Runner.xcworkspace

# 4. In Xcode:
#    - Select your Team
#    - Set Bundle Identifier
#    - Configure Signing & Capabilities

# 5. Build
flutter build ios --release

# 6. Archive for App Store
#    Xcode → Product → Archive
```

### iOS Permissions

Add to `ios/Runner/Info.plist`:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access for voice cloning.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs photo library access to import audio files.</string>
<key>NSDocumentsFolderUsageDescription</key>
<string>This app needs document access to save audio files.</string>
```

---

## Changing TTS Provider

VietVoice Studio uses a provider abstraction pattern, making it easy to switch TTS providers.

### Current Providers

| Provider | Status | Description |
|----------|--------|-------------|
| **Google TTS** | ✅ Default | Free Vietnamese voice, no key required, no voice cloning |
| **ElevenLabs** | ✅ Optional | High quality + voice cloning (needs a key on the backend) |
| **Local TTS** | ✅ Free | Edge TTS + XTTS-v2 voice cloning on the backend machine, no key |

See [TTS_PROVIDER.md](TTS_PROVIDER.md) for the full design.

### Switching Providers

1. Go to **Settings** → **Nhà cung cấp giọng đọc**
2. Select your preferred provider
3. Tap **Kiểm tra kết nối** to verify (usage is shown only if the provider reports it)

### Adding a Custom Provider

Extend `BackendTtsProvider` so the provider is reached through the VietVoice backend
(vendor keys stay server-side):

```dart
// lib/data/services/acme_tts_provider.dart
import '../../core/localization/app_strings.dart';
import 'backend_tts_provider.dart';
import 'tts_provider.dart';

class AcmeTtsProvider extends BackendTtsProvider {
  AcmeTtsProvider(super.remote);

  @override
  String get id => 'acme';

  @override
  String get name => AppStrings.providerAcmeName;

  @override
  bool get supportsVoiceCloning => false;
}
```

Then add the id to `TtsProviderIds`, register the class in
`ttsProviderRegistryProvider`, and route it in `backend/src/services/providerRouter.ts`.

See [TTS_PROVIDER.md](TTS_PROVIDER.md) for detailed documentation.---

## Resetting the App

### Soft Reset (Clear Cache)

Clears temporary files and cached data:

```
Settings → Advanced → Clear Cache
```

### Hard Reset (Factory Reset)

**⚠️ Warning: This will delete ALL local data including projects, scripts, and audio files.**

```
Settings → Advanced → Factory Reset → Confirm
```

### Programmatic Reset

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:voice_huluca/data/datasources/local/app_database.dart';

// Clear secure storage
const storage = FlutterSecureStorage();
await storage.deleteAll();

// Delete database
final db = AppDatabase();
await db.deleteDatabase(); // Or delete the .db file directly

// Clear shared preferences
final prefs = await SharedPreferences.getInstance();
await prefs.clear();
```

### What Gets Reset

| Data | Soft Reset | Hard Reset |
|------|-----------|------------|
| API Key | ❌ | ✅ |
| Projects | ❌ | ✅ |
| Scripts | ❌ | ✅ |
| Audio Files | ❌ | ✅ |
| Voices | ❌ | ✅ |
| Settings | ❌ | ✅ |
| Cached Data | ✅ | ✅ |
| Temp Files | ✅ | ✅ |

---

## Documentation

| Document | Description |
|----------|-------------|
| [ARCHITECTURE.md](ARCHITECTURE.md) | App architecture and design patterns |
| [DESIGN_SYSTEM.md](DESIGN_SYSTEM.md) | Colors, typography, spacing, components |
| [TTS_PROVIDER.md](TTS_PROVIDER.md) | TTS provider abstraction and integrations |
| [VOICE_CLONING.md](VOICE_CLONING.md) | Voice cloning flow and best practices |
| [BACKEND.md](BACKEND.md) | Backend API documentation |
| [LOCAL_STORAGE.md](LOCAL_STORAGE.md) | Database schema and storage |
| [TROUBLESHOOTING.md](TROUBLESHOOTING.md) | Common issues and solutions |

---

## License

This project is proprietary software. All rights reserved.

---

**Made with ❤️ for Vietnamese content creators**
