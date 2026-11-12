# SECURITY-CLOUDFLARE.md — Standar Keamanan Edge & Anti-Abuse (Cloudflare)

> **WAJIB untuk setiap project yang di-deploy ke domain publik.** Ini lapisan keamanan di *edge*
> (sebelum request sampai ke app), melengkapi — bukan menggantikan — validasi, auth, CSRF,
> dan rate-limit di level aplikasi.

---

## 🎯 Kenapa Wajib?

Setiap SaaS publik **pasti** jadi target abuse. Contoh nyata yang harus kita antisipasi:

- **Registrasi massal akun palsu** — bot daftar 100.000 email palsu → database penuh sampah,
  kuota email/OTP jebol, metrik user jadi tidak valid.
- **Pentest / vulnerability scan tanpa izin** — orang iseng menjalankan scanner (SQLi, XSS,
  path traversal, brute force login) ke app kita tanpa diminta.
- **Brute force / credential stuffing** di halaman login & reset password.
- **DDoS** atau flood request yang bikin app down.

Cloudflare duduk di depan DNS app, jadi serangan ini bisa diblok **sebelum** menyentuh server & database.

---

## ✅ Checklist Wajib (Pass/Fail)

> Ini **gate pass/fail**, bukan skor. Semua item bertanda **WAJIB** harus ✅ sebelum go-live.

| # | Kontrol | Status | Keterangan |
|---|---------|--------|------------|
| CF-01 | DNS di-proxy lewat Cloudflare (orange-cloud) | **WAJIB** | Prasyarat semua kontrol di bawah |
| CF-02 | Turnstile di form signup, login, reset password | **WAJIB** | Fix langsung untuk registrasi massal palsu |
| CF-03 | Rate Limiting Rules di endpoint sensitif | **WAJIB** | Signup, login, reset password, OTP, write API publik |
| CF-04 | WAF Managed Rules (Cloudflare Managed + OWASP Core Ruleset) + custom rules | **WAJIB** | Blok pola injection/exploit di edge |
| CF-05 | Bot Fight Mode / Super Bot Fight Mode aktif | **WAJIB** | Challenge/blok scraper & bot otomatis |
| CF-06 | DDoS protection terkonfirmasi aktif | **WAJIB** | Otomatis begitu DNS di-proxy |
| CF-07 | API Shield (Schema Validation) untuk endpoint API / agent-key | *Anjuran* | Lapisan kedua di depan auth & rate-limit app |
| CF-08 | IP Access Rules / WAF custom rules siap dipakai | **WAJIB** (terdokumentasi) | Blok/challenge per negara, ASN, atau IP saat ada abuse |
| CF-09 | Security Events logging + alert lonjakan challenge/block | **WAJIB** | Sinyal dini ada pentest/abuse yang sedang berjalan |

---

## 🔧 Detail per Kontrol

