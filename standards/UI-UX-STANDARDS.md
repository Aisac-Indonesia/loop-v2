# UI-UX-STANDARDS.md — Standar UI/UX Sainskerta

> **Standar desain antarmuka Sainskerta. Digunakan untuk semua project. Konsistensi adalah prioritas.**

---

## 🎨 Color Palette Sainskerta

### Primary Colors

| Role | Color | Hex | Penggunaan |
|------|-------|-----|------------|
| Primary | Blue | `#3B82F6` | Tombol utama, link, active state |
| Primary Dark | Blue-700 | `#1D4ED8` | Hover tombol |
| Primary Light | Blue-50 | `#EFF6FF` | Background ringan |
| Secondary | Slate | `#64748B` | Teks sekunder, icon |
| Accent | Emerald | `#10B981` | Sukses, restore, approval |
| Danger | Red | `#EF4444` | Delete, error, warning |
| Warning | Yellow | `#F59E0B` | Peringatan |
| Info | Indigo | `#6366F1` | Informasi |

### Neutral Colors

| Role | Hex | Penggunaan |
|------|-----|------------|
| Background | `#F8FAFC` | Background halaman |
| Card | `#FFFFFF` | Card, modal, form |
| Border | `#E2E8F0` | Border, divider |
| Text Primary | `#0F172A` | Judul, konten utama |
| Text Secondary | `#64748B` | Label, deskripsi |
| Disabled | `#94A3B8` | Tombol/input disabled |
| Sidebar | `#1E293B` | Background sidebar |

### Sidebar Icon Colors (1 Color Solid per Menu)

| Menu | Hex |
|------|-----|
| Dashboard | `#3B82F6` |
| Produk | `#10B981` |
| Kategori | `#F59E0B` |
| Transaksi | `#14B8A6` |
| Laporan | `#8B5CF6` |
| Pengguna | `#EF4444` |
| Pengaturan | `#6B7280` |

---

## 🔤 Typography

### Font Stack
```
font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
```

### Font Sizes

| Element | Size | Weight | Line Height |
|---------|------|--------|-------------|
| H1 | 24px | 700 | 32px |
| H2 | 20px | 600 | 28px |
| H3 | 18px | 600 | 24px |
| Body | 14px | 400 | 20px |
| Small | 12px | 400 | 16px |
| Label | 13px | 500 | 18px |
| Button | 14px | 500 | 20px |

---

## 🧩 Component Library Rekomendasi

