# CHANGELOG

All notable changes to VietVoice Studio. Format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased] — VoiceStudio provider (GPU PC on the LAN)

### Added
- **`voicestudio` provider.** The backend forwards clone (`POST /profiles`) and
  speech (`POST /v1/audio/speech`) to VoiceStudio at `VOICESTUDIO_BASE_URL`, with
  the LAN-share PIN (`x-omnivoice-pin`) or `Authorization: Bearer` only when set.
  XTTS, Google and ElevenLabs are unchanged. See `DOCS/VOICESTUDIO_LOCAL_SETUP.md`.
- **`GET /v1/voicestudio/health`** reports reachability, the device VoiceStudio
  itself reports (CUDA/CPU), version and latency; null where it reports nothing.
- **"Nghe lại bản ghi"** plays the recorder's original file, reloaded on every
  press, before anything is uploaded.
- **Transcript of the sample (`ref_text`)** is sent with every clone; the record
  sheet pre-fills it with the sample sentence and lets the user correct it.
- The app switches to VoiceStudio once, the first time the backend reports it ready.

### Changed
- Voice samples are capped at 20s (recorder stops at 19s): OmniVoice reads at
  most 20s of reference, and a cut sample with a full transcript makes every
  generated sentence start with the cut-off words. The sample text is shorter
  so it fits.
- Recordings are named `voice_clone_<uuid>.wav`.

### Fixed
- VoiceStudio answers an unknown voice id with its default voice and HTTP 200;
  the backend now checks the profile exists and returns `PROFILE_INVALID`.
- VoiceStudio failures never surface as HTTP 401, which the app shows as
  "Phiên đăng nhập đã hết hạn"; the backend's Vietnamese explanation is shown.

## Backend LAN / iOS connectivity

### Fixed
- **Stale hard-coded backend address.** `AppConstants.apiBaseUrl` defaulted to
  `http://192.168.68.65:3000/v1`, so every request went to a host that no longer
  existed on the user's network. It is now `String.fromEnvironment('API_BASE_URL')`
  — empty unless the build explicitly sets it, which makes the app ask for an
  address instead of silently dialling a dead host.
- **LAN discovery could never run on iOS.** `selectLocalAddresses()` filtered on
  interface names (`wlan`, `wi-fi`), so Android's `wlan0` worked while iOS's
  `en0` produced an empty candidate list and aborted before opening a socket.
  Interface names are now only a preference; any private IPv4 counts.
- **The phone's own IP could be reported as a backend.** Discovery now removes the
  device's addresses from the candidate set before probing.
- **Discovery accepted any web server.** A host is only accepted when `/v1/health`
  returns 200 *and* contains the `vietvoice-backend` signature.
- **Settings showed contradictory IPs with no labels.** Rebuilt around
  *Thiết bị này* vs *Máy chủ giọng nói*, with a status dot, address, port,
  provider and latency. Raw interface names (`pdp_ip0`, `rd0`, `ipsec5`) are no
  longer shown to users; they go to `debugPrint`.
- **`app_theme.dart` did not compile.** `CupertinoPageTransitionsBuilder` was used
  without importing `package:flutter/cupertino.dart`, which broke every widget
  test.
- **Two missing AppStrings getters** (`recordVoiceDeleteSample`,
  `recordVoiceChooseServer`) referenced by the record sheet.

### Added
- `lib/core/network/backend_config.dart` — `BackendConfig` as the single source of
  truth for the backend address; Settings, Voice Clone, TTS, Health Check and LAN
  Discovery all read from it instead of keeping separate `backendUrl` /
  `serverUrl` / `apiBaseUrl` / `discoveredServer` copies.
- `BackendCheckResult` + `checkBackendHealth()` — a health check that returns
  address, provider, latency, or the real cause, never a single "cannot connect".
- Per-cause error messages: Local Network permission denied, connection refused
  (with the port), timeout, no route / unreachable, DNS, TLS, HTTP 404, 401/403,
  and 5xx.
- iOS method channel `com.vietvoice.vietvoice_studio/settings` → `openAppSettings`,
  so a denied Local Network permission links straight to the right Settings page.
- `NSLocalNetworkUsageDescription` and `NSAllowsLocalNetworking` in `Info.plist`.
- `GET /health` as an alias of `/v1/health`, mounted ahead of the rate limiter so
  a liveness probe is never throttled; `/v1/health` now also reports per-provider
  availability.
- `test/manual/live_health_check.dart` and `test/manual/live_backend_probe_check.dart`
  — opt-in tests that exercise the real probe against a running backend
  (`--dart-define=LAN_BACKEND_URL=…`).

### Changed
- Backend binds `0.0.0.0` explicitly (no route removed).
- CORS reflects the request origin so a LAN backend called by IP from the phone
  works in every `NODE_ENV` without allowing credentialed cross-site use.
- Voice clone health-checks the backend *before* uploading, and a failed clone
  keeps the local recording with **Thử lại / Chọn máy chủ / Xóa bản ghi**.
- Discovery tests now assert the device's own address is never probed.

### Security
- Provider secrets stay on the backend. The app only calls
  `POST /v1/voices/clone`; no ElevenLabs key is ever present in the Flutter/iOS
  build.
