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
- [ ] **Semua aturan konkret UX-01 s/d UX-07 di bawah terpenuhi** — berapa pun skornya

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
UX-01..07: ✅ semua terpenuhi / ❌ <ID yang gagal>
Status gate: ✅ LULUS / ❌ REVISI
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
- [ ] **Aturan UX-01 s/d UX-07 terpenuhi** (termasuk navigasi top-level ≤ 9 item)

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
