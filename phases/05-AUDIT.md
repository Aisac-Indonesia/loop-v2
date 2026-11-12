# Fase 05: Audit

> **Fase audit pra-deploy — TIDAK BOLEH deploy sebelum audit selesai. Ini adalah gerbang terakhir sebelum production.**

---

## 🎯 Tujuan

1. Security check (XSS, SQL injection, CSRF)
2. Performance test
3. Code review
4. UI/UX consistency check
5. Error handling check
6. Mobile responsiveness
7. Database optimization
8. Code language check (English-only code)
9. Supply-chain & dependency security
10. Core Web Vitals (pasangan kuantitatif UX Heuristic Benchmark)
11. OWASP ASVS 5.0 — keamanan level aplikasi
12. Testing & coverage gate (TDD)
13. Pelindungan data pribadi (UU PDP + PP 33/2026)
14. Twelve-Factor & config hygiene

---

## 📋 Checklist Audit

### □ 1. Security Check

**XSS (Cross-Site Scripting)**
- [ ] Semua user input sudah di-escape di frontend
- [ ] Backend menggunakan prepared statements/ORM (bukan raw query)
- [ ] Output di-react sudah pakai `{}` (React auto-escape)
- [ ] Tidak ada `dangerouslySetInnerHTML` tanpa sanitasi

**SQL Injection**
- [ ] Tidak ada raw SQL queries
- [ ] Semua query menggunakan ORM/Query Builder
- [ ] Parameter binding untuk semua query

**CSRF**
- [ ] CSRF token ada di semua form
- [ ] CSRF middleware aktif untuk semua POST/PUT/DELETE
- [ ] Cookie HTTP-only untuk session

**Authentication**
- [ ] Password di-hash (bcrypt/argon2)
- [ ] Rate limiting di login endpoint
- [ ] Token expiry yang reasonable
- [ ] Logout menghapus token

### □ 2. Performance Test

- [ ] Response time API < 500ms (untuk list data)
- [ ] Pagination untuk data > 50 rows
- [ ] Database query tidak N+1
- [ ] Asset (JS, CSS, image) di-minify
- [ ] Caching untuk data yang jarang berubah
- [ ] Lazy loading untuk komponen berat
- [ ] Core Web Vitals diukur & lulus — lihat **□ 10** di bawah

### □ 3. Code Review

**Backend:**
- [ ] Repository pattern konsisten di semua module
- [ ] Service layer ada business logic (controller hanya routing)
- [ ] Tidak ada logic duplikat
- [ ] Naming convention konsisten
- [ ] Error handling ada di semua endpoint
- [ ] Validation rules lengkap

**Frontend:**
- [ ] Component reusable (tidak copy-paste)
- [ ] State management konsisten
- [ ] Tidak ada commented code
- [ ] Import yang tidak terpakai sudah dihapus
- [ ] API service layer terpusat

### □ 4. UI/UX Consistency

