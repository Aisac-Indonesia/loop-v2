# TWELVE-FACTOR.md — The Twelve-Factor App (Teori Lengkap + Rekonsiliasi dengan Aturan Sainskerta)

> **Status:** Standar WAJIB untuk cara aplikasi di-build, dikonfigurasi, di-deploy, dan dijalankan.
> Twelve-Factor adalah metodologi dari tim Heroku (Adam Wiggins, 2011) untuk membangun
> *software-as-a-service* yang portabel, mudah di-deploy ke cloud modern, minim perbedaan
> dev/prod, dan bisa di-scale tanpa ubah arsitektur. Sumber primer: <https://12factor.net>.
>
> Dokumen ini menulis **ke-12 faktor secara penuh** (bukan ringkasan), masing-masing dengan:
> **(a)** definisi/prinsip asli, dan **(b)** "Penerapan di stack kita" — konkret untuk stack
> Sainskerta (Laravel / Node.js / Next.js / React + Vite, Postgres/MySQL, deploy ke Vercel,
> VPS, Hostinger/Domainesia, cloud).
>
> Di bagian akhir ada **Rekonsiliasi Eksplisit** yang menunjukkan bahwa aturan mutlak
> Sainskerta (Modular Monolith, No-FK, Soft Delete, `.env`, Right-Side Drawer / CRUD in One Page)
> **kompatibel** dengan Twelve-Factor — tidak ada konflik.

---

## 🧭 Kenapa Twelve-Factor?

Twelve-Factor menjawab tiga masalah klasik aplikasi web:

1. **Erosi software** — aplikasi yang jalan di laptop developer tapi rusak di server, atau
   server yang "dirawat tangan" sampai tidak ada yang berani menyentuhnya.
2. **Portabilitas** — kontrak bersih antara aplikasi dan sistem operasi/platform di bawahnya,
   sehingga bisa pindah Vercel → VPS → cloud tanpa tulis ulang kode.
3. **Skalabilitas & kolaborasi** — developer baru bisa setup dalam menit, aplikasi bisa
   di-scale horizontal tanpa perubahan tooling/arsitektur.

