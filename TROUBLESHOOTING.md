# Troubleshooting

Common issues and solutions for VietVoice Studio.

---

## Common Issues

### App Won't Start

| Symptom | Cause | Solution |
|---------|-------|----------|
| White screen on launch | Database corruption | Delete app data and reinstall |
| Crash on startup | Incompatible SDK version | Update Flutter to >= 3.11.1 |
| Stuck on splash | Network timeout | Check internet connection |
| "Provider scope" error | Riverpod not initialized | Ensure `ProviderScope` wraps app |

### App Crashes

```
Settings → Advanced → Clear Cache → Restart app
```

If crash persists:
1. Check crash logs: `flutter logs`
2. Try factory reset: `Settings → Advanced → Factory Reset`
3. Reinstall the app

---

## Build Problems

### Flutter SDK Issues

```bash
# Check Flutter version
flutter --version
# Required: >= 3.11.1

# Upgrade Flutter
flutter upgrade

# Clean and rebuild
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### iOS Build Issues

| Error | Solution |
|-------|----------|
| `CocoaPods not installed` | `sudo gem install cocoapods` |
| `Pod install failed` | `cd ios && pod deintegrate && pod install` |
| `Signing error` | Open Xcode → Select Team → Enable "Automatically manage signing" |
| `Minimum iOS version` | Set `platform :ios, '13.0'` in `ios/Podfile` |
| `Xcode not found` | `sudo xcode-select --switch /Applications/Xcode.app` |

```bash
# Full iOS clean build
flutter clean
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
flutter build ios --release
```

### Android Build Issues

| Error | Solution |
|-------|----------|
| `Gradle sync failed` | `cd android && ./gradlew clean` |
| `SDK not found` | Install Android SDK via Android Studio |
| `NDK version mismatch` | Set `ndkVersion` in `android/app/build.gradle` |
| `Min SDK too low` | Set `minSdkVersion 21` in `build.gradle` |
| `Duplicate files` | Add `packagingOptions` in `build.gradle` |

```gradle
// android/app/build.gradle
android {
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 34
    }
    packagingOptions {
        pickFirst '**/libc++_shared.so'
        pickFirst '**/libjsc.so'
    }
}
```

### Code Generation Issues

```bash
# If build_runner fails
flutter pub run build_runner build --delete-conflicting-outputs

# If conflicts persist
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## Runtime Errors

### Riverpod Errors

| Error | Cause | Solution |
|-------|-------|----------|
| `Bad state: No element` | Provider not found | Check provider name spelling |
| `ProviderScope not found` | Missing ProviderScope | Wrap app in `ProviderScope` |
| `Cannot modify provider` | Writing to read-only provider | Use `StateNotifier` for mutable state |
| `Circular dependency` | Providers depend on each other | Refactor to remove circular refs |

### Database Errors

| Error | Cause | Solution |
|-------|-------|----------|
| `DatabaseException` | Corrupted database | Delete `vietvoice_studio.db` and restart |
| `Migration failed` | Schema version mismatch | Uninstall and reinstall app |
| `Table not found` | Migration not run | Run `flutter clean` and rebuild |
| `Constraint failed` | Duplicate or invalid data | Check data before insert |

### Network Errors

| Error | Cause | Solution |
|-------|-------|----------|
| `SocketException` | No internet | Check network connection |
| `TimeoutException` | Slow network | Increase timeout in settings |
| `HandshakeException` | SSL error | Check system date/time |
| `Connection refused` | Server down | Check backend status |

---

## API Connection Issues

### ElevenLabs API

#### Test Connection

```
Settings → API Configuration → Test Connection
```

#### Common API Errors

| Status | Error | Solution |
|--------|-------|----------|
| `401` | Invalid API key | Update API key in Settings |
| `403` | Forbidden | Check API key permissions |
| `404` | Voice not found | Refresh voice list |
| `422` | Invalid request | Check text length and parameters |
| `429` | Rate limited | Wait 60 seconds and retry |
| `500` | Server error | Retry with exponential backoff |
| `503` | Service unavailable | Check ElevenLabs status page |

#### API Key Issues

```
Symptom: "401 Unauthorized" khi dùng provider ElevenLabs

1. ElevenLabs KHÔNG dùng key trong app — key nằm ở backend
2. Kiểm tra backend/.env có ELEVENLABS_API_KEY=... rồi khởi động lại backend
3. Kiểm tra backend: curl http://127.0.0.1:3000/v1/voices?provider=elevenlabs
4. Nếu backend báo 401 InvalidApiKey → chưa cấu hình key
5. Nếu backend báo 401 MissingApiKey/InvalidApiKey kèm VVT_API_KEYS → kiểm tra
   key app gửi qua header x-vvt-api-key
6. Tạo key mới tại: https://elevenlabs.io/app/settings/api-keys

Lưu ý: provider Google TTS không cần key, nếu Google cũng lỗi 401 thì kiểm tra
VVT_API_KEYS ở backend.
```

#### Connection Timeout

```dart
// Increase timeout in lib/core/constants/app_constants.dart
static const Duration apiTimeout = Duration(seconds: 60);  // Was 30
static const Duration connectionTimeout = Duration(seconds: 15);  // Was 10
```

### Backend Proxy

#### Test Backend Connection

