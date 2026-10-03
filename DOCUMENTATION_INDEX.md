# DOCUMENTATION INDEX

Every document in this repository and what it is for.

## Start here

| Document | Read it when |
|---|---|
| [README.md](README.md) | Setting up the app, running it, pointing it at a backend |
| [HANDOVER.md](HANDOVER.md) | **The phone cannot reach the backend.** Root cause, what changed, what is still unverified |
| [CHANGELOG.md](CHANGELOG.md) | What changed in each release |
| [TROUBLESHOOTING.md](TROUBLESHOOTING.md) | Something is broken and you need the symptom → cause → fix |

## Backend LAN connectivity

| Document | Covers |
|---|---|
| [HANDOVER.md](HANDOVER.md) §3–6 | Real backend address, verified commands, iPhone test plan |
| [BACKEND.md](BACKEND.md) | API reference, routes, env vars, deployment |
| [DOCS/LAN_DISCOVERY_AUDIT.md](DOCS/LAN_DISCOVERY_AUDIT.md) | How LAN discovery works and what was audited |

Quick facts, all verified on the backend machine:

```
backend must bind : 0.0.0.0:3000   (never 127.0.0.1 / localhost)
health endpoint   : GET {base}/health   → {"service":"vietvoice-backend", …}
iOS permission    : NSLocalNetworkUsageDescription in ios/Runner/Info.plist
                    Settings → Privacy & Security → Local Network → VietVoice Studio
firewall (Win)    : inbound TCP 3000 allowed (Node.js rule, Public profile)
```

## Architecture and design

| Document | Covers |
|---|---|
| [ARCHITECTURE.md](ARCHITECTURE.md) | Layers, state management, data flow |
| [DESIGN_SYSTEM.md](DESIGN_SYSTEM.md) | Colors, typography, spacing, components |
| [LOCAL_STORAGE.md](LOCAL_STORAGE.md) | Database schema and on-device storage |
| [VOICE_CLONING.md](VOICE_CLONING.md) | Recording → upload → provider → `voice_id` |
| [TTS_PROVIDER.md](TTS_PROVIDER.md) | Provider abstraction, ElevenLabs / Google / local |

## Key source files for the backend flow

| File | Responsibility |
|---|---|
| `lib/core/network/backend_config.dart` | **Single source of truth** for the backend address |
| `lib/core/network/backend_endpoint.dart` | Parses/validates what the user types |
| `lib/core/network/backend_discovery.dart` | LAN scan, self-exclusion, VietVoice signature |
| `lib/core/network/network_failure.dart` | Maps a socket error to a cause |
| `lib/features/voice/voice_provider.dart` | `checkBackendHealth`, per-cause messages |
| `lib/features/settings/settings_screen.dart` | Address UI, health check, LAN scan |
| `lib/features/voice/voice_cloning_provider.dart` | Keeps the recording when upload fails |
| `backend/src/index.ts` | Bind address, CORS, route mounting |
| `backend/src/routes/health.ts` | Health payload |

## Tests

| Command | What it covers |
|---|---|
| `flutter test` | Unit + widget tests (322 passing) |
| `cd backend && npm test` | Backend tests (38 passing) |
| `flutter test test/manual/ --dart-define=LAN_BACKEND_URL=http://<LAN_IP>:3000/v1` | Real probe against a **running** backend — needs the server up |
