# LAN DISCOVERY AUDIT — iOS vs Android

Audit date: 2026-10-03 · Backend under test: `http://192.168.68.65:3000/v1`

---

## 1. Current discovery method

There is exactly one discovery mechanism in this project: an HTTP sweep of the
device's own `/24`. There is no UDP, no broadcast, no multicast, no mDNS and no
Bonjour anywhere in `lib/` or `backend/src/`.

Verified by exhaustive search for `RawDatagramSocket`, `RawSocket`,
`InternetAddress(`, `multicast`, `broadcast`, `mdns`, `Bonjour`, `zeroconf`,
`SSDP`, `HttpServer.`, `ServerSocket` — the only hits were
`Stream.asBroadcastStream()` in `lib/features/voice/voice_provider.dart:303`
(unrelated Dart API) and TypeScript type declarations inside
`backend/node_modules/`.

### Call chain

| Step | Location |
|---|---|
| Button "Dò mạng LAN" | `lib/features/settings/settings_screen.dart:472` (`onPressed: _scanLan`) |
| Handler | `lib/features/settings/settings_screen.dart:590` `_scanLan()` |
| Local address acquisition | `lib/core/network/backend_discovery.dart:78` `LanBackendScanner.localAddresses()` → `:93` `selectLocalAddresses()` |
| Interface enumeration | `dart:io` `NetworkInterface.list(type: IPv4, includeLoopback: false)` |
| Private-range filter | `backend_discovery.dart:45` `isPrivate()` (RFC-1918 only) |
| Subnet expansion | `backend_discovery.dart:136` `subnetOf()` → `backend_discovery.dart:143` `neighboursOf()` → `.1` … `.254` |
| Sweep | `backend_discovery.dart:152` `scan()` — 32 hosts in parallel, 600 ms per probe |
| Request | `backend_discovery.dart:216` `_httpProbe()` → `GET http://<host>:3000/v1/health` |
| Acceptance | HTTP 200 **and** body contains `vietvoice-backend` (`backend_discovery.dart:232`) |
| Result UI | `settings_screen.dart:646` `_showDiscoveredSheet()` (Cupertino action sheet) |
| Persist | `settings_screen.dart:661` → `_saveBackendUrl()` → `BackendUrlNotifier.setUrl()` (`lib/features/voice/voice_provider.dart:228`) |

### Server side

| Item | Location | Value |
|---|---|---|
| Listen address | `backend/src/index.ts:67` | `app.listen(config.port, '0.0.0.0', ...)` |
| Port | `backend/src/config.ts:6` | `PORT` default `3000` |
| Health route | `backend/src/index.ts:53` | `/v1/health` (alias `:63` `/health`) |
| Health handler | `backend/src/routes/health.ts:11` | 200, `Cache-Control: no-store`, body `{status, service: 'vietvoice-backend', version, discovery: true}` |
| Auth | `backend/src/index.ts:53` | health is mounted **before** `appApiKeyAuth`, so it is reachable unauthenticated — required by discovery |

---

## 2. Root cause

The iOS failure message the user reported is
`"Không lấy được địa chỉ IP của máy. Hãy nhập địa chỉ thủ công."`, which is
`AppStrings.settingsBackendScanNoAddress`
(`lib/core/localization/app_strings.dart:323`). That string is produced in
exactly one place: `settings_screen.dart:592`, when
`LanBackendScanner.localAddresses()` returns an empty list.

This narrows the failure precisely: **iOS never reached the network.** No socket
was opened, no host was probed. The defect is entirely in local address
acquisition.

Concretely, the code at `backend_discovery.dart` (before this audit) was:

```dart
interfaces
    .where((iface) =>
        iface.name.startsWith('wlan') || iface.name.startsWith('wi-fi'))
    .expand((iface) => iface.addresses)
    ...
```

* Android Wi-Fi interface: `wlan0` → matches → scan works.
* iOS Wi-Fi interface: `en0` → matches neither prefix → list is empty →
  `settingsBackendScanNoAddress`.

This is the platform-specific API difference that produced the divergence. It is
not "iOS restricting LAN".

### Permission is a second, separate blocker — not the cause of this message

`NSLocalNetworkUsageDescription` was **absent** from `ios/Runner/Info.plist`
before this audit. On iOS 14+ that omission means the system never shows the
local-network prompt and unicast TCP to LAN peers stays blocked.

It is important to be precise about which symptom each defect produces:

* missing `NSLocalNetworkUsageDescription` → addresses are found, the sweep runs,
  every probe is blocked → message would be `settingsBackendScanNone`
  ("Không tìm thấy backend nào…").
* interface-name filter → nothing to sweep → message is
  `settingsBackendScanNoAddress` ← **this is the message actually reported.**

So the reported message proves the filter was the first failure, and the missing
permission would have been the next one.

---

## 3. iOS permission status (before / after)

| Key | Before | After |
|---|---|---|
| `NSLocalNetworkUsageDescription` | **missing** | present (`ios/Runner/Info.plist:33`) |
| `NSAppTransportSecurity` → `NSAllowsLocalNetworking` | present | unchanged |
| `NSBonjourServices` | absent | absent — correct, no mDNS/Bonjour is used |
| `ios/Runner/*.entitlements` | no entitlements file exists | unchanged; the multicast entitlement is not needed for unicast TCP |

Verified statically after the change (plist parses, 24 keys):

```
NSLocalNetworkUsageDescription: True
NSBonjourServices: False
NSAppTransportSecurity: True
```

ATS is not a factor: per Apple, `NSAllowsLocalNetworking` permits plain-HTTP
loads to IP literals, which is exactly what the probe uses.