```bash
curl -X GET https://api.vietvoice.studio/v1/health \
  -H "Authorization: Bearer YOUR_TOKEN"
```

#### Backend Errors

| Error | Cause | Solution |
|-------|-------|----------|
| `401` | Token expired | Re-login to refresh token |
| `403` | Subscription expired | Upgrade subscription |
| `429` | Rate limited | Wait and retry |
| `500` | Server error | Contact support |
| `502` | Bad gateway | Backend is down, try later |
| `503` | Maintenance | Check status page |

---

## Audio Playback Issues

### No Sound

| Check | Action |
|-------|--------|
| Volume | Increase device volume |
| Mute switch | Check physical mute switch (iOS) |
| Bluetooth | Disconnect Bluetooth headphones |
| Audio route | Check audio output route |
| App permissions | Grant audio permissions |

### Audio Cracking/Distortion

```
1. Reduce audio quality settings
2. Close other audio apps
3. Restart the app
4. Check for app updates
```

### Playback Stuttering

```dart
// In audio player, increase buffer duration
await player.setAudioSource(
  AudioSource.uri(Uri.parse(url)),
  preload: true,
);
```

### Recording Issues

| Issue | Solution |
|-------|----------|
| No microphone permission | Settings → Privacy → Microphone → Enable |
| Poor recording quality | Move closer to microphone, reduce background noise |
| Recording too short | Record at least 30 seconds for voice cloning |
| File format error | Use WAV or M4A format |

---

## Performance Issues

### Slow App

```
1. Close background apps
2. Clear app cache: Settings → Advanced → Clear Cache
3. Reduce audio quality in settings
4. Delete old audio files from library
5. Restart the app
```

### High Memory Usage

```
1. Close unused projects
2. Delete old generation jobs
3. Clear audio cache
4. Limit concurrent generations to 1-2
```

### Slow Generation

| Cause | Solution |
|-------|----------|
| Long text | Split into smaller segments |
| Slow network | Check internet speed |
| Server load | Try again later |
| High quality settings | Reduce quality for faster generation |

---

## Platform-Specific Issues

### iOS

| Issue | Solution |
|-------|----------|
| App stuck on splash | Force close and reopen |
| Audio plays through earpiece | Check audio session configuration |
| Recording permission denied | Settings → Privacy → Microphone |
| Push notifications not working | Settings → Notifications → Enable |
| App crashes on background | Check background modes in Xcode |

### Android

| Issue | Solution |
|-------|----------|
| App crashes on launch | Clear app data: Settings → Apps → VietVoice → Clear Data |
| Notification permission denied | Settings → Apps → VietVoice → Notifications |
| Storage permission denied | Settings → Apps → VietVoice → Permissions |
| Audio focus issues | Close other media apps |
| Battery optimization killing app | Settings → Battery → Don't optimize |

---

## Debug Mode

### Enable Debug Logging

```bash
flutter run --dart-define=DEV_MODE=true --dart-define=ENABLE_LOGGING=true
```

### View Logs

```bash
# iOS
flutter logs

# Android
adb logcat | grep flutter

# Both
flutter run -v
```

### Common Debug Commands

```bash
# Check dependencies
flutter pub deps

# Analyze code
flutter analyze

# Run tests
flutter test

# Check for outdated packages
flutter pub outdated

# Validate app bundle
flutter build apk --debug --analyze-size
```

---

## Getting Help

### Before Contacting Support

1. [ ] Check this troubleshooting guide
2. [ ] Try clearing cache and restarting
3. [ ] Try factory reset
4. [ ] Check for app updates
5. [ ] Test on a different device
6. [ ] Note the exact error message
7. [ ] Note steps to reproduce the issue

### Information to Provide

| Info | How to Get |
|------|-----------|
| App version | Settings → About |
| Device model | Settings → About |
| OS version | Device settings |
| Error message | Screenshot or copy text |
| Steps to reproduce | Write down what you did |
| Logs | `flutter logs` or `adb logcat` |

### Support Channels

- **Email:** support@vietvoice.studio
- **GitHub Issues:** github.com/your-org/vietvoice-studio/issues
- **Discord:** discord.gg/vietvoice

---

## FAQ

### General

**Q: Is VietVoice Studio free?**
A: The app is free to download. TTS generation requires an ElevenLabs API key with available credits.

**Q: Does it work offline?**
A: Basic features work offline. TTS generation requires internet connection.

**Q: Is my voice data safe?**
A: Audio samples are stored only on your device and transmitted via encrypted HTTPS. API keys are stored in platform-secured storage.

**Q: Can I use it for commercial projects?**
A: Yes, generated audio can be used for commercial purposes. Check ElevenLabs' terms of service for details.

### Technical

**Q: Why is generation slow?**
A: Generation time depends on text length, server load, and network speed. Typical generation takes 2-10 seconds.

**Q: How much storage does the app use?**
A: The app itself is ~50MB. Audio files vary in size (1-5MB per minute of audio).

**Q: Can I export my data?**
A: Yes, audio files can be exported and shared. Projects and scripts can be backed up via factory reset.

**Q: What happens if I uninstall the app?**
A: All local data (projects, scripts, audio, settings) will be deleted. Cloned voices on ElevenLabs servers will remain unless manually deleted.
