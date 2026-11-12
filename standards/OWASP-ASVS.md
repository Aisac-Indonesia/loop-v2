# OWASP-ASVS.md — Application Security Verification Standard (Lapisan Aplikasi)

> **WAJIB untuk setiap project.** ASVS adalah standar verifikasi keamanan **di level aplikasi**
> (kode, auth, session, akses data, kripto, logging). Dicek di
> [phases/03-BACKEND.md](../phases/03-BACKEND.md) saat implementasi dan di
> [phases/05-AUDIT.md](../phases/05-AUDIT.md) sebelum deploy.

---

## 🧱 ASVS vs Cloudflare — Dua Lapisan, Keduanya Wajib

| | **Cloudflare** ([SECURITY-CLOUDFLARE.md](SECURITY-CLOUDFLARE.md)) | **OWASP ASVS** (dokumen ini) |
|---|---|---|
| Lapisan | **Edge / network** — sebelum request sampai server | **Aplikasi** — di dalam kode & data |
| Menahan | DDoS, bot, scan massal, brute force volumetrik, signup massal, path sensitif (`/.env`) | Broken access control, IDOR antar tenant, injection, auth/session lemah, kripto salah, kebocoran data lewat API/log |
| Contoh | WAF OWASP Core Ruleset, Turnstile, Rate Limiting Rules | Cek otorisasi per object, parameterized query, hashing password, validasi server-side |

**Tidak ada yang menggantikan yang lain.** WAF tidak tahu bahwa user tenant A tidak boleh membaca
`/api/invoices/123` milik tenant B — itu hanya bisa dijaga di kode. Sebaliknya, kode yang aman
tetap bisa tumbang oleh DDoS atau 10.000 akun palsu tanpa edge protection. Dependency yang dibajak
melewati keduanya → itu domain [SUPPLY-CHAIN-SECURITY.md](SUPPLY-CHAIN-SECURITY.md).

```
Internet → [Cloudflare: edge] → [App: ASVS] → [Dependencies: Supply-Chain] → Data
```

---

## 📌 Versi yang Berlaku — **ASVS 5.0.0**

- **Versi stabil terbaru: OWASP ASVS 5.0.0**, dirilis **30 Mei 2025** (diumumkan di OWASP Global AppSec EU, Barcelona).
  Diverifikasi dari README repo resmi (*"Latest Stable Version - 5.0.0"*) dan halaman release:
  - <https://github.com/OWASP/ASVS> (README)
  - <https://github.com/OWASP/ASVS/releases/tag/v5.0.0_release>
  - Daftar chapter: <https://github.com/OWASP/ASVS/tree/master/5.0/en>
- Versi sebelumnya **4.0.3 (Oktober 2021)** memakai struktur **14 chapter** (V1 Architecture … V14 Configuration).
  **Struktur 5.0 berbeda total** — 17 chapter dengan pengelompokan & penomoran baru (mis. Authentication
  bukan lagi V2 tapi V6; ada chapter baru untuk Web Frontend, Self-contained Tokens, OAuth/OIDC, WebRTC).
  Mapping 4.0.3 ↔ 5.0 tersedia di folder `5.0/mappings` repo resmi.
- Format referensi requirement di 5.0: `v5.0.0-<chapter>.<section>.<requirement>`, mis. `v5.0.0-1.2.5`.
  **Selalu sertakan prefix versi** saat mengutip requirement agar tidak tertukar dengan nomor 4.x.
- Jumlah requirement: sekitar ±350 (sumber sekunder menyebut angka berbeda; rujuk file CSV/JSON
  resmi di repo bila butuh angka pasti).

---

## 🎚️ Level Verifikasi

ASVS 5.0 memakai tiga level yang **kumulatif** (L2 mencakup L1, L3 mencakup L2). Di 5.0 level
dibingkai sebagai **tahapan kedalaman pertahanan berdasarkan risiko**, bukan lagi dikaitkan dengan
metode pengujian tertentu (di 4.x, L1 disebut "bisa diuji penuh secara black-box/penetration testing").