Ini sejalan langsung dengan aturan fleksibilitas deployment yang sudah ada di
[DATABASE-RULES.md](DATABASE-RULES.md#-standar-fleksibilitas-database--migration-wajib) dan
[phases/06-DEPLOYMENT.md](../phases/06-DEPLOYMENT.md): *"bisa deploy di Vercel ATAU di luar
Vercel tanpa ubah kode"*. Twelve-Factor adalah teori formal di balik aturan itu.

---

## I. Codebase — *One codebase tracked in revision control, many deploys*

### (a) Definisi / Prinsip Asli
Aplikasi twelve-factor **selalu** dilacak di version control (Git). Ada korelasi **satu-ke-satu**
antara *codebase* (satu repo, atau sekumpulan repo yang berbagi root commit) dan *app*:

- Kalau ada **banyak codebase**, itu bukan *app* — itu *distributed system*; tiap komponennya
  adalah app yang masing-masing harus mematuhi twelve-factor.
- Kalau **banyak app berbagi satu kode yang sama**, itu pelanggaran — kode bersama harus
  difaktorkan menjadi library yang di-include lewat dependency manager (Faktor II).
- Satu codebase punya **banyak deploy**: production, staging, dan setiap salinan lokal
  developer. Tiap deploy bisa berada di commit berbeda (staging di depan production),
  tetapi **codebase-nya sama**.

### (b) Penerapan di Stack Kita
- **Satu repo Git per project** (aturan anjuran #21 "Git Wajib" → di sini dinaikkan konteksnya:
  satu repo = satu app). Backend + frontend boleh di satu repo (monorepo `backend/` + `frontend/`)
  selama dideploy sebagai satu sistem yang versinya bergerak bersama.
- **Satu codebase → banyak deploy:** `local` (laptop dev), `staging` (preview Vercel / subdomain
  staging di VPS), `production`. Perbedaan antar deploy **hanya** di config (Faktor III), bukan di kode.
- **Tidak boleh** ada "versi khusus klien A" sebagai fork/copy repo. Variasi per klien = config
  atau feature flag, bukan cabang kode yang menyimpang permanen.
- Kode yang dipakai lintas project Sainskerta (mis. helper export, komponen drawer) → jadikan
  **paket internal** yang di-publish & di-pin (lihat [SUPPLY-CHAIN-SECURITY.md](SUPPLY-CHAIN-SECURITY.md) SC-06),
  bukan copy-paste antar repo.

---

## II. Dependencies — *Explicitly declare and isolate dependencies*

### (a) Definisi / Prinsip Asli
Aplikasi twelve-factor **tidak pernah** bergantung pada keberadaan implisit paket di level
sistem. Semua dependency **dideklarasikan** lengkap dan persis lewat *dependency declaration
manifest*, dan **diisolasi** lewat *dependency isolation tool* agar tidak ada dependency
implisit yang "bocor" dari sistem sekitarnya. Deklarasi + isolasi harus dipakai **bersamaan**.
Aplikasi juga tidak boleh bergantung pada tool sistem implisit (mis. `curl`, `ImageMagick`) —
kalau butuh, tool itu di-*vendor* atau dideklarasikan. Manfaatnya: developer baru cukup
clone + satu perintah build deterministik untuk menyiapkan semuanya.

### (b) Penerapan di Stack Kita
- **Manifest:** `package.json` (Node/React/Next), `composer.json` (Laravel).
- **Lockfile wajib di-commit** dan dipakai dengan install beku: `npm ci` / `pnpm install --frozen-lockfile`
  / `composer install --no-dev` di production. Ini sudah aturan mutlak #17 →
  [SUPPLY-CHAIN-SECURITY.md](SUPPLY-CHAIN-SECURITY.md) SC-01 (exact pin) & SC-02 (lockfile).
- **Isolasi:** `node_modules/` & `vendor/` per project (tidak pakai paket global); runtime
  dipin di `.nvmrc` / `engines` / `"php": "x.y.*"` di `composer.json`; Docker image dipin by digest (SC-07).
- Tool sistem yang dibutuhkan (mis. `mysqldump` untuk backup, `chromium` untuk export PDF)
  **dicatat di README project** + di Dockerfile bila memakai container — tidak boleh "kebetulan
  ada di server".

---

## III. Config — *Store config in the environment*

### (a) Definisi / Prinsip Asli
*Config* adalah segala hal yang **berbeda antar deploy**: handle ke database/cache/backing
service lain, credential layanan eksternal (S3, payment gateway, AI provider), nilai per-deploy
seperti hostname kanonik. Twelve-factor menuntut **pemisahan ketat config dari kode** — config
berubah antar deploy, kode tidak. Tes lakmusnya: *"Apakah codebase bisa di-open-source-kan
sekarang juga tanpa membocorkan satu pun credential?"* Config disimpan di **environment
variables** — mudah diganti antar deploy tanpa ubah kode, kecil peluang ter-commit, dan
agnostik bahasa/OS. Env vars bersifat granular dan ortogonal satu sama lain, **bukan**
dikelompokkan menjadi "environment bernama" (`development`, `production`, …) yang meledak
kombinasinya ketika jumlah deploy bertambah. Catatan: config **internal** aplikasi yang sama
di semua deploy (mis. routing, wiring module) **bukan** config dalam arti ini dan boleh tetap di kode.

### (b) Penerapan di Stack Kita — **DIFORMALKAN SEBAGAI HARD REQUIREMENT**
Selama ini `.env` sudah dipakai secara informal (DATABASE-RULES.md §1 & §4, Turnstile key di
SECURITY-CLOUDFLARE.md). Mulai sekarang ini **aturan keras**:

> **🔒 TF-III (WAJIB): Tidak ada secret atau config per-deploy yang di-hardcode di kode yang
> di-commit — di mana pun, tanpa pengecualian.** Ini mencakup source code, migration, seeder,
> test fixture, Dockerfile, `docker-compose.yml`, file CI, `next.config.*`, `vite.config.*`,
> dan dokumentasi contoh yang berisi nilai asli.

Aturan turunan:
1. Semua secret & config per-deploy dibaca dari env (`process.env.X`, `env('X')` di
   `config/*.php` Laravel — **jangan** panggil `env()` langsung di luar `config/`, karena
   `config:cache` akan membuatnya `null`).
2. **`.env` tidak pernah di-commit** — `.gitignore` wajib berisi `.env`, `.env.*` (kecuali `.env.example`).
3. **`.env.example` wajib di-commit** berisi semua key dengan nilai dummy/kosong + komentar. Ini
   adalah *kontrak config* app.
4. **Validasi config saat startup** (fail fast): app menolak start bila env wajib kosong/invalid
   (mis. `zod`/`envalid` di Node, `config` + assertion di service provider Laravel).
5. **Frontend:** hanya variabel yang memang publik yang boleh diberi prefix `NEXT_PUBLIC_` /
   `VITE_` — semua yang ber-prefix itu ter-*bundle* ke browser, jadi **tidak boleh secret**.
6. Production: env diset di dashboard platform (Vercel Environment Variables), di `.env` server
   VPS dengan permission `600`, atau secret manager — tidak pernah di repo.
7. **Secret scanning** di CI (mis. `gitleaks`/GitHub secret scanning push protection) — lihat
   [SUPPLY-CHAIN-SECURITY.md](SUPPLY-CHAIN-SECURITY.md) SC-10. Secret yang terlanjur ter-commit
   = **rotasi segera**, menghapus dari history saja tidak cukup.
8. Nilai yang benar-benar konstan di semua deploy (mis. jumlah item per halaman default, daftar
   locale `id/en/ja`) **boleh** di kode — itu bukan config per-deploy.

---

## IV. Backing Services — *Treat backing services as attached resources*

### (a) Definisi / Prinsip Asli
*Backing service* adalah layanan apa pun yang dikonsumsi app lewat jaringan sebagai bagian
operasi normal: datastore (Postgres, MySQL), cache (Redis, Memcached), message queue
(RabbitMQ, SQS), SMTP, object storage (S3), API pihak ketiga (payment, maps, AI provider).
Twelve-factor **tidak membedakan** layanan lokal vs pihak ketiga — keduanya adalah *attached
resource* yang diakses lewat URL/credential di config (Faktor III). Sebuah deploy harus bisa
**menukar** database MySQL lokal dengan yang dikelola pihak ketiga (mis. Amazon RDS) **tanpa
perubahan kode** — cukup ganti resource handle di config. Resource bisa di-*attach* dan
di-*detach* sesuka hati (mis. DB rusak → attach DB baru dari backup, tanpa ubah kode).

### (b) Penerapan di Stack Kita
- DB, Redis, SMTP, storage (S3/R2/local disk), AI provider, payment gateway — **semua** diakses
  lewat env (`DATABASE_URL`/`DB_*`, `REDIS_URL`, `MAIL_*`, `FILESYSTEM_DISK` + `AWS_*`,
  `AI_PROVIDER` + key — lihat [AI-PROVIDERS.md](AI-PROVIDERS.md)).
- **Swap tanpa ubah kode adalah kriteria lulus**, bukan aspirasi: Neon ↔ Supabase ↔ Postgres
  hosting ↔ MySQL cPanel cukup ganti `.env` (DATABASE-RULES.md §1–§5).
- Kode memanggil backing service **lewat abstraksi** (Repository Layer untuk DB, Laravel
  `Storage`/`Mail`/`Cache` facade, adapter AI provider) — tidak ada SDK vendor yang bocor ke
  service/controller.
- Lihat rekonsiliasi No-FK + soft delete ↔ Faktor IV di bagian akhir.

---

## V. Build, Release, Run — *Strictly separate build and run stages*

### (a) Definisi / Prinsip Asli
Codebase diubah menjadi deploy melalui **tiga tahap terpisah**:
1. **Build** — mengubah kode di satu commit menjadi *executable bundle*: fetch & vendor
   dependency, compile binary & aset.
2. **Release** — menggabungkan hasil build dengan **config** deploy saat ini → siap dieksekusi.
3. **Run (runtime)** — menjalankan app di environment eksekusi dengan meluncurkan sekumpulan proses.

Pemisahannya **ketat**: tidak boleh mengubah kode saat runtime (karena tidak bisa dipropagasi
balik ke tahap build). Setiap release punya **ID unik** (timestamp / nomor versi / commit SHA)
dan bersifat **immutable** — perubahan apa pun = release baru. Ini memungkinkan **rollback**
ke release sebelumnya. Build dipicu developer (saat ada kode baru); run bisa terjadi otomatis
(restart server, proses crash di-restart), maka tahap run harus sesederhana mungkin.

### (b) Penerapan di Stack Kita
- **Build:** CI (GitHub Actions) menjalankan `npm ci && npm run build` / `composer install --no-dev
  --optimize-autoloader` + test + lint (lihat [TESTING-TDD.md](TESTING-TDD.md)). Artefak = bundle
  `dist/`/`.next/`, image Docker (tag = commit SHA), atau folder release.
- **Release:** artefak + env per-environment. Vercel melakukan ini secara native (tiap deployment
  immutable, punya URL & bisa *Instant Rollback*). Di VPS: pola `releases/<timestamp>/` + symlink
  `current` (Deployer/Envoyer-style), atau image Docker ber-tag SHA.
- **Run:** `php artisan config:cache` dkk dijalankan saat release, bukan di-edit manual di server.
- **Dilarang:** SSH ke production lalu `vim` file PHP/JS, atau `git pull` + edit manual di server
  sebagai cara deploy permanen. Hotfix = commit → build → release baru.
- Migration DB dijalankan sebagai langkah release (lihat Faktor XII), bukan dari kode yang berjalan.

---

## VI. Processes — *Execute the app as one or more stateless processes*

### (a) Definisi / Prinsip Asli
App dieksekusi sebagai satu atau lebih **proses yang stateless dan share-nothing**. Data yang
perlu persisten **harus** disimpan di backing service yang stateful (biasanya database). Memori
atau filesystem proses hanya boleh dipakai sebagai **cache singkat satu transaksi** (mis. download
file → proses → simpan hasil ke DB). App tidak boleh berasumsi bahwa sesuatu yang di-cache di
memori/disk akan tersedia di request berikutnya — request berikutnya bisa dilayani proses lain,
dan restart (deploy, config change, relokasi proses) akan menghapus state lokal. **Sticky
session melanggar twelve-factor**; data session cocok disimpan di datastore dengan expiry
(Redis/Memcached/DB).

### (b) Penerapan di Stack Kita
- **Session:** Laravel `SESSION_DRIVER=database` atau `redis` (bukan `file`) di production
  multi-instance; JWT/session token stateless untuk API. Vercel serverless memaksa stateless secara natural.
- **Upload file:** simpan ke object storage (S3/R2/Supabase Storage) lewat `Storage` abstraction —
  **bukan** ke filesystem lokal server yang hilang saat redeploy atau tidak terlihat oleh instance lain.
  (Shared hosting single-instance boleh `local` disk **sementara**, tapi tetap lewat abstraksi agar
  bisa ditukar ke S3 hanya dengan ganti env.)
- **Cache:** `CACHE_DRIVER=redis/database` untuk multi-instance; cache in-memory hanya untuk
  data yang boleh hilang.
- **Job/queue:** state job di queue backend (DB/Redis), bukan variabel global.
- Modular Monolith tetap **stateless per proses** — event antar module (in-process event bus)
  tidak menyimpan state lintas request; event yang harus andal → queue (persisted).

---

## VII. Port Binding — *Export services via port binding*

### (a) Definisi / Prinsip Asli
App twelve-factor **self-contained** dan tidak bergantung pada web server yang di-*inject*
ke runtime pada saat eksekusi (contoh klasik: PHP sebagai modul Apache, Java di dalam Tomcat).
App **meng-export layanan HTTP dengan bind ke sebuah port** dan listen request di port itu.
Di lokal developer mengakses `http://localhost:5000/`; di deploy, routing layer meneruskan
request dari hostname publik ke proses yang bind di port tersebut. Library web server
dideklarasikan sebagai dependency (Faktor II). Port binding juga berarti satu app bisa menjadi
backing service untuk app lain (URL-nya menjadi resource handle di config app lain).

### (b) Penerapan di Stack Kita
- **Node/Next.js:** `next start -p $PORT` / `app.listen(process.env.PORT)` — port dari env, bukan hardcode.
- **Laravel di VPS/container:** PHP-FPM bind ke port/socket di belakang Nginx sebagai reverse
  proxy, atau Laravel Octane/FrankenPHP yang bind langsung ke port. Nginx + Cloudflare berfungsi
  sebagai *routing layer* (lihat [SECURITY-CLOUDFLARE.md](SECURITY-CLOUDFLARE.md)).
- **Shared hosting (cPanel/Hostinger):** Apache + mod_php adalah model "server di-inject" —
  ini **pengecualian yang diterima** karena keterbatasan platform; dampaknya terbatas karena
  kode tetap tidak bergantung pada fitur khusus Apache (tidak ada logic di `.htaccess` selain
  rewrite ke `public/index.php`). Kode yang sama tetap bisa jalan di model port-binding (VPS/Vercel).
- Vercel serverless: platform yang melakukan binding; kontraknya tetap HTTP handler self-contained.

---

## VIII. Concurrency — *Scale out via the process model*

### (a) Definisi / Prinsip Asli
Di twelve-factor, **proses adalah warga kelas satu**, terinspirasi model Unix process untuk
daemon. Developer merancang app agar tiap jenis pekerjaan ditangani oleh **process type**
tersendiri (mis. `web` untuk HTTP, `worker` untuk background job) — disebut *process formation*.
Ini tidak melarang thread/async di dalam proses, tetapi satu VM/proses hanya bisa tumbuh
vertikal sebatas tertentu; app harus bisa **scale horizontal** dengan menambah jumlah proses
(di banyak mesin). Karena proses share-nothing (Faktor VI), menambah konkurensi itu operasi
yang sederhana dan andal. Proses twelve-factor **tidak boleh men-daemonize diri** atau menulis
PID file — serahkan ke process manager OS/platform (systemd, Foreman, platform cloud) untuk
mengelola output stream, restart crash, dan restart/shutdown yang diminta user.

### (b) Penerapan di Stack Kita
- Process types standar: `web` (HTTP), `worker` (`php artisan queue:work` / BullMQ worker),
  `scheduler` (`php artisan schedule:work` atau cron → 1 proses), opsional `realtime` (websocket).
- Dikelola oleh **Supervisor / systemd / PM2 / Docker Compose / platform** — tidak ada
  `nohup ... &` manual di server sebagai cara produksi.
- Scale: tambah worker/instance (Vercel otomatis; VPS → `numprocs` Supervisor, replika container).
- Background job berat (export PDF/XLSX besar, kirim email massal, panggil AI provider) → **queue
  worker**, bukan di request HTTP — menjaga latency SLO (lihat [SRE-RELIABILITY.md](SRE-RELIABILITY.md)).
- Modular Monolith **tetap bisa scale horizontal**: satu artefak yang sama dijalankan N kali
  sebagai process type berbeda — tidak perlu memecah ke microservices untuk scale.

---

## IX. Disposability — *Maximize robustness with fast startup and graceful shutdown*

### (a) Definisi / Prinsip Asli
Proses twelve-factor bersifat **disposable** — bisa di-start atau di-stop kapan saja. Ini
memungkinkan elastic scaling cepat, deploy perubahan kode/config cepat, dan ketahanan production.
Proses harus:
- **Startup cepat** (idealnya beberapa detik) → release & scale lebih lincah, proses mudah
  dipindah ke mesin fisik lain.
- **Shutdown graceful saat menerima `SIGTERM`**: proses web berhenti menerima request baru,
  menyelesaikan request yang sedang berjalan, lalu exit. Worker mengembalikan job yang sedang
  dikerjakan ke antrian (job harus **reentrant**, idealnya dibungkus transaksi, atau idempotent).
- **Robust terhadap *sudden death*** (hardware failure, kill -9): menggunakan queue backend yang
  mengembalikan job ke antrian bila koneksi worker putus. Desain *crash-only* adalah ideal.

### (b) Penerapan di Stack Kita
- Laravel worker: `queue:work` menangani `SIGTERM` secara native; set `--timeout` < `retry_after`;
  deploy memakai `php artisan queue:restart` (graceful) bukan kill paksa.
- Node: tangani `process.on('SIGTERM', ...)` → `server.close()` + tutup pool DB.
- **Job wajib idempotent** — mis. kirim email/invoice diberi idempotency key; proses ulang job
  yang sama tidak boleh dobel menagih/mengirim.
- Startup cepat: tidak ada warm-up berat di boot; migration **tidak** dijalankan otomatis di setiap
  startup instance (lihat Faktor XII).
- Health check (`/api/health`) dipakai platform untuk tahu kapan instance siap/sakit —
  lihat [SRE-RELIABILITY.md](SRE-RELIABILITY.md).

---

## X. Dev/Prod Parity — *Keep development, staging, and production as similar as possible*

### (a) Definisi / Prinsip Asli
Secara historis ada tiga *gap* antara development dan production:
1. **Time gap** — kode developer butuh hari/minggu/bulan untuk sampai production.
2. **Personnel gap** — developer menulis kode, ops engineer yang men-deploy.
3. **Tools gap** — dev pakai stack berbeda (mis. Nginx/SQLite/macOS) dari production
   (Apache/MySQL/Linux).

Twelve-factor dirancang untuk **continuous deployment** dengan memperkecil ketiganya: deploy
dalam jam/menit, developer yang menulis kode ikut men-deploy dan memantau perilakunya di
production, dan dev/prod memakai tool **semirip mungkin**. Developer harus **menahan godaan**
memakai backing service yang berbeda antara dev dan prod (mis. SQLite di lokal, PostgreSQL di
prod), bahkan bila adapter secara teori menutupi perbedaannya — inkompatibilitas kecil akan
muncul dan menyebabkan kode yang lulus test di dev gagal di production.

### (b) Penerapan di Stack Kita
- **Engine DB sama** di dev & prod: production Postgres → dev pakai Postgres (Docker/Neon branch);
  production MySQL → dev pakai MySQL. SQLite boleh untuk **unit test cepat** saja, tidak untuk
  integration test yang menjadi gate deploy.
- Karena repository layer DB-agnostic + migration multi-engine (DATABASE-RULES.md §3, §5),
  **CI menjalankan integration test terhadap engine target** (service container Postgres/MySQL di GitHub Actions).
- `docker-compose.yml` dev menyediakan DB/Redis versi mayor yang sama dengan production.
- Staging = konfigurasi production dengan data dummy/anonim (bukan copy data personal production
  — lihat [DATA-PROTECTION-ID.md](DATA-PROTECTION-ID.md)).
- Time & personnel gap: deploy kecil & sering; developer yang menulis fitur ikut memverifikasi
  di production (dashboard monitoring — [SRE-RELIABILITY.md](SRE-RELIABILITY.md)).

---

## XI. Logs — *Treat logs as event streams*

### (a) Definisi / Prinsip Asli
Log adalah **aliran event** teragregasi dan berurutan waktu, dikumpulkan dari output stream
semua proses yang berjalan dan backing service. Dalam bentuk mentah biasanya teks satu event
per baris; tidak punya awal/akhir tetap, mengalir terus selama app berjalan. App twelve-factor
**tidak pernah mengurus routing atau penyimpanan output stream-nya sendiri** — tidak menulis atau
mengelola file log. Setiap proses menulis event stream-nya **tanpa buffer ke `stdout`**. Di dev,
developer melihatnya di terminal; di staging/production, stream tiap proses ditangkap oleh
execution environment, digabung, lalu dirutekan ke satu atau lebih tujuan untuk dilihat dan
diarsip jangka panjang (*log router* seperti Logplex/Fluentd, atau sistem indexing/analisis
seperti Splunk). Tujuan ini tidak terlihat dan tidak bisa dikonfigurasi oleh app.

### (b) Penerapan di Stack Kita
- **Structured logging (JSON)** ke `stdout`/`stderr`: Laravel `LOG_CHANNEL=stderr` + formatter
  JSON (Monolog `JsonFormatter`); Node pakai `pino`. Field minimal: `timestamp`, `level`,
  `message`, `request_id`, `user_id` (ID, bukan PII), `module`, `route`, `duration_ms`, `status`.
- Platform/agent yang meneruskan: Vercel Logs/Log Drains, Docker log driver, journald → Better
  Stack/Grafana Loki/Datadog. Detail & retensi: [SRE-RELIABILITY.md](SRE-RELIABILITY.md).
- **Shared hosting** yang hanya mendukung file log: pengecualian yang diterima — pakai channel
  `daily` dengan rotasi otomatis, dan tetap format JSON agar bisa di-ship ke log service.
- **Jangan log secret atau data pribadi mentah** (password, token, NIK, nomor kartu) — masking
  wajib. Lihat [OWASP-ASVS.md](OWASP-ASVS.md) (V16) & [DATA-PROTECTION-ID.md](DATA-PROTECTION-ID.md).

---

## XII. Admin Processes — *Run admin/management tasks as one-off processes*

### (a) Definisi / Prinsip Asli
*Process formation* adalah sekumpulan proses yang menjalankan pekerjaan reguler app. Selain
itu developer sering perlu tugas **admin/maintenance satu kali**: menjalankan migration DB,
membuka console/REPL untuk inspeksi data, menjalankan script sekali jalan yang di-commit di repo.
Proses admin satu kali harus dijalankan di **environment yang identik** dengan proses
long-running biasa: terhadap **release yang sama**, memakai **codebase dan config yang sama**.
Kode admin **dikirim bersama kode aplikasi** untuk mencegah masalah sinkronisasi. Teknik isolasi
dependency yang sama dipakai untuk semua jenis proses. Twelve-factor sangat menyukai bahasa
yang menyediakan REPL dan memudahkan menjalankan script sekali jalan.

### (b) Penerapan di Stack Kita
- Migration: `php artisan migrate --force` / `npx prisma migrate deploy` / `drizzle-kit migrate`
  dijalankan **sekali per release** sebagai langkah deploy (Vercel build step / release hook / CI job),
  memakai artefak & env release yang sama.
- Script satu kali (backfill data, perbaikan data, anonymization job manual) → **Artisan command /
  script di repo** (`app/Console/Commands/`, `scripts/`), di-review & di-commit, **bukan** SQL
  ad-hoc yang diketik langsung di phpMyAdmin production.
- Console production (`php artisan tinker`, `node` REPL) hanya untuk inspeksi darurat, dicatat
  di log insiden ([SRE-RELIABILITY.md](SRE-RELIABILITY.md)), dengan akses least-privilege
  ([ISO-27001-27701.md](ISO-27001-27701.md) — access control).
- Job terjadwal (retensi/hard-delete data pribadi, backup) = Artisan command + scheduler, satu
  codebase dengan app — lihat [DATA-PROTECTION-ID.md](DATA-PROTECTION-ID.md).

---

## 🔗 Rekonsiliasi Eksplisit — Aturan Sainskerta ↔ Twelve-Factor

> **Kesimpulan di depan:** tidak ada konflik. Aturan mutlak Sainskerta justru **memperkuat**
> beberapa faktor. Detail per titik di bawah.

### 1. Modular Monolith ↔ Faktor I (Codebase) — ✅ Kompatibel

**Klaim:** Modular Monolith (satu codebase, batas module internal) **memenuhi** Faktor I
(*one codebase, many deploys*). Ia berbeda dari microservices yang memakai *satu codebase per
service*, tetapi **itu bukan pelanggaran Twelve-Factor**.

**Kenapa:**
- Faktor I mendefinisikan korelasi **satu codebase ↔ satu app**. Modular Monolith **adalah satu
  app** → satu codebase. Korelasinya persis 1:1.
- Pelanggaran Faktor I hanya ada dua: (a) **satu app tersebar di banyak codebase** tanpa
  diperlakukan sebagai distributed system, atau (b) **banyak app berbagi kode yang di-copy**
  alih-alih lewat library. Modular Monolith tidak melakukan keduanya — module-module
  (`modules/Products`, `modules/Orders`, …) adalah **bagian internal satu app**, bukan app terpisah.
- "Satu codebase per service" di microservices bukan aturan tambahan Twelve-Factor; itu hanya
  **konsekuensi** Faktor I ketika sistem memang terdiri dari banyak app. Twelve-Factor **netral
  terhadap granularitas** — ia tidak menyuruh memecah app; ia hanya menuntut setiap app (berapa
  pun ukurannya) punya satu codebase.
- "Many deploys" tetap terpenuhi: satu artefak Modular Monolith di-deploy ke local, staging,
  production — dan bahkan bisa dijalankan sebagai beberapa **process type** (`web`, `worker`,
  `scheduler`) dari artefak yang sama (Faktor VIII). Batas module internal tidak mengubah fakta itu.
- Faktor-faktor lain juga tetap terpenuhi: stateless (VI), scale horizontal (VIII), disposable (IX).
  Alasan Sainskerta memilih monolith (tim kecil, kompleksitas infra, tanpa network call — aturan
  mutlak #1) adalah keputusan arsitektur yang **ortogonal** terhadap Twelve-Factor.
- Bila suatu hari satu module diekstrak menjadi service sendiri, module itu otomatis menjadi
  app baru dengan codebase sendiri — Twelve-Factor tetap konsisten di kedua bentuk.

### 2. No-Foreign-Key + Soft Delete ↔ Faktor IV (Backing Services) — ✅ Saling Menguatkan

**Klaim:** Aturan No-FK (aturan mutlak #2) dan Soft Delete (aturan mutlak #3) **berpasangan
secara alami** dengan Faktor IV. Database bisa ditukar tanpa perubahan kode **justru karena**
aturan DB-Agnostic Repository Layer yang sudah ada di
[DATABASE-RULES.md §5](DATABASE-RULES.md#5-db-agnostic-repository-layer--wajib-anti-vendor-lock-in)
memastikan **tidak ada FK constraint maupun fitur vendor-spesifik yang tertanam di logika app**.

**Hubungan eksplisitnya:**
- Faktor IV menuntut DB adalah *attached resource* yang bisa di-swap lewat config. Agar ini
  benar dalam praktik (bukan hanya di URL koneksi), **perilaku** app tidak boleh bergantung pada
  fitur yang hanya ada di satu engine.
- **FK constraint + `ON DELETE CASCADE`** adalah perilaku yang hidup **di dalam database**, dan
  semantiknya berbeda-beda antar engine (MyISAM tidak mendukung FK, urutan migration & locking
  berbeda, deferrable constraint hanya di Postgres). Karena referential integrity & cascade
  dijaga di **service layer aplikasi** (No-FK), logika itu **ikut pindah bersama kode**, bukan
  tertinggal di engine lama → swap Postgres ↔ MySQL tidak mengubah perilaku.
- **Soft delete (`deleted_at`)** diimplementasikan sebagai kolom `TIMESTAMP NULL` + filter di
  repository — portable di semua engine, tanpa trigger/rule vendor-spesifik.
- **Repository layer DB-agnostic** (DATABASE-RULES.md §5) adalah titik di mana Faktor IV
  "ditegakkan": service hanya bicara ke interface repository; SQL/ORM spesifik engine terisolasi
  di adapter. Tukar engine = ganti `.env` (Faktor III) + provider/adapter, **service & controller tidak berubah**.
- Hasilnya, **attach/detach** DB dari backup, pindah Neon → Postgres VPS → MySQL hosting, atau
  restore ke instance baru saat insiden ([SRE-RELIABILITY.md](SRE-RELIABILITY.md)) semuanya
  operasi config, bukan operasi kode.

### 3. Config via `.env` ↔ Faktor III — ✅ Diformalkan Jadi Hard Requirement

`.env` sudah dipakai informal (DATABASE-RULES.md, SECURITY-CLOUDFLARE.md, AI-PROVIDERS.md).
Dokumen ini **memformalkannya**: lihat **TF-III** di Faktor III — *tidak ada secret/config
per-deploy yang di-hardcode di kode yang di-commit, di mana pun.* Ini dicek di Audit
([phases/05-AUDIT.md](../phases/05-AUDIT.md)) via secret scanning + review `.env.example`.

### 4. Right-Side Drawer Modal / CRUD in One Page ↔ Twelve-Factor — ⚪ Ortogonal

Aturan mutlak #4 (CRUD in One Page) dan #5 (Right-Side Drawer) adalah **konvensi UI/UX**.
Twelve-Factor hanya mengatur **deployment, config, dan model proses** — tidak menyentuh layout
atau interaksi UI sama sekali. Tidak ada titik kontak, maka **tidak ada konflik yang perlu
direkonsiliasi**. (Satu-satunya irisan tidak langsung: state UI drawer tinggal di browser/URL,
bukan di session server — konsisten dengan Faktor VI.)

### Tabel Ringkas

| Aturan Sainskerta | Faktor terkait | Status |
|---|---|---|
| #1 Modular Monolith | I Codebase, VIII Concurrency | ✅ Kompatibel (1 app = 1 codebase) |
| #2 No Foreign Keys | IV Backing Services, X Parity | ✅ Menguatkan (logic portable) |
| #3 Soft Delete | IV Backing Services | ✅ Menguatkan (portable, tanpa trigger vendor) |
| DB-Agnostic Repository Layer | IV, X | ✅ Mekanisme penegak Faktor IV |
| `.env` (informal) → TF-III | III Config | ✅ Diformalkan WAJIB |
| #4 CRUD in One Page, #5 Right Drawer | — | ⚪ Ortogonal (UI) |
| #17 Supply-Chain Security | II Dependencies, V Build | ✅ Menguatkan |

---

## ✅ Checklist Twelve-Factor (dicek di Backend & Audit)

- [ ] I — Satu repo per app; tidak ada fork per klien; kode lintas project via paket internal
- [ ] II — Manifest + lockfile ter-commit; install beku di CI; runtime dipin; tool sistem terdokumentasi
- [ ] III — **TF-III:** nol secret/config per-deploy di kode; `.env` di-gitignore; `.env.example` lengkap; validasi env saat startup; secret scanning CI hijau
- [ ] IV — Semua backing service via env + abstraksi; swap DB terbukti hanya dengan ganti `.env`
- [ ] V — Build di CI; release immutable ber-ID (SHA); rollback terdokumentasi; tidak ada edit manual di server
- [ ] VI — Session/cache/upload tidak di filesystem/memori lokal (multi-instance)
- [ ] VII — Port dari env (`$PORT`); web server dideklarasikan sebagai dependency (kecuali shared hosting)
- [ ] VIII — Process types (`web`/`worker`/`scheduler`) dikelola process manager, bukan `nohup`
- [ ] IX — Graceful shutdown `SIGTERM`; job idempotent; startup cepat
- [ ] X — Engine DB & versi mayor sama di dev/CI/prod; staging tanpa data personal asli
- [ ] XI — Structured JSON log ke stdout; tanpa secret/PII mentah
- [ ] XII — Migration & script satu kali = command di repo, dijalankan terhadap release yang sama

---

## 🔗 Referensi

- [The Twelve-Factor App](https://12factor.net) — sumber primer (Adam Wiggins)
- [standards/MODULAR-MONOLITH.md](MODULAR-MONOLITH.md) — Arsitektur (Faktor I, VIII)
- [standards/DATABASE-RULES.md](DATABASE-RULES.md) — DB-agnostic repository, `.env` (Faktor III, IV, X)
- [standards/SUPPLY-CHAIN-SECURITY.md](SUPPLY-CHAIN-SECURITY.md) — Dependency & build (Faktor II, V)
- [standards/SRE-RELIABILITY.md](SRE-RELIABILITY.md) — Logs, health, disposability (Faktor IX, XI)
- [standards/TESTING-TDD.md](TESTING-TDD.md) — Build stage quality gate (Faktor V)
- [phases/03-BACKEND.md](../phases/03-BACKEND.md) · [phases/06-DEPLOYMENT.md](../phases/06-DEPLOYMENT.md)
