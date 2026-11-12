# Fase 01: Planning

> **Fase perencanaan — menentukan blueprint arsitektur project sebelum coding dimulai. Semua keputusan kritis ditentukan di sini bersama user.**

---

## 🎯 Tujuan

1. Menganalisa requirement dari `user_requirement.md`
2. Menentukan arsitektur sesuai aturan [RULES-OF-THE-GAME.md](../RULES-OF-THE-GAME.md)
3. Tanya jawab dengan user via `user_requirement.md`
4. Membuat roadmap development
5. Setup environment detail

---

## 📋 Langkah-Langkah

### Langkah 1: Analisa Requirement

Baca `user_requirement.md`, ekstrak:

- **Fitur utama** — apa saja yang harus dibuat?
- **Entities/Models** — apa saja data yang perlu disimpan?
- **Relasi antar entity** — bagaimana hubungan data?
- **UI requirements** — halaman apa saja yang dibutuhkan?
- **Business logic** — aturan bisnis khusus?

**Output:** Ringkasan requirement di `progress.md`

### Langkah 2: Breakdown Arsitektur

Gunakan [TEMPLATE-ARCHITECTURE.md](../TEMPLATE-ARCHITECTURE.md) untuk tanya jawab dengan user.

**Wajib ditanyakan ke user:**
1. ✅ Framework backend
2. ✅ Framework frontend
3. ✅ Database engine
4. ✅ Deployment target
5. ✅ Domain & SSL
6. ✅ Integrasi AI (jika ada)
7. ✅ Fitur tambahan (auth, upload, queue, dll)

**Cara tanya:**
```
[AI] Halo! Untuk memulai project, saya perlu beberapa informasi:

1. Framework backend apa yang kamu mau? (Laravel/Next.js/Express/dll)
2. Framework frontend? (React/Vue/Svelte)
3. Database? (MySQL/PostgreSQL/SQLite)
4. Target deploy dimana? (VPS/shared hosting/cloud)
5. Ada domain? Butuh SSL?
6. Butuh integrasi AI? Provider apa?

Silakan jawab di user_requirement.md ya!
```

### Langkah 3: Tanya Jawab dengan User

- User jawab di `user_requirement.md`
- AI baca, tanya follow-up jika perlu
- Iterasi sampai semua jelas
- **Jangan lanjut sebelum semua keputusan firm**

### Langkah 3b: Skrining Data Pribadi (DPIA), Tier SLO & Level ASVS (WAJIB)

Detail: [standards/DATA-PROTECTION-ID.md](../standards/DATA-PROTECTION-ID.md) · [standards/SRE-RELIABILITY.md](../standards/SRE-RELIABILITY.md) · [standards/OWASP-ASVS.md](../standards/OWASP-ASVS.md)

**Skrining DPIA** — tanyakan ke user, jawab ya/tidak. **Satu "ya" → DPIA wajib** (`docs/DPIA.md`) sebelum fase Backend dimulai,
dan module terkait memakai **ASVS L3**:
1. [ ] Ada **keputusan otomatis** yang berakibat hukum / berdampak signifikan bagi orang (approval kredit, seleksi otomatis, scoring)?
2. [ ] Memproses **data pribadi spesifik**: kesehatan, biometrik, genetika, catatan kejahatan, **data anak**, keuangan pribadi?
3. [ ] Memproses data pribadi dalam **skala besar** (dinilai kontekstual: jumlah subjek, volume, durasi, cakupan wilayah)?
4. [ ] Ada **evaluasi, penskoran, atau pemantauan sistematis** (profiling, tracking perilaku, monitoring karyawan)?
5. [ ] Ada **pencocokan/penggabungan** beberapa sumber data pribadi?
6. [ ] Memakai **teknologi baru** atas data pribadi (AI/ML, IoT, face recognition)?
7. [ ] Pemrosesan bisa **membatasi pelaksanaan hak** subjek data?

**Pertanyaan pendukung:**
- [ ] Kategori data pribadi apa saja yang dikumpulkan, dari siapa, untuk tujuan apa, dasar hukumnya apa? → isi **`docs/ROPA.md` awal**
- [ ] Apakah klien wajib menunjuk **DPO** (pelayanan publik / pemantauan sistematis skala besar / data spesifik skala besar)? Catat nama/kontak DPO
- [ ] Ada data yang disimpan/diproses di luar Indonesia (hosting, email, AI provider)? → catat mekanisme transfer
- [ ] Masa retensi per kategori data (dasar `docs/RETENTION-POLICY.md`)
- [ ] **Tier SLO** project: T1 internal tool / T2 aplikasi klien standar / T3 SaaS berbayar — siapa user, jam pakai, dampak bila down 1 jam?
- [ ] Apakah kontrak klien mensyaratkan **SLA**?

