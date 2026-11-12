# RULES-OF-THE-GAME

> **Aturan Sainskerta yang WAJIB dipatuhi di setiap project. Tidak ada toleransi. Tidak ada pengecualian.**

---

## 🔴 Aturan Mutlak (Absolute Rules)

### 1. Modular Monolith — WAJIB
Tidak ada microservices. Semua project adalah **Modular Monolith**: satu codebase, module terpisah, komunikasi event-driven.

```
Kenapa? Karena:
- TIM KECIL — tidak ada tim besar yang butuh deploy independen
- KOMPLEKSITAS — microservices butuh infra yang rumit (message broker, container orchestration)
- MAINTENANCE — satu codebase lebih mudah di-maintain tim kecil
- PERFORMANCE — tidak perlu network call antar service
```

Detail: [standards/MODULAR-MONOLITH.md](standards/MODULAR-MONOLITH.md)

### 2. No Foreign Keys di Database — WAJIB
Di level database, **TIDAK BOLEH ada foreign key constraint**. Referential integrity dijaga di level aplikasi.

```
Kenapa? Karena:
- FLEKSIBILITAS — soft delete lebih mudah tanpa cascade constraint
- MIGRATION — tidak ada error constraint saat migrate
- PERFORMANCE — tidak perlu index overhead dari FK
- TESTING — lebih mudah seed data tanpa urutan dependency
```

Detail: [standards/DATABASE-RULES.md](standards/DATABASE-RULES.md)

### 3. Soft Delete & Restore — WAJIB
Setiap tabel harus punya kolom `deleted_at` (TIMESTAMP nullable). Data tidak pernah dihapus permanen.

**Wajib ada:**
- Endpoint `GET /api/{resource}/trashed` — lihat data terhapus
- Endpoint `PATCH /api/{resource}/{id}/restore` — restore data
- Cascade delete di handle aplikasi (bukan database)

### 4. CRUD in One Page — WAJIB
Tidak ada halaman terpisah untuk create, edit, list. Semua dalam satu halaman.

**Pattern:**
- List (table) → default view
- Create → tombol "Tambah" → modal form
- Edit → klik row/list → modal form yang sama
- Delete → konfirmasi soft delete
- Restore → tombol di table trashed items

### 5. Modal di Kanan (Right-Side Drawer) — WAJIB
Semua form create/edit menggunakan **right-side drawer modal**, bukan popup tengah.

**Spesifikasi:**
- Lebar: 400px (atau 90% di mobile < 768px)
- Animasi: slide-in dari kanan (300ms ease)
- Backdrop: semi-transparan hitam (rgba(0,0,0,0.5))
- Close: tombol X di pojok kanan atas + klik backdrop
- Scroll: overflow-y auto jika konten panjang

### 6. Sidebar Dashboard — 1 Color Icon — WAJIB
Sidebar menggunakan **1 warna solid per icon**. Setiap menu punya icon monochrome dengan warna solid yang berbeda.

**Aturan:**
- SVG inline (bukan icon font)
- Satu warna solid per menu (hex code)
- Tidak ada gradient
- Web-safe colors
- Hover: opacity 0.8
- Active/selected: warna lebih terang (lighten 20%)

### 7. Say No to Hardcoded Dummy Data — WAJIB
Frontend **TIDAK BOLEH** menggunakan dummy/hardcoded data untuk development. Semua data harus dari database via backend API.

**Konsekuensi:**
- Backend harus punya seeder/endpoint untuk data development
- Frontend harus loading state jika data belum tersedia
- Kalau belum ada API endpoint, frontend nunggu — tidak pakai mock data

### 8. Database Access — WAJIB DARI USER
User WAJIB memberikan akses database (host, user, password, db_name) SEBELUM project dibuat.

**Tanpa DB access? Project tidak bisa dimulai.**

### 9. Backend Dulu, Baru Frontend
Urutan development: **Backend → API Documentation → Frontend**.

Backend harus selesai dengan API yang berfungsi sebelum frontend dimulai. Frontend integrasi dengan API beneran, bukan mock.

### 10. Semua Keputusan Arsitektur dari User
User menentukan di fase planning:
- Framework backend & frontend
- Target deployment (VPS/shared hosting/cloud)
- Database engine
- Integrasi AI (provider)
- Domain & SSL

Template tanya jawab: [TEMPLATE-ARCHITECTURE.md](TEMPLATE-ARCHITECTURE.md)

### 11. Audit Wajib Sebelum Deploy
TIDAK BOLEH deploy sebelum fase audit selesai. Audit mencakup:
- Security check (XSS, SQL injection, CSRF)
- Performance test
- Code review
- UI/UX consistency
- Mobile responsiveness
- Database optimization

