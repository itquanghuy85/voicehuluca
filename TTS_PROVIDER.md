# TTS Provider (Multi-Provider)

VietVoice Studio hỗ trợ nhiều nhà cung cấp giọng nói. Ứng dụng **không bao giờ** gọi
trực tiếp API của nhà cung cấp — mọi request đi qua backend VietVoice, nơi giữ toàn bộ
khóa bí mật.

---

## 1. Danh sách provider

| ID | Tên | Mặc định | Nhân bản giọng | Cần key |
|----|-----|----------|-----------------|---------|
| `google` | Google TTS | ✅ | ❌ (không hỗ trợ) | Không (chế độ miễn phí) |
| `elevenlabs` | ElevenLabs | ❌ | ✅ | Có (`ELEVENLABS_API_KEY` ở backend) |
| `local` | TTS trên máy | ❌ | ✅ (XTTS-v2) | Không (Python + XTTS ở máy chủ) |

Google TTS là provider mặc định nên người dùng mới cài app đã có thể tạo giọng ngay,
không cần đăng ký tài khoản nào. `local` là lựa chọn miễn phí để nhân bản giọng mà
không cần tài khoản trả phí.

---

## 2. Kiến trúc

```
┌───────────────────────────────────────────────────────────────┐
│  Presentation: settings_screen (radio) · home · generation      │
│              voice_selector · record_voice_sheet                │
├───────────────────────────────────────────────────────────────┤
│  TtsProviderRegistry  ──►  resolve(activeId)                    │
│     ├─ GoogleTtsProvider   (supportsVoiceCloning = false)      │
│     ├─ ElevenLabsProvider  (supportsVoiceCloning = true)       │
│     └─ LocalTtsProvider    (supportsVoiceCloning = true)       │
├───────────────────────────────────────────────────────────────┤
│  BackendTtsProvider (chung) ──► TtsRemoteDatasource             │
│                                   │ provider + x-vvt-api-key   │
├───────────────────────────────────────────────────────────────┤
│  Backend (Node/Express) providerRouter                          │
│     ├─ googleTts.ts      (endpoint công khai | Cloud TTS)      │
│     ├─ elevenlabs.ts     (khóa nằm ở backend)                  │
│     └─ localTtsProvider.ts ──spawn──► scripts/tts_local.py     │
│                                  ├─ edge-tts  (MP3)            │
│                                  └─ XTTS-v2   (WAV, nhân bản)   │
└───────────────────────────────────────────────────────────────┘
```

Provider đang chọn lưu trong bảng `app_settings.tts_provider` (schemaVersion 2) và được
giữ trong `ttsProviderIdProvider` (Riverpod `Notifier`) làm nguồn sự thật: đổi provider
có hiệu lực tức thì cho datasource, registry và UI, rồi mới ghi xuống DB.

---

## 3. Interface (`lib/data/services/tts_provider.dart`)

```dart
abstract class TtsProvider {
  String get id;
  String get name;
  bool get supportsVoiceCloning;
  bool get isAvailable;

  Future<List<Voice>> getVoices();
  Future<TtsResult> synthesize({
    required String voiceId,
    required String text,
    TtsOptions options = const TtsOptions(),
  });
  Future<Voice> cloneVoice({required String name, required String description,
      required List<File> audioFiles, String? language});
  Future<void> deleteVoice(String providerVoiceId);
  Future<TtsUsage?> getUsage();   // null = provider không công bố mức dùng
  Future<bool> testConnection();
}
```

Kiểu dữ liệu đi kèm: `TtsOptions`, `TtsResult`, `TtsUsage`, `TtsErrorKind`.

Ngoại lệ:

| Lớp | `kind` | Dùng khi |
|-----|--------|----------|
| `TtsProviderException` | theo từng loại lỗi | lỗi HTTP từ backend |
| `TtsOperationNotSupportedException` | `unsupported` | provider không hỗ trợ (clone trên Google) |
| `TtsProviderUnavailableException` | `unavailable` | provider chưa dùng được (Local TTS) |

`mapTtsErrorKind(kind)` trong `voice_provider.dart` là nơi duy nhất ánh xạ lỗi → text
hiển thị (dùng chung cho voice list, generation, segment editor, settings).

---

## 4. API backend

| Endpoint | Method | Body / Query | Mô tả |
|----------|--------|--------------|-------|
| `/v1/providers` | GET | — | Danh sách provider + `supportsVoiceCloning`, `available` |
| `/v1/tts` | POST | `{provider, voiceId, text, options}` | Tạo giọng, trả `audio/mpeg` |
| `/v1/voices` | GET | `?provider=` | Danh sách giọng của provider |
| `/v1/voices` | DELETE | `?provider=&{id}` | Xoá giọng đã nhân bản |
| `/v1/voices/clone` | POST | multipart `provider, name, files` | Nhân bản giọng (ElevenLabs) |
| `/v1/user/subscription` | GET | `?provider=` | Mức dùng thật, hoặc `{available:false}` |

Header xác thực app: `x-vvt-api-key` (khoá VietVoice Studio của người dùng — **không
phải** khoá của nhà cung cấp). Đặt `VVT_API_KEYS` ở backend để bật kiểm tra; để trống
thì bỏ qua (môi trường dev).

Mã lỗi trả về: `UnknownProvider` (400), `VoiceCloningNotSupported` (501),
`OperationNotSupported` (400), `InvalidApiKey` (401), `QuotaExceeded` (429),
`ServiceUnavailable` (502), `NetworkError` (503), `Timeout` (504).

