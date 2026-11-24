<div align="center">

# 🎧 yt-audio-tool

**Bộ tải audio YouTube portable cho Windows — dán link hoặc chỉ cần gõ tên bài.**
**Tự lọc bản mix dài, tự đổi tên theo thứ tự, tự kiểm tra file tải về.**

![Windows](https://img.shields.io/badge/Windows-portable-0078D6?logo=windows&logoColor=white)
![PowerShell](https://img.shields.io/badge/PowerShell-5.1+-5391FE?logo=powershell&logoColor=white)
![yt-dlp](https://img.shields.io/badge/yt--dlp-engine-FF0000?logo=youtube&logoColor=white)
![ffmpeg](https://img.shields.io/badge/ffmpeg-MP3-007808?logo=ffmpeg&logoColor=white)
![License](https://img.shields.io/badge/license-MIT-green)

</div>

> **Không cài đặt, không quyền admin.** Chạy `setup.bat` một lần, tool tự tải `yt-dlp` + `ffmpeg` vào thư mục `tools\`.
> Xóa thư mục là gỡ sạch.

> ⚖️ Chỉ dùng với nội dung bạn **có quyền tải**: video/playlist của chính bạn, nhạc Creative Commons, public domain, YouTube Audio Library, nhạc mà người đăng cho phép tải.

---

## ✨ Tính năng

| | Tính năng | Chi tiết |
|---|---|---|
| 🔗 | **Tải theo link** | Video, playlist hay cả channel — mỗi link một dòng trong `links.txt` |
| 🔎 | **Tải theo tên bài** | Gõ tên bài vào `queries.txt`, tool tự tìm trên YouTube và lấy kết quả khớp |
| 👀 | **Xem trước** | Liệt kê 5 kết quả đầu mỗi bài để kiểm tra trước khi tải |
| ⏱️ | **Lọc theo thời lượng** | Bỏ qua video dài hơn 10 phút (thường là bản mix / liên khúc), tự thử kết quả kế tiếp — tối đa 10 lần |
| 🔢 | **Đặt tên theo thứ tự** | `01 - Tên bài.mp3`, `02 - …` đúng thứ tự trong `queries.txt` |
| ✅ | **Kiểm tra sau khi tải** | Báo file thiếu, tên không khớp, file rác, file có dung lượng bất thường (dấu hiệu tải nhầm video) |
| 🧾 | **Không tải trùng** | Tải theo link có ghi log `downloaded_archive.txt`; tải theo tên thì chống trùng bằng tên file |
| 📋 | **Báo bài thiếu** | Bài nào tìm mãi không được sẽ ghi vào `missing_after_run.txt` |

---

## 🚀 Bắt đầu

```bat
git clone https://github.com/Meow1088/yt-audio-tool
cd yt-audio-tool
setup.bat
```

`setup.bat` sẽ:
- tải `yt-dlp.exe` và `ffmpeg` (bản *essentials*) vào `tools\`,
- tạo `links.txt` / `queries.txt` từ file `.example`,
- báo máy đã có Node / Deno chưa (nên có, để yt-dlp lấy đủ định dạng).

Chạy lại bao nhiêu lần cũng được: cái gì có rồi thì bỏ qua, **không bao giờ ghi đè** `links.txt` / `queries.txt` bạn đã điền. Muốn tải lại bản mới của yt-dlp/ffmpeg: `setup.bat -Force`.

<details>
<summary>Cài bằng tay (không chạy script)</summary>

1. Tải `yt-dlp.exe` từ https://github.com/yt-dlp/yt-dlp/releases → đặt vào `tools\yt-dlp.exe`
2. Tải bản *essentials* từ https://www.gyan.dev/ffmpeg/builds/ → chép `ffmpeg.exe` + `ffprobe.exe` vào `tools\ffmpeg\bin\`
3. Chép `links.txt.example` → `links.txt`, `queries.txt.example` → `queries.txt`

</details>

---

## 📖 Cách dùng

### 🔗 Có sẵn link

1. Dán link vào `links.txt`, mỗi dòng một link.
2. Chạy `download_mp3.bat`.
3. File MP3 nằm trong `downloads\`.

### 🔎 Chỉ có tên bài

1. Gõ tên bài vào `queries.txt`, mỗi dòng một bài.
2. (Nên làm) chạy `download_by_song_names_preview.bat` để xem kết quả tìm được.
3. Chạy `download_by_song_names_mp3.bat`.
4. Chạy `check_downloads.bat` để kiểm tra lại.

> 💡 Thêm từ khóa như `official`, `creative commons`, `royalty free`, `no copyright` hoặc tên kênh vào tên bài để giảm tải nhầm.

---

## 🧰 Các lệnh

| Lệnh | Làm gì |
|---|---|
| `setup.bat` | Tải yt-dlp + ffmpeg, tạo file đầu vào |
| `download_mp3.bat` | Tải theo `links.txt`, xuất MP3 chất lượng cao |
| `download_original_audio.bat` | Tải audio gốc tốt nhất, nhanh hơn, không convert |
| `download_by_song_names_preview.bat` | Xem trước 5 kết quả tìm kiếm mỗi bài, không tải |
| `download_by_song_names_mp3.bat` | Tìm theo `queries.txt` rồi tải MP3 |
| `organize_existing_by_queries.bat` | Đổi tên file đã tải theo thứ tự `queries.txt`, dọn ảnh bìa `.jpg` sót lại |
| `check_downloads.bat` | Kiểm tra thiếu / sai tên / file rác / dung lượng bất thường |

## 📁 Cấu trúc

```
yt-audio-tool/
├── *.bat / *.ps1          # các lệnh ở trên (lệnh phức tạp có .ps1 cùng tên)
├── links.txt.example      # mẫu danh sách link
├── queries.txt.example    # mẫu danh sách tên bài
├── tools/                 # yt-dlp + ffmpeg (setup.bat tải về, không lên git)
└── downloads/             # file tải về (không lên git)
```

---

## ⚠️ Lưu ý

- YouTube **không phải nguồn lossless**. Convert sang FLAC không làm âm thanh tốt hơn nếu nguồn gốc đã bị nén.
- yt-dlp thay đổi thường xuyên theo YouTube — gặp lỗi tải thì chạy `setup.bat -Force` để lấy bản mới nhất.

## 📝 Giấy phép & ghi nhận

- Mã nguồn: **MIT** — xem [LICENSE](LICENSE).
- Dùng [yt-dlp](https://github.com/yt-dlp/yt-dlp) (Unlicense) và [FFmpeg](https://ffmpeg.org/) (LGPL/GPL) — tải riêng, không đóng gói trong repo.
