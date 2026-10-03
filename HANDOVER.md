# HANDOVER

## BACKEND LAN / iOS — "iPhone không tìm thấy backend"

**Status: backend + app VERIFIED on Windows · iPhone real-device test NOT RUN
(the host is Windows and no iPhone is attached, so `flutter build ios` and any
Local Network prompt cannot be exercised here). Every box that depends on a real
iPhone is listed under *NOT VERIFIED* below and must not be reported as passed.**

### 1. ROOT CAUSE

Three separate faults were stacked, which is why the screen showed two
contradictory IPs at once and no working server:

1. **A stale hard-coded default.** `app_constants.dart` compiled
   `http://192.168.68.65:3000/v1`. That address belonged to an earlier
   machine/network; on the current network the backend host is
   **`192.168.68.50`**. Every request went to a dead host, so "Dò mạng LAN"
   reported failure while a hand-typed address worked. The two IPs shown were
   *one stale default* and *one manually entered address* — neither was the
   phone's own IP.
2. **Discovery could not work on iOS at all.** `selectLocalAddresses()` only
   accepted interface names starting with `wlan`/`wi-fi`. Android's `wlan0`
   matched; iOS's `en0` did not, so the scan aborted with an empty address list
   before a single socket was opened. `NSLocalNetworkUsageDescription` was also
   missing, which on iOS 14+ blocks LAN probes outright.
3. **Every failure collapsed into one message.** Refused port, wrong subnet,
   denied Local Network permission, HTTP 404 and HTTP 500 all showed as
   "Không tìm thấy backend", so the permission case was indistinguishable from a
   wrong IP.

The backend needed no fix: it already listened on `0.0.0.0:3000`.

### 2. WHAT CHANGED

- **`lib/core/network/backend_config.dart` (new)** — single source of truth.
  Settings, Voice Clone, TTS, Health Check and LAN Discovery all resolve their
  address through `BackendConfig`; the separate `backendUrl` / `serverUrl` /
  `apiBaseUrl` / `discoveredServer` copies that overwrote each other are gone.
- **`lib/core/constants/app_constants.dart`** — `apiBaseUrl` is now
  `String.fromEnvironment('API_BASE_URL')`, i.e. **empty by default**. No LAN IP
  is compiled in, so a new user sees "chưa cấu hình" and is asked for an address
  instead of silently dialling a stranger's machine.
- **`lib/core/network/backend_discovery.dart`** — interface names are a
  preference, never a gate (`en0` now works); the device's own addresses are
  removed from the candidate set so the phone's IP can never be reported as a
  backend; a host answering HTTP 200 without the `vietvoice-backend` signature is
  rejected.
- **`lib/core/network/network_failure.dart`** + `voice_provider.dart` —
  `classifyNetworkFailure` splits refused / timeout / unreachable / DNS / TLS, and
  `checkBackendHealth` adds HTTP 404 / 401 / 403 / 5xx, each with its own message
  and its own fix.
- **`lib/features/settings/settings_screen.dart`** — the section is rebuilt around
  *Thiết bị này* (the phone) vs *Máy chủ giọng nói* (the server), with a status
  dot, address, port, provider and latency. Raw interfaces (`pdp_ip0`, `rd0`,
  `ipsec5`…) are no longer shown to the user; they go to `debugPrint`.
- **`ios/Runner/Info.plist`** — `NSLocalNetworkUsageDescription` (Vietnamese) and
  `NSAllowsLocalNetworking` for plain-HTTP LAN calls.
- **`ios/Runner/AppDelegate.swift`** — a method channel that opens this app's
  Settings page, so a denied Local Network permission is actionable.
- **`backend/src/index.ts`** — explicit `0.0.0.0` bind (was implicit), a `/health`
  alias beside `/v1/health`, and `/v1/health` moved ahead of the rate limiter so a
  liveness probe is never throttled. No route was removed.
- **`backend/src/routes/health.ts`** — returns `ok`, `service`, `version`,
  `provider`, `timestamp` plus per-provider availability.
- **Voice clone** — the backend is health-checked *before* upload, and a failure
  never deletes the recording: the sheet offers **Thử lại / Chọn máy chủ / Xóa
  bản ghi**.

### 3. BACKEND ADDRESS ACTUAL

Measured on the machine that runs Node, not assumed:

```
BACKEND LAN ADDRESS : 192.168.68.50      (Ethernet, NetworkCategory = Public)
BACKEND PORT        : 3000
BACKEND BASE URL    : http://192.168.68.50:3000/v1
BACKEND HEALTH URL  : http://192.168.68.50:3000/v1/health
IPHONE ADDRESS      : 192.168.68.84      (from the device screenshot)
```

`192.168.68.65` and `192.168.1.20` are **not** the backend. Same /24 as the
phone, so discovery should find `192.168.68.50` without typing anything.

### 4. VERIFIED HERE

- `netstat` → `0.0.0.0:3000 LISTENING` (not `127.0.0.1`).
- `curl http://192.168.68.50:3000/v1/health` → **200**, body contains
  `"service":"vietvoice-backend"`, measured latency **22 ms**.
- `/health` alias → 200. Unknown path → 404. Closed port 3999 → connection refused.
- Every failure cause produces a **different** message (printed and asserted in
  `test/manual/live_health_check.dart`).
- Clone upload over LAN reached the backend and was refused with a clear
  `InvalidApiKey` — i.e. multipart reached the server, and the provider secret
  stayed on the backend.
- `flutter analyze` → 0 errors (18 pre-existing style infos).
  `flutter test` → **322 passed**. `npm run lint` clean, `npm test` 38/38.
- Windows firewall: ON for all profiles, but a **Node.js inbound Allow rule exists
  on the Public profile**, so TCP 3000 inbound is permitted. Nothing was disabled.

### 5. NOT VERIFIED — run on a real iPhone before calling this done

1. Safari on the iPhone opening `http://192.168.68.50:3000/v1/health`. If Safari
   fails it is network/firewall; if Safari works and the app does not, it is the
   app or the permission.
2. The **Local Network** prompt, and the denied → Settings → re-enable → retry path.
3. "Dò mạng LAN" listing `http://192.168.68.50:3000/v1`, never the phone's IP.
4. A full clone returning a real `voice_id` — blocked here only because no
   `ELEVENLABS_API_KEY` is configured on this machine. Put the key in
   `backend/.env` and restart; the app never needs it.

### 6. HOW TO TEST (iPhone, backend up)

```
# on the backend machine
cd backend && npm install && npm run dev
curl http://<LAN_IP>:3000/v1/health        # must print "service":"vietvoice-backend"

# on the iPhone, same Wi-Fi
Safari  → http://<LAN_IP>:3000/v1/health   # proves network, independent of the app
App     → Cài đặt → Máy chủ giọng nói → Kiểm tra kết nối
        → Dò mạng LAN → should list the backend with its latency
        → Nhập địa chỉ máy chủ → <LAN_IP>:3000 → Lưu
App     → Ghi âm giọng mới → save → clone; on failure the sample is kept
```

Stop the backend and press **Kiểm tra** again: the message must name the refused
port, not "không tìm thấy backend". Start it again and **Thử lại** must succeed
without re-recording.