### Google TTS

- **Mặc định (không key):** dùng endpoint TTS công khai của Google, tự chia văn bản
  thành các đoạn ≤ 190 ký tự theo ranh giới câu rồi ghép MP3. Một giọng tiếng Việt
  (`google-vi-standard`), không điều chỉnh được tốc độ đọc.
- **Có `GOOGLE_TTS_API_KEY`:** dùng Google Cloud Text-to-Speech v1 chính thức — nhiều
  giọng tiếng Việt hơn và hỗ trợ `speakingRate`.

Hàm chia đoạn có test riêng: `backend/test/googleTts.test.js`.

### TTS trên máy (`local`)

Miễn phí, không cần API key, không tốn phí theo ký tự. Backend chạy một sidecar Python
(`backend/scripts/tts_local.py`) giao tiếp qua **stdin/stdout JSON**, mỗi dòng là một
request/response JSON:

```jsonc
// → gửi
{"id": 1, "command": "synth", "params": {"voiceId": "vi-VN-HoaiMyNeural", "text": "Xin chào"}}
// ← nhận
{"id": 1, "ok": true, "data": {"audioBase64": "...", "format": "mp3", "engine": "edge-tts"}}
// hoặc
{"id": 1, "ok": false, "error": {"code": "CloneNotFound", "message": "..."}}
```

Năm lệnh:

| Lệnh | Mục đích |
|------|----------|
| `list-voices` | Giọng Edge (lọc theo `language`) + giọng clone đã lưu |
| `list-clones` | Danh sách clone trên máy |
| `clone` | Nhân bản từ file WAV mẫu (XTTS-v2) |
| `delete-clone` | Xoá clone |
| `synth` | Tạo giọng nói (`clone:<id>` dùng XTTS, còn lại dùng Edge) |

**Hai engine, một provider:**

- **edge-tts** — giọng Neural của Microsoft Edge (tiếng Việt có `vi-VN-HoaiMyNeural`
  và `vi-VN-NamMinhNeural`), trả MP3, hỗ trợ tốc độ đọc. Endpoint công khai nên thỉnh
  thoảng trả về âm thanh rỗng khi có nhiều request liên tiếp — sidecar tự thử lại 3
  lần với backoff nên người dùng không thấy lỗi.
- **XTTS-v2 (Coqui TTS)** — nhân bản giọng từ mẫu 5–30 giây, trả WAV. Lần đầu tải
  mô hình ~1.8GB về máy, các lần sau dùng cache và chạy trên CPU.

**Cài đặt một lần:**

```bash
pip install torch --index-url https://download.pytorch.org/whl/cpu
pip install -r backend/requirements-tts.txt
```

Rồi bật trong `backend/.env`:

```env
LOCAL_TTS_PYTHON=python
LOCAL_TTS_VOICES_DIR=            # để trống = ~/.vietvoice/voices
```

Nếu thiếu `torchaudio` hoặc `transformers` phiên bản không tương thích, sidecar báo
`MissingDependency` kèm hướng dẫn; khi đó giọng Edge vẫn dùng được, chỉ tính năng
nhân bản bị từ chối rõ ràng (không giả lập kết quả).

**Lưu giọng:** mỗi clone là một thư mục trong `~/.vietvoice/voices/<id>/` gồm
`reference.wav` (mẫu gốc) và `config.json` (tên, ngôn ngữ, thời gian tạo). Xoá clone
sẽ xoá cả thư mục.

**Từ app:** mọi thao tác đi qua backend y hệt provider khác, nên secret không bao giờ
nằm trong app. Mức sẵn sàng thật do backend báo qua `GET /v1/providers`; nếu chưa cấu
hình, Settings hiển thị badge "Chưa cấu hình" thay vì chặn người dùng.

---

## 5. Quy tắc sản phẩm

1. **Không giả lập.** Provider chưa hỗ trợ tính năng thì báo rõ và chặn thao tác
   (ví dụ: banner "không hỗ trợ nhân bản giọng" + nút chuyển ElevenLabs).
2. **Usage thật.** Chỉ hiển thị số liệu khi provider trả về; Google trả
   `available:false` nên UI hiện "Nhà cung cấp này không công bố mức sử dụng".
3. **Đổi provider tốn phí phải hỏi trước.** Khi provider đang dùng lỗi (lỗi máy chủ /
   dịch vụ gián đoạn), app hiện dialog xác nhận trước khi chuyển sang ElevenLabs; không
   hỏi khi lỗi là xác thực/quota/offline vì đổi cũng không giải quyết được.
4. **Giọng thuộc về provider.** Khi đổi provider, danh sách giọng được tải lại và
   retry dùng giọng của provider mới.
5. **Offline không crash.** Mất mạng → hiện badge "Mất kết nối", vô hiệu nút Tạo giọng
   nói; giọng đã cache vẫn xem được.

---

## 6. Test

| File | Phủ |
|------|-----|
| `test/unit/tts_provider_test.dart` | registry, provider stub, request contract, mapping lỗi, usage, offline |
| `test/unit/tts_voice_loading_test.dart` | cache/voice list theo provider, clone, xoá, settings, progress stream |
| `test/unit/generation_provider_test.dart` | chặn offline, dialog fallback, ghi file âm thanh, retry |
| `backend/test/googleTts.test.js` | chia đoạn văn bản, resolve provider, khả năng provider |

Chạy: `flutter test` · `npm test` (trong `backend/`).
