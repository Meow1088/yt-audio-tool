# YouTube Audio Tool

Tool nay dung `yt-dlp` va `ffmpeg` portable de tai audio tu danh sach link.

Chi nen dung voi noi dung dai ka co quyen tai: video/playlist cua minh, nhac Creative Commons, public domain, YouTube Audio Library, nhac AI/free ma uploader cho phep download.

## Cai dat lan dau

Repo khong chua binary (~214 MB) va khong chua input ca nhan. Sau khi clone, chay:

```text
setup.bat
```

Script se tai `yt-dlp.exe` va `ffmpeg`, roi tao `queries.txt` / `links.txt` tu ban `.example`.
Chay lai luc nao cung duoc: cai gi da co thi bo qua, va no KHONG BAO GIO ghi de
`queries.txt` / `links.txt` neu dai ka da dien vao roi. Muon tai lai binary moi thi:

```text
setup.bat -Force
```

Nen cai them Node hoac Deno. Script da bat san `--js-runtimes node`; thieu runtime thi
yt-dlp van chay nhung se canh bao deprecation va co the thieu mot so format.
`setup.bat` co bao cho biet may da co runtime chua.

### Cai bang tay

Neu khong muon chay script: tai `yt-dlp.exe` tu
https://github.com/yt-dlp/yt-dlp/releases dat vao `tools\yt-dlp.exe`, tai ban
`essentials` tu https://www.gyan.dev/ffmpeg/builds/ roi copy `ffmpeg.exe` +
`ffprobe.exe` vao `tools\ffmpeg\bin\`, cuoi cung copy 2 file `.example` bo duoi `.example`.

## Cach dung nhanh

1. Mo `links.txt`.
2. Dan moi link YouTube video/playlist/channel tren mot dong.
3. Chay `download_mp3.bat` de tai va convert sang MP3.
4. File se nam trong folder `downloads`.

## Tu tim theo ten bai

1. Mo `queries.txt`.
2. Dan moi ten bai/search query tren mot dong.
3. Neu so bi nham video, chay `download_by_song_names_preview.bat` de xem 5 ket qua dau.
4. Chay `download_by_song_names_mp3.bat` de tai ket qua dau tien thanh MP3.

Meo: nen them tu khoa nhu `official`, `creative commons`, `royalty free`, `ai music`, `no copyright`, hoac ten kenh de giam tai nham.

Script bo qua video dai hon 10 phut (thuong la ban mix / lien khuc chu khong phai bai hat),
tu dong thu ket qua tiep theo. Bai nao thu het 10 ket qua van khong duoc se ghi vao
`missing_after_run.txt`.

File tai theo ten bai se co dang:

```text
01 - Ten Bai Trong Queries.mp3
02 - Ten Bai Tiep Theo.mp3
```

## Tuy chon

- `setup.bat`: tai yt-dlp + ffmpeg va tao file input tu ban `.example`.
- `download_mp3.bat`: xuat MP3 chat luong cao, can ffmpeg.
- `download_original_audio.bat`: tai audio goc tot nhat, nhanh hon, khong convert lai.
- `download_by_song_names_mp3.bat`: tu tim YouTube theo `queries.txt` roi tai ket qua dau tien.
- `download_by_song_names_preview.bat`: xem truoc 5 ket qua tim kiem moi bai, khong tai.
- `organize_existing_by_queries.bat`: doi ten file da tai theo thu tu trong `queries.txt` va xoa anh bia `.jpg` bi roi lai.
- `check_downloads.bat`: kiem tra thieu file, ten khong khop, file rac khong phai MP3, va file co dung luong bat thuong (dau hieu tai nham video).

## File quan trong

- `links.txt`: danh sach link dau vao (khong len git, xem `links.txt.example`).
- `queries.txt`: danh sach ten bai/search query (khong len git, xem `queries.txt.example`).
- `downloads`: noi luu file tai ve (khong len git).
- `downloaded_archive.txt`: log cac video da tai qua `links.txt`, giup lan sau khong tai trung.
  Luu y: luong tim theo ten bai KHONG ghi vao file nay, no chong trung bang ten file.
- `missing_after_run.txt`: sinh ra sau moi lan chay neu co bai khong tai duoc.
- `tools/yt-dlp.exe`: downloader.
- `tools/ffmpeg/bin/ffmpeg.exe`: converter MP3.

## Luu y

YouTube khong phai nguon lossless. Convert sang FLAC khong lam audio thanh lossless that neu nguon goc da bi nen.