| Level | Untuk siapa | Keputusan Sainskerta |
|---|---|---|
| **L1 — Baseline** | Lapisan pertahanan minimum; titik awal untuk aplikasi berisiko rendah | Hanya untuk prototipe/landing page tanpa login & tanpa data pribadi |
| **L2 — Standard** | Aplikasi yang memproses data bisnis/akun user — mayoritas aplikasi | **DEFAULT WAJIB untuk SaaS & aplikasi klien pada umumnya** |
| **L3 — Advanced** | Aplikasi bernilai tinggi / data sangat sensitif / regulasi ketat / kegagalan berdampak serius | **WAJIB bila memproses data pribadi spesifik** (lihat di bawah) |

**Kapan L3 wajib** — dikaitkan langsung ke [DATA-PROTECTION-ID.md](DATA-PROTECTION-ID.md):
- Memproses **data pribadi yang bersifat spesifik** menurut UU PDP 27/2022 Pasal 4 ayat (2): data
  kesehatan, biometrik, genetika, catatan kejahatan, data anak, data keuangan pribadi — **dalam skala besar
  atau sebagai kegiatan inti**;
- Project yang hasil skrining DPIA-nya "wajib DPIA" (risiko tinggi), atau
- Transaksi keuangan/pembayaran inti, layanan publik, atau klien yang secara kontrak meminta L3.

Untuk project campuran: L2 untuk keseluruhan app, **L3 untuk module** yang menyentuh data spesifik
(mis. module `MedicalRecords` L3, module `Products` L2).

---

## 📚 Daftar Chapter ASVS 5.0 (17 chapter)

Judul chapter persis mengikuti nama file resmi di `5.0/en/` repo OWASP/ASVS. Ringkasan satu baris adalah parafrase Sainskerta.

| # | Chapter | Ringkasan |
|---|---|---|
| V1 | **Encoding and Sanitization** | Output encoding sesuai konteks & pencegahan injection (SQL, OS command, LDAP, template, dll), sanitasi HTML/markdown, deserialisasi aman |
| V2 | **Validation and Business Logic** | Validasi input positif di server, aturan bisnis ditegakkan berurutan & atomik, anti-otomasi/abuse limit pada alur bisnis |
| V3 | **Web Frontend Security** | Keamanan sisi browser: CSP, header keamanan, atribut cookie, anti-clickjacking, CORS & origin, isolasi konten pihak ketiga |
| V4 | **API and Web Service** | Keamanan HTTP API/REST/GraphQL/WebSocket: method & content-type, struktur pesan, validasi schema, pembatasan query |
| V5 | **File Handling** | Upload (tipe, ukuran, nama, konten), penyimpanan di luar webroot, download aman, anti path traversal & zip bomb |
| V6 | **Authentication** | Password (panjang, cek breach, tanpa aturan komposisi aneh), MFA, anti credential stuffing, recovery akun, lifecycle authenticator |
| V7 | **Session Management** | Pembuatan, timeout (idle & absolut), terminasi/logout, re-autentikasi untuk aksi sensitif, session federasi |
| V8 | **Authorization** | Dokumentasi aturan akses, cek otorisasi di level fungsi **dan data/object** (anti-IDOR), isolasi multi-tenant, least privilege |
| V9 | **Self-contained Tokens** | JWT & token sejenis: validasi signature/algoritma, klaim (exp, aud, iss), tujuan token tidak tertukar |
| V10 | **OAuth and OIDC** | Peran client, resource server, authorization server, dan OIDC: PKCE, redirect URI ketat, state/nonce, scope |
| V11 | **Cryptography** | Inventaris kripto, algoritma & mode yang disetujui, random aman, hashing password, manajemen key, kesiapan post-quantum |
| V12 | **Secure Communication** | TLS untuk semua koneksi (eksternal & antar layanan internal), validasi sertifikat, HSTS |
| V13 | **Configuration** | Konfigurasi aman: secret management (bukan di kode), hardening, tidak ada debug/akses backend yang bocor, isolasi komunikasi backend |
| V14 | **Data Protection** | Klasifikasi data sensitif, minimisasi, perlindungan di sisi klien (cache, storage browser), retensi & penghapusan |
| V15 | **Secure Coding and Architecture** | Dokumentasi arsitektur keamanan, dependency aman (SBOM, update), concurrency/race condition, pola kode aman |
| V16 | **Security Logging and Error Handling** | Inventaris event keamanan yang dilog, isi log, proteksi log, error handling yang tidak membocorkan detail |
| V17 | **WebRTC** | TURN server, media & signaling untuk aplikasi real-time audio/video — **hanya relevan bila app memakai WebRTC** |

