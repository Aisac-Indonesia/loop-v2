# SRE-RELIABILITY.md — Site Reliability Engineering: SLI, SLO, SLA, Error Budget, Monitoring, Backup & Postmortem

> **WAJIB untuk setiap project yang go-live** (aturan mutlak #18 di
> [RULES-OF-THE-GAME.md](../RULES-OF-THE-GAME.md)). Gate go-live ada di
> [phases/06-DEPLOYMENT.md](../phases/06-DEPLOYMENT.md): **SLO terdefinisi, monitoring aktif,
> restore drill backup terbukti**.
>
> **⚠️ Kenapa ini ditambahkan:** standar ini menutup **gap nyata** yang ditemukan pada sebuah
> project yang dibangun dengan workflow ini — project tersebut **shipped ke production tanpa
> monitoring dan tanpa rutinitas backup**. Fase 06 sebelumnya hanya mencantumkan monitoring &
> backup sebagai langkah "minimal" yang mudah terlewat, tanpa gate pass/fail dan tanpa bukti
> bahwa backup bisa di-restore. Mulai sekarang ini **gate, bukan saran**.

SRE (Site Reliability Engineering, dipopulerkan Google — *Site Reliability Engineering*, O'Reilly 2016,
dan *The Site Reliability Workbook*, 2018) memperlakukan reliability sebagai **fitur yang diukur**,
bukan perasaan. Kuncinya: tentukan apa yang diukur (SLI), targetnya (SLO), janji ke luar (SLA),
dan berapa banyak kegagalan yang masih boleh (error budget).

---

## 📐 1. SLI — Service Level Indicator

**Definisi:** metrik kuantitatif yang **benar-benar diukur** tentang perilaku layanan dari sudut
pandang user. Bentuk paling berguna adalah rasio: `event baik / total event × 100%`.

| SLI | Cara ukur | Sumber data di stack kita |
|---|---|---|
| **Availability** | `% request non-5xx` atau `% probe uptime sukses` | Uptime monitor (probe `/api/health`), Cloudflare Analytics, log status code |
| **Latency** | `% request dengan durasi < threshold`, dilaporkan sebagai p50/p95/p99 | Field `duration_ms` di structured log, APM (Sentry Performance), Vercel Analytics |
| **Error rate** | `request 5xx / total request` (4xx dari validasi user **bukan** error layanan) | Log aggregator, Sentry, Cloudflare |
| **Throughput** | request/detik, job/menit yang diproses | Log, metrics queue (Horizon / BullMQ dashboard) |
| *(opsional)* **Freshness / job success** | `% job queue sukses dalam < N menit` (export, email) | Tabel `failed_jobs`, metrics worker |

Aturan:
- Ukur di titik sedekat mungkin dengan user (edge/load balancer/probe eksternal) — bukan hanya
  "server saya bilang sehat".
- Persentil, **bukan rata-rata**, untuk latency (rata-rata menyembunyikan ekor yang lambat).
- Health check & bot traffic dikecualikan dari SLI latency/error rate agar tidak bias.

---

## 🎯 2. SLO — Service Level Objective

**Definisi:** **target nilai internal** untuk sebuah SLI dalam **jendela waktu** tertentu
(umumnya rolling 28/30 hari). Contoh: *"99.9% request sukses dalam 30 hari"*,
*"p95 latency < 300 ms"*, *"error rate < 0.1%"*.

### Memilih SLO yang realistis per tier project

**Prinsip:** 100% bukan target yang benar — mahal tak terbatas dan tidak bisa dibedakan user
dari 99.9x%. Pilih SLO **sedikit di atas** batas di mana user mulai mengeluh, dan yang
**bisa dicapai infrastruktur yang benar-benar dipakai** (shared hosting tidak realistis 99.99%).