### Langkah 4: Buat Project Structure

Berdasarkan arsitektur yang dipilih, buat struktur folder:

**Contoh untuk Laravel + React + MySQL:**

```
project-name/
├── backend/               ← Laravel
│   ├── app/
│   │   ├── Modules/       ← Modular Monolith modules
│   │   │   ├── User/
│   │   │   │   ├── Controllers/
│   │   │   │   ├── Models/
│   │   │   │   ├── Repositories/
│   │   │   │   ├── Services/
│   │   │   │   └── Routes/
│   │   │   ├── Product/
│   │   │   └── Transaction/
│   │   └── ...
│   ├── database/
│   │   └── migrations/
│   └── routes/
├── frontend/              ← React
│   ├── src/
│   │   ├── components/
│   │   ├── pages/
│   │   ├── services/
│   │   └── layouts/
│   └── ...
├── .claude/               ← Workflow files
│   └── loop.md
├── progress.md             ← Tracking
└── user_requirement.md     ← Requirements
```

### Langkah 5: Setup Environment Detail

Berdasarkan arsitektur yang dipilih:

```bash
# Jika Laravel
composer create-project laravel/laravel .
php artisan storage:link

# Jika React
npx create-vite frontend --template react
cd frontend && npm install

# Setup .env
# DB_HOST, DB_PORT, DB_DATABASE, DB_USERNAME, DB_PASSWORD
```

### Langkah 6: Buat Roadmap

Breakdown fitur ke dalam task per fase:

```markdown
## Roadmap

### Phase 03 — Backend
- [ ] Migration: users table
- [ ] Migration: products table
- [ ] Migration: transactions table
- [ ] Model & Repository User
- [ ] Model & Repository Product
- [ ] Model & Repository Transaction
- [ ] Auth API (login, register)
- [ ] CRUD API User
- [ ] CRUD API Product
- [ ] CRUD API Transaction

### Phase 04 — Frontend
- [ ] Setup layout (sidebar)
- [ ] Halaman User (list + modal)
- [ ] Halaman Product (list + modal)
- [ ] Halaman Transaction (list + modal)
- [ ] Integrasi semua API
```

---

## ✅ Output Fase 01

Setelah fase ini selesai:
- [x] Requirement sudah dianalisa
- [x] Framework backend & frontend ditentukan
- [x] Database engine ditentukan
- [x] Deployment target ditentukan
- [x] Project structure sudah dibuat
- [x] Environment sudah ter-setup
- [x] Roadmap sudah dibuat
- [x] User sudah setuju dengan keputusan arsitektur
- [x] Skrining DPIA dijawab (DPIA dijadwalkan bila wajib), ROPA awal dibuat, kebutuhan DPO diputuskan
- [x] Tier SLO & level ASVS per module disepakati

---

## ▶️ Lanjut ke Fase 02

Setelah semua keputusan arsitektur firm, update progress dan lanjut ke [02-WIREFRAME-AUDIT.md](02-WIREFRAME-AUDIT.md).

---

## 🔗 Referensi

- [TEMPLATE-ARCHITECTURE.md](../TEMPLATE-ARCHITECTURE.md) — Template tanya jawab
- [RULES-OF-THE-GAME.md](../RULES-OF-THE-GAME.md) — Aturan wajib
- [standards/MODULAR-MONOLITH.md](../standards/MODULAR-MONOLITH.md) — Arsitektur modular
- [standards/UI-UX-STANDARDS.md](../standards/UI-UX-STANDARDS.md) — Standar UI/UX yang akan dipake di wireframe
- [templates/user_requirement.md](../templates/user_requirement.md) — Template requirement
- [standards/DATA-PROTECTION-ID.md](../standards/DATA-PROTECTION-ID.md) — Skrining DPIA, ROPA, DPO
- [standards/SRE-RELIABILITY.md](../standards/SRE-RELIABILITY.md) — Memilih tier SLO
- [standards/OWASP-ASVS.md](../standards/OWASP-ASVS.md) — Level verifikasi L1/L2/L3
- [standards/TWELVE-FACTOR.md](../standards/TWELVE-FACTOR.md) — Prinsip codebase, config & deploy
