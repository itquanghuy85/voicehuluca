# Voice Cloning

Voice cloning lets you create a reusable AI voice from a short audio sample. Two
providers can do it:

| Provider | Engine | Chi phí | Dùng khi |
|----------|--------|---------|----------|
| **TTS trên máy** (`local`) | XTTS-v2 (Coqui TTS) chạy trên máy chủ | Miễn phí, không cần key | Muốn nhân bản giọng mà không tạo tài khoản trả phí |
| **ElevenLabs** | ElevenLabs Instant Voice Cloning | Có thể phát sinh phí | Cần chất lượng cao hơn |

Google TTS **không** hỗ trợ nhân bản. Khi provider đang chọn không hỗ trợ, app hiện
rõ lý do và gợi ý các provider có thể dùng (HTTP 501 kèm `suggestions`) thay vì báo
lỗi chung chung hoặc tự chuyển sang provider trả phí.

---

## Ghi âm nhanh trong màn chọn giọng (RecordVoiceSheet)

Ngoài màn hình nhân bản đầy đủ (ghi âm / nhập file), màn **Chọn giọng đọc** có nút
**Ghi âm giọng mới** mở `RecordVoiceSheet` — luồng ngắn gọn nhất:

1. Đọc to đoạn văn bản mẫu có sẵn (tiếng Việt, khoảng 20 giây).
2. Bấm **Bắt đầu ghi âm** — ghi bằng `record` ở **WAV 22 kHz mono**, đúng định dạng
   XTTS cần. Đồng hồ đếm, chặn lưu khi dưới 5 giây và tự dừng ở 30 giây.
3. Đặt tên cho giọng rồi bấm **Lưu giọng này**.
4. App `POST /v1/voices/clone` (multipart, `provider` = provider đang chọn) rồi tự
   tải lại danh sách giọng.

Nếu provider đang chọn hỗ trợ nhân bản
(`TtsProviderIds.cloningProviders` = `elevenlabs`, `local`) thì nút hiện; nếu không,
sheet hiện lý do và không cho ghi.

Sau khi lưu, giọng mới xuất hiện ở nhóm **Giọng của tôi** và có nút xoá. Xoá sẽ gọi
`DELETE /v1/voices/clone:<id>?provider=local` (xoá cả thư mục giọng trên máy chủ) rồi
xóa bản ghi trong cache cục bộ.

---

## Nhân bản trên máy (XTTS-v2)

### Cài đặt

```bash
pip install torch torchaudio --index-url https://download.pytorch.org/whl/cpu
pip install -r backend/requirements-tts.txt
```

```env
# backend/.env
LOCAL_TTS_PYTHON=python
LOCAL_TTS_VOICES_DIR=          # để trống = ~/.vietvoice/voices
```

Lần nhân bản đầu tiên sẽ tải mô hình XTTS-v2 (~1.8GB). App hiển thị
"Đang tạo giọng từ âm thanh của bạn…" và nhắc lần đầu sẽ mất vài phút. Các lần sau
dùng bản cache nên nhân bản xong trong vài giây.

### Cách hoạt động

```
App (record 22kHz mono WAV)
   │  POST /v1/voices/clone  (multipart, provider=local)
   ▼
Backend (clone.ts → providerRouter)
   │  ghi file tạm, spawn sidecar
   ▼
scripts/tts_local.py  ── clone ──►  ~/.vietvoice/voices/<id>/{reference.wav,config.json}
   │
   └── synth (voiceId = clone:<id>) ──► XTTS-v2 ──► WAV
```

Giọng đã nhân bản được trả về cho app với `voice_id` dạng `clone:<id>`; backend báo
đúng `Content-Type`/`X-Audio-Format` (wav cho clone, mp3 cho Edge) để app lưu đúng
định dạng.

### Khi thiếu thư viện

Nếu máy chủ thiếu `coqui-tts`, `torchaudio`, `torchcodec` hoặc sai phiên bản
`transformers`, sidecar trả mã `MissingDependency` kèm hướng dẫn cài đặt. Giọng Edge
vẫn dùng được; riêng tính năng nhân bản được báo lỗi rõ ràng và mẫu ghi âm vẫn được
lưu lại để không phải ghi lại.

> Lưu ý phiên bản: Coqui TTS 0.27 không chạy với `transformers` 5.x, và từ torch 2.9
> cần thêm `torchcodec`. `requirements-tts.txt` đã ghim sẵn các phiên bản tương thích.