| Framework | Recommended Library |
|-----------|-------------------|
| React | [shadcn/ui](https://ui.shadcn.com/) + Tailwind |
| Vue | [shadcn-vue](https://www.shadcn-vue.com/) + Tailwind |
| Vue (alt) | [PrimeVue](https://primevue.org/) |
| Svelte | [shadcn-svelte](https://www.shadcn-svelte.com/) |
| Laravel | [Filament](https://filamentphp.com/) (admin panel) |

### Kenapa shadcn/ui?
- Copy-paste components (bukan dependency berat)
- Fully customizable dengan Tailwind
- Accessible (Radix UI under the hood)
- Dark mode support
- Modern design

---

## 📐 Wireframe → Mockup Flow

### Step 1: Low Fidelity Wireframe (.html)
```
Wireframe-only, grayscale, placeholder boxes
Fokus: layout & flow
Tidak ada: warna, gambar, typography detail
```

### Step 2: Audit dengan User
```
Kirim wireframe ke user → feedback → iterasi
User approve → lanjut ke mockup
```

### Step 3: High Fidelity Mockup (.html)
```
Full color (palette Sainskerta)
Icon SVG inline
Typography proper
Animasi & interaksi
Data placeholder (tapi dari format API beneran)
```

### Step 4: Audit Mockup
```
Kirim mockup ke user → feedback → iterasi
User approve → lanjut coding
```

---

## 🧠 UX Heuristic Benchmark (Mandatory)

> **WAJIB untuk setiap wireframe & mockup.** Tidak ada wireframe/mockup yang boleh ditampilkan ke user
> sebelum lulus gate skor di bawah. Gagal gate → revisi internal → scoring ulang → baru tampilkan.

### Framework A — Nielsen's 10 Usability Heuristics

| ID | Heuristic |
|----|-----------|
| A1 | Visibility of system status |
| A2 | Match between system and the real world |
| A3 | User control and freedom |
| A4 | Consistency and standards |
| A5 | Error prevention |
| A6 | Recognition rather than recall |
| A7 | Flexibility and efficiency of use |
| A8 | Aesthetic and minimalist design |
| A9 | Help users recognize, diagnose, and recover from errors |
| A10 | Help and documentation |

### Framework B — Shneiderman's Eight Golden Rules of Interface Design

| ID | Rule |
|----|------|
| B1 | Strive for consistency |
| B2 | Enable frequent users to use shortcuts |
| B3 | Offer informative feedback |
| B4 | Design dialogs to yield closure |
| B5 | Offer error prevention and simple error handling |
| B6 | Permit easy reversal of actions |
| B7 | Support internal locus of control |
| B8 | Reduce short-term memory load |

### Framework C — Laws of UX (Jon Yablonski)

| ID | Law | Inti |
|----|-----|------|
| C1 | Jakob's Law | User berharap app kita bekerja seperti app lain yang sudah mereka kenal |
| C2 | Fitts's Law | Target makin besar & dekat → makin cepat & akurat diklik |
| C3 | Hick's Law | Makin banyak pilihan → makin lama user memutuskan |
| C4 | Miller's Law | Working memory rata-rata 7±2 item |
| C5 | Aesthetic-Usability Effect | Desain rapi dianggap lebih mudah dipakai |
| C6 | Peak-End Rule | User menilai pengalaman dari puncak & akhirnya |
| C7 | Tesler's Law | Kompleksitas tidak hilang — sistem yang harus menanggungnya, bukan user |
| C8 | Zeigarnik Effect | Task yang belum selesai lebih diingat → tampilkan progress |
| C9 | Doherty Threshold | Respon < 400ms menjaga user tetap "flow" |
| C10 | Postel's Law | Liberal dalam menerima input, konservatif dalam output |
| C11 | Law of Proximity | Elemen yang berdekatan dianggap satu grup |
| C12 | Law of Common Region | Elemen dalam satu area/border dianggap satu grup |
| C13 | Serial Position Effect | Item pertama & terakhir paling diingat |
| C14 | Von Restorff Effect | Item yang beda sendiri paling diingat → pakai untuk CTA utama |

### Rubrik Skor

Setiap item di A, B, C diberi skor:

| Skor | Arti |
|------|------|
| **0** | Tidak ditangani sama sekali |
| **5** | Ditangani sebagian |
| **10** | Ditangani penuh, ada mekanisme konkret & bisa dicek di wireframe/mockup |
| **N/A** | Tidak relevan untuk halaman ini — **wajib tulis alasan**. N/A tanpa alasan = 0 |

```
Rata-rata A = jumlah skor A / jumlah item A yang bukan N/A
Rata-rata B = jumlah skor B / jumlah item B yang bukan N/A
Rata-rata C = jumlah skor C / jumlah item C yang bukan N/A
Overall     = (Rata-rata A + Rata-rata B + Rata-rata C) / 3
```

### 🚦 Gate (WAJIB lulus semua)

- [ ] **Overall ≥ 9.0 / 10**
- [ ] **Tidak ada framework (A, B, atau C) dengan rata-rata < 8.0 / 10** — supaya satu area lemah tidak ketutup rata-rata
- [ ] **Semua aturan konkret UX-01 s/d UX-11 di bawah terpenuhi** — berapa pun skornya

Gagal salah satu → wireframe/mockup **direvisi internal & di-score ulang**. Draft yang gagal gate **TIDAK BOLEH** ditampilkan ke user.

### 📏 Aturan Konkret (WAJIB)

| ID | Aturan | Sumber |
|----|--------|--------|
| **UX-01** | Setiap aksi destruktif / multi-step punya jalan keluar yang terlihat: tombol Batal, Undo, atau `Esc` untuk tutup drawer/modal | A3, B6 |
| **UX-02** | Setiap layar menampilkan konteks lokasi: judul halaman + menu sidebar aktif ter-highlight + breadcrumb (untuk halaman bertingkat) | A6, B8 |
| **UX-03** | *(Anjuran, tidak blocking)* Aksi umum punya keyboard shortcut jika memungkinkan: `/` fokus search, `Esc` tutup drawer, `Ctrl+S`/`Cmd+S` simpan form | A7, B2 |
| **UX-04** | Setiap field form yang tidak trivial & fitur kompleks punya bantuan inline: tooltip, hint text, atau link ke dokumentasi | A10 |
| **UX-05** | Semua elemen interaktif (tombol, icon, menu item) punya area klik/tap minimal **44×44px** | C2 |
| **UX-06** | Aksesibilitas minimal **WCAG 2.1 AA**: kontras teks ≥ 4.5:1, semua elemen interaktif bisa dipakai pakai keyboard (`Tab`/`Enter`/`Esc`), focus ring terlihat, `aria-label` untuk tombol icon-only, HTML semantik | A4, B1 |
| **UX-07** | Navigasi top-level datar **maksimal 9 item**. Lebih dari itu → kelompokkan ke kategori berlabel (collapsible group) atau pindah ke submenu sekunder/Pengaturan | C3, C4 |
| **UX-08** | **Ikon proporsional**: aksi utama (tambah/edit/hapus/restore/export/filter) & status pakai ikon; maks **1 ikon per tombol/aksi**; tidak ada ikon dekoratif di setiap label/field; tombol icon-only wajib `aria-label` + tooltip. Detail: [Ikon Proporsional](#-ikon-proporsional-wajib) | A4, A6, A8, C5 |
| **UX-09** | **Data visualization**: dashboard home ≥ **2 widget chart/stat**; list modul dengan data numerik/agregat ≥ **1 chart** — bukan tabel mentah saja. Detail: [Data Visualization](#-data-visualization-wajib) | A1, A8, C4 |
| **UX-10** | **Guided tour "?"**: setiap modul/halaman utama punya tombol `?` di kanan atas topbar yang menjalankan walkthrough bernomor (±5 langkah). Detail: [Guided Tour](#-guided-tour--bantuan--wajib) | A10, C1 |
| **UX-11** | **Language switcher** (id/en/ja) di topbar; semua teks UI dari file terjemahan. Detail: [Internationalization](#-internationalization-i18n--3-bahasa-wajib) | A2, A4 |

> **Kenapa UX-07?** Project nyata yang dibangun dari keluarga workflow ini pernah rilis dengan **sidebar datar 19 menu** —
> jauh di atas batas 7±2 (Miller's Law) dan bikin user baru lama memilih (Hick's Law). Aturan ini menutup celah itu di level template.

### Template Score Card (per halaman)

```markdown
## UX Score — <Nama Halaman> (wireframe | mockup) — iterasi <n>

| ID | Skor | Bukti / Catatan |
|----|------|-----------------|
| A1 | 10 | Loading skeleton + toast sukses |
| ... | ... | ... |

Rata-rata A: x.x | Rata-rata B: x.x | Rata-rata C: x.x | **Overall: x.x**
UX-01..11: ✅ semua terpenuhi / ❌ <ID yang gagal>
Status gate: ✅ LULUS / ❌ REVISI
```

---

## 🌐 Internationalization (i18n) — 3 Bahasa (WAJIB)

> Aturan mutlak: [RULES-OF-THE-GAME.md #14](../RULES-OF-THE-GAME.md#14-internationalization-i18n--3-bahasa--wajib)

Setiap aplikasi yang di-generate **WAJIB** mendukung 3 bahasa UI:

| Locale | Bahasa | Status |
|--------|--------|--------|
| `id` | Bahasa Indonesia | **Default** + fallback |
| `en` | English | Wajib |
| `ja` | 日本語 (Japanese) | Wajib |

### Library standar per framework

| Framework | Library |
|-----------|---------|
| Next.js (App Router) | [`next-intl`](https://next-intl.dev/) |
| React (Vite/SPA) | [`i18next`](https://www.i18next.com/) + [`react-i18next`](https://react.i18next.com/) |
| Vue / Nuxt | [`vue-i18n`](https://vue-i18n.intlify.dev/) / `@nuxtjs/i18n` |
| Svelte / SvelteKit | [`svelte-i18n`](https://github.com/kaisermann/svelte-i18n) |
| Laravel / Filament | Laravel localization bawaan (`lang/{id,en,ja}/*.php`) |

### Aturan

- **Semua** teks user-facing — label, tombol, pesan, error validasi, tooltip, placeholder, empty state, toast, judul halaman, langkah guided tour, teks dialog export — diambil dari **translation key**. Tidak ada string hardcoded di komponen.
- File terjemahan **per modul/fitur**, satu set per locale:

```
src/locales/
├── id/  common.json  products.json  auth.json
├── en/  common.json  products.json  auth.json
└── ja/  common.json  products.json  auth.json
```

- Key dalam bahasa Inggris, dot-path `camelCase`: `products.form.priceLabel` (bukan `produk.form.labelHarga`) — konsisten dengan [aturan #15](../RULES-OF-THE-GAME.md#15-code-language-standard--english-only-untuk-kode--wajib).
- **Language switcher** di topbar (kanan, sebelum tombol `?` & avatar), label pakai nama bahasa aslinya: `Bahasa Indonesia` · `English` · `日本語`. Pilihan disimpan (cookie/localStorage/profil user) dan dipakai di request berikutnya (`Accept-Language` / prefix URL).
- Format angka, tanggal, mata uang lewat `Intl.*` / helper library i18n sesuai locale — jangan format manual.
- Pesan error dari backend: kirim **error code** (`PRODUCT_NOT_FOUND`), frontend yang menerjemahkan.
- Layout tahan teks panjang/pendek: teks Jepang & Inggris bisa beda panjang jauh — jangan fixed-width tombol; font stack punya fallback CJK (`'Noto Sans JP'`, `'Hiragino Sans'`, `'Yu Gothic'`).
- **Gate merge:** perubahan yang menambah/mengubah string UI di satu bahasa **tanpa** dua bahasa lain = **tidak lengkap & tidak boleh di-merge**. Cek otomatis di CI (key parity antar locale), contoh:

```bash
# Gagal jika key di id/ berbeda dengan en/ atau ja/
for f in src/locales/id/*.json; do
  n=$(basename "$f")
  for l in en ja; do
    diff <(jq -r 'paths(scalars)|join(".")' "$f" | sort) \
         <(jq -r 'paths(scalars)|join(".")' "src/locales/$l/$n" | sort) \
      || { echo "❌ key mismatch: id vs $l/$n"; exit 1; }
  done
done
```

---

## 🎯 Ikon Proporsional (WAJIB)

> Melengkapi aturan sidebar 1 color solid ([RULES-OF-THE-GAME.md #6](../RULES-OF-THE-GAME.md#6-sidebar-dashboard--1-color-icon--wajib)) — gaya ikon sama: SVG inline, monochrome, satu warna solid.

**Wajib pakai ikon** di setiap halaman list/CRUD & modal create/edit untuk:

| Aksi / Elemen | Contoh ikon | Warna (palette) |
|---------------|-------------|-----------------|
| Tambah | `plus` | Primary `#3B82F6` |
| Edit | `pencil` | Secondary `#64748B` |
| Hapus (soft delete) | `trash` | Danger `#EF4444` |
| Restore | `rotate-ccw` | Accent `#10B981` |
| Export | `download` | Secondary `#64748B` |
| Filter | `filter` | Secondary `#64748B` |
| Status (aktif/nonaktif/terhapus) | dot / badge ikon | Sesuai semantik |
| Bantuan | `circle-help` (`?`) | Secondary `#64748B` |

**Proporsional — batas tegas:**
- Ikon **hanya** untuk aksi utama, status, dan navigasi. **Tidak** ada ikon dekoratif di setiap label/field form.
- Maksimal **1 ikon per tombol/aksi**.
- Tombol aksi utama: ikon **+ label teks** (`[+ Tambah]`). Icon-only hanya untuk aksi baris tabel yang berulang (edit/hapus per row) **dan wajib** `aria-label` + tooltip (UX-06).
- Ukuran ikon 16–20px di dalam tombol, area klik tetap ≥ 44×44px (UX-05).
- Satu set ikon per project (mis. [Lucide](https://lucide.dev/) — sudah dipakai shadcn/ui). Jangan campur set ikon.

---

## 📊 Data Visualization (WAJIB)

| Halaman | Minimum |
|---------|---------|
| **Dashboard / Home** | ≥ **2** widget visualisasi (chart dan/atau stat card dengan trend/sparkline) yang merangkum metrik kunci |
| **List modul dengan data numerik/agregat** (transaksi, stok, laporan, dll) | ≥ **1** chart (bar/line/pie/donut) di atas/samping tabel |
| List modul tanpa data numerik (mis. master kategori) | Tidak wajib — tulis alasan N/A di score card |

### Library standar (ringan, sesuai framework)

| Framework | Library |
|-----------|---------|
| React / Next.js | [Recharts](https://recharts.org/) (basis [shadcn/ui charts](https://ui.shadcn.com/charts)) |
| Vue / Nuxt | [`vue-chartjs`](https://vue-chartjs.org/) (Chart.js) |
| Svelte | [Chart.js](https://www.chartjs.org/) |
| Laravel / Filament | Filament Chart Widgets (Chart.js) |

### Aturan
- Data chart dari **API backend** (endpoint agregat, mis. `GET /api/{resource}/stats`) — bukan dummy ([aturan #7](../RULES-OF-THE-GAME.md#7-say-no-to-hardcoded-dummy-data--wajib)).
- Warna series dari palette Sainskerta; jangan hanya mengandalkan warna — sertakan legend/label (WCAG).
- Setiap chart punya loading skeleton, empty state, dan judul + unit (Rp, pcs, %) dari i18n.
- Pilih bentuk sesuai data: tren waktu → line/area; perbandingan kategori → bar; komposisi (≤ 5 kategori) → donut/pie.
- Chart punya alternatif teks (`aria-label` ringkasan atau tabel data tersembunyi untuk screen reader).

---

## 🔒 Export dengan Password (WAJIB jika ada fitur export)

Setiap fitur export ke **DOCX / PDF / XLSX** wajib menawarkan password **opsional**:

- Dialog export punya toggle **"Lindungi dengan password"** (default OFF) + input password dengan tombol show/hide.
- Password kosong = file tidak terproteksi (default). Password diisi = file dienkripsi dengan **enkripsi native format** (OOXML untuk DOCX/XLSX, AES-256 untuk PDF).
- Sheet protection ≠ enkripsi — tidak boleh dipakai sebagai pengganti.

Detail library per stack, API & UI: **[standards/EXPORT-STANDARDS.md](EXPORT-STANDARDS.md)**

---

## ❓ Guided Tour / Bantuan "?" (WAJIB)

Setiap modul/halaman utama punya tombol **`?`** yang menjalankan walkthrough bernomor step-by-step.

### Library standar — semua framework

**[driver.js](https://driverjs.com/)** — framework-agnostic (React/Vue/Svelte/Blade sama), ringan, tanpa dependency.
Satu library untuk semua project supaya pola & tampilan tour konsisten.

### Aturan
- **Posisi konsisten:** kanan atas topbar, di kiri avatar user (urutan topbar kanan: language switcher → `?` → avatar).
- Tombol `?` = ikon + `aria-label` (i18n: "Bantuan halaman ini"), area klik ≥ 44×44px.
- Target **±5 langkah** per halaman (3 untuk halaman sederhana, maks 8 untuk halaman kompleks). Setiap langkah: nomor (`2/5`), highlight elemen, popover singkat.
- Isi tiap langkah = **apa fungsi area ini + aksi yang biasa dilakukan user di sana** (Nielsen A10).
- Teks tour dari file i18n (`{module}.tour.{step}.title`, `...desc`).
- Elemen target pakai `data-tour="products-add"` (bukan class CSS yang bisa berubah).
- Tour bisa di-skip, di-`Esc`, dan diulang kapan saja (UX-01). Auto-start **hanya** saat kunjungan pertama ke modul (flag per user), setelah itu hanya via tombol `?`.

```js
import { driver } from 'driver.js';
import 'driver.js/dist/driver.css';

const tour = driver({
  showProgress: true,               // "2 / 5"
  steps: [
    { element: '[data-tour="products-add"]',    popover: { title: t('products.tour.add.title'),    description: t('products.tour.add.desc') } },
    { element: '[data-tour="products-filter"]', popover: { title: t('products.tour.filter.title'), description: t('products.tour.filter.desc') } },
    { element: '[data-tour="products-chart"]',  popover: { title: t('products.tour.chart.title'),  description: t('products.tour.chart.desc') } },
    { element: '[data-tour="products-table"]',  popover: { title: t('products.tour.table.title'),  description: t('products.tour.table.desc') } },
    { element: '[data-tour="products-trash"]',  popover: { title: t('products.tour.trash.title'),  description: t('products.tour.trash.desc') } },
  ],
});
// Tombol "?" di topbar → tour.drive()
```

---

## ✅ Audit Checklist UI/UX

### Sebelum Coding (Wireframe & Mockup)
- [ ] Layout sesuai dengan requirement
- [ ] Alur navigasi jelas
- [ ] Setiap halaman punya purpose
- [ ] Right modal pattern untuk create/edit
- [ ] Sidebar dengan icon 1 color solid
- [ ] Konsisten: spacing, alignment, hierarchy
- [ ] **UX Heuristic Benchmark lulus gate** (overall ≥ 9.0, tiap framework ≥ 8.0) — lihat section di atas
- [ ] **Aturan UX-01 s/d UX-11 terpenuhi** (termasuk navigasi top-level ≤ 9 item)
- [ ] Ikon proporsional di list/CRUD & modal (UX-08): aksi utama + status pakai ikon, maks 1 ikon/aksi, tanpa ikon dekoratif per field
- [ ] Dashboard ≥ 2 widget chart/stat; list modul numerik ≥ 1 chart (UX-09)
- [ ] Posisi tombol `?` di topbar + daftar langkah tour (±5) direncanakan per halaman (UX-10)
- [ ] Language switcher id/en/ja ada di topbar (UX-11); layout dicek dengan teks `ja` & `en`
- [ ] Dialog export (jika ada) punya toggle password + show/hide ([EXPORT-STANDARDS.md](EXPORT-STANDARDS.md))

### Setelah Coding (Frontend)
- [ ] Semua halaman sesuai mockup
- [ ] Warna konsisten dengan palette
- [ ] Typography konsisten
- [ ] Hover, focus, active states ada
- [ ] Loading state ada untuk setiap fetch
- [ ] Error state ada untuk setiap failure
- [ ] Empty state untuk data kosong
- [ ] Mobile responsive
- [ ] Animasi smooth (300ms untuk modal)
- [ ] Form validation error ditampilkan
- [ ] Tidak ada string UI hardcoded; key id/en/ja lengkap & sinkron (CI key-parity hijau)
- [ ] Chart memakai data dari API + loading/empty state
- [ ] Tombol `?` menjalankan tour driver.js bernomor di setiap modul utama
- [ ] Export terproteksi password bisa dibuka hanya dengan password (round-trip test)

---

## 📱 Responsive Breakpoints

| Device | Width | Notes |
|--------|-------|-------|
| Mobile | < 768px | Sidebar collapse, modal full-width |
| Tablet | 768px - 1024px | Sidebar mini, modal 400px |
| Desktop | > 1024px | Full layout |

---

## 🔗 Referensi

- [RULES-OF-THE-GAME.md](../RULES-OF-THE-GAME.md) — Aturan UI/UX wajib
- [standards/SAINSKERTA-RULES.md](SAINSKERTA-RULES.md) — Detail right modal & sidebar icon
- [phases/02-WIREFRAME-AUDIT.md](../phases/02-WIREFRAME-AUDIT.md) — Proses wireframe & audit
- [phases/04-FRONTEND.md](../phases/04-FRONTEND.md) — Implementasi frontend
- [standards/SECURITY-CLOUDFLARE.md](SECURITY-CLOUDFLARE.md) — Turnstile di form signup/login (dampak ke desain form)
- [standards/EXPORT-STANDARDS.md](EXPORT-STANDARDS.md) — Export DOCX/PDF/XLSX dengan password
- [standards/SUPPLY-CHAIN-SECURITY.md](SUPPLY-CHAIN-SECURITY.md) — Aturan pinning & review untuk library UI (i18n, chart, tour)
