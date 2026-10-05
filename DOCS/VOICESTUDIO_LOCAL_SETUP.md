# VoiceStudio trên PC GPU

VietVoice dùng VoiceStudio (engine OmniVoice) trên một máy có card NVIDIA để
nhân bản giọng và đọc văn bản. iPhone không gọi VoiceStudio trực tiếp:

```
iPhone ──Wi-Fi──► Backend VietVoice :3000 ──LAN──► VoiceStudio :3901 (PC GPU)
```

XTTS (`local`), Google và ElevenLabs vẫn còn nguyên; VoiceStudio là provider
`voicestudio` thêm vào bên cạnh.

## 1. Máy VoiceStudio (PC GPU)

1. Mở VoiceStudio như bình thường.
2. Bật chia sẻ mạng LAN — PowerShell (Admin) trên chính máy đó:

   ```powershell
   New-NetFirewallRule -DisplayName "VoiceStudio LAN 3901" -Direction Inbound -Protocol TCP -LocalPort 3901 -Profile Private,Public -Action Allow
   Invoke-RestMethod -Method Post http://127.0.0.1:3900/system/network/enable
   ```

   Lệnh thứ hai in ra `pin` (6 số) và `share_port` (3901). VoiceStudio mặc định
   chỉ nghe 127.0.0.1; chia sẻ mạng mở thêm cổng 3901 cho LAN mà không phải
   khởi động lại.

## 2. Backend (máy chạy VietVoice backend)

`backend/.env`:

```
VOICESTUDIO_BASE_URL=http://<IP máy GPU>:3901
VOICESTUDIO_PIN=<pin ở bước 1>
VOICESTUDIO_API_KEY=
```

Khởi động lại backend, rồi kiểm tra:

```
GET http://127.0.0.1:3000/v1/voicestudio/health
```

Kết quả tốt: `"connected": true`, `"device": "cuda (NVIDIA GeForce RTX 2060 SUPER)"`,
`"gpu": true`. `"device": "cpu"` nghĩa là VoiceStudio đang chạy bằng CPU (rất chậm).

## 3. iPhone

Không cần cấu hình gì thêm. Lần đầu app thấy backend báo VoiceStudio sẵn sàng,
app tự chọn VoiceStudio (chỉ một lần; đổi lại trong Cài đặt thì app giữ lựa chọn
đó).

Ghi giọng: đọc đúng câu mẫu trên màn hình, 5–19 giây. Bấm **Nghe lại bản ghi**
để kiểm tra. Nếu đọc khác câu mẫu, sửa ô **Nội dung bạn đã đọc** cho đúng từng
chữ — VoiceStudio dùng nội dung này; sai nội dung thì giọng tạo ra sẽ đọc lẫn các
chữ đó vào đầu mỗi câu.

## Lỗi thường gặp

| Thông báo | Nguyên nhân | Cách xử lý |
|---|---|---|
| Không kết nối được máy VoiceStudio | PC GPU tắt / khác mạng Wi-Fi | Bật máy, cùng mạng |
| VoiceStudio chưa mở hoặc chưa bật chia sẻ mạng LAN | Máy bật nhưng VoiceStudio đóng, hoặc chia sẻ tắt | Mở VoiceStudio, chạy lại bước 1.2 |
| mã PIN chia sẻ mạng sai hoặc đã đổi | Bật lại chia sẻ sinh PIN mới | Cập nhật `VOICESTUDIO_PIN`, khởi động lại backend |
| VoiceStudio đang khởi động mô hình | Vừa mở VoiceStudio | Chờ 1–2 phút |
| Bản ghi dài …s, VoiceStudio chỉ nhận dưới 20s | Mẫu ≥ 20s | Ghi lại ngắn hơn |
| Cần nội dung câu bạn đã đọc | Ô nội dung để trống | Nhập đúng câu đã đọc |
| Giọng này không còn trong VoiceStudio | Profile đã bị xoá trên PC | Tạo lại giọng |

## Đã đo (2026-10-05, RTX 2060 SUPER 8 GB, VoiceStudio 0.5.6, OmniVoice)

- Câu ngắn (6s audio): 1,9–3,9s tạo → 1,6x–3,2x realtime.
- Chưa đo bài dài 1/5 phút.
- Trên máy chỉ có CPU (Intel Arc, không CUDA): một câu ngắn quá 600s và
  VoiceStudio bỏ job (503); hai lần crash native — không dùng máy CPU làm server.