| Tier | Contoh | Availability (30 hari) | Latency API | Error rate | Downtime diizinkan / 30 hari |
|---|---|---|---|---|---|
| **T1 — Internal tool** | Dashboard admin internal, tool back-office, jam kerja saja | **99.0%** | p95 < 800 ms | < 1% | ± 7 jam 12 menit |
| **T2 — Aplikasi klien standar** | Company profile + CMS, LMS internal, SaaS kecil gratis/early | **99.5%** | p95 < 500 ms | < 0.5% | ± 3 jam 36 menit |
| **T3 — SaaS berbayar / customer-facing** | Platform berlangganan, e-commerce, transaksi pembayaran | **99.9%** | p95 < 300 ms, p99 < 1 s | < 0.1% | ± 43 menit |
| **T4 — Kritis/regulasi** *(jarang, keputusan khusus)* | Pembayaran inti, layanan publik, data kesehatan | 99.95%+ | sesuai kontrak | < 0.05% | ± 21 menit |

Cara memutuskan:
1. Tanyakan user di **fase Planning** (lihat [phases/01-PLANNING.md](../phases/01-PLANNING.md)):
   siapa pengguna, jam pemakaian, dampak bisnis bila down 1 jam, target hosting.
2. Cocokkan dengan kemampuan hosting: shared hosting single-server → realistis T1/T2;
   Vercel/managed DB/VPS dengan backup & monitoring → T2/T3; T4 butuh redundansi multi-zona.
3. Mulai **konservatif**, evaluasi setelah 1–3 bulan data riil, naikkan bila konsisten tercapai.
4. Tulis SLO di `docs/SLO.md` project (template di bawah) — SLO yang tidak tertulis = tidak ada.

---

## 📜 3. SLA — Service Level Agreement

**Definisi:** **komitmen eksternal/kontraktual** ke klien, biasanya dengan konsekuensi
(service credit, penalti, hak terminasi) bila dilanggar.

- SLA **selalu lebih longgar** dari SLO internal. Contoh: SLO internal 99.9% → SLA kontrak 99.5%.
  Selisihnya adalah *safety margin* agar tim sudah bereaksi (SLO breach) jauh sebelum kontrak dilanggar.
- SLA **hanya dibutuhkan bila kontrak klien memintanya.** Kebanyakan project internal/klien kecil
  cukup SLO internal tanpa SLA.
- SLA harus mendefinisikan: SLI yang diukur, jendela, pengecualian (maintenance terjadwal,
  force majeure, gangguan pihak ketiga yang di luar kendali seperti outage Cloudflare/Vercel global),
  cara klaim, dan kompensasi. **Disusun bersama tim legal/bisnis**, bukan oleh developer sendirian.

```
SLA (kontrak, longgar)  ≤  SLO (target internal)  ≤  performa aktual (SLI terukur)
     99.5%                     99.9%                     99.95% (contoh)
```

---

## 💰 4. Error Budget

**Definisi:** `Error budget = 100% − SLO`, dihitung atas jendela SLO.
Contoh: SLO 99.9% / 30 hari → budget **0.1%** = ± **43 menit** downtime atau 1 dari setiap 1.000 request boleh gagal.

**Fungsi:** menjadi kesepakatan objektif antara "kirim fitur cepat" vs "jaga stabilitas".

**Kebijakan Error Budget (WAJIB ditulis di `docs/SLO.md`):**
| Sisa budget (jendela berjalan) | Tindakan |
|---|---|
| > 50% | Normal — rilis fitur seperti biasa |
| 25–50% | Waspada — perubahan berisiko butuh review ekstra & rencana rollback |
| < 25% | Rilis fitur diperlambat; prioritaskan perbaikan reliability |
| **Habis (0%)** | **Freeze fitur baru.** Hanya perbaikan reliability, security patch, dan bug kritis yang boleh di-deploy sampai budget pulih atau root cause selesai ditangani (via postmortem) |

Burn-rate alert (anjuran untuk T3+): alert bila budget terbakar jauh lebih cepat dari normal,
mis. *2% budget habis dalam 1 jam* (page segera) atau *5% dalam 6 jam* (tiket).

---

## 🔧 5. Requirement WAJIB