### 12. UX Heuristic Benchmark ≥ 9.0/10 — WAJIB
Setiap wireframe & mockup **WAJIB** di-score terhadap 3 framework UX sebelum ditampilkan ke user:
- **Nielsen's 10 Usability Heuristics**
- **Shneiderman's Eight Golden Rules of Interface Design**
- **Laws of UX** (Jon Yablonski)

**Gate:**
- Overall **≥ 9.0 / 10**
- Tidak ada framework dengan rata-rata **< 8.0 / 10**
- Aturan konkret **UX-01 s/d UX-07** terpenuhi (cancel/undo/Esc, konteks lokasi, inline help, touch target 44×44px, WCAG 2.1 AA, navigasi top-level ≤ 9 item)

Gagal gate → revisi internal & score ulang. **Draft yang gagal TIDAK BOLEH ditampilkan ke user.**

Detail rubrik: [standards/UI-UX-STANDARDS.md](standards/UI-UX-STANDARDS.md#-ux-heuristic-benchmark-mandatory) · Proses: [phases/02-WIREFRAME-AUDIT.md](phases/02-WIREFRAME-AUDIT.md)

### 13. Cloudflare Edge Security & Anti-Abuse — WAJIB
Setiap project yang di-deploy ke domain publik **WAJIB** di belakang Cloudflare dengan baseline keamanan edge,
untuk menahan registrasi massal akun palsu, pentest/scan tanpa izin, brute force, dan DDoS.

**Minimal:** DNS proxied (orange-cloud) · Turnstile di signup/login/reset password (diverifikasi di backend) ·
Rate Limiting Rules di endpoint sensitif · WAF Managed Rules + OWASP Core Ruleset · Bot Fight Mode ·
DDoS aktif · runbook blok IP/negara/ASN · alert Security Events.

Ini gate **pass/fail** — semua item WAJIB harus ✅ sebelum go-live. Lapisan edge ini **melengkapi**, bukan menggantikan, keamanan di level aplikasi.

Detail: [standards/SECURITY-CLOUDFLARE.md](standards/SECURITY-CLOUDFLARE.md)

---

## 🟡 Aturan Anjuran (Recommendations)

### 14. Database Migration Wajib
Gunakan migration system. Jangan edit schema manual di database.

### 15. Seeder untuk Development — Tapi Jangan di Frontend
Seeder untuk populate database development itu BOLEH. Tapi frontend tetap nunggu data dari API.

### 16. Snake_case untuk Database
Semua nama tabel, kolom menggunakan `snake_case`. Bukan `camelCase` atau `PascalCase`.

### 17. Git Wajib
Setiap project harus version controlled dengan Git. Commit minimal per fase selesai.

### 18. Progress Tracking
File `progress.md` WAJIB diupdate setiap kali ada perubahan status. Ini satu-satunya source of truth progress project.

---

## 📋 Checklist Sebelum Project Dimulai

- [ ] User sudah siapkan database credentials
- [ ] User sudah tentukan framework & target deploy
- [ ] User sudah siapkan requirement dasar (user_requirement.md)
- [ ] Folder project sudah di-setup
- [ ] Loop workflow sudah siap

## 📋 Checklist Sebelum Deploy

- [ ] Audit keamanan sudah dilakukan
- [ ] Semua form sudah ada validasi
- [ ] Error handling sudah cover semua edge case
- [ ] UI sudah responsive (mobile tested)
- [ ] Soft delete & restore berfungsi
- [ ] Database optimization sudah cek (query, index)
- [ ] Environment variables ter-setup
- [ ] SSL sudah aktif
- [ ] Wireframe & mockup lulus UX Heuristic Benchmark (overall ≥ 9.0, tiap framework ≥ 8.0) — lihat aturan #12
- [ ] **Cloudflare (aturan #13)** — detail [standards/SECURITY-CLOUDFLARE.md](standards/SECURITY-CLOUDFLARE.md):
  - [ ] DNS proxied (orange-cloud), SSL Full (strict)
  - [ ] Turnstile di signup/login/reset password + verifikasi `siteverify` di backend
  - [ ] Rate Limiting Rules di endpoint auth, OTP & write API publik
  - [ ] WAF Managed Rules + OWASP Core Ruleset + custom rule path sensitif
  - [ ] Bot Fight Mode / Super Bot Fight Mode aktif
  - [ ] DDoS protection terkonfirmasi aktif
  - [ ] API Shield Schema Validation untuk API publik / agent-key (anjuran)
  - [ ] Runbook blok IP / negara / ASN terdokumentasi
  - [ ] Notifications Security Events aktif ke channel tim
- [ ] User sudah approve deployment
