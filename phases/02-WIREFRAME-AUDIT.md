# Fase 02: Wireframe & Audit

> **Fase desain visual — membuat wireframe, audit dengan user, iterasi, upgrade ke mockup, audit lagi, baru coding.**

---

## 🎯 Tujuan

1. Membuat wireframe (low fidelity) untuk semua halaman
2. Menampilkan wireframe ke user untuk feedback
3. Iterasi sampai approve
4. Upgrade wireframe ke mockup (high fidelity)
5. Audit mockup dengan user
6. Baru lanjut coding setelah approve final

---

## 📋 Langkah-Langkah

### Langkah 1: Buat Wireframe .html (Low Fidelity)

Buat wireframe untuk **setiap halaman** dalam format HTML. **Gunakan HTML murni + Tailwind CDN atau CSS minimal.**

**Karakteristik wireframe:**
- Tidak ada gambar/icon detail
- Layout kotak-kotak (placeholder)
- Warna greyscale (abu-abu)
- Fokus: tata letak, alur navigasi, posisi komponen
- Responsive: desktop & mobile

**Halaman yang wajib ada wireframe:**
1. Login page
2. Dashboard (home)
3. Tiap fitur CRUD (list + right modal form)
4. Profile/settings (jika ada)
5. Halaman khusus sesuai requirement

**Contoh wireframe list page:**

```html
<!-- Wireframe: Daftar Produk -->
<div style="display:flex; min-height:100vh;">
  <!-- Sidebar -->
  <div style="width:240px; background:#eee; padding:16px;">
    <div style="height:40px; background:#ddd; margin-bottom:16px;">Logo</div>
    <div style="height:32px; background:#ccc; margin-bottom:8px;">Menu 1</div>
    <div style="height:32px; background:#ccc; margin-bottom:8px;">Menu 2</div>
    <div style="height:32px; background:#999; color:white; margin-bottom:8px;">Menu 3</div>
  </div>
  <!-- Main content -->
  <div style="flex:1; padding:24px;">
    <h2>Daftar Produk</h2>
    <!-- Search & Add -->
    <div style="display:flex; justify-content:space-between; margin:16px 0;">
      <div style="width:300px; height:36px; background:#eee; border-radius:8px;"></div>
      <div style="width:120px; height:36px; background:#007bff; border-radius:8px;"></div>
    </div>
    <!-- Table -->
    <table style="width:100%; border-collapse:collapse;">
      <tr style="background:#f5f5f5;">
        <th style="padding:12px; text-align:left;">Nama</th>
        <th style="padding:12px; text-align:left;">Harga</th>
        <th style="padding:12px; text-align:left;">Stok</th>
        <th style="padding:12px; text-align:left;">Aksi</th>
      </tr>
      <tr><td colspan="4" style="padding:40px; text-align:center; color:#999;">[Data akan muncul dari database]</td></tr>
    </table>
  </div>
</div>
```

**Contoh wireframe right-side modal:**

```html
<!-- Right Modal (Create/Edit) -->
<div id="modal" style="display:none;">
  <div style="position:fixed; inset:0; background:rgba(0,0,0,0.5); z-index:1000;"></div>
  <div style="position:fixed; top:0; right:0; width:400px; height:100vh; background:white; z-index:1001; padding:24px; box-shadow:-4px 0 12px rgba(0,0,0,0.1); animation:slideIn 0.3s;">
    <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:24px;">
      <h3>Tambah Produk</h3>
      <button style="border:none; background:none; font-size:24px;">×</button>
    </div>
    <div style="margin-bottom:16px;">
      <label>Nama Produk</label>
      <div style="height:40px; background:#f5f5f5; border-radius:8px;"></div>
    </div>
    <div style="margin-bottom:16px;">
      <label>Harga</label>
      <div style="height:40px; background:#f5f5f5; border-radius:8px;"></div>
    </div>
    <div style="margin-bottom:16px;">
      <label>Stok</label>
      <div style="height:40px; background:#f5f5f5; border-radius:8px;"></div>
    </div>
  </div>
</div>
```

**Wajib direncanakan di setiap wireframe** (meski masih greyscale/placeholder):

