# CORE-WEB-VITALS.md — Standar Performa Frontend Terukur (LCP, INP, CLS)

> **WAJIB untuk setiap halaman user-facing.** Diukur di [phases/05-AUDIT.md](../phases/05-AUDIT.md)
> (gate sebelum deploy) dan dijaga sejak [phases/04-FRONTEND.md](../phases/04-FRONTEND.md).
>
> **Pasangan kuantitatif dari UX Heuristic Benchmark** (aturan #12,
> [UI-UX-STANDARDS.md](UI-UX-STANDARDS.md#-ux-heuristic-benchmark-mandatory)): heuristic benchmark
> menilai *apakah UI mudah dipakai* (kualitatif, skor rubrik), Core Web Vitals menilai *apakah UI terasa
> cepat dan stabil* (kuantitatif, diukur mesin). Keduanya wajib lulus; skor heuristic 9.5 tidak menolong
> halaman yang butuh 6 detik untuk tampil.

---

## 📏 Tiga Metrik & Target

Core Web Vitals adalah metrik dari Google untuk pengalaman nyata user: **loading**, **responsiveness**,
**visual stability**. Threshold dinilai pada **persentil ke-75** (p75) kunjungan, dipisah mobile & desktop.

| Metrik | Mengukur | ✅ Good (WAJIB) | ⚠️ Needs Improvement | ❌ Poor |
|---|---|---|---|---|
| **LCP** — Largest Contentful Paint | Waktu sampai elemen konten terbesar di viewport (hero image, judul besar, tabel) tampil | **≤ 2.5 s** | 2.5 – 4.0 s | > 4.0 s |
| **INP** — Interaction to Next Paint | Latensi dari interaksi user (klik, tap, ketik) sampai frame berikutnya dirender, diambil dari interaksi terburuk (mendekati) selama kunjungan | **≤ 200 ms** | 200 – 500 ms | > 500 ms |
| **CLS** — Cumulative Layout Shift | Total pergeseran layout tak terduga (skor tanpa satuan, dari *session window* terbesar) | **≤ 0.1** | 0.1 – 0.25 | > 0.25 |

**Catatan INP:** INP **menggantikan FID** (First Input Delay) sebagai Core Web Vital resmi sejak
**12 Maret 2024**. FID hanya mengukur *delay* input **pertama**; INP mengukur latensi penuh
(input delay + processing + presentation delay) dari **seluruh** interaksi — jauh lebih representatif
untuk aplikasi CRUD/dashboard seperti yang kita bangun. **Jangan lagi melaporkan FID.**

Metrik pendukung (diagnostik, bukan gate): **TTFB** (≤ 0.8 s disarankan), **FCP** (≤ 1.8 s), **TBT** di
Lighthouse (proxy lab untuk INP, target < 200 ms).

---

## 🧪 Requirement Pengukuran (WAJIB di Fase Audit)

### CWV-01 — Lighthouse CI atau PageSpeed Insights API
Pilih salah satu (Lighthouse CI direkomendasikan karena masuk pipeline):

**Opsi A — Lighthouse CI (`@lhci/cli`)** dijalankan di CI terhadap build production / preview URL:

```js
// lighthouserc.js
module.exports = {
  ci: {
    collect: {
      url: [
        'http://localhost:3000/login',
        'http://localhost:3000/dashboard',
        'http://localhost:3000/products',   // satu halaman CRUD representatif per module utama
      ],
      numberOfRuns: 3,                     // ambil median, kurangi noise
      settings: { preset: 'desktop' },     // jalankan juga konfigurasi mobile (default Lighthouse = mobile)
    },
    assert: {
      assertions: {
        'largest-contentful-paint': ['error', { maxNumericValue: 2500 }],
        'cumulative-layout-shift':  ['error', { maxNumericValue: 0.1 }],
        'total-blocking-time':      ['error', { maxNumericValue: 200 }], // proxy lab untuk INP
        'categories:performance':   ['warn',  { minScore: 0.9 }],
      },
    },
    upload: { target: 'filesystem', outputDir: './lhci-report' },
  },
};
```
Install dengan exact pin sesuai SC-01 ([SUPPLY-CHAIN-SECURITY.md](SUPPLY-CHAIN-SECURITY.md)).
Halaman di balik login: gunakan script `puppeteerScript` LHCI untuk login dengan **akun test** (credential dari env CI, bukan hardcode).

**Opsi B — PageSpeed Insights API** (untuk URL staging/production publik):
```bash
curl -s "https://www.googleapis.com/pagespeedonline/v5/runPagespeed?url=https://staging.project.com/&strategy=mobile&key=$PSI_API_KEY" \
  | jq '.lighthouseResult.audits["largest-contentful-paint"].numericValue,
        .lighthouseResult.audits["cumulative-layout-shift"].numericValue,
        .loadingExperience.metrics.INTERACTION_TO_NEXT_PAINT.percentile'
```
PSI juga mengembalikan **field data CrUX** (data user nyata) bila situs sudah punya cukup traffic.

### CWV-02 — Lab vs Field
- **INP adalah metrik field** — Lighthouse tidak bisa mengukurnya langsung (tidak ada interaksi nyata);
  gunakan **TBT ≤ 200 ms** sebagai proxy lab di CI, **plus** uji interaksi manual di Chrome DevTools
  Performance panel (rekam: buka drawer, submit form, filter tabel, ganti bahasa) dengan CPU throttling 4×.
- Setelah go-live, pasang **RUM** (Real User Monitoring) dengan library `web-vitals` → kirim ke
  analytics/Sentry/Vercel Speed Insights, agar p75 field data terpantau (lihat [SRE-RELIABILITY.md](SRE-RELIABILITY.md)).

### CWV-03 — Catat Skor & Perbaiki Sebelum Go-Live
- Skor per halaman (mobile & desktop) dicatat di **Laporan Audit** (tabel di bawah).
- **Setiap halaman yang gagal threshold WAJIB diperbaiki sebelum go-live** — bukan dicatat sebagai
  "known issue". Pengecualian hanya dengan persetujuan tertulis user + rencana perbaikan bertanggal.

```markdown
| Halaman | Device | LCP | TBT (proxy INP) | INP manual | CLS | Status |
|---------|--------|-----|-----------------|------------|-----|--------|
| /login | mobile | 1.8 s | 90 ms | 120 ms | 0.00 | ✅ |
| /dashboard | mobile | 2.9 s | 340 ms | 260 ms | 0.18 | ❌ → diperbaiki |
```

---

## 🛠️ Teknik Praktis

### Memperbaiki LCP (≤ 2.5 s)
- **Optimasi gambar:** format modern (AVIF/WebP), ukuran sesuai tampilan (`srcset`/`sizes`), kompresi;
  Next.js `<Image>` atau CDN image resizing (Cloudflare Images/Polish).
- **Elemen LCP jangan di-lazy-load** — gambar hero/above-the-fold diberi `fetchpriority="high"`
  (Next.js `priority`); `loading="lazy"` hanya untuk gambar di bawah fold.
- Preload font utama & aset LCP (`<link rel="preload">`); `font-display: swap`; self-host font / `next/font`.
- TTFB rendah: cache di edge (Cloudflare), query dashboard dioptimasi (index — DATABASE-RULES.md),
  SSR/SSG bila cocok; hindari waterfall request API berantai saat load pertama.
- Hapus CSS/JS render-blocking yang tidak diperlukan di halaman tersebut.

### Memperbaiki INP (≤ 200 ms)
- **Kurangi JS yang memblok main thread:** pecah long task (> 50 ms) — `await` ke `scheduler.yield()`
  / `setTimeout` di loop berat; pindahkan komputasi berat ke Web Worker atau ke server.
- Handler event ringan: update UI dulu (optimistic/loading state), kerja berat setelahnya; React
  `useTransition`/`useDeferredValue` untuk filter/search tabel besar.
- **Virtualisasi** tabel/list panjang (TanStack Virtual) — jangan render 5.000 row di DOM.
- Debounce input pencarian; hindari re-render seluruh halaman saat drawer dibuka (state lokal drawer).
- Batasi script pihak ketiga (chat widget, analytics ganda); muat `defer`/setelah interaksi.

### Memperbaiki CLS (≤ 0.1)
- **Reservasi ruang:** semua `<img>`/`<video>`/`<iframe>` punya `width` & `height` eksplisit atau CSS
  `aspect-ratio`; container chart (Recharts/Chart.js — aturan #16) punya tinggi tetap.
- **Skeleton dengan dimensi sama** dengan konten final untuk tabel, kartu stat, chart (bukan spinner kecil
  yang lalu diganti blok besar).
- Font: `next/font` atau `size-adjust`/`font-display: optional` untuk meminimalkan pergeseran saat font web dimuat;
  perhatikan panjang teks berbeda antar locale `id/en/ja` (aturan #14) — layout tidak boleh melompat saat ganti bahasa.
- Banner/toast/cookie notice **overlay** (position fixed), tidak mendorong konten.
- **Right-side drawer** (aturan #5) dirender sebagai overlay `position: fixed` + animasi `transform` —
  tidak mengubah lebar konten utama; animasi hanya `transform`/`opacity`.

### Code-Splitting
- Route-based splitting (Next.js otomatis; Vite + `React.lazy`/dynamic import per route).
- Komponen berat dimuat saat dibutuhkan: editor rich-text, library chart, `driver.js` (guided tour "?"),
  library export (DOCX/PDF/XLSX) → `import()` saat tombol diklik.
- Pantau ukuran bundle (`next build` output / `rollup-plugin-visualizer`); budget awal: JS initial < 200 KB gzip per route.

---

## ✅ Checklist Core Web Vitals (pass/fail di Audit)

- [ ] **CWV-01** Lighthouse CI / PSI dijalankan untuk login, dashboard, dan ≥ 1 halaman CRUD per module utama — mobile & desktop
- [ ] **CWV-02** LCP ≤ 2.5 s · TBT ≤ 200 ms (lab) **dan** INP ≤ 200 ms (uji manual / field) · CLS ≤ 0.1 untuk semua halaman tersebut
- [ ] **CWV-03** Skor tercatat di Laporan Audit; semua halaman gagal sudah diperbaiki & diukur ulang
- [ ] RUM `web-vitals` terpasang untuk monitoring p75 setelah go-live (anjuran T2, wajib T3 — lihat tier di [SRE-RELIABILITY.md](SRE-RELIABILITY.md))

---

## 🔗 Referensi

- [web.dev — Web Vitals](https://web.dev/articles/vitals) · [LCP](https://web.dev/articles/lcp) · [INP](https://web.dev/articles/inp) · [CLS](https://web.dev/articles/cls)
- [INP menggantikan FID (Maret 2024)](https://web.dev/blog/inp-cwv-march-12)
- [Lighthouse CI](https://github.com/GoogleChrome/lighthouse-ci) · [PageSpeed Insights API](https://developers.google.com/speed/docs/insights/v5/get-started)
- [standards/UI-UX-STANDARDS.md](UI-UX-STANDARDS.md) — UX Heuristic Benchmark (pasangan kualitatif)
- [phases/04-FRONTEND.md](../phases/04-FRONTEND.md) · [phases/05-AUDIT.md](../phases/05-AUDIT.md)