Appendix resmi: A Glossary, B References, C Cryptography, D Recommendations, E Contributors.

---

## ✅ Priority Checklist untuk Stack Sainskerta (Level 2 default)

Bukan pengganti membaca ASVS — ini **subset prioritas** yang paling sering gagal di stack kita
(Laravel / Node / Next.js / React, Postgres/MySQL, multi-tenant SaaS). Kolom "Chapter" menunjuk
chapter ASVS 5.0 untuk detail requirement.

### A. Authentication — V6
- [ ] **ASVS-A1** Password minimal **8 karakter (L1) / 12+ disarankan**, maksimum ≥ 64, tanpa aturan komposisi wajib; tolak password dari daftar bocor (Have I Been Pwned k-anonymity / `Password::uncompromised()` Laravel)
- [ ] **ASVS-A2** Hashing password: `bcrypt` (cost ≥ 12) atau `argon2id` — tidak pernah MD5/SHA1/plaintext
- [ ] **ASVS-A3** Anti brute force di level aplikasi (throttle per akun + per IP, lockout bertahap) — **selain** Rate Limiting Rules Cloudflare (CF-03)
- [ ] **ASVS-A4** MFA (TOTP/WebAuthn) tersedia — **wajib** untuk role admin & L3
- [ ] **ASVS-A5** Reset password: token acak sekali pakai, kedaluwarsa ≤ 1 jam, respons identik untuk email terdaftar/tidak (anti user enumeration)
- [ ] **ASVS-A6** Pesan login gagal generik ("email atau password salah")

### B. Session Management — V7, V9, V3
- [ ] **ASVS-B1** Cookie session `HttpOnly`, `Secure`, `SameSite=Lax/Strict`; prefix `__Host-` bila memungkinkan
- [ ] **ASVS-B2** Session ID di-regenerate setelah login & perubahan privilege
- [ ] **ASVS-B3** Idle timeout & absolute timeout terdefinisi; logout menghapus session di server
- [ ] **ASVS-B4** Re-autentikasi untuk aksi sensitif (ganti email/password, hapus akun, export data massal)
- [ ] **ASVS-B5** JWT (bila dipakai): algoritma di-whitelist (tolak `none`), cek `exp`/`aud`/`iss`, access token umur pendek + refresh token rotasi; **jangan simpan token di `localStorage`** untuk app berisiko — utamakan cookie HttpOnly
- [ ] **ASVS-B6** CSRF protection untuk semua state-changing request berbasis cookie

