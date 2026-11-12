# EXPORT-STANDARDS.md — Standar Export DOCX / PDF / XLSX (Password-Protected)

> **WAJIB untuk setiap fitur export ke DOCX, PDF, atau XLSX.** Export menawarkan password **opsional**;
> jika diisi, file dienkripsi pakai **enkripsi native format tersebut** (bukan ZIP berpassword, bukan sheet protection).
>
> Dipakai di: [phases/03-BACKEND.md](../phases/03-BACKEND.md) (generate & enkripsi) ·
> [phases/04-FRONTEND.md](../phases/04-FRONTEND.md) (dialog export) ·
> UI rule: [standards/UI-UX-STANDARDS.md](UI-UX-STANDARDS.md#-export-dengan-password-wajib-jika-ada-fitur-export)

---

## 🧭 Aturan

| ID | Aturan |
|----|--------|
| **EX-01** | Dialog export punya toggle **"Lindungi dengan password"** (default OFF) + input password dengan tombol show/hide |
| **EX-02** | Password kosong = file **tidak** dienkripsi (default). Password terisi = file **wajib** terenkripsi (open-password) |
| **EX-03** | Enkripsi pakai mekanisme **native** format: OOXML Agile Encryption (DOCX/XLSX), PDF Standard Security Handler AES-256 (PDF) |
| **EX-04** | Enkripsi dilakukan di **backend** (server-side). Password dikirim via HTTPS body (bukan query string), **tidak pernah** di-log, disimpan, atau dimasukkan ke audit trail |
| **EX-05** | Proteksi sheet/worksheet (mis. `worksheet.protect()` exceljs) **BUKAN** enkripsi — data tetap terbaca di XML. Tidak boleh dipakai sebagai pengganti EX-03 |
| **EX-06** | Setiap format yang diekspor punya **round-trip test**: file terenkripsi → gagal dibuka tanpa password → berhasil dibuka dengan password |
| **EX-07** | Semua teks di dialog (label, hint, error) dari i18n (id/en/ja) — lihat [aturan #14](../RULES-OF-THE-GAME.md#14-internationalization-i18n--3-bahasa--wajib) |

---

## 📚 Library per Format (terverifikasi Nov 2026)

> Kemampuan library berubah — **verifikasi ulang versi yang di-pin** dengan round-trip test (EX-06) setiap upgrade.
> Semua dependency tunduk ke [SUPPLY-CHAIN-SECURITY.md](SUPPLY-CHAIN-SECURITY.md) (exact pin, review gate).

### XLSX

| Langkah | Node.js | Catatan |
|---------|---------|---------|
| Generate | [`exceljs`](https://github.com/exceljs/exceljs) | `workbook.xlsx.writeBuffer()` |
| Enkripsi | [`officecrypto-tool`](https://github.com/zurmokeeper/officecrypto-tool) | `officeCrypto.encrypt(buffer, { password })` → ECMA-376 encryption |

```js
import ExcelJS from 'exceljs';
import officeCrypto from 'officecrypto-tool';

const buffer = await workbook.xlsx.writeBuffer();
const output = password ? officeCrypto.encrypt(Buffer.from(buffer), { password }) : buffer;
```

⚠️ `exceljs` **hanya** punya sheet protection (`worksheet.protect(pwd)`), **bukan** file encryption — lihat EX-05.

PHP/Laravel: [PhpSpreadsheet](https://phpspreadsheet.readthedocs.io/) hanya punya sheet/workbook protection (bukan open-password) → generate dengan PhpSpreadsheet, enkripsi via CLI `msoffcrypto-tool` (lihat DOCX).

### DOCX

| Langkah | Tool | Catatan |
|---------|------|---------|
| Generate | [`docx`](https://github.com/dolanmiu/docx) / `docxtemplater` (Node), PHPWord (PHP) | Library generator **tidak** punya enkripsi |
| Enkripsi (opsi 1) | [`officecrypto-tool`](https://github.com/zurmokeeper/officecrypto-tool) | Sama seperti XLSX — `encrypt(buffer, { password })`; dukungan ECMA-376 untuk DOCX/XLSX/PPTX. **Wajib round-trip test di Word & LibreOffice** sebelum dipakai |
| Enkripsi (opsi 2, fallback) | [`msoffcrypto-tool`](https://github.com/nolze/msoffcrypto-tool) (Python CLI) | `msoffcrypto-tool -e -p "$PASSWORD" in.docx out.docx` — dukungan enkripsi OOXML berlabel experimental di upstream; jalankan via child process **tanpa** password di argumen yang ter-log |

Tidak ada library JS "satu paket" untuk generate + enkripsi DOCX. Pilih opsi 1 untuk stack Node murni; opsi 2 kalau
container sudah punya Python atau stack backend-nya PHP/Python.

### PDF

| Opsi | Tool | Catatan |
|------|------|---------|
| **Default** | [`pdfkit`](https://github.com/foliojs/pdfkit) | Enkripsi built-in: `new PDFDocument({ userPassword, ownerPassword, pdfVersion: '1.7ext3' })` → AES-256 |
| Post-process | [`qpdf`](https://qpdf.readthedocs.io/) CLI | `qpdf --encrypt <user> <owner> 256 -- in.pdf out.pdf` — untuk PDF dari generator lain (Puppeteer/Playwright, dompdf, wkhtmltopdf). Wrapper Node: [`node-qpdf2`](https://github.com/SYugel/node-qpdf2) |

```js
import PDFDocument from 'pdfkit';
import { randomBytes } from 'node:crypto';

const doc = new PDFDocument(password ? {
  pdfVersion: '1.7ext3',                              // AES-256
  userPassword: password,                             // password untuk membuka file
  ownerPassword: randomBytes(32).toString('hex'),     // owner password acak, tidak disimpan
  permissions: { printing: 'highResolution', copying: true },
} : {});
```

⚠️ [`pdf-lib`](https://github.com/Hopding/pdf-lib) **tidak** mendukung enkripsi — jika dipakai, wajib post-process dengan `qpdf`.
⚠️ `qpdf` versi lama menerima password di argumen CLI (terlihat di `ps`) — pakai `@argfile` qpdf atau wrapper yang menulis argumen ke file sementara (permission `0600`), hapus setelah selesai.

---

## 🖥️ UI — Dialog Export

```
┌──────────────────────────────────────────┐
│  Export Data                         [X] │
│                                          │
│  Format:  ( ) XLSX  ( ) PDF  ( ) DOCX    │
│                                          │
│  [ ] 🔒 Lindungi dengan password         │
│      ┌───────────────────────────┐       │
│      │ ••••••••            [👁]  │       │  ← muncul hanya jika toggle ON
│      └───────────────────────────┘       │
│      Simpan password ini — file tidak    │
│      bisa dibuka tanpanya.               │
│                                          │
│              [Batal]  [⬇ Export]         │
└──────────────────────────────────────────┘
```

- Toggle OFF → input password disembunyikan & nilainya dikosongkan.
- Toggle ON + password kosong → tombol Export disabled + pesan validasi (i18n).
- Tombol show/hide punya `aria-label` (UX-06); input `type="password"` + `autocomplete="new-password"`.
- Hint wajib: password **tidak disimpan** di sistem dan tidak bisa dipulihkan (Nielsen A5 — error prevention).
- Panjang minimal password: 8 karakter (validasi frontend + backend).

## 🔌 API

```http
POST /api/{resource}/export
Content-Type: application/json

{ "format": "xlsx", "filters": { ... }, "password": "optional-string" }
```

- Response: file stream, `Content-Disposition: attachment`.
- `password` **tidak** boleh muncul di access log, error log, APM, atau audit trail — redaksi di middleware logger.
- Endpoint export kena rate limit (lihat [SECURITY-CLOUDFLARE.md](SECURITY-CLOUDFLARE.md)).

---

## ✅ Checklist Export

- [ ] EX-01/02 Dialog export punya toggle + password show/hide; default unprotected
- [ ] EX-03 XLSX & DOCX terenkripsi OOXML, PDF AES-256 (bukan sheet protection / ZIP)
- [ ] EX-04 Enkripsi di backend; password tidak di-log/disimpan
- [ ] EX-06 Round-trip test per format ada & hijau
- [ ] EX-07 Semua teks dialog dari file terjemahan id/en/ja

---

## 🔗 Referensi

- [standards/UI-UX-STANDARDS.md](UI-UX-STANDARDS.md) — Aturan UI export & ikon
- [standards/SUPPLY-CHAIN-SECURITY.md](SUPPLY-CHAIN-SECURITY.md) — Pinning & review library export
- [phases/03-BACKEND.md](../phases/03-BACKEND.md) — Endpoint export
- [phases/04-FRONTEND.md](../phases/04-FRONTEND.md) — Dialog export
- [PDFKit — Encryption and Access Privileges](https://github.com/foliojs/pdfkit/blob/master/docs/getting_started.md)
- [officecrypto-tool](https://github.com/zurmokeeper/officecrypto-tool) · [msoffcrypto-tool](https://github.com/nolze/msoffcrypto-tool) · [qpdf encryption](https://qpdf.readthedocs.io/en/stable/cli.html#encryption)