- [ ] Sidebar sama di semua halaman (icon 1 color)
- [ ] Right modal konsisten (400px, slide-in)
- [ ] Warna sesuai palette Sainskerta
- [ ] Typography konsisten
- [ ] Spacing konsisten
- [ ] Button style konsisten
- [ ] Form field style konsisten
- [ ] Ikon proporsional: aksi utama & status pakai ikon, maks 1 ikon/aksi, icon-only punya `aria-label` (UX-08)
- [ ] Dashboard ≥ 2 widget chart/stat; list modul numerik ≥ 1 chart, data dari API (UX-09)
- [ ] Tombol `?` + guided tour bernomor di setiap modul utama (UX-10)
- [ ] i18n: switcher id/en/ja berfungsi, tidak ada string UI hardcoded, key parity antar locale hijau (UX-11, aturan #14)
- [ ] Export DOCX/PDF/XLSX: password opsional → file terenkripsi native, round-trip test hijau ([EXPORT-STANDARDS.md](../standards/EXPORT-STANDARDS.md))

### □ 5. Error Handling

- [ ] 404 page (not found)
- [ ] 500 page (server error)
- [ ] Form validation error messages
- [ ] API error messages (toast/notification)
- [ ] Network error handling
- [ ] Timeout handling

### □ 6. Mobile Responsiveness

Test di viewport:
- [ ] Desktop (1920x1080)
- [ ] Laptop (1366x768)
- [ ] Tablet (768x1024)
- [ ] Mobile (375x667)

Check:
- [ ] Sidebar collapse/hamburger di mobile
- [ ] Right modal full-width di mobile (< 768px)
- [ ] Table horizontal scroll di mobile
- [ ] Font size readable di mobile
- [ ] Touch targets minimal 44px

### □ 7. Database Optimization

- [ ] Index untuk kolom yang sering di-query (search, filter)
- [ ] Index untuk foreign key columns (meskipun tanpa FK constraint)
- [ ] Query tidak N+1 (gunakan eager loading)
- [ ] Pagination dengan cursor/index (bukan offset untuk data besar)
- [ ] Tidak ada query di loop

### □ 8. Code Language Check (English Only)

Aturan: [RULES-OF-THE-GAME.md #15](../RULES-OF-THE-GAME.md#15-code-language-standard--english-only-untuk-kode--wajib).
Berlaku untuk source code aplikasi (identifier, komentar, nama tabel/kolom, commit message) — **bukan** file terjemahan UI.

- [ ] Identifier (variabel, function, class, file, folder) bahasa Inggris
- [ ] Komentar kode bahasa Inggris
- [ ] Nama tabel & kolom database: `snake_case` + kata bahasa Inggris
- [ ] Commit message repo aplikasi bahasa Inggris

**Grep sanity check** (jalankan dari root project aplikasi):

```bash
# Kata Indonesia umum yang sering jadi identifier. Hit = review manual (bisa false positive).
# Catatan: "data" sengaja tidak masuk — itu juga kata bahasa Inggris yang valid.
ID_WORDS='nama|harga|simpan|hapus|tambah|ubah|daftar|pengguna|produk|kategori|jumlah|tanggal|keterangan|alamat|barang|transaksi|laporan|pembayaran|pelanggan|tampil|ambil|hitung|kirim'

grep -rnoiE "[A-Za-z_]*(${ID_WORDS})[A-Za-z_]*" . \
  --include='*.ts' --include='*.tsx' --include='*.js' --include='*.jsx' --include='*.vue' \
  --include='*.svelte' --include='*.php' --include='*.py' --include='*.go' --include='*.sql' \
  --exclude-dir=node_modules --exclude-dir=vendor --exclude-dir=.git --exclude-dir=dist \
  --exclude-dir=locales --exclude-dir=lang \
  && echo "⚠️  Review hit di atas — ganti ke English" || echo "✅ Tidak ada identifier Indonesia umum"

# Nama file/folder
find . -path ./node_modules -prune -o -path ./vendor -prune -o -path ./.git -prune -o \
  -iregex ".*\(${ID_WORDS//|/\\|}\).*" -print

# Commit message
git log --format='%s' | grep -iwE "${ID_WORDS}|perbaikan|tambahkan|perbarui" | head
```

Contoh hit yang harus diganti: `hitungTotalHarga` → `calculateTotalPrice`, `tabel produk.harga` → `products.price`,
`// simpan data produk` → `// save product data`.

### □ 9. Supply-Chain & Dependency Security

Aturan: [RULES-OF-THE-GAME.md #17](../RULES-OF-THE-GAME.md#17-supply-chain--dependency-security--wajib) ·
Detail & perintah: [standards/SUPPLY-CHAIN-SECURITY.md](../standards/SUPPLY-CHAIN-SECURITY.md)

- [ ] SC-01 Tidak ada `^`/`~`/`*`/`latest` di manifest (cek `jq` di standar)
- [ ] SC-02 Lockfile ter-commit; CI pakai `npm ci` / `pnpm install --frozen-lockfile`
- [ ] SC-03 Dependency baru sejak audit terakhir punya catatan Dependency Review
- [ ] SC-04 `npm audit --audit-level=high` + Trivy/Grype bersih (atau exception terdokumentasi); `npm audit signatures` lulus
- [ ] SC-05 Install scripts: hanya allowlist yang ter-review (`npm approve-scripts` / `pnpm ignored-builds`)
- [ ] SC-07 Semua `FROM` di Dockerfile di-pin digest
- [ ] SC-08 Renovate/Dependabot: cooldown + no auto-merge major
- [ ] SC-09 SBOM release ter-generate
- [ ] SC-10 Token CI least-privilege, tidak ada long-lived publish token

### □ 10. Core Web Vitals

Standar: [standards/CORE-WEB-VITALS.md](../standards/CORE-WEB-VITALS.md). Ini **pasangan kuantitatif** dari UX Heuristic Benchmark
([aturan #12](../RULES-OF-THE-GAME.md#12-ux-heuristic-benchmark--9010--wajib), fase 02): heuristic menilai *mudah dipakai*, CWV menilai *cepat & stabil*.

- [ ] **CWV-01** Lighthouse CI (`lhci autorun`) atau PageSpeed Insights API dijalankan untuk login, dashboard, dan ≥ 1 halaman CRUD per module utama — mobile & desktop
- [ ] **CWV-02** LCP ≤ 2.5 s · CLS ≤ 0.1 · TBT ≤ 200 ms (proxy lab) **+** INP ≤ 200 ms dari uji interaksi manual DevTools (buka drawer, submit form, filter, ganti bahasa)
- [ ] **CWV-03** Skor dicatat di Laporan Audit; **halaman yang gagal diperbaiki & diukur ulang sebelum go-live**

### □ 11. OWASP ASVS (Keamanan Aplikasi)

Standar: [standards/OWASP-ASVS.md](../standards/OWASP-ASVS.md) — ASVS **5.0.0**, **L2** default, **L3** untuk module data pribadi spesifik.
Lapisan aplikasi ini **wajib bersama** Cloudflare (edge) — tidak saling menggantikan.

- [ ] Checklist prioritas A–I (auth, session, access control & tenant isolation, input, crypto/secrets, error/logging, file upload, API, dependency) lulus
- [ ] Test otomatis tenant isolation & otorisasi object ada dan hijau
- [ ] SAST (Semgrep/CodeQL) bersih atau exception terdokumentasi
- [ ] OWASP ZAP baseline scan ke staging — tidak ada temuan high
- [ ] Health check / error response tidak membocorkan detail exception

### □ 12. Testing & Coverage Gate (TDD)

Standar: [standards/TESTING-TDD.md](../standards/TESTING-TDD.md)

- [ ] CI hard-fail aktif untuk test gagal & coverage turun; branch protection mewajibkan status check
- [ ] Minimum test per module terpenuhi (unit service, integration CRUD + soft delete/restore, authz, event, regression)
- [ ] Coverage: kritis ≥ 80% line / 70% branch · backend ≥ 70% · frontend ≥ 60% · diff ≥ 80%
- [ ] Tidak ada test di-skip tanpa issue; integration test pakai engine DB production; E2E smoke hijau

### □ 13. Pelindungan Data Pribadi

Standar: [standards/DATA-PROTECTION-ID.md](../standards/DATA-PROTECTION-ID.md) · [aturan #19](../RULES-OF-THE-GAME.md#19-pelindungan-data-pribadi-uu-pdp-272022--pp-332026--wajib)

- [ ] DPIA disetujui (bila skrining Planning = wajib); ROPA mencerminkan kondisi akhir
- [ ] Consent eksplisit per tujuan + penarikan berfungsi (< 3 × 24 jam)
- [ ] Endpoint & UI hak subjek data lulus test (export lengkap, erasure tanpa sisa di tabel turunan & storage)
- [ ] Job `privacy:purge` (hard-delete/anonimisasi) aktif — soft delete saja **tidak** lulus
- [ ] Log tanpa PII mentah; data spesifik terenkripsi kolom
- [ ] Runbook kebocoran data + template notifikasi 3 × 24 jam ke subjek data & Lembaga PDP tersedia

### □ 14. Twelve-Factor & Config Hygiene

Standar: [standards/TWELVE-FACTOR.md](../standards/TWELVE-FACTOR.md)

- [ ] **TF-III:** secret scanning (gitleaks/GitHub) bersih; tidak ada secret/config per-deploy di kode, CI, Dockerfile; `.env.example` lengkap
- [ ] Session/cache/upload tidak bergantung filesystem lokal (bila multi-instance)
- [ ] Build → release → run terpisah; rollback ke release sebelumnya terdokumentasi
- [ ] Migration & script satu kali berupa command di repo

---

## 📋 Output Audit

Setelah audit selesai, buat laporan:

```markdown
## Laporan Audit — [Nama Project]

**Tanggal:** 2026-06-19  
**Auditor:** Sainskerta Loop Workflow

### Summary
- ✅ Security: [pass/warning/fail]
- ✅ Performance: [pass/warning/fail]
- ✅ Code Quality: [pass/warning/fail]
- ✅ UI/UX: [pass/warning/fail]
- ✅ Mobile: [pass/warning/fail]
- ✅ Database: [pass/warning/fail]
- ✅ Code Language (English-only): [pass/warning/fail]
- ✅ Supply Chain: [pass/fail]
- ✅ Core Web Vitals: [pass/fail] (tabel skor per halaman di bawah)
- ✅ OWASP ASVS (L2/L3): [pass/fail]
- ✅ Testing & Coverage: [pass/fail] (coverage: backend __% · frontend __% · kritis __%)
- ✅ Data Pribadi (UU PDP/PP 33): [pass/fail/N/A]
- ✅ Twelve-Factor / TF-III: [pass/fail]

### Core Web Vitals
| Halaman | Device | LCP | TBT | INP (manual) | CLS | Status |
|---------|--------|-----|-----|--------------|-----|--------|

### Issues Found
1. [Issue 1] — [Severity: high/medium/low] — [Status: fixed/open]
2. [Issue 2] — [Severity: high/medium/low] — [Status: fixed/open]

### Rekomendasi
- [Rekomendasi 1]
- [Rekomendasi 2]

### Kesimpulan
- ✅ Siap deploy
- ❌ Perlu perbaikan
```

---

## ✅ Output Fase 05

Setelah fase ini selesai:
- [x] Semua security check pass
- [x] Performance test pass
- [x] Code review selesai
- [x] UI/UX konsisten dengan standar
- [x] Error handling cover semua edge case
- [x] Mobile responsive
- [x] Database optimized
- [x] Code language check (English-only) lulus
- [x] Supply-chain checklist lulus (pass/fail)
- [x] Core Web Vitals lulus di semua halaman yang diukur, skor tercatat
- [x] Checklist OWASP ASVS L2 (L3 untuk data spesifik) lulus
- [x] CI test + coverage gate hijau
- [x] Checklist data pribadi lulus (jika ada data pribadi)
- [x] TF-III & checklist Twelve-Factor lulus
- [x] Laporan audit dibuat
- [x] User sudah review laporan audit

---

## ▶️ Lanjut ke Fase 06

Setelah audit lulus dan user approves laporan, update progress dan lanjut ke [06-DEPLOYMENT.md](06-DEPLOYMENT.md).

---

## 🔗 Referensi

- [RULES-OF-THE-GAME.md](../RULES-OF-THE-GAME.md) — Aturan audit wajib
- [standards/UI-UX-STANDARDS.md](../standards/UI-UX-STANDARDS.md) — Standar UI/UX
- [standards/DATABASE-RULES.md](../standards/DATABASE-RULES.md) — Aturan database
- [standards/SUPPLY-CHAIN-SECURITY.md](../standards/SUPPLY-CHAIN-SECURITY.md) — Gate supply-chain & dependency
- [standards/EXPORT-STANDARDS.md](../standards/EXPORT-STANDARDS.md) — Export dengan password
- [standards/CORE-WEB-VITALS.md](../standards/CORE-WEB-VITALS.md) — LCP, INP, CLS & Lighthouse CI
- [standards/OWASP-ASVS.md](../standards/OWASP-ASVS.md) — Verifikasi keamanan aplikasi
- [standards/TESTING-TDD.md](../standards/TESTING-TDD.md) — TDD & coverage gate
- [standards/DATA-PROTECTION-ID.md](../standards/DATA-PROTECTION-ID.md) — UU PDP & PP 33/2026
- [standards/TWELVE-FACTOR.md](../standards/TWELVE-FACTOR.md) — Config & deploy hygiene