| Item | Yang harus terlihat di wireframe | Aturan |
|------|----------------------------------|--------|
| Topbar kanan | `[ID ▾]` language switcher → `[?]` tombol bantuan → avatar | UX-10, UX-11 |
| Ikon aksi | Placeholder ikon kecil (□) di tombol Tambah/Edit/Hapus/Restore/Export/Filter & badge status — **maks 1 per tombol**, tidak di setiap label field | UX-08 |
| Data viz | Dashboard: ≥ 2 kotak chart/stat (tulis jenisnya: "Bar — penjualan/bulan"). List modul numerik: ≥ 1 kotak chart | UX-09 |
| Export (jika ada) | Dialog export dengan toggle "Lindungi dengan password" + input show/hide | [EXPORT-STANDARDS.md](../standards/EXPORT-STANDARDS.md) |
| Rencana tour | Daftar langkah tour per halaman (±5) di `wireframe/tour-plan.md`: nomor, elemen target (`data-tour="..."`), judul, isi singkat | UX-10 |

```html
<!-- Topbar (kanan) -->
<div style="display:flex; justify-content:flex-end; gap:8px; padding:8px 24px; background:#f5f5f5;">
  <div style="width:72px; height:36px; background:#ddd; border-radius:8px;">ID ▾</div>   <!-- id / en / ja -->
  <div style="width:36px; height:36px; background:#ddd; border-radius:50%;">?</div>      <!-- guided tour -->
  <div style="width:36px; height:36px; background:#bbb; border-radius:50%;"></div>        <!-- avatar -->
</div>
<!-- Dashboard: minimal 2 widget visualisasi -->
<div style="display:grid; grid-template-columns:1fr 1fr; gap:16px;">
  <div style="height:200px; background:#eee;">[Line — pendapatan 12 bulan]</div>
  <div style="height:200px; background:#eee;">[Donut — komposisi kategori]</div>
</div>
```

```markdown
<!-- wireframe/tour-plan.md -->
## Tour — Daftar Produk (5 langkah)
1. `products-add` — Tambah produk: buka form di drawer kanan
2. `products-filter` — Filter & cari: persempit daftar
3. `products-chart` — Grafik stok: lihat tren sekilas
4. `products-table` — Tabel: klik baris untuk edit
5. `products-trash` — Data terhapus: restore data
```

### Langkah 1b: UX Heuristic Self-Score Wireframe (WAJIB)