### SRE-01 — Health Check Endpoint
Melanjutkan preseden yang sudah ada (`/health` di [phases/06-DEPLOYMENT.md](../phases/06-DEPLOYMENT.md) Langkah 6) —
distandarkan menjadi `GET /api/health`:
- **Liveness** (`/api/health/live`, opsional terpisah): proses hidup, tanpa cek dependency → untuk restart otomatis.
- **Readiness** (`/api/health`): cek koneksi DB (+ Redis/queue bila dipakai) dengan timeout pendek (≤ 2 s).
- Response: `200 {"status":"healthy","checks":{"database":"ok"},"version":"<commit-sha>","timestamp":...}`;
  gagal → `503`.
- **Jangan bocorkan detail error** (pesan exception, host DB, stack trace) ke response publik — tulis
  detailnya ke log saja ([OWASP-ASVS.md](OWASP-ASVS.md) V16). Contoh lama yang mengembalikan
  `$e->getMessage()` harus diganti `"database":"unavailable"`.
- Tanpa auth, tapi rate-limited di edge; dikecualikan dari Turnstile/bot challenge agar monitor tidak terblok.

### SRE-02 — Structured Logging
- JSON ke stdout/stderr (Twelve-Factor XI — [TWELVE-FACTOR.md](TWELVE-FACTOR.md#xi-logs--treat-logs-as-event-streams)),
  field: `timestamp`, `level`, `message`, `request_id` (correlation ID diteruskan antar module/job),
  `route`, `status`, `duration_ms`, `user_id`/`tenant_id` (ID saja), `module`.
- Level konsisten: `error` = butuh tindakan; `warning` = anomali; `info` = event bisnis; `debug` off di production.
- **Tanpa secret/PII mentah** (password, token, OTP, NIK, nomor kartu, isi dokumen).
- Dikirim ke log aggregator dengan **retensi terdefinisi** (mis. 30 hari hot, 1 tahun arsip untuk
  log audit/security) — retensi log yang berisi data pribadi ikut aturan [DATA-PROTECTION-ID.md](DATA-PROTECTION-ID.md).
- Error tracking: **Sentry** (atau setara) aktif di backend & frontend dengan release = commit SHA.

### SRE-03 — Uptime Monitoring
- **Rekomendasi default: [Better Stack Uptime](https://betterstack.com/uptime)** (uptime + status page
  + on-call + log dalam satu tempat, ada free tier). Alternatif setara: **UptimeRobot** (free tier
  sederhana), **Healthchecks.io** (khusus *heartbeat* cron/backup job).
- Minimal: probe `GET /api/health` tiap **1–3 menit** dari ≥ 2 lokasi; probe halaman utama (cek
  status 200 + keyword); **heartbeat monitor untuk job backup & scheduler** (job "ping" Healthchecks.io /
  Better Stack heartbeat setelah sukses — bila ping tidak datang, alert).
- Monitoring SSL expiry & domain expiry.
- Status page publik (anjuran T3+).

### SRE-04 — Alerting pada SLO Breach
- Alert dikirim ke **channel yang benar-benar dibaca** (Slack/Telegram/WhatsApp grup tim + email),
  dengan **penanggung jawab on-call bernama** di `docs/SLO.md`.
- Alert minimal: uptime probe gagal ≥ 2 kali berturut-turut; error rate > SLO selama 5–10 menit;
  p95 latency > SLO selama 10 menit; heartbeat backup tidak datang; disk > 85%; sertifikat SSL < 14 hari.
- Alert harus **actionable** — setiap alert punya link ke runbook singkat. Alert yang selalu diabaikan
  dihapus atau diperbaiki (alert fatigue = tidak ada alert).

### SRE-05 — Backup + Restore Procedure dengan **Restore Drill yang Terbukti**
"Backup ada" **tidak cukup**. Backup yang belum pernah di-restore = **belum terbukti ada**.

**Backup:**
- DB: backup otomatis harian minimum (managed DB: aktifkan PITR bila tersedia; self-hosted: script
  `mysqldump`/`pg_dump` dari [DATABASE-RULES.md](DATABASE-RULES.md#-backup-strategy) via cron).
- File/upload: object storage dengan versioning, atau sync harian.
- Aturan **3-2-1**: 3 salinan, 2 media berbeda, **1 off-site** (bucket/provider/region berbeda dari server produksi).
- Backup **terenkripsi** (data pribadi — [DATA-PROTECTION-ID.md](DATA-PROTECTION-ID.md)), credential di env.
- Retensi backup terdefinisi (mis. harian 14 hari, mingguan 8 minggu, bulanan 12 bulan) & selaras
  dengan kebijakan retensi data pribadi (data yang sudah di-hard-delete akan ikut hilang saat backup lama kedaluwarsa).
- Heartbeat sukses backup ke uptime monitor (SRE-03).

**Target pemulihan (tulis di `docs/SLO.md`):**
- **RPO** (Recovery Point Objective — maksimal data hilang): T1/T2 ≤ 24 jam; T3 ≤ 1 jam (PITR).
- **RTO** (Recovery Time Objective — maksimal waktu pulih): T1 ≤ 24 jam; T2 ≤ 8 jam; T3 ≤ 2 jam.

**Restore Drill (WAJIB sebelum go-live, lalu minimal tiap 3 bulan):**
1. Ambil backup terbaru **dari lokasi off-site** (bukan dari server produksi).
2. Restore ke **environment terpisah** (DB baru/staging) — jangan pernah drill di atas production.
3. Jalankan app terhadap DB hasil restore; verifikasi: migration status cocok, jumlah row tabel
   kunci ≈ production, login berhasil, 3–5 alur kritis berjalan, file upload sampel terbuka.
4. Catat **waktu aktual restore** (bandingkan dengan RTO) dan umur data (bandingkan dengan RPO).
5. Simpan bukti di `docs/restore-drill-log.md`: tanggal, pelaksana, sumber backup, durasi, hasil, masalah & perbaikan.
6. Gagal/ melebihi RTO → perbaiki prosedur → **ulangi drill** sampai lulus. Gate go-live belum lulus.

### SRE-06 — Blameless Incident Postmortem
Wajib untuk setiap insiden yang: menyebabkan downtime terlihat user, melanggar SLO / menghabiskan
> 20% error budget dalam sekali kejadian, kehilangan data, atau insiden keamanan/kebocoran data
(untuk kebocoran data pribadi, **juga** ikuti alur notifikasi di [DATA-PROTECTION-ID.md](DATA-PROTECTION-ID.md)).

**Blameless:** fokus pada **sistem dan proses** yang memungkinkan kesalahan, bukan menyalahkan
individu. Asumsi dasar: setiap orang bertindak dengan informasi terbaik yang dimilikinya saat itu.
Postmortem ditulis dalam ≤ 5 hari kerja dan disimpan di `docs/postmortems/YYYY-MM-DD-<slug>.md`.

---

## 📄 Template — `docs/SLO.md`

```markdown
# SLO — <Nama Project>
Tier: T2 — Aplikasi klien standar            Owner on-call: <nama>, cadangan: <nama>
Jendela: rolling 30 hari                      Ditinjau: <tanggal>, berikutnya: <tanggal>

| SLI | Definisi pengukuran | SLO | Sumber |
|-----|---------------------|-----|--------|
| Availability | % probe /api/health sukses (2 lokasi, tiap 1 menit) | 99.5% | Better Stack |
| Latency | p95 durasi request API (exclude /api/health) | < 500 ms | Sentry / log |
| Error rate | 5xx / total request | < 0.5% | Log aggregator |

Error budget: 0.5% (~3 jam 36 menit / 30 hari). Kebijakan: lihat standar SRE §4.
SLA kontrak: tidak ada / 99.0% (lihat kontrak no. ...)
RPO: 24 jam · RTO: 8 jam · Restore drill terakhir: <tanggal> — LULUS (durasi 38 menit)
Alert channel: <Slack #ops-project / grup Telegram>
```

## 📄 Template — Blameless Postmortem

```markdown
# Postmortem: <judul singkat>  —  <YYYY-MM-DD>
Status: Draft / Final · Penulis: <nama> · Severity: SEV1/SEV2/SEV3

## Ringkasan
2–3 kalimat: apa yang terjadi, dampak ke user, durasi.

## Dampak
- Durasi: <mulai> – <selesai> (WIB), total <menit>
- User/tenant terdampak: <jumlah/persen> · Error budget terpakai: <x%>
- Data hilang/bocor: ya/tidak (jika ya → alur notifikasi DATA-PROTECTION-ID.md)

## Timeline (WIB)
| Waktu | Kejadian |
|-------|----------|
| 10:02 | Deploy release abc123 |
| 10:05 | Alert error rate > 0.5% |
| 10:09 | On-call acknowledge |
| 10:20 | Rollback ke release def456 |
| 10:24 | Error rate normal |

## Root Cause
Penyebab teknis & kondisi sistem/proses yang memungkinkannya (pakai "5 Whys").

## Deteksi
Bagaimana kita tahu? Seberapa cepat? Apakah alert bekerja / apakah user yang melapor duluan?

## Respons & Pemulihan
Apa yang dilakukan, apa yang membantu, apa yang menghambat.

## Yang Berjalan Baik / Yang Kurang Baik / Di Mana Kita Beruntung

## Action Items
| # | Tindakan | Jenis (cegah/deteksi/mitigasi) | Owner | Due | Tiket |
|---|----------|--------------------------------|-------|-----|-------|

## Pelajaran
(Tanpa menyalahkan individu.)
```

---

## ✅ Checklist Gate Go-Live (pass/fail — dicek di Fase 06)

- [ ] **SLO terdefinisi:** `docs/SLO.md` berisi tier, SLI, SLO, error budget policy, RPO/RTO, owner on-call
- [ ] **SRE-01** `GET /api/health` aktif (cek DB, 503 saat gagal, tanpa bocor detail error)
- [ ] **SRE-02** Structured JSON logging + error tracking (Sentry) aktif, tanpa secret/PII mentah
- [ ] **SRE-03** Uptime monitor aktif (default Better Stack) untuk `/api/health` + halaman utama + heartbeat backup
- [ ] **SRE-04** Alert SLO breach terkirim ke channel tim — **diuji** (trigger alert uji, pastikan diterima)
- [ ] **SRE-05** Backup otomatis harian off-site terenkripsi **+ restore drill LULUS** tercatat di `docs/restore-drill-log.md`
- [ ] **SRE-06** Template postmortem tersedia di `docs/postmortems/` & alur insiden diketahui tim

---

## 🔗 Referensi

- [RULES-OF-THE-GAME.md](../RULES-OF-THE-GAME.md) — Aturan mutlak #18
- [phases/06-DEPLOYMENT.md](../phases/06-DEPLOYMENT.md) — Gate go-live SRE
- [phases/07-IMPROVEMENT.md](../phases/07-IMPROVEMENT.md) — Review SLO & restore drill berkala
- [standards/TWELVE-FACTOR.md](TWELVE-FACTOR.md) — Faktor IX (Disposability) & XI (Logs)
- [standards/DATABASE-RULES.md](DATABASE-RULES.md) — Script backup DB
- [standards/DATA-PROTECTION-ID.md](DATA-PROTECTION-ID.md) — Notifikasi kebocoran data, retensi
- [standards/ISO-27001-27701.md](ISO-27001-27701.md) — Incident management & business continuity
- [Google SRE Book — Service Level Objectives](https://sre.google/sre-book/service-level-objectives/)
- [Google SRE Workbook — Implementing SLOs](https://sre.google/workbook/implementing-slos/)
- [Google SRE Book — Postmortem Culture](https://sre.google/sre-book/postmortem-culture/)
