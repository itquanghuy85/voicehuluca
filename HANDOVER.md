# HANDOVER

## LAN DISCOVERY iOS FIX

**Status: Android PASS · iOS UNVERIFIED (iOS REAL DEVICE TEST BLOCKED — no iPhone
attached and the host is Windows, so `flutter build ios` does not exist here).**

**Cause.** Discovery reads the phone's own IPv4 through
`NetworkInterface.list()`, then sweeps the whole `/24` with
`GET http://<host>:3000/v1/health` and keeps hosts answering 200 with
`vietvoice-backend`. The interface filter only accepted names starting with
`wlan` or `wi-fi`, so Android (`wlan0`) scanned fine while iOS (`en0`) produced
an empty address list and the message "Không lấy được địa chỉ IP của máy" — the
failure happened before any socket was opened. Separately,
`NSLocalNetworkUsageDescription` was missing, which on iOS 14+ would have blocked
the probes themselves even once an address existed.

**Changes.**
- `lib/core/network/backend_discovery.dart` — `selectLocalAddresses()` treats
  interface names as a preference and falls back to any private IPv4;
  `interfaceReport()` exposes the raw platform report. No architecture change, no
  mDNS/Bonjour.
- `ios/Runner/Info.plist` — added `NSLocalNetworkUsageDescription`.
- `lib/features/settings/settings_screen.dart` + `app_strings.dart` — a failed
  scan now shows the interfaces reported, the addresses swept, how to grant
  Local Network, and that manual entry still works.
- `test/unit/backend_endpoint_test.dart` — 4 new cases; `DOCS/LAN_DISCOVERY_AUDIT.md`,
  `TROUBLESHOOTING.md` — documentation.

**How to test.**
- Android (done, PASS): Cài đặt → **Dò mạng LAN** → sheet lists
  `http://192.168.68.65:3000/v1` → tap it → **Kiểm tra** → `Kết nối được`.
- iOS (needs macOS + iPhone): same steps; accept the **Local Network** prompt on
  the first scan. If it fails, the snackbar's `Giao diện mạng: …` line gives the
  exact interface list the device reported.

**Verified:** `flutter analyze` 0 errors · `flutter test` 298 passed ·
`flutter build apk --debug` OK · server `0.0.0.0:3000` returns 200 +
`vietvoice-backend` when queried from the phone over Wi-Fi.
**Not verified:** anything on real iOS hardware. No production behaviour changed.