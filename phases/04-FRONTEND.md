# Fase 04: Frontend Development

> **Fase pembangunan frontend — semua halaman dibuat berdasarkan mockup yang sudah di-approve. Data dari API backend (TIDAK ADA hardcoded dummy data!).**

---

## 🎯 Tujuan

1. Setup frontend project
2. Sidebar layout dengan 1 color icon
3. CRUD pages (list + right modal) untuk setiap fitur
4. Soft delete & restore UI
5. Integrasi dengan backend API (data real!)
6. Form validation
7. Loading & error states
8. i18n (id/en/ja) + language switcher + guided tour "?"
9. Ikon proporsional & data visualization
10. Export dengan password (jika ada fitur export)
11. Core Web Vitals (LCP/INP/CLS) dijaga sejak awal
12. Test komponen & E2E alur kritis (TDD)
13. Halaman "Privasi & Data Saya" (jika ada data pribadi)

---

## 📋 Aturan Frontend

- **WAJIB**: Sidebar dengan icon SVG inline 1 color solid
- **WAJIB**: CRUD in one page (list + right drawer modal)
- **WAJIB**: Modal di kanan (400px, slide-in animation)
- **WAJIB**: Data dari API — TIDAK BOLEH hardcoded
- **WAJIB**: Loading state saat fetch data
- **WAJIB**: Error handling untuk setiap request
- **WAJIB**: Soft delete & restore UI
- **WAJIB**: Mobile responsive
- **WAJIB**: i18n 3 bahasa (id default, en, ja) + language switcher di topbar — tidak ada string UI hardcoded ([aturan #14](../RULES-OF-THE-GAME.md#14-internationalization-i18n--3-bahasa--wajib))
- **WAJIB**: Kode bahasa Inggris (identifier, komentar, nama file/folder) ([aturan #15](../RULES-OF-THE-GAME.md#15-code-language-standard--english-only-untuk-kode--wajib))
- **WAJIB**: Ikon proporsional di list/CRUD & modal + data visualization (dashboard ≥ 2, list numerik ≥ 1) ([aturan #16](../RULES-OF-THE-GAME.md#16-ikon-proporsional--data-visualization--wajib))
- **WAJIB**: Tombol `?` + guided tour driver.js di setiap modul utama ([UX-10](../standards/UI-UX-STANDARDS.md#-guided-tour--bantuan--wajib))
- **WAJIB**: Dialog export dengan password opsional (jika ada fitur export) ([EXPORT-STANDARDS.md](../standards/EXPORT-STANDARDS.md))
- **WAJIB**: Dependency frontend exact-pinned & lolos review ([SUPPLY-CHAIN-SECURITY.md](../standards/SUPPLY-CHAIN-SECURITY.md))
- **WAJIB**: Core Web Vitals — LCP ≤ 2.5 s, INP ≤ 200 ms, CLS ≤ 0.1: reservasi ruang gambar/chart/skeleton, code-splitting library berat, drawer sebagai overlay ([CORE-WEB-VITALS.md](../standards/CORE-WEB-VITALS.md))
- **WAJIB**: Test komponen berlogika (form, drawer, filter, language switcher) + E2E Playwright alur kritis, coverage frontend ≥ 60% (hooks/state ≥ 80%) ([TESTING-TDD.md](../standards/TESTING-TDD.md))
- **WAJIB**: Halaman "Privasi & Data Saya" — unduh data, tarik consent, ajukan koreksi/hapus/keberatan (jika app memproses data pribadi) ([DATA-PROTECTION-ID.md](../standards/DATA-PROTECTION-ID.md))
- **WAJIB**: Hanya env publik (`NEXT_PUBLIC_*` / `VITE_*`) di bundle — tidak ada secret di frontend ([TWELVE-FACTOR.md](../standards/TWELVE-FACTOR.md) TF-III)
- **LARANGAN**: Dummy/hardcoded data untuk development

---

## 📋 Langkah-Langkah

### Langkah 1: Setup Frontend Project

```bash
# React + Vite
cd frontend
npm create vite@latest . -- --template react
npm install axios react-router-dom

# Vue + Vite
npm create vite@latest . -- --template vue
npm install axios vue-router pinia

# Setup Tailwind CSS (rekomendasi)
npm install -D tailwindcss @tailwindcss/vite

# i18n + chart + guided tour (WAJIB) — exact pin (SC-01)
npm config set save-exact true --location=project
npm install i18next react-i18next recharts driver.js     # React
npm install vue-i18n vue-chartjs chart.js driver.js      # Vue
```

Struktur i18n minimal (detail: [UI-UX-STANDARDS.md — i18n](../standards/UI-UX-STANDARDS.md#-internationalization-i18n--3-bahasa-wajib)):

```
src/locales/{id,en,ja}/common.json      # topbar, tombol umum, validasi
src/locales/{id,en,ja}/<module>.json    # label, pesan, chart, tour per modul
```

### Langkah 2: Sidebar Layout dengan 1 Color Icon

**Setiap menu sidebar punya icon SVG inline dengan 1 warna solid.**

```jsx
// Contoh React — Sidebar component
const menuItems = [
  {
    label: 'Dashboard',
    icon: `<svg width="20" height="20" viewBox="0 0 20 20" fill="#3B82F6">
      <path d="M3 3h6v8H3V3zm8 0h6v4h-6V3zm0 6h6v8h-6V9zM3 13h6v4H3v-4z"/>
    </svg>`,
    path: '/'
  },
  {
    label: 'Produk',
    icon: `<svg width="20" height="20" viewBox="0 0 20 20" fill="#10B981">
      <path d="M3 3h14v14H3V3zm2 2v10h10V5H5z"/>
    </svg>`,
    path: '/products'
  },
  {
    label: 'Kategori',
    icon: `<svg width="20" height="20" viewBox="0 0 20 20" fill="#F59E0B">
      <path d="M10 2l8 4v8l-8 4-8-4V6l8-4z"/>
    </svg>`,
    path: '/categories'
  }
];
```

**CSS untuk sidebar:**

```css
.sidebar {
  width: 240px;
  min-height: 100vh;
  background: #1e293b;
  padding: 16px 0;
}

.sidebar-menu-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 10px 20px;
  color: #94a3b8;
  transition: all 0.2s;
}

.sidebar-menu-item:hover {
  background: rgba(255,255,255,0.05);
  color: #ffffff;
  opacity: 0.8;
}

.sidebar-menu-item.active {
  background: rgba(255,255,255,0.1);
  color: #ffffff;
}
```

### Langkah 3: CRUD Pages (List + Right Modal)

**Setiap halaman CRUD terdiri dari:**
1. Header (judul + tombol Tambah)
2. Search bar & filter
3. Table data (dari API, dengan loading state)
4. Right drawer modal (create/edit form)
5. Delete confirmation
6. Trashed items view + restore

**Struktur Component:**

```
pages/
├── Dashboard.jsx
├── products/
│   ├── ProductList.jsx       # List + search + table
│   ├── ProductModal.jsx      # Right drawer modal
│   └── ProductTrashed.jsx    # Deleted items
└── categories/
    ├── CategoryList.jsx
    ├── CategoryModal.jsx
    └── CategoryTrashed.jsx
```

**Contoh Right Modal Component:**

```jsx
// RightDrawerModal.jsx
function RightDrawerModal({ isOpen, onClose, title, children }) {
  if (!isOpen) return null;
  
  return (
    <>
      {/* Backdrop */}
      <div 
        onClick={onClose}
        style={{
          position: 'fixed', inset: 0,
          background: 'rgba(0,0,0,0.5)',
          zIndex: 1000
        }}
      />
      
      {/* Drawer */}
      <div style={{
        position: 'fixed', top: 0, right: 0,
        width: '400px', height: '100vh',
        background: 'white', zIndex: 1001,
        padding: '24px', overflowY: 'auto',
        boxShadow: '-4px 0 12px rgba(0,0,0,0.1)',
        animation: 'slideIn 0.3s ease'
      }}>
        {/* Header */}
        <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 24 }}>
          <h2>{title}</h2>
          <button onClick={onClose} style={{ border: 'none', background: 'none', fontSize: 24, cursor: 'pointer' }}>
            &times;
          </button>
        </div>
        
        {/* Content */}
        {children}
      </div>
      
      <style>{`
        @keyframes slideIn {
          from { transform: translateX(100%); }
          to { transform: translateX(0); }
        }
      `}</style>
    </>
  );
}
```

### Langkah 4: Soft Delete & Restore UI

UI untuk soft delete dan restore:

```jsx
// Di ProductList.jsx — Tombol aksi
function ActionButtons({ product, onEdit, onDelete }) {
  return (
    <div style={{ display: 'flex', gap: 8 }}>
      <button onClick={() => onEdit(product)} className="btn-icon">✏️</button>
      <button onClick={() => onDelete(product)} className="btn-icon">🗑️</button>
    </div>
  );
}

// Tabs: Active / Trashed
function ProductTabs({ activeTab, onTabChange }) {
  return (
    <div style={{ display: 'flex', gap: 0, marginBottom: 16 }}>
      <button 
        onClick={() => onTabChange('active')}
        className={`tab ${activeTab === 'active' ? 'active' : ''}`}
      >
        Aktif
      </button>
      <button 
        onClick={() => onTabChange('trashed')}
        className={`tab ${activeTab === 'trashed' ? 'active' : ''}`}
      >
        Sampah
      </button>
    </div>
  );
}

// Tombol Restore di trashed items
<button onClick={() => handleRestore(item.id)} className="btn-success">
  Pulihkan
</button>
```

### Langkah 5: Integrasi Backend API

**Gunakan service layer untuk API calls — jangan panggil axios langsung di component.**

```javascript
// services/productService.js
import api from './api';

export const productService = {
  getAll(params) {
    return api.get('/products', { params });
  },
  getById(id) {
    return api.get(`/products/${id}`);
  },
  create(data) {
    return api.post('/products', data);
  },
  update(id, data) {
    return api.put(`/products/${id}`, data);
  },
  delete(id) {
    return api.delete(`/products/${id}`);
  },
  getTrashed() {
    return api.get('/products/trashed');
  },
  restore(id) {
    return api.patch(`/products/${id}/restore`);
  }
};
```

### Langkah 6: Form Validation

Validasi di frontend (client-side) + backend validation.

```jsx
function ProductForm({ initialData, onSubmit }) {
  const [form, setForm] = useState({
    name: '', price: '', stock: '', category_id: ''
  });
  const [errors, setErrors] = useState({});
  
  const validate = () => {
    const errs = {};
    if (!form.name.trim()) errs.name = 'Nama produk wajib diisi';
    if (!form.price || form.price <= 0) errs.price = 'Harga harus lebih dari 0';
    if (!form.stock || form.stock < 0) errs.stock = 'Stok tidak valid';
    if (!form.category_id) errs.category_id = 'Pilih kategori';
    return errs;
  };
  
  const handleSubmit = (e) => {
    e.preventDefault();
    const errs = validate();
    if (Object.keys(errs).length > 0) {
      setErrors(errs);
      return;
    }
    onSubmit(form);
  };
  
  return (
    <form onSubmit={handleSubmit}>
      <div className="form-group">
        <label>Nama Produk</label>
        <input
          value={form.name}
          onChange={e => setForm({...form, name: e.target.value})}
          className={errors.name ? 'error' : ''}
        />
        {errors.name && <span className="error-text">{errors.name}</span>}
      </div>
      {/* ... fields lainnya */}
    </form>
  );
}
```

### Langkah 7: Loading & Error States

Setiap halaman harus handle:
- **Loading**: spinner/skeleton saat fetch data
- **Error**: pesan error jika API gagal
- **Empty state**: pesan jika data kosong
- **Success**: toast/notifikasi setelah operasi berhasil

```jsx
function ProductList() {
  const [products, setProducts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  
  useEffect(() => {
    fetchProducts();
  }, []);
  
  const fetchProducts = async () => {
    setLoading(true);
    setError(null);
    try {
      const res = await productService.getAll();
      setProducts(res.data);
    } catch (err) {
      setError('Gagal memuat data produk. Silakan coba lagi.');
    } finally {
      setLoading(false);
    }
  };
  
  if (loading) return <Spinner />;
  if (error) return <ErrorMessage message={error} onRetry={fetchProducts} />;
  
  return (
    <div>
      {/* Table */}
      {products.length === 0 ? (
        <EmptyState message="Belum ada produk. Klik Tambah untuk menambahkan." />
      ) : (
        <table>...</table>
      )}
    </div>
  );
}
```

### Langkah 8: Topbar — Language Switcher & Tombol "?" (i18n + Guided Tour)

Urutan topbar kanan: **language switcher → `?` → avatar**. Semua teks via `t()`.

```jsx
// components/Topbar.jsx — React + react-i18next + driver.js
import { useTranslation } from 'react-i18next';
import { CircleHelp } from 'lucide-react';
import { startPageTour } from '../tours';

const LOCALES = { id: 'Bahasa Indonesia', en: 'English', ja: '日本語' };

export function Topbar({ pageKey }) {
  const { t, i18n } = useTranslation('common');
  return (
    <header className="flex justify-end items-center gap-2 px-6 h-14">
      <select aria-label={t('topbar.language')} value={i18n.language}
              onChange={(e) => i18n.changeLanguage(e.target.value)}>
        {Object.entries(LOCALES).map(([code, label]) => <option key={code} value={code}>{label}</option>)}
      </select>
      <button aria-label={t('topbar.help')} title={t('topbar.help')} className="h-11 w-11"
              onClick={() => startPageTour(pageKey, t)}>
        <CircleHelp size={20} />
      </button>
      {/* avatar */}
    </header>
  );
}
```

- Setiap modul utama mendaftarkan langkah tour (±5) di `src/tours/<module>.js`, target `data-tour="..."`, teks dari `<module>.tour.*`.
- Tambah string baru → **wajib** di `id`, `en`, `ja` sekaligus; CI key-parity harus hijau.

### Langkah 9: Ikon Proporsional & Data Visualization

- Tombol aksi utama = ikon + label (`[+ Tambah]`); aksi per baris boleh icon-only dengan `aria-label` + tooltip. Maks 1 ikon per tombol, tanpa ikon di label field.
- Dashboard: ≥ 2 widget chart/stat; list modul numerik: ≥ 1 chart dari `GET /api/{resource}/stats`.

```jsx
// Recharts — data dari API, bukan dummy
<ResponsiveContainer width="100%" height={240}>
  <BarChart data={stats} aria-label={t('products.chart.stockByCategory')}>
    <XAxis dataKey="category" /><YAxis /><Tooltip />
    <Bar dataKey="stock" fill="#3B82F6" />
  </BarChart>
</ResponsiveContainer>
```

### Langkah 10: Dialog Export dengan Password (jika ada fitur export)

Ikuti [standards/EXPORT-STANDARDS.md](../standards/EXPORT-STANDARDS.md): toggle "Lindungi dengan password" (default OFF),
input `type="password"` + tombol show/hide ber-`aria-label`, password dikirim di body `POST /api/{resource}/export`, tidak disimpan di state global/localStorage.

### Langkah 11: Core Web Vitals sejak Awal (WAJIB)

Detail & teknik: [standards/CORE-WEB-VITALS.md](../standards/CORE-WEB-VITALS.md). Yang diukur formal di Audit, tapi dibangun di sini:
- [ ] Semua `<img>`/chart container punya `width`/`height` atau `aspect-ratio`; skeleton berdimensi sama dengan konten final (CLS)
- [ ] Gambar hero/LCP **tidak** di-lazy-load (`fetchpriority="high"` / Next `priority`); gambar lain `loading="lazy"`, format AVIF/WebP (LCP)
- [ ] Route-based code-splitting; library berat (chart, driver.js, export, rich-text editor) via dynamic `import()` (LCP/INP)
- [ ] Tabel panjang divirtualisasi, search di-debounce, long task dipecah; drawer = overlay `position: fixed` + animasi `transform` (INP/CLS)
- [ ] Ganti bahasa id/en/ja tidak membuat layout melompat (CLS)
- [ ] Cek cepat Lighthouse lokal per halaman baru sebelum PR

### Langkah 12: Test Frontend (WAJIB)

Detail: [standards/TESTING-TDD.md](../standards/TESTING-TDD.md)
- [ ] Logika state/hooks/form ditulis test-first (Vitest + React Testing Library)
- [ ] Setiap komponen berlogika: render + interaksi utama + state loading/error/empty
- [ ] E2E Playwright `@smoke`: login, CRUD satu module utama via right-side drawer (create/edit/soft delete/restore), ganti bahasa
- [ ] CI hard-fail bila test gagal / coverage di bawah threshold `vitest.config.ts`

### Langkah 13: Halaman "Privasi & Data Saya" (WAJIB bila ada data pribadi)

Detail: [standards/DATA-PROTECTION-ID.md](../standards/DATA-PROTECTION-ID.md) §1 & §5
- [ ] Checkbox consent tidak pre-checked, terpisah per tujuan, di signup & pengaturan
- [ ] Toggle tarik consent per tujuan; tombol "Unduh data saya" (JSON/CSV); form koreksi, hapus akun (re-auth), keberatan/pembatasan
- [ ] Status permintaan terlihat oleh user (diterima → diverifikasi → selesai) — semua teks via i18n id/en/ja

---

## ✅ Output Fase 04

Setelah fase ini selesai:
- [x] Sidebar dengan icon 1 color solid untuk semua menu
- [x] Halaman CRUD untuk setiap fitur (list + right modal)
- [x] Soft delete & restore UI berfungsi
- [x] Semua data dari API backend (no hardcoded!)
- [x] Form validation (client + server)
- [x] Loading state di semua halaman
- [x] Error handling untuk setiap request
- [x] Empty state untuk data kosong
- [x] Mobile responsive
- [x] Sesuai dengan mockup yang sudah di-approve
- [x] UI tersedia dalam id (default), en, ja; language switcher di topbar; tidak ada string UI hardcoded
- [x] Identifier, komentar, nama file/folder dalam bahasa Inggris
- [x] Ikon proporsional di list/CRUD & modal; dashboard ≥ 2 chart/stat; list numerik ≥ 1 chart
- [x] Tombol `?` + guided tour bernomor (±5 langkah) di setiap modul utama
- [x] Dialog export dengan password opsional (jika ada fitur export)
- [x] Dependency frontend exact-pinned, lockfile ter-commit
- [x] Teknik Core Web Vitals diterapkan (reservasi ruang, code-splitting, lazy-load non-LCP)
- [x] Test komponen + E2E smoke hijau di CI, coverage frontend memenuhi threshold
- [x] Halaman "Privasi & Data Saya" berfungsi (jika ada data pribadi)

---

## ▶️ Lanjut ke Fase 05

Setelah frontend selesai, update progress dan lanjut ke [05-AUDIT.md](05-AUDIT.md).

---

## 🔗 Referensi

- [standards/UI-UX-STANDARDS.md](../standards/UI-UX-STANDARDS.md) — Standar UI/UX
- [RULES-OF-THE-GAME.md](../RULES-OF-THE-GAME.md) — Aturan sidebar icon, CRUD one page
- [phases/02-WIREFRAME-AUDIT.md](02-WIREFRAME-AUDIT.md) — Mockup yang sudah di-approve
- [standards/EXPORT-STANDARDS.md](../standards/EXPORT-STANDARDS.md) — Export DOCX/PDF/XLSX dengan password
- [standards/SUPPLY-CHAIN-SECURITY.md](../standards/SUPPLY-CHAIN-SECURITY.md) — Pinning & review dependency frontend
- [standards/CORE-WEB-VITALS.md](../standards/CORE-WEB-VITALS.md) — LCP, INP, CLS
- [standards/TESTING-TDD.md](../standards/TESTING-TDD.md) — Test komponen & E2E
- [standards/DATA-PROTECTION-ID.md](../standards/DATA-PROTECTION-ID.md) — UI hak subjek data & consent