---

## 4. Fixes applied

1. **`lib/core/network/backend_discovery.dart` — names are a preference, not a gate.**
   `selectLocalAddresses()` prefers Wi-Fi-like interfaces (`wlan`, `wi-fi`, `en`,
   `eth`) but falls back to *any* interface holding a private IPv4 address. An
   interface name this code has never seen can no longer hide the LAN. The choice
   is a pure function, so it is unit-tested.
2. **`ios/Runner/Info.plist` — added `NSLocalNetworkUsageDescription`** so iOS
   14+ shows the prompt and allows the sweep.
3. **`lib/features/settings/settings_screen.dart` — a failed scan now explains
   itself.** `_showScanFailure()` reports the interfaces the platform actually
   returned (`LanBackendScanner.interfaceReport()`), the addresses that were
   swept, the local-network-permission guidance, and that manual entry still
   works. Discovery failure never blocks the app.
4. **`lib/core/localization/app_strings.dart`** — new diagnostic strings only.
5. **Docs** — this file, `TROUBLESHOOTING.md`, `HANDOVER.md`.

Architecture was deliberately **not** changed. The HTTP `/24` sweep works on iOS
— it is plain unicast TCP, which needs no multicast entitlement and no Bonjour
service type. mDNS would only hide a bug that is now fixed, and would require
backend changes plus `NSBonjourServices`.

---

## 5. Test results

| Check | Command | Result |
|---|---|---|
| Static analysis | `flutter analyze lib test` | 17 issues, all pre-existing `info` (deprecated `withOpacity`, `minSize`, style hints). **0 errors, 0 warnings** |
| Full test suite | `flutter test` | **298 passed** |
| Discovery unit tests | `flutter test test/unit/backend_endpoint_test.dart` | 20 passed (4 new: Wi-Fi preferred per platform, unknown interface name still yields an address, public/link-local never scanned, real host interfaces usable) |
| Android build | `flutter build apk --debug` | **OK** → `build/app/outputs/flutter-apk/app-debug.apk` |
| iOS build | `flutter build ios` | **BLOCKED** — the subcommand does not exist on Windows; iOS builds require macOS + Xcode |

### Android — real device, PASS

Device: **OPPO CPH2239, Android 11 (API 30)**, serial `WCE65565HMDYOB59`,
Wi-Fi `192.168.68.117/22` on `wlan0`.

Server reachability proven from the phone itself, not from the PC:

```
$ adb -s WCE65565HMDYOB59 shell "toybox nc -w 3 192.168.68.65 3000 < /dev/null"
TCP_OK

$ adb -s WCE65565HMDYOB59 shell \
    "printf 'GET /v1/health HTTP/1.0\r\nHost: 192.168.68.65\r\n\r\n' | toybox nc 192.168.68.65 3000"
HTTP/1.1 200 OK
...
{"status":"ok","service":"vietvoice-backend","version":"1.0.0","discovery":true}
```

End-to-end run on the device (screenshots taken with `adb screencap`):

1. Cài đặt → **Dò mạng LAN** → action sheet showed
   `http://192.168.68.65:3000/v1 · 263 ms` → **PASS**
2. Tapped the entry → URL saved → **PASS**
3. **Kiểm tra** → snackbar `Kết nối được (141 ms).` → **PASS**

Server-side confirmation: `netstat` shows `0.0.0.0:3000 LISTENING`, Windows
firewall has `node.exe` inbound-allow rules, and
`http://192.168.68.65:3000/v1/health` returns 200 with the discovery signature.
**No backend change was required or made.**

### iOS — BLOCKED

**iOS REAL DEVICE TEST BLOCKED.** Reasons, both environmental:

* No iPhone/iPad is attached — `flutter devices` lists only two OPPO Android
  phones, Windows and Chrome.
* The host is Windows, so `flutter build ios` is not available at all; an iOS
  binary cannot be produced or installed from this machine.

What *was* verified for iOS: the plist keys (section 3), the platform-independent
selection logic via unit tests, and removal of the name filter that caused the
message. What was **not** verified: that the app on real iOS hardware finds
`192.168.68.65`, and that the local-network prompt is answered "Allow".

Status must be read as **iOS UNVERIFIED**, not as PASS.

### Test plan for the iOS side (needs macOS + iPhone)

1. `flutter run` on an iPhone on the same Wi-Fi as `192.168.68.65`.
2. First tap of "Dò mạng LAN" → accept the **Local Network** prompt.
   A denied prompt shows the new diagnostic message; re-enable at
   Settings → VietVoice Studio → Local Network.
3. Expect the sheet entry `http://192.168.68.65:3000/v1 · <n> ms`.
4. Also verify manual entry `192.168.68.65:3000` + **Kiểm tra** (TEST A), which
   isolates discovery from connectivity.
5. Read the reported `Giao diện mạng: …` line from the failure snackbar if
   anything still fails — it prints the raw interface list the device reported.

---

## 6. Known limitation (pre-existing, unchanged)

The sweep only walks one `/24` (`neighboursOf()`). The test network is
`192.168.68.117/22`, i.e. `192.168.68.0 – 192.168.71.255`; a backend placed
outside `192.168.68.x` will not be found by discovery and must be typed in. This
is documented in `TROUBLESHOOTING.md` and was not changed by this audit.

---

## 7. Production impact

None. Changes are confined to LAN discovery, its UI messaging, the iOS usage
description and documentation. No database, schema, auth, sync, Firestore or
business-logic code was touched. Manual server entry remains available in every
failure path.