### CF-01: DNS Proxied (Orange-Cloud)
- Semua record publik (`A`, `AAAA`, `CNAME`) untuk domain app → status **Proxied** (awan oranye).
- Record **DNS only** (awan abu-abu) membuat IP origin terekspos & semua kontrol di bawah **tidak berlaku**.
- SSL/TLS mode: **Full (strict)** — jangan pakai *Flexible*.
- Jika origin VPS: batasi firewall origin agar hanya menerima traffic dari
  [IP range Cloudflare](https://www.cloudflare.com/ips/) (mencegah bypass langsung ke IP server).

### CF-02: Turnstile (Anti-Bot di Form)
- Pasang widget **Cloudflare Turnstile** di: **signup/registrasi, login, reset password**,
  dan form publik lain yang memicu email/OTP (contact form, invite, dll).
- **Token WAJIB diverifikasi di backend** via endpoint `siteverify`
  (`https://challenges.cloudflare.com/turnstile/v0/siteverify`). Verifikasi hanya di frontend = tidak aman.
- Simpan `TURNSTILE_SITE_KEY` (frontend) & `TURNSTILE_SECRET_KEY` (backend) di `.env` — jangan hardcode.
- Gunakan mode *Managed* (invisible untuk user normal, challenge hanya untuk traffic mencurigakan) supaya UX tetap lancar.

```
Contoh alur signup:
Form → widget Turnstile → token dikirim bersama form → backend POST ke siteverify
→ success=false? tolak 400 → success=true? lanjut validasi & create user
```

### CF-03: Rate Limiting Rules
Buat **Rate Limiting Rules** di dashboard Cloudflare (Security → WAF → Rate limiting rules):

| Endpoint | Contoh Batas | Aksi |
|----------|--------------|------|
| `POST /api/auth/register` | 5 request / 10 menit / IP | Block / Managed Challenge |
| `POST /api/auth/login` | 10 request / menit / IP | Managed Challenge |
| `POST /api/auth/forgot-password` | 3 request / 10 menit / IP | Block |
| `POST /api/auth/otp*`, `/verify*` | 5 request / 10 menit / IP | Block |
| Write API publik lain (`POST/PUT/PATCH/DELETE /api/*`) | Sesuaikan beban normal | Managed Challenge |

- Angka di atas **contoh awal** — sesuaikan dengan traffic normal project, lalu ketatkan.
- Rate limit di edge **tidak menggantikan** rate limit di aplikasi — keduanya wajib.

### CF-04: WAF Managed Rules + Custom Rules
- Aktifkan **Cloudflare Managed Ruleset** dan **Cloudflare OWASP Core Ruleset**
  (Security → WAF → Managed rules). Mulai dengan sensitivitas default, mode *Block*.
- Custom rules minimal:
  - Blok akses ke path sensitif yang tidak seharusnya publik (`/.env`, `/.git`, `/phpmyadmin`, `/wp-admin` jika bukan WordPress, backup file `*.sql`, `*.zip`).
  - Challenge request ke `/admin*` dari negara di luar target user (jika relevan).
- Pantau false positive di minggu pertama → buat exception yang spesifik, **jangan matikan ruleset**.

### CF-05: Bot Fight Mode / Super Bot Fight Mode
- Plan Free: aktifkan **Bot Fight Mode** (Security → Bots).
- Plan Pro ke atas: pakai **Super Bot Fight Mode** → *Definitely automated* = Block,
  *Likely automated* = Managed Challenge, *Verified bots* (Google, dll) = Allow.
- Pastikan webhook/callback pihak ketiga (payment gateway, dll) tidak ikut terblok — buat skip rule untuk path webhook.

### CF-06: DDoS Protection
- DDoS protection L3/L4/L7 Cloudflare **aktif otomatis** untuk domain yang di-proxy (CF-01).
- Cek di Security → DDoS bahwa managed ruleset aktif (default). Tidak perlu konfigurasi tambahan kecuali ada kebutuhan khusus.

### CF-07: API Shield — Schema Validation (Anjuran)
- Untuk app yang punya API publik / endpoint ber-agent-key: upload skema OpenAPI ke **API Shield → Schema Validation**
  supaya request yang tidak sesuai skema diblok di edge.
- Opsional: JWT validation / mTLS untuk client machine-to-machine.
- Ini lapisan **kedua** — auth, validasi, idempotency, dan rate limit di aplikasi tetap wajib.

### CF-08: IP Access Rules / Firewall Rules
- Dokumentasikan di runbook project **cara cepat** memblok/challenge:
  - IP tunggal atau range (IP Access Rules)
  - Negara / ASN tertentu (WAF custom rule: `ip.src.country`, `ip.src.asnum`)
- Saat ada serangan aktif (registrasi massal, scan), langkah pertama: challenge/blok sumbernya di sini,
  baru investigasi.

### CF-09: Security Events Logging + Alert
- Pantau **Security → Events** (Security Analytics) untuk lonjakan block/challenge.
- Aktifkan **Notifications** Cloudflare (mis. *Security Events Alert*, *HTTP DDoS Attack Alert*,
  *Origin Error Rate Alert*) → kirim ke email/Slack/webhook tim.
- Lonjakan tiba-tiba di WAF/rate-limit = kemungkinan besar **ada pentest/scan atau bot abuse yang sedang berjalan** →
  respon pakai CF-08.

---

## 📋 Checklist Ringkas Sebelum Go-Live

- [ ] CF-01 DNS proxied (orange-cloud), SSL Full (strict), origin hanya terima IP Cloudflare (jika VPS)
- [ ] CF-02 Turnstile terpasang di signup/login/reset password **+ diverifikasi di backend**
- [ ] CF-03 Rate Limiting Rules aktif di endpoint auth & write API publik
- [ ] CF-04 WAF Managed Rules + OWASP Core Ruleset aktif, custom rule path sensitif aktif
- [ ] CF-05 Bot Fight Mode / Super Bot Fight Mode aktif (webhook di-skip)
- [ ] CF-06 DDoS managed ruleset terkonfirmasi aktif
- [ ] CF-07 API Shield Schema Validation (jika ada API publik / agent-key) — *anjuran*
- [ ] CF-08 Runbook blok IP/negara/ASN terdokumentasi
- [ ] CF-09 Notifications security aktif & terhubung ke channel tim

---

## 🔗 Referensi

- [RULES-OF-THE-GAME.md](../RULES-OF-THE-GAME.md) — Aturan mutlak keamanan edge
- [standards/OWASP-ASVS.md](OWASP-ASVS.md) — Keamanan **lapisan aplikasi** (ASVS 5.0) — wajib bersama edge, tidak saling menggantikan
- [standards/SUPPLY-CHAIN-SECURITY.md](SUPPLY-CHAIN-SECURITY.md) — Keamanan dependency
- [phases/05-AUDIT.md](../phases/05-AUDIT.md) — Audit keamanan aplikasi
- [phases/06-DEPLOYMENT.md](../phases/06-DEPLOYMENT.md) — Langkah setup Cloudflare saat deploy
- [Cloudflare Turnstile docs](https://developers.cloudflare.com/turnstile/)
- [Cloudflare WAF docs](https://developers.cloudflare.com/waf/)
- [Cloudflare Bots docs](https://developers.cloudflare.com/bots/)
- [Cloudflare API Shield docs](https://developers.cloudflare.com/api-shield/)
