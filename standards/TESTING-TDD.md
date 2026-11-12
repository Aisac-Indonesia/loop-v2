# TESTING-TDD.md — Test-Driven Development, Test Pyramid & Coverage Gate

> **WAJIB untuk setiap project.** Requirement konkret dijalankan di
> [phases/03-BACKEND.md](../phases/03-BACKEND.md) dan [phases/04-FRONTEND.md](../phases/04-FRONTEND.md),
> diverifikasi di [phases/05-AUDIT.md](../phases/05-AUDIT.md), dan ditegakkan otomatis oleh CI.
> Contoh test service & API yang sudah ada: [MODULAR-MONOLITH.md — Testing Strategy](MODULAR-MONOLITH.md#-testing-strategy).

---

## 🧭 Kenapa Formalisasi Ini?

Di riwayat workflow ini sudah ada **preseden "9 unit test"** — satu project menutup fase backend dengan
9 unit test untuk service intinya. Itu langkah baik, tapi angka tetap tanpa aturan punya dua masalah:
**(1)** untuk project kecil bisa berlebihan, untuk project dengan 15 module jelas tidak cukup;
**(2)** tidak ada yang mencegah test itu dilewati — tidak ada gate CI. Dokumen ini mengganti angka tetap
dengan **minimum yang berskala sesuai ukuran project** + **gate CI yang hard-fail**.

---

## 🔴🟢🔵 1. Siklus Red → Green → Refactor

TDD (Kent Beck, *Test-Driven Development: By Example*, 2002) adalah disiplin desain, bukan sekadar
"menulis test". Satu siklus berukuran menit, bukan jam:

1. **🔴 Red** — tulis **satu** test kecil untuk perilaku berikutnya yang belum ada. Jalankan → **harus
   gagal**, dan gagal **karena alasan yang benar** (perilaku belum ada, bukan typo/import salah). Test yang
   tidak pernah terlihat gagal tidak membuktikan apa-apa.
2. **🟢 Green** — tulis **kode minimal** yang membuat test itu lulus. Boleh "jelek" sementara; jangan
   menambah perilaku yang belum dituntut test.
3. **🔵 Refactor** — dengan semua test hijau, rapikan kode **dan test**: hapus duplikasi, perjelas nama,
   ekstrak fungsi, terapkan pola Modular Monolith (service/repository). Test harus tetap hijau setelah tiap langkah.

Ulangi. Urutan perilaku: **happy path → failure path → edge case** (empty/null, batas nilai, unicode
untuk teks id/en/ja, timezone WIB vs UTC, concurrency, permission/tenant lain, data soft-deleted).

**Manfaat yang dicari:** desain API yang lebih bersih (test adalah klien pertama kode), cakupan perilaku
yang lahir bersama kode, dan *safety net* untuk refactor & upgrade dependency (SC-08 Renovate/Dependabot).

**Pragmatis:** TDD ketat **wajib** untuk logika bisnis (service layer, perhitungan uang/stok/kuota, aturan
otorisasi, job retensi data). Untuk scaffolding UI murni, boleh *test-after* selama test ditulis di PR yang sama.
Untuk bug fix: **wajib** tulis test yang mereproduksi bug (red) sebelum memperbaikinya.

---

## 🔺 2. Test Pyramid

```
            /\        E2E (~10%)  — alur user kritis lewat browser (Playwright)
           /  \
          /----\      Integration (~20%) — API endpoint + DB nyata, antar module via event
         /      \
        /--------\    Unit (~70%) — service, helper, validator, komponen murni; cepat, tanpa I/O
```

| Lapis | Target rasio (pedoman) | Apa yang diuji | Tool di stack kita | Kecepatan |
|---|---|---|---|---|
| **Unit** | ~70% | Service layer, aturan bisnis, value object, util, hook/komponen React murni | PHPUnit/Pest, Vitest/Jest, React Testing Library | ms per test |
| **Integration** | ~20% | Endpoint API (status, response shape), repository ↔ DB engine target, soft delete/restore, tenant isolation, event antar module, job queue | PHPUnit `RefreshDatabase` + DB service container, Supertest | detik |
| **E2E** | ~10% | Alur kritis end-to-end: login, CRUD satu module via right-side drawer, ganti bahasa, export, permintaan hak subjek data | Playwright | detik–menit |

**Ini pedoman, bukan hukum.** Rasio 70/20/10 adalah titik awal — app yang dominan CRUD dengan sedikit
logika bisnis wajar punya porsi integration lebih besar. Yang dihindari adalah **"ice cream cone"**
(kebanyakan E2E lambat & rapuh, sedikit unit test) — itu yang membuat CI 30 menit dan test sering di-skip.

Aturan tambahan:
- Integration test yang menjadi gate deploy berjalan terhadap **engine DB yang sama dengan production**
  (Twelve-Factor X — [TWELVE-FACTOR.md](TWELVE-FACTOR.md#x-devprod-parity--keep-development-staging-and-production-as-similar-as-possible)).
- Test **deterministik**: tanpa ketergantungan jam nyata (freeze time), urutan, atau network eksternal
  (mock/fake HTTP untuk payment, AI provider, email).
- Test data dari factory/fixture **dummy** — tidak pernah data pribadi production
  ([DATA-PROTECTION-ID.md](DATA-PROTECTION-ID.md)); sesuai aturan #7, data dummy hanya di test/seeder, tidak di UI.

---

## 📊 3. Coverage — Target & Kenapa Bukan 100%

### Target WAJIB
| Cakupan | Minimum line/branch coverage |
|---|---|
| **Logika bisnis kritis** — service layer, perhitungan uang/stok/kuota, policy/otorisasi, validasi, job retensi & penghapusan data pribadi | **≥ 80% line, ≥ 70% branch** |
| Keseluruhan codebase backend | ≥ 70% line |
| Keseluruhan frontend | ≥ 60% line (komponen presentational murni boleh rendah; hooks/state/form logic ≥ 80%) |
| Kode baru di setiap PR (*diff coverage*) | ≥ 80% |

Threshold ditulis di config (`phpunit.xml` / `vitest.config.ts` `coverage.thresholds`) dan **hanya boleh naik**
(*ratchet*) — menurunkan threshold butuh persetujuan tertulis di PR.

### Kenapa mandat 100% bukan tujuan
- **Coverage mengukur baris yang dieksekusi, bukan perilaku yang diverifikasi.** Test tanpa assertion
  yang bermakna bisa memberi 100% coverage dan tidak menangkap bug apa pun.
- **Hukum Goodhart:** ketika angka jadi target, orang mengoptimalkan angkanya — test untuk getter/setter,
  konfigurasi framework, dan kode generated — sementara edge case penting tetap kosong.
- **Diminishing returns:** 20% terakhir biasanya kode glue, error handler framework, dan cabang defensif
  yang mahal diuji dan jarang salah; biaya maintenance test-nya melebihi nilai yang didapat.
- **Test rapuh memperlambat refactor** — test yang mengunci detail implementasi (bukan perilaku) demi coverage
  membuat setiap perubahan internal memecahkan puluhan test.

**Yang benar-benar dicari: kualitas test yang bermakna.** Ukuran kualitas yang dipakai di review:
- Setiap test punya assertion terhadap **perilaku yang terlihat** (output, state DB, event yang di-dispatch, response API).
- Ada test untuk **failure path & edge case**, bukan hanya happy path.
- Test gagal bila logikanya rusak — verifikasi berkala dengan **mutation testing** pada module kritis
  (Infection untuk PHP, Stryker untuk JS/TS; anjuran mutation score ≥ 60% di service kritis).
- Test dibaca seperti spesifikasi (`test_cannot_restore_product_of_another_tenant`).

---

## 📏 4. Minimum Test yang Berskala (Pengganti Angka Tetap "9 Unit Test")

Minimum **per module** (Modular Monolith) — total project otomatis berskala sesuai jumlah module:

| Untuk setiap... | Minimum |
|---|---|
| **Method publik service** dengan logika bisnis | 1 happy path + 1 failure path + edge case relevan (≥ 3 unit test) |
| **Resource CRUD** (aturan #4) | Integration test: list (paginasi), create (valid & invalid), update, soft delete, `trashed`, restore (aturan #3) |
| **Policy/otorisasi** | Test "tenant/user lain ditolak" untuk read, update, delete, restore (ASVS-C3 — [OWASP-ASVS.md](OWASP-ASVS.md)) |
| **Event antar module** | 1 test listener bereaksi benar terhadap event |
| **Bug yang diperbaiki** | 1 regression test yang gagal sebelum fix |
| **Endpoint hak subjek data & job retensi** | Export lengkap; erasure tanpa sisa di tabel turunan (PDP-S5, PDP-R3) |
| **Komponen frontend dengan logika** (form, drawer, filter, language switcher) | Render + interaksi utama + state error/loading |
| **Alur kritis app** | 1 E2E Playwright per alur (minimal: login, CRUD 1 module utama, ganti bahasa) |

Patokan kasar: project kecil (≤ 3 module) biasanya berakhir di **± 30–60 test**, project menengah (4–10 module)
**± 100–250 test**. Angka ini **hasil**, bukan target — yang diaudit adalah tabel minimum di atas.

---

## 🚦 5. CI Gate — Hard Fail

CI (GitHub Actions) **WAJIB gagal** — dan PR tidak boleh di-merge (branch protection: required status checks) — bila:
1. Ada test yang gagal (unit, integration, atau E2E smoke);
2. Coverage turun di bawah threshold yang disepakati (keseluruhan, kritis, atau diff coverage);
3. Lint/typecheck gagal.

```yaml
# .github/workflows/test.yml (cuplikan) — action dipin by commit SHA sesuai SC-01/SC-07
jobs:
  backend:
    runs-on: ubuntu-latest
    services:
      postgres:            # engine sama dengan production (Twelve-Factor X)
        image: postgres:16@sha256:<digest>
        env: { POSTGRES_PASSWORD: test, POSTGRES_DB: app_test }
        ports: ['5432:5432']
    steps:
      - uses: actions/checkout@<sha>
      - run: composer install --no-interaction --prefer-dist
      - run: php artisan test --coverage --min=70          # gagal bila < 70%
  frontend:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@<sha>
      - run: npm ci
      - run: npm run lint && npm run typecheck
      - run: npx vitest run --coverage                     # thresholds di vitest.config.ts → exit != 0 bila turun
      - run: npx playwright install --with-deps && npx playwright test --grep @smoke
```

```ts
// vitest.config.ts (cuplikan)
test: { coverage: { provider: 'v8', thresholds: { lines: 60, branches: 60,
  'src/**/hooks/**': { lines: 80 }, 'src/**/services/**': { lines: 80, branches: 70 } } } }
```

**Dilarang:** `--passWithNoTests` di pipeline utama, `test.skip`/`markTestSkipped` tanpa issue terlink,
`continue-on-error: true` pada job test, menurunkan threshold diam-diam.

---

## ✅ Checklist Testing (Backend, Frontend, Audit)

- [ ] Logika bisnis ditulis dengan siklus Red-Green-Refactor; bug fix diawali regression test
- [ ] Minimum per module (§4) terpenuhi
- [ ] Rasio pyramid wajar (tidak ice cream cone); integration test pakai engine DB production
- [ ] Coverage kritis ≥ 80% line / 70% branch; backend ≥ 70%; frontend ≥ 60%; diff coverage ≥ 80%
- [ ] CI hard-fail untuk test gagal & coverage turun; branch protection aktif
- [ ] Tidak ada test yang di-skip tanpa issue; test deterministik & tanpa data pribadi asli

---

## 🔗 Referensi

- [standards/MODULAR-MONOLITH.md](MODULAR-MONOLITH.md#-testing-strategy) — Contoh unit & integration test
- [standards/OWASP-ASVS.md](OWASP-ASVS.md) — Test tenant isolation & otorisasi
- [standards/DATA-PROTECTION-ID.md](DATA-PROTECTION-ID.md) — Test hak subjek data & retensi
- [standards/TWELVE-FACTOR.md](TWELVE-FACTOR.md) — Faktor V (build gate) & X (parity)
- [phases/03-BACKEND.md](../phases/03-BACKEND.md) · [phases/04-FRONTEND.md](../phases/04-FRONTEND.md) · [phases/05-AUDIT.md](../phases/05-AUDIT.md)
- Kent Beck, *Test-Driven Development: By Example* (2002) · Martin Fowler, [Test Pyramid](https://martinfowler.com/bliki/TestPyramid.html) · [Test Coverage](https://martinfowler.com/bliki/TestCoverage.html)