---

## Cloning Flow

### End-to-End Process

```
┌─────────────────────────────────────────────────────────────────┐
│                    Voice Cloning Workflow                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐  │
│  │  Record  │ →  │  Review  │ →  │  Submit  │ →  │  Ready   │  │
│  │  Audio   │    │  & Edit  │    │  to API  │    │  to Use  │  │
│  └──────────┘    └──────────┘    └──────────┘    └──────────┘  │
│       ↑                                              │          │
│       └────────────── Re-record ←────────────────────┘          │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Detailed Steps

#### Step 1: Record or Import Audio

**Option A: Record in App**
```
Voice Cloning Screen → Tap Record → Speak clearly → Stop
```

**Option B: Import Files**
```
Voice Cloning Screen → Tap Import → Select audio files → Confirm
```

#### Step 2: Review Audio

- Play back recorded audio
- Check duration and quality
- Re-record if needed
- Add multiple samples for better results

#### Step 3: Configure Voice

| Field | Required | Description |
|-------|----------|-------------|
| **Name** | Yes | Display name for the voice |
| **Description** | Yes | Brief description of characteristics |
| **Language** | No | Default: `vi` (Vietnamese) |
| **Audio Files** | Yes | 1-5 audio samples |

#### Step 4: Submit for Cloning

```
App → ElevenLabs API → Processing → Voice Ready
```

Processing time: **30 seconds to 5 minutes** depending on audio length.

#### Step 5: Use Cloned Voice

The cloned voice appears in the voice selector and can be used for synthesis immediately.

---

## Audio Requirements

### Minimum Requirements

| Requirement | Value | Notes |
|-------------|-------|-------|
| **Duration** | 30 seconds total | Across all samples |
| **Format** | WAV, MP3, M4A | WAV preferred |
| **Sample Rate** | 16kHz minimum | 44.1kHz recommended |
| **Channels** | Mono | Stereo accepted |
| **File Size** | < 10MB per file | < 50MB total |
| **Bit Depth** | 16-bit | 24-bit recommended |

### Recommended Specifications

| Specification | Value | Why |
|---------------|-------|-----|
| **Duration** | 1-3 minutes | More data = better clone |
| **Format** | WAV (uncompressed) | No quality loss |
| **Sample Rate** | 44.1kHz | CD quality |
| **Channels** | Mono | Consistent with training data |
| **Bit Depth** | 24-bit | Higher dynamic range |
| **Noise Floor** | <-60dB | Clean recording |

### Recording Environment

```
✓ Quiet room with minimal echo
✓ Close to microphone (15-20cm)
✓ Consistent distance and volume
✓ No background music or noise
✓ No other speakers in recording
```

### Content Guidelines

**DO:**
- Speak naturally and clearly
- Use varied sentence structures
- Include questions and statements
- Cover different emotions (neutral, happy, serious)
- Speak for at least 1 minute per sample

**DON'T:**
- Whisper or shout
- Have background noise or music
- Use multiple speakers in one sample
- Include non-speech sounds (laughing, coughing)
- Use very short samples (< 10 seconds)

---

## Quality Guidelines

### Audio Quality Checklist

Before submitting for cloning, verify:

- [ ] Audio is clear and intelligible
- [ ] No background noise or music
- [ ] Consistent volume throughout
- [ ] No clipping or distortion
- [ ] No echo or reverb
- [ ] Single speaker only
- [ ] Natural speaking pace
- [ ] Proper pronunciation

### Quality Levels

| Level | Duration | Expected Result |
|-------|----------|-----------------|
| **Basic** | 30s - 1m | Acceptable for casual use |
| **Standard** | 1m - 2m | Good quality, recommended |
| **Premium** | 2m - 5m | Best quality, professional |
| **Studio** | 5m+ | Maximum fidelity |

### Improving Clone Quality

1. **More audio** — Longer samples = better results
2. **Varied content** — Different sentence types and emotions
3. **Clean recording** — Use a quiet room, quality microphone
4. **Consistent delivery** — Same distance, volume, tone
5. **Multiple samples** — 3-5 short samples often work better than 1 long one

---

## Privacy Considerations

### Data Handling

| Data | Storage | Transmission | Retention |
|------|---------|--------------|-----------|
| **Audio Samples** | Device only | Encrypted (HTTPS) | Until cloning complete |
| **Voice Profile** | ElevenLabs servers | Encrypted (HTTPS) | Until deleted |
| **Voice Metadata** | Local database | N/A | Until app reset |

### Privacy Best Practices

1. **Only clone your own voice** — Never clone someone else's without permission
2. **Inform participants** — If recording others, get consent
3. **Secure your device** — Use device lock (PIN/biometric)
4. **Delete when done** — Remove cloned voices you no longer need
5. **Review ElevenLabs policy** — Understand their data handling

### Data Flow

```
Your Device (Audio Files)
  ↓ HTTPS (encrypted)
