# Fase 03: Backend Development

> **Fase pembangunan backend — semua API endpoint dibuat. Frontend BELUM disentuh. Semua data dari database (tidak ada hardcoded).**

---

## 🎯 Tujuan

1. Migration database
2. Models & relationships (tanpa foreign key constraints)
3. Repository pattern untuk akses data
4. Service layer untuk business logic
5. Controllers dengan CRUD in one page pattern
6. Auth & middleware
7. API documentation

---

## 📋 Aturan Backend

- **WAJIB**: Modular Monolith structure
- **WAJIB**: No foreign key constraints di database
- **WAJIB**: Soft delete (`deleted_at` column)
- **WAJIB**: Timestamps (`created_at`, `updated_at`)
- **WAJIB**: Snake_case untuk database
- **WAJIB**: Repository + Service pattern
- **WAJIB**: API endpoints sesuai spesifikasi
- **WAJIB**: Kode dalam bahasa Inggris — identifier, komentar, nama tabel/kolom (`products.price`, bukan `produk.harga`), commit message ([aturan #15](../RULES-OF-THE-GAME.md#15-code-language-standard--english-only-untuk-kode--wajib))
- **WAJIB**: Error API berupa **error code** (`PRODUCT_NOT_FOUND`) — teks pesan diterjemahkan frontend (i18n id/en/ja, [aturan #14](../RULES-OF-THE-GAME.md#14-internationalization-i18n--3-bahasa--wajib))
- **WAJIB**: Supply-chain gate — exact pin, lockfile, CI scan, install scripts off ([aturan #17](../RULES-OF-THE-GAME.md#17-supply-chain--dependency-security--wajib), [SUPPLY-CHAIN-SECURITY.md](../standards/SUPPLY-CHAIN-SECURITY.md))
- **WAJIB**: Endpoint agregat untuk chart (`GET /api/{resource}/stats`) di modul dengan data numerik ([UX-09](../standards/UI-UX-STANDARDS.md#-data-visualization-wajib))
- **WAJIB**: Endpoint export (jika ada) mendukung password opsional + enkripsi native ([EXPORT-STANDARDS.md](../standards/EXPORT-STANDARDS.md))
- **WAJIB**: Config & secret hanya via env — **TF-III** nol secret/config per-deploy di kode, `.env.example` lengkap, validasi env saat startup ([TWELVE-FACTOR.md](../standards/TWELVE-FACTOR.md))
- **WAJIB**: Keamanan aplikasi OWASP **ASVS 5.0 L2** (L3 untuk module data pribadi spesifik) — terutama otorisasi per object & tenant isolation di repository ([OWASP-ASVS.md](../standards/OWASP-ASVS.md))
- **WAJIB**: TDD untuk logika bisnis (Red → Green → Refactor), minimum test per module, CI hard-fail bila test gagal / coverage turun ([TESTING-TDD.md](../standards/TESTING-TDD.md))
- **WAJIB**: Endpoint hak subjek data + job retensi hard-delete/anonimisasi + tabel consent ([aturan #19](../RULES-OF-THE-GAME.md#19-pelindungan-data-pribadi-uu-pdp-272022--pp-332026--wajib), [DATA-PROTECTION-ID.md](../standards/DATA-PROTECTION-ID.md))
- **WAJIB**: `GET /api/health` + structured JSON logging ([aturan #18](../RULES-OF-THE-GAME.md#18-sre--slo-monitoring--backup-teruji--wajib), [SRE-RELIABILITY.md](../standards/SRE-RELIABILITY.md))
- **LARANGAN**: Hardcoded data di response
- **LARANGAN**: Logic di controller (pindahkan ke service)

---

## 📋 Langkah-Langkah

### Langkah 0: Setup Dependency & CI Supply-Chain (WAJIB)

Sebelum menulis kode, kunci rantai dependency sesuai [standards/SUPPLY-CHAIN-SECURITY.md](../standards/SUPPLY-CHAIN-SECURITY.md):

```bash
npm config set save-exact true --location=project   # SC-01: semua install exact
npm config set ignore-scripts true --location=project   # SC-05 (npm < 12; npm 12+ default off)
git add package.json package-lock.json .npmrc        # SC-02: lockfile di-commit
```

- CI: `npm ci` / `pnpm install --frozen-lockfile` + `npm audit --audit-level=high` + Trivy/Grype (SC-02, SC-04)
- `renovate.json` / `.github/dependabot.yml` dengan cooldown 7 hari & no auto-merge major (SC-08)
- Dockerfile: `FROM image:tag@sha256:<digest>` (SC-07); SBOM di job release (SC-09)
- Setiap dependency baru → isi Dependency Review di PR (SC-03)

### Langkah 1: Migration Database

Buat migration untuk setiap entity.

**Contoh migration MySQL:**

```sql
-- migration_create_users_table.sql
CREATE TABLE users (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role ENUM('admin', 'staff') DEFAULT 'staff',
    deleted_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

**⚠️ Catatan:** Tidak ada `FOREIGN KEY` — referensi ke tabel lain hanya sebagai kolom `bigint` biasa.

### Langkah 2: Models & Relations (Tanpa FK)

Model dengan relasi tanpa foreign key constraint.

**Contoh Laravel:**

```php
// Modules/Product/Models/Product.php
class Product extends Model
{
    use SoftDeletes;
    
    protected $fillable = ['name', 'price', 'stock', 'category_id'];
    
    // Relasi TANPA foreign key — handle di aplikasi
    public function category()
    {
        return $this->belongsTo(Category::class, 'category_id');
    }
}
```

**Contoh Node.js (Sequelize):**

```javascript
// modules/product/models/Product.js
const Product = sequelize.define('Product', {
    name: DataTypes.STRING,
    price: DataTypes.DECIMAL(10,2),
    stock: DataTypes.INTEGER,
    category_id: DataTypes.BIGINT.UNSIGNED, // NO foreign key constraint
    deleted_at: DataTypes.DATE
}, {
    paranoid: true, // soft delete
    underscored: true
});
```

### Langkah 3: Repository Pattern

Repository sebagai satu-satunya akses ke database.

**🧷 DB-Agnostic (WAJIB):** Repository memakai abstraction netral (ORM/query builder).
**JANGAN import driver vendor langsung** (`@vercel/postgres`, `neon`, `pg`, `mysql2`)
di controller/CRUD. Controller/service tidak boleh tahu engine database di belakang —
tukar Postgres/MySQL/SQLite cukup ubah `.env` + provider config, tanpa rombak migration 
& CRUD. Lihat [standards/DATABASE-RULES.md](../standards/DATABASE-RULES.md).

```php
// Modules/Product/Repositories/ProductRepository.php
class ProductRepository
{
    public function getAll(array $filters = [])
    {
        $query = Product::query();
        
        if (!empty($filters['search'])) {
            $query->where('name', 'like', "%{$filters['search']}%");
        }
        
        return $query->paginate($filters['per_page'] ?? 10);
    }
    
    public function getTrashed()
    {
        return Product::onlyTrashed()->paginate(10);
    }
    
    public function findById($id)
    {
        return Product::withTrashed()->findOrFail($id);
    }
    
    public function create(array $data)
    {
        return Product::create($data);
    }
    
    public function update($id, array $data)
    {
        $product = $this->findById($id);
        $product->update($data);
        return $product;
    }
    
    public function softDelete($id)
    {
        $product = $this->findById($id);
        $product->delete(); // soft delete
        return $product;
    }
    
    public function restore($id)
    {
        $product = Product::onlyTrashed()->findOrFail($id);
        $product->restore();
        return $product;
    }
}
```

### Langkah 4: Service Layer

Service untuk business logic.

```php
// Modules/Product/Services/ProductService.php
class ProductService
{
    public function __construct(
        private ProductRepository $repository,
        private CategoryRepository $categoryRepository
    ) {}
    
    public function list(array $filters)
    {
        return $this->repository->getAll($filters);
    }
    
    public function create(array $data)
    {
        // Validasi referensi category ada
        if (!$this->categoryRepository->findById($data['category_id'])) {
            throw new \Exception('Category not found');
        }
        
        return $this->repository->create($data);
    }
    
    public function delete($id)
    {
        $product = $this->repository->softDelete($id);
        
        // Cascade: soft delete related data di app level
        event(new ProductDeleted($product->id));
        
        return $product;
    }
}
```

### Langkah 5: Controllers

Controller dengan pattern CRUD in one page.

```
Endpoint Pattern:
GET    /api/{resource}          → List (with pagination, search, filter)
POST   /api/{resource}          → Create
GET    /api/{resource}/{id}     → Show detail
PUT    /api/{resource}/{id}     → Update
DELETE /api/{resource}/{id}     → Soft delete
GET    /api/{resource}/trashed  → Get deleted items
PATCH  /api/{resource}/{id}/restore → Restore
```

**Contoh Controller (Laravel):**

```php
// Modules/Product/Controllers/ProductController.php
class ProductController extends Controller
{
    public function __construct(private ProductService $service) {}
    
    public function index(Request $request)
    {
        return response()->json([
            'data' => $this->service->list($request->all())
        ]);
    }
    
    public function store(StoreProductRequest $request)
    {
        $product = $this->service->create($request->validated());
        return response()->json(['data' => $product], 201);
    }
    
    public function show($id)
    {
        return response()->json([
            'data' => $this->service->findById($id)
        ]);
    }
    
    public function update(UpdateProductRequest $request, $id)
    {
        $product = $this->service->update($id, $request->validated());
        return response()->json(['data' => $product]);
    }
    
    public function destroy($id)
    {
        $this->service->delete($id);
        return response()->json(['message' => 'Deleted'], 200);
    }
    
    public function trashed()
    {
        return response()->json([
            'data' => $this->service->trashed()
        ]);
    }
    
    public function restore($id)
    {
        $product = $this->service->restore($id);
        return response()->json(['data' => $product]);
    }
}
```

### Langkah 6: Auth & Middleware

```php
// Auth routes
POST /api/auth/login
POST /api/auth/register
POST /api/auth/logout
GET  /api/auth/me
POST /api/auth/refresh

// Middleware untuk semua protected routes
Route::middleware('auth:sanctum')->group(function () {
    Route::apiResource('products', ProductController::class);
    Route::get('products/trashed', [ProductController::class, 'trashed']);
    Route::patch('products/{id}/restore', [ProductController::class, 'restore']);
});
```

### Langkah 6b: Test-Driven Development & CI Gate (WAJIB)

Detail teori & threshold: [standards/TESTING-TDD.md](../standards/TESTING-TDD.md)

- Tulis test **sebelum** kode untuk setiap service method berlogika bisnis: 🔴 red → 🟢 minimal code → 🔵 refactor
- Minimum **per module** (menggantikan angka tetap "9 unit test" dari project sebelumnya — sekarang berskala dengan jumlah module):
  - [ ] ≥ 3 unit test per method service berlogika bisnis (happy + failure + edge)
  - [ ] Integration test CRUD lengkap: list/paginasi, create valid & invalid, update, soft delete, `trashed`, restore
  - [ ] Test otorisasi: user/tenant lain **ditolak** untuk read/update/delete/restore (ASVS-C3)
  - [ ] Test listener untuk setiap event antar module
  - [ ] Regression test untuk setiap bug yang diperbaiki
- Integration test jalan terhadap **engine DB yang sama dengan production** (service container di CI)
- Coverage: logika bisnis kritis ≥ 80% line / 70% branch, backend keseluruhan ≥ 70%, diff coverage PR ≥ 80%
- CI **hard-fail** bila test gagal atau coverage di bawah threshold; branch protection: status check wajib

### Langkah 6c: Keamanan Aplikasi — OWASP ASVS (WAJIB)

Gunakan checklist prioritas [standards/OWASP-ASVS.md](../standards/OWASP-ASVS.md) sebagai *definition of done* per module:
- [ ] Auth (V6): bcrypt/argon2id, cek password bocor, throttle per akun, MFA admin, reset token sekali pakai
- [ ] Session (V7/V9): cookie HttpOnly/Secure/SameSite, regenerate saat login, re-auth aksi sensitif, CSRF
- [ ] Access control (V8): deny-by-default, policy per object, **tenant scope di repository** (karena No-FK), `trashed`/`restore` ikut dicek
- [ ] Input (V1/V2): validasi server-side, query parameterized, aturan bisnis & harga dihitung server, anti-SSRF
- [ ] Crypto/secrets (V11–V13): TF-III, TLS ke DB, enkripsi kolom data spesifik
- [ ] Error/logging (V16): `APP_DEBUG=false`, event keamanan dilog, tanpa PII/secret di log
- [ ] File upload (V5) & API (V4): allowlist + magic bytes, simpan private, pagination max, CORS allowlist

Ini lapisan **aplikasi** — melengkapi, bukan digantikan oleh, Cloudflare di edge ([SECURITY-CLOUDFLARE.md](../standards/SECURITY-CLOUDFLARE.md)).

### Langkah 6d: Pelindungan Data Pribadi — Endpoint & Job (WAJIB bila ada data pribadi)

Detail: [standards/DATA-PROTECTION-ID.md](../standards/DATA-PROTECTION-ID.md)

- [ ] Tabel `consents` (append-only) + `privacy_requests` (dengan `due_at` = 3 × 24 jam & alert)
- [ ] Endpoint hak subjek data:
  - `POST /api/me/data-export` (akses & portabilitas, JSON/CSV, job async + signed URL)
  - `PATCH /api/me` + `POST /api/me/privacy-requests` (`rectification` / `erasure` / `objection` / `restriction`)
  - `DELETE /api/me/consents/{purpose}` (tarik consent → hentikan pemrosesan < 3 × 24 jam)
  - `POST /api/decisions/{id}/human-review` (bila ada keputusan otomatis berdampak)
- [ ] Job terjadwal `privacy:purge` — **hard-delete / anonimisasi** data lewat retensi & soft-deleted lewat grace period
  (soft delete aturan #3 tetap dipakai sebagai jaring pengaman, tapi **bukan** penghapusan kepatuhan); cascade ke tabel
  turunan & file di storage dikerjakan service layer (No-FK); heartbeat ke uptime monitor
- [ ] Enkripsi kolom untuk data spesifik; log event keamanan untuk deteksi kebocoran (PDP-B1)
- [ ] `docs/RETENTION-POLICY.md` & `docs/ROPA.md` diperbarui untuk module baru

### Langkah 6e: Health Check & Structured Logging (WAJIB)

Detail: [standards/SRE-RELIABILITY.md](../standards/SRE-RELIABILITY.md) SRE-01 & SRE-02
- [ ] `GET /api/health` — cek DB (+ Redis/queue), `200`/`503`, sertakan `version` (commit SHA), **tanpa** detail exception
- [ ] Log JSON ke stdout/stderr dengan `request_id`, `route`, `status`, `duration_ms`, `user_id`/`tenant_id` — tanpa secret/PII
- [ ] Error tracking (Sentry) dengan release = commit SHA

### Langkah 7: API Documentation

Dokumentasi API yang jelas untuk frontend developer.

```markdown
## API Endpoints

### Products
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | /api/products | List all (paginated) |
| POST | /api/products | Create new |
| GET | /api/products/{id} | Get detail |
| PUT | /api/products/{id} | Update |
| DELETE | /api/products/{id} | Soft delete |
| GET | /api/products/trashed | List deleted |
| PATCH | /api/products/{id}/restore | Restore |

### Response Format
```json
{
  "data": { ... },
  "message": "optional"
}
```
```

---

## ✅ Output Fase 03

Setelah fase ini selesai:
- [x] Semua migration sudah dibuat dan dijalankan
- [x] Semua model sudah dibuat
- [x] Repository pattern untuk setiap module
- [x] Service layer untuk business logic
- [x] Controller dengan CRUD endpoints lengkap
- [x] Auth & middleware
- [x] API documentation
- [x] Semua endpoint bisa di-test via Postman/curl
- [x] Tidak ada data hardcoded di response
- [x] Identifier, komentar, tabel/kolom dalam bahasa Inggris
- [x] Endpoint stats untuk chart & export (password opsional) tersedia sesuai kebutuhan modul
- [x] Supply-chain baseline aktif (exact pin, lockfile, CI scan, install scripts off, SBOM)
- [x] TF-III: tidak ada secret/config di kode, `.env.example` lengkap ([TWELVE-FACTOR.md](../standards/TWELVE-FACTOR.md))
- [x] Test minimum per module terpenuhi, CI test + coverage gate hijau ([TESTING-TDD.md](../standards/TESTING-TDD.md))
- [x] Checklist ASVS L2 (L3 module data spesifik) terpenuhi ([OWASP-ASVS.md](../standards/OWASP-ASVS.md))
- [x] Endpoint hak subjek data, consent, job retensi `privacy:purge` aktif (jika ada data pribadi) ([DATA-PROTECTION-ID.md](../standards/DATA-PROTECTION-ID.md))
- [x] `/api/health` + structured logging + error tracking aktif ([SRE-RELIABILITY.md](../standards/SRE-RELIABILITY.md))

---

## ▶️ Lanjut ke Fase 04

Setelah backend selesai dan API bisa diakses, update progress dan lanjut ke [04-FRONTEND.md](04-FRONTEND.md).

---

## 🔗 Referensi

- [standards/MODULAR-MONOLITH.md](../standards/MODULAR-MONOLITH.md) — Pattern modular
- [standards/DATABASE-RULES.md](../standards/DATABASE-RULES.md) — Aturan database
- [standards/SUPPLY-CHAIN-SECURITY.md](../standards/SUPPLY-CHAIN-SECURITY.md) — Pinning, lockfile, scan, SBOM
- [standards/EXPORT-STANDARDS.md](../standards/EXPORT-STANDARDS.md) — Enkripsi export DOCX/PDF/XLSX
- [standards/TWELVE-FACTOR.md](../standards/TWELVE-FACTOR.md) — Config via env, stateless, build/release/run
- [standards/TESTING-TDD.md](../standards/TESTING-TDD.md) — TDD, test pyramid, coverage gate
- [standards/OWASP-ASVS.md](../standards/OWASP-ASVS.md) — Keamanan level aplikasi
- [standards/DATA-PROTECTION-ID.md](../standards/DATA-PROTECTION-ID.md) — Hak subjek data, retensi, consent
- [standards/SRE-RELIABILITY.md](../standards/SRE-RELIABILITY.md) — Health check & logging
- [RULES-OF-THE-GAME.md](../RULES-OF-THE-GAME.md) — Aturan soft delete & no FK