**Sebelum wireframe ditampilkan ke user**, score setiap halaman pakai
[UX Heuristic Benchmark](../standards/UI-UX-STANDARDS.md#-ux-heuristic-benchmark-mandatory)
(Nielsen 10 + Shneiderman 8 + Laws of UX, rubrik 0/5/10).

1. Isi score card per halaman → simpan di `wireframe/ux-scores.md`
2. Cek gate:
   - Overall **≥ 9.0 / 10**
   - Rata-rata tiap framework (A, B, C) **≥ 8.0 / 10**
   - Aturan konkret **UX-01 s/d UX-11** terpenuhi (navigasi top-level ≤ 9 item, touch target 44×44px, WCAG 2.1 AA, dll)
3. **Gagal gate?** → revisi wireframe secara internal → score ulang → ulangi sampai lulus.
4. **Lulus gate** → baru lanjut ke Langkah 2.

> ⛔ Wireframe yang belum lulus gate **TIDAK BOLEH** ditampilkan ke user.

### Langkah 2: Loop Audit Wireframe

Tampilkan wireframe **yang sudah lulus gate UX** ke user via `user_requirement.md`:

```
## Wireframe Audit

Halo! Berikut wireframe untuk project kamu:

1. **Login Page** — [link ke wireframe/login.html]
2. **Dashboard** — [link ke wireframe/dashboard.html]
3. **Daftar Produk** — [link ke wireframe/products-list.html]
4. **Modal Form Produk** — [link ke wireframe/products-form.html]

Skor UX Heuristic (detail: wireframe/ux-scores.md):
| Halaman | A | B | C | Overall |
|---------|---|---|---|---------|
| Login   | x.x | x.x | x.x | x.x |

Mohon review dan feedbacknya:
- ✅ Approve? Kalau ada yang diubah?
- ❌ Ada yang kurang pas?
- 💡 Ada saran tambahan?
```

### Langkah 3: Iterasi Wireframe

- Jika user minta perubahan, update wireframe
- **Score ulang** (Langkah 1b) — perubahan dari user tetap wajib lulus gate UX
- Tampilkan lagi ke user
- Ulangi sampai user approve SEMUA wireframe

**User harus menulis `APPROVED` di `user_requirement.md`.**

### Langkah 4: Upgrade ke Mockup (High Fidelity)

Setelah wireframe approve, upgrade ke mockup **dengan styling proper**:

- Warna sesuai palet Sainskerta (lihat [UI-UX-STANDARDS.md](../standards/UI-UX-STANDARDS.md))
- Icon SVG inline (1 color solid) — proporsional: aksi utama & status saja, maks 1 ikon per tombol (UX-08)
- Chart nyata (Recharts/Chart.js) di dashboard (≥ 2) & list modul numerik (≥ 1) (UX-09)
- Tombol `?` di topbar menjalankan demo tour sesuai `wireframe/tour-plan.md` (UX-10)
- Language switcher id/en/ja berfungsi minimal untuk 1 halaman contoh; cek layout dengan teks `ja` & `en` (UX-11)
- Typography proper
- Shadow, border-radius, spacing realistis
- Animasi slide-in right modal

**Mockup harus bisa di-interact (klik, hover).**

### Langkah 4b: UX Heuristic Self-Score Mockup (WAJIB)

Sama seperti Langkah 1b, tapi untuk mockup high fidelity. Tambahan cek visual & interaksi:
kontras warna (WCAG 2.1 AA ≥ 4.5:1), focus ring, hover/active state, ukuran tombol 44×44px,
`Esc` menutup drawer, feedback (toast/loading) di setiap aksi.

1. Isi score card per halaman → simpan di `templates/mockup/ux-scores.md`
2. Gate sama: overall ≥ 9.0, tiap framework ≥ 8.0, UX-01..11 terpenuhi
3. Gagal → revisi internal → score ulang. Lulus → lanjut Langkah 5.

> ⛔ Mockup yang belum lulus gate **TIDAK BOLEH** ditampilkan ke user.

### Langkah 5: Audit Mockup

Tampilkan mockup **yang sudah lulus gate UX** ke user (sertakan ringkasan skor dari `templates/mockup/ux-scores.md`):

```
## Mockup Audit

Wireframe sudah di-upgrade ke high fidelity mockup:
1. **Login Page** — [link]
2. **Dashboard** — [link]
3. **Daftar Produk + Modal** — [link]

Cek: apakah warna, layout, dan interaksi sudah sesuai?
```

### Langkah 6: Approve Final

User WAJIB approve mockup sebelum coding dimulai.

**Jika user minta perubahan:** iterasi lagi (dan score ulang — Langkah 4b).

**Jika user approve:** tulis `MOCKUP APPROVED` di `user_requirement.md`.

---

## ✅ Output Fase 02

Setelah fase ini selesai:
- [x] Wireframe semua halaman sudah dibuat
- [x] User sudah review wireframe
- [x] Iterasi wireframe sesuai feedback user
- [x] Wireframe sudah di-approve user
- [x] Mockup high fidelity sudah dibuat
- [x] Mockup sudah di-approve user
- [x] Semua file mockup ada di `templates/mockup/`
- [x] Semua wireframe lulus gate UX Heuristic (skor di `wireframe/ux-scores.md`)
- [x] Semua mockup lulus gate UX Heuristic (skor di `templates/mockup/ux-scores.md`)
- [x] Setiap halaman punya rencana ikon proporsional, data viz, dan posisi tombol `?` + language switcher
- [x] Rencana tour per halaman ada di `wireframe/tour-plan.md`
- [x] Dialog export dengan opsi password ada di mockup (jika project punya fitur export)

---

## ▶️ Lanjut ke Fase 03

Setelah mockup approve, update progress dan lanjut ke [03-BACKEND.md](03-BACKEND.md).

---

## 🔗 Referensi

- [standards/UI-UX-STANDARDS.md](../standards/UI-UX-STANDARDS.md) — Standar UI/UX & color palette
- [RULES-OF-THE-GAME.md](../RULES-OF-THE-GAME.md) — Aturan right-side drawer modal
- [templates/user_requirement.md](../templates/user_requirement.md) — Tempat feedback user
- [standards/UI-UX-STANDARDS.md#-ux-heuristic-benchmark-mandatory](../standards/UI-UX-STANDARDS.md#-ux-heuristic-benchmark-mandatory) — Rubrik & gate skor UX (≥ 9.0)
- [standards/UI-UX-STANDARDS.md#-guided-tour--bantuan--wajib](../standards/UI-UX-STANDARDS.md#-guided-tour--bantuan--wajib) — Guided tour "?", ikon proporsional, data viz, i18n
- [standards/EXPORT-STANDARDS.md](../standards/EXPORT-STANDARDS.md) — Dialog export dengan password