### C. Access Control & Tenant Isolation — V8
- [ ] **ASVS-C1** **Deny by default**: setiap route/controller punya middleware auth + policy/gate; route tanpa policy = gagal review
- [ ] **ASVS-C2** **Otorisasi di level object** (anti-IDOR): setiap `find($id)` dicek kepemilikan/tenant — pakai Laravel Policy / scope repository `where tenant_id = currentTenant()`
- [ ] **ASVS-C3** **Tenant isolation di repository layer**: karena No-FK (aturan #2), isolasi tenant **wajib** di global scope repository/ORM, bukan mengandalkan constraint DB; test otomatis "user tenant A tidak bisa baca/ubah/hapus/restore data tenant B" untuk **setiap** resource
- [ ] **ASVS-C4** Endpoint soft-delete `trashed` & `restore` (aturan #3) ikut dicek otorisasi — data terhapus tenant lain tidak boleh terlihat
- [ ] **ASVS-C5** Mass assignment dicegah (`$fillable` eksplisit / DTO / schema `zod`) — user tidak bisa set `role`, `tenant_id`, `is_admin`
- [ ] **ASVS-C6** Fungsi admin terpisah role & di-log

### D. Input Validation & Injection — V1, V2
- [ ] **ASVS-D1** Validasi **server-side** untuk semua input (FormRequest Laravel / `zod` di Node) — validasi frontend hanya UX
- [ ] **ASVS-D2** Query selalu parameterized / ORM; **tidak ada** string-concat SQL; raw query di-review khusus
- [ ] **ASVS-D3** Output encoding: Blade `{{ }}`/JSX default; `{!! !!}`/`dangerouslySetInnerHTML` hanya untuk HTML yang sudah disanitasi (DOMPurify / HTML Purifier)
- [ ] **ASVS-D4** Tidak ada `eval`, deserialisasi data user (`unserialize`), atau command shell dengan input user
- [ ] **ASVS-D5** Aturan bisnis server-side: harga/diskon/kuota dihitung server, bukan percaya nilai dari client; operasi bernilai uang idempotent & atomik (transaksi DB)
- [ ] **ASVS-D6** Anti-SSRF: URL dari user (webhook, import URL, preview link) divalidasi allowlist, blok IP internal/metadata cloud

### E. Cryptography & Secrets — V11, V12, V13
- [ ] **ASVS-E1** **Nol secret di kode** — aturan TF-III di [TWELVE-FACTOR.md](TWELVE-FACTOR.md#iii-config--store-config-in-the-environment); `APP_KEY`/`JWT_SECRET` unik per environment
- [ ] **ASVS-E2** TLS untuk semua koneksi termasuk app → DB (`sslmode=require`) dan app → Redis/API pihak ketiga; HSTS aktif
- [ ] **ASVS-E3** Data pribadi spesifik dienkripsi at-rest di level kolom (Laravel `encrypted` cast / libsodium) **di luar** enkripsi disk provider; kolom yang perlu dicari pakai blind index
- [ ] **ASVS-E4** Random token pakai CSPRNG (`random_bytes`, `crypto.randomUUID`/`crypto.randomBytes`), tidak `Math.random()`/`rand()`
- [ ] **ASVS-E5** Tidak ada algoritma usang (MD5/SHA1 untuk keamanan, AES-ECB, RSA < 2048); export password (EXPORT-STANDARDS) pakai AES-256

### F. Error Handling & Logging — V16
- [ ] **ASVS-F1** Production `APP_DEBUG=false` / `NODE_ENV=production`; error ke user generik + `request_id` untuk korelasi
- [ ] **ASVS-F2** Event keamanan dilog: login sukses/gagal, reset password, perubahan role, akses ditolak, export data massal, aksi admin, restore data
- [ ] **ASVS-F3** Log **tanpa** password, token, OTP, session ID, data pribadi spesifik mentah — masking wajib
- [ ] **ASVS-F4** Log dilindungi dari modifikasi & aksesnya dibatasi; retensi sesuai [SRE-RELIABILITY.md](SRE-RELIABILITY.md) & [DATA-PROTECTION-ID.md](DATA-PROTECTION-ID.md)

### G. File Upload — V5
- [ ] **ASVS-G1** Allowlist ekstensi **dan** validasi MIME/magic bytes; batas ukuran di app (bukan hanya Nginx/Cloudflare)
- [ ] **ASVS-G2** Nama file diganti (UUID); disimpan **di luar webroot** / object storage private; download lewat endpoint yang cek otorisasi atau signed URL berumur pendek
- [ ] **ASVS-G3** File gambar diproses ulang (strip metadata EXIF yang bisa berisi lokasi); SVG diperlakukan sebagai berbahaya kecuali disanitasi
- [ ] **ASVS-G4** Arsip (zip) dicek ukuran ekstraksi (anti zip bomb) & path traversal (`../`)
- [ ] **ASVS-G5** Scan malware untuk upload yang dibagikan ke user lain (anjuran L2, wajib L3)

### H. API Security — V4, V3
- [ ] **ASVS-H1** Semua endpoint API terdokumentasi (OpenAPI) — dokumen sama dipakai untuk API Shield Schema Validation (CF-07)
- [ ] **ASVS-H2** Content-Type divalidasi; ukuran body dibatasi; pagination wajib dengan `per_page` maksimum
- [ ] **ASVS-H3** CORS allowlist origin eksplisit — tidak `*` untuk API yang memakai credential
- [ ] **ASVS-H4** Response API tidak mengembalikan field sensitif berlebih (pakai Resource/Transformer/DTO, bukan dump model)
- [ ] **ASVS-H5** Rate limit per user/API key di level aplikasi untuk operasi mahal (export, AI call) — melengkapi CF-03
- [ ] **ASVS-H6** Security headers: CSP, `X-Content-Type-Options: nosniff`, `Referrer-Policy`, `frame-ancestors`

### I. Dependency & Architecture — V15
- [ ] **ASVS-I1** Semua item [SUPPLY-CHAIN-SECURITY.md](SUPPLY-CHAIN-SECURITY.md) (SC-01..SC-10) lulus — itu implementasi Sainskerta untuk bagian dependency di V15
- [ ] **ASVS-I2** Operasi concurrent kritis (stok, saldo, kuota) aman dari race condition (lock / transaksi / unique constraint)

---

## 🧪 Cara Verifikasi

| Kapan | Apa |
|---|---|
| Fase 03 Backend | Checklist di atas dipakai sebagai *definition of done* per module; test otomatis tenant isolation (ASVS-C3) & authz (lihat [TESTING-TDD.md](TESTING-TDD.md)) |
| CI | SAST (Semgrep / CodeQL), secret scanning, dependency scan (SC-04) |
| Fase 05 Audit | Review checklist ASVS L2 (L3 untuk module data spesifik) + DAST ringan (OWASP ZAP baseline scan ke staging) — hasil dicatat di Laporan Audit |
| Tahunan / rilis besar | Penetration test independen untuk project L3 |

---

## 🔗 Referensi

- [OWASP ASVS — repo resmi](https://github.com/OWASP/ASVS) · [Release 5.0.0](https://github.com/OWASP/ASVS/releases/tag/v5.0.0_release) · [Chapter 5.0 (en)](https://github.com/OWASP/ASVS/tree/master/5.0/en)
- [OWASP ASVS project page](https://owasp.org/www-project-application-security-verification-standard/)
- [OWASP Cheat Sheet Series — ASVS index](https://cheatsheetseries.owasp.org/IndexASVS.html)
- [standards/SECURITY-CLOUDFLARE.md](SECURITY-CLOUDFLARE.md) — Lapisan edge (pelengkap, bukan pengganti)
- [standards/SUPPLY-CHAIN-SECURITY.md](SUPPLY-CHAIN-SECURITY.md) — Lapisan dependency
- [standards/DATA-PROTECTION-ID.md](DATA-PROTECTION-ID.md) — Pemicu L3 (data pribadi spesifik)
- [standards/ISO-27001-27701.md](ISO-27001-27701.md) — Kontrol organisasi (secure development, access control)
- [phases/03-BACKEND.md](../phases/03-BACKEND.md) · [phases/05-AUDIT.md](../phases/05-AUDIT.md)