ElevenLabs API (Processing)
  ↓ Returns voice_id
Your Device (voice_id stored locally)
  ↓ HTTPS (encrypted, voice_id only)
ElevenLabs API (Synthesis)
  ↓ Returns audio
Your Device (Audio playback)
```

### Deleting Cloned Voices

```dart
// Delete from ElevenLabs
await ttsProvider.deleteVoice(voiceId);

// Delete from local database
await voiceRepository.deleteVoice(voiceId);

// Or factory reset to remove all
await settingsRepository.resetToDefaults();
```

---

## API Integration

### Cloning Request

```dart
// POST /v1/voices/clone
// Content-Type: multipart/form-data
// Header: x-vvt-api-key (app key, not a provider key)

final uri = Uri.parse('$baseUrl/voices/clone');
final request = http.MultipartRequest('POST', uri);
request.headers.addAll({
  'x-vvt-api-key': apiKey,
});
request.fields['provider'] = 'elevenlabs';
request.fields['name'] = 'My Cloned Voice';
request.fields['description'] = 'Warm female Vietnamese voice';
request.fields['language'] = 'vi';

// Add audio files
for (final file in audioFiles) {
  final bytes = await file.readAsBytes();
  request.files.add(http.MultipartFile.fromBytes(
    'files',
    bytes,
    filename: file.path.split(Platform.pathSeparator).last,
  ));
}

final response = await _client.send(request);
```

### Response Format

```json
{
  "voice_id": "abc123def456",
  "name": "My Cloned Voice",
  "description": "Warm female Vietnamese voice",
  "category": "cloned",
  "labels": {
    "language": "vi",
    "gender": "female",
    "accent": "vietnamese"
  }
}
```

### Error Handling

| Error | Cause | Solution |
|-------|-------|----------|
| `400` | Invalid audio format | Use WAV or MP3 |
| `400` | Audio too short | Record at least 30 seconds |
| `400` | Too many files | Maximum 5 files |
| `401` | Invalid API key | Check API key in settings |
| `413` | File too large | Reduce file size |
| `422` | Poor audio quality | Re-record in better conditions |
| `429` | Rate limited | Wait and retry |

---

## Using Cloned Voices

### In the App

1. Go to **Voice Selector**
2. Cloned voices appear with a **"Cloned"** badge
3. Select the voice
4. Adjust settings (stability, similarity, style)
5. Generate audio

### Voice Settings for Cloned Voices

| Setting | Range | Default | Recommendation |
|---------|-------|---------|----------------|
| **Stability** | 0.0 - 1.0 | 0.5 | 0.4-0.6 for natural variation |
| **Similarity Boost** | 0.0 - 1.0 | 0.75 | 0.7-0.9 for closer match |
| **Style** | 0.0 - 1.0 | 0.0 | 0.0-0.3 for subtle expression |
| **Speaker Boost** | true/false | true | Keep enabled |

### Tips for Best Results

1. **Write natural text** — Avoid robotic or unnatural phrasing
2. **Use proper punctuation** — Commas and periods affect pacing
3. **Include tone marks** — Vietnamese tone marks improve pronunciation
4. **Test with short text** — Verify quality before long generation
5. **Adjust settings** — Fine-tune stability and similarity for your use case

---

## Troubleshooting

### Common Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| Clone sounds robotic | Too little audio | Record more samples (2+ minutes) |
| Clone has background noise | Noisy recording | Re-record in quiet environment |
| Clone doesn't match voice | Inconsistent recording | Use same microphone, distance, tone |
| Pronunciation errors | Missing tone marks | Ensure proper Vietnamese diacritics |
| Slow processing | Long audio files | Use shorter samples (1-2 min each) |
| API error 422 | Poor audio quality | Check for noise, clipping, echo |

### Getting Help

1. Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for general issues
2. Review ElevenLabs documentation at [elevenlabs.io/docs](https://elevenlabs.io/docs)
3. Contact support with your voice_id and error details
