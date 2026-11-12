# DATA-PROTECTION-ID.md — Kepatuhan Pelindungan Data Pribadi Indonesia (UU PDP 27/2022 + PP 33/2026)

> **WAJIB untuk setiap project yang memproses data pribadi** (praktis: setiap app yang punya akun
> user, form kontak, data pelanggan/karyawan/siswa/pasien) — aturan mutlak #19 di
> [RULES-OF-THE-GAME.md](../RULES-OF-THE-GAME.md).
> Dipakai di: [phases/01-PLANNING.md](../phases/01-PLANNING.md) (skrining DPIA),
> [phases/03-BACKEND.md](../phases/03-BACKEND.md) (endpoint hak subjek data, job retensi/penghapusan),
> [phases/05-AUDIT.md](../phases/05-AUDIT.md) (verifikasi).
>
> **⚖️ Disclaimer:** dokumen ini adalah **standar teknis-operasional untuk tim engineering**, bukan
> nasihat hukum. Untuk keputusan dasar hukum, isi kontrak, transfer lintas negara, dan penanganan
> insiden nyata — **konsultasikan dengan konsultan hukum / DPO klien**. Lihat bagian
> [Status Verifikasi Sumber](#-status-verifikasi-sumber) untuk apa yang sudah dan belum diverifikasi.

---

## 📚 Dasar Hukum

### UU No. 27 Tahun 2022 tentang Pelindungan Data Pribadi (UU PDP)
- Diundangkan **17 Oktober 2022**; masa penyesuaian 2 tahun → **berlaku penuh sejak 17 Oktober 2024**.
- Berlaku untuk setiap orang, badan publik, dan organisasi internasional yang memproses data pribadi
  di Indonesia, **dan** di luar Indonesia bila berakibat hukum di Indonesia / terhadap subjek data WNI di luar negeri.
- Membedakan **data pribadi umum** (nama, jenis kelamin, kewarganegaraan, agama, status perkawinan,
  data kombinasi yang mengidentifikasi) dan **data pribadi yang bersifat spesifik** (Pasal 4 ayat (2)):
  **data dan informasi kesehatan, data biometrik, data genetika, catatan kejahatan, data anak, data keuangan
  pribadi**, dan data lain sesuai peraturan perundang-undangan.
- Sanksi administratif (UU PDP Pasal 57) termasuk denda administratif **paling tinggi 2% dari pendapatan
  tahunan** terhadap variabel pelanggaran; ditambah ketentuan pidana (Pasal 67–70) untuk perbuatan tertentu.

### PP No. 33 Tahun 2026 tentang Peraturan Pelaksanaan UU PDP
Yang **terkonfirmasi dari beberapa sumber sekunder kredibel yang saling konsisten** (law firm & platform
compliance — lihat daftar sumber di akhir):
- **Ditetapkan & diundangkan 16 Juli 2026**, terdiri dari **225 pasal**, dan menurut **Pasal 225 mulai berlaku
  enam bulan kemudian: 16 Januari 2027**. Tercatat di Lembaran Negara 2026 No. 88 (menurut database peraturan Meridian Hukum).
- Mengikat **pengendali, prosesor, dan badan publik**; pengecualian (Pasal 3) hanya orang perseorangan untuk
  kegiatan pribadi/rumah tangga.
- Memperinci cara pelaksanaan & **pembuktian kepatuhan**: ROPA, DPIA, kebijakan retensi, perjanjian
  pengendali–prosesor, petugas pelindungan data, tenggat 3 × 24 jam, dan rumus denda administratif.
- Lembaga PDP masih akan menerbitkan **peraturan lembaga** untuk ketentuan teknis yang lebih rinci (mis. DPIA).

> **⚠️ Batas verifikasi:** nomor pasal PP 33/2026 di dokumen ini dikutip dari **ringkasan sekunder**
> (Verihubs, SIP Law Firm, Meridian Hukum, MNL Law) yang konsisten satu sama lain, **bukan** dari teks resmi
> di JDIH / peraturan.go.id (tidak berhasil diakses saat penyusunan). **Sebelum dipakai untuk keputusan
> hukum atau dikutip ke klien, cocokkan dengan salinan resmi PP 33/2026.**
>
> **Timeline kepatuhan untuk project:** project yang go-live **sebelum** 16 Januari 2027 tetap wajib patuh
> UU PDP (sudah berlaku penuh), dan harus **siap memenuhi rincian PP 33/2026 paling lambat 16 Januari 2027**.
> Project baru: rancang sesuai keduanya dari awal.

---

## 1️⃣ Consent (Persetujuan)

**Prinsip hukum:**
- Setiap pemrosesan wajib punya **dasar pemrosesan yang sah** — UU PDP mengenal 6: (1) persetujuan
  yang sah secara eksplisit, (2) pemenuhan perjanjian, (3) kewajiban hukum, (4) kepentingan vital,
  (5) tugas kepentingan umum/kewenangan, (6) kepentingan yang sah. Consent **bukan satu-satunya** dasar —
  jangan minta consent untuk hal yang dasarnya kontrak/kewajiban hukum (consent bisa ditarik kapan saja,
  kontrak/kewajiban hukum tidak).
- Consent harus **eksplisit, informed, spesifik per tujuan**, tertulis atau terekam (elektronik boleh);
  bila digabung dengan perjanjian lain harus **dapat dibedakan jelas**, bahasa sederhana. Consent yang
  tidak memenuhi syarat = **batal demi hukum**.
- Subjek data berhak **menarik persetujuan**; pengendali wajib **menghentikan pemrosesan paling lambat
  3 × 24 jam** sejak permintaan penarikan (PP 33/2026 Pasal 92 menurut Verihubs).
- **Data anak** (< 18 tahun dan belum menikah — PP 33/2026 Pasal 1 angka 21): wajib persetujuan
  orang tua/wali yang diverifikasi (PP 33/2026 Pasal 38).
- **Pemberitahuan privasi** wajib memuat minimal: legalitas, tujuan, jenis data, masa retensi, rincian
  informasi yang dikumpulkan, jangka waktu pemrosesan, hak subjek data — tersedia selama pemrosesan
  berlangsung; **klausul eksonerasi dilarang** (PP 33/2026 Pasal 62 & 65).
- Kepentingan yang sah sebagai dasar → wajib **Legitimate Interest Assessment (LIA)** terdokumentasi.

**Implementasi teknis (WAJIB):**
- [ ] **PDP-C1** Checkbox consent **tidak pre-checked**, satu per tujuan opsional (marketing, analytics, berbagi ke pihak ketiga) — terpisah dari "Saya setuju Syarat & Ketentuan"
- [ ] **PDP-C2** Tabel `consents`: `id, user_id, purpose, policy_version, granted_at, withdrawn_at, channel, ip_hash, user_agent` — **append-only** (riwayat, bukan overwrite) sebagai bukti
- [ ] **PDP-C3** Halaman **Pengaturan Privasi** di app: lihat & tarik consent per tujuan semudah memberikannya; penarikan memicu penghentian pemrosesan otomatis (unsubscribe, stop sync ke pihak ketiga) **< 3 × 24 jam**
- [ ] **PDP-C4** Data spesifik (kesehatan, biometrik, keuangan pribadi, anak, dll): consent/dasar hukum terpisah & eksplisit, enkripsi kolom (ASVS-E3), akses dibatasi role, ASVS **L3** untuk module tersebut ([OWASP-ASVS.md](OWASP-ASVS.md))
- [ ] **PDP-C5** Privacy notice ter-versi (`policy_version`) & tersedia di 3 bahasa (aturan #14); perubahan material → minta ulang consent

---

## 2️⃣ Retention (Retensi) & Penghapusan

**Prinsip hukum:** data pribadi hanya disimpan **selama diperlukan untuk tujuan pemrosesan** atau
selama diwajibkan peraturan lain; setelah itu **dihapus atau dimusnahkan**. PP 33/2026 (Pasal 75 menurut
Verihubs) mewajibkan **dokumen kebijakan masa retensi** yang memuat: periode retensi, jenis data, metode
pemusnahan, ketentuan untuk prosesor, dan dasar hukum bila masa simpan ditentukan aturan lain.

### ⚠️ Soft Delete ≠ Penghapusan untuk Kepatuhan
Aturan mutlak #3 (`deleted_at`, endpoint `trashed`/`restore`) adalah **jaring pengaman operasional**:
melindungi dari salah hapus oleh user/admin dan memungkinkan restore. **Soft delete BUKAN mekanisme
penghapusan (erasure) untuk kepatuhan** — row dengan `deleted_at` terisi **masih data pribadi yang
disimpan dan diproses** (ada di DB, di backup, bisa di-restore, bisa dibaca DBA).

Maka **tetap WAJIB** ada mekanisme penghapusan nyata:
- **Hard-delete setelah masa retensi** — job terjadwal menghapus permanen row yang sudah soft-deleted
  lebih lama dari *grace period* (mis. 30 hari) **atau** yang masa retensinya habis; **atau**
- **Anonimisasi** — bila row masih dibutuhkan untuk integritas laporan/statistik (mis. transaksi untuk
  laporan pajak keuangan), ganti kolom identitas dengan nilai yang tidak bisa dikembalikan
  (`name → "Deleted User #<random>"`, email → `null`/hash acak bergaram yang dibuang, hapus telepon/alamat/NIK)
  sehingga data **tidak lagi bisa mengidentifikasi** individu. Pseudonimisasi (masih bisa dipulihkan
  dengan key) **bukan** anonimisasi.

Ini **tidak mengubah** aturan #3: soft delete tetap default untuk aksi hapus di UI; hard-delete/anonimisasi
adalah lapisan **tambahan** yang dijalankan job retensi atau permintaan penghapusan subjek data.

**Implementasi teknis (WAJIB):**
- [ ] **PDP-R1** `docs/RETENTION-POLICY.md`: tabel per kategori data → periode, justifikasi/dasar hukum, metode (hard-delete/anonimisasi), berlaku juga di prosesor (contoh di bawah)
- [ ] **PDP-R2** Job terjadwal `privacy:purge` (Artisan command / script di repo — Twelve-Factor XII) harian: hard-delete/anonimisasi data lewat retensi & soft-deleted lewat grace period; **idempotent**, di-log (jumlah row per tabel, tanpa isi data), heartbeat ke monitor ([SRE-RELIABILITY.md](SRE-RELIABILITY.md))
- [ ] **PDP-R3** Karena **No-FK** (aturan #2), cascade hard-delete/anonimisasi **wajib di service layer** — daftar eksplisit tabel turunan per entitas (event map module), diuji dengan test (tidak ada orphan data pribadi tertinggal)
- [ ] **PDP-R4** File terkait (upload KTP, foto, dokumen) ikut dihapus dari object storage
- [ ] **PDP-R5** **Backup:** data yang dihapus akan hilang saat backup lama kedaluwarsa sesuai retensi backup ([SRE-RELIABILITY.md](SRE-RELIABILITY.md) SRE-05) — dokumentasikan; bila backup di-restore, jalankan ulang `privacy:purge` **sebelum** sistem dipakai agar data yang sudah dihapus tidak "hidup kembali"
- [ ] **PDP-R6** Log aplikasi & analytics punya retensi sendiri dan tidak menyimpan PII mentah

```markdown
| Kategori data | Retensi | Justifikasi | Metode akhir |
|---------------|---------|-------------|--------------|
| Akun user (profil) | Selama akun aktif + 30 hari setelah penutupan | Perjanjian layanan | Hard-delete |
| Transaksi/invoice | 10 tahun | Kewajiban dokumen keuangan/perpajakan (konfirmasi dengan konsultan) | Anonimisasi identitas, nilai transaksi dipertahankan |
| Log keamanan (login, IP) | 1 tahun | Kepentingan sah: keamanan | Hard-delete |
| Lamaran kerja ditolak | 6 bulan | Consent | Hard-delete |
| Data soft-deleted (umum) | Grace 30 hari | Pemulihan salah hapus | Hard-delete / anonimisasi |
```

---

## 3️⃣ ROPA — Records of Processing Activities (Perekaman Kegiatan Pemrosesan)

**Prinsip hukum:** pengendali **wajib merekam seluruh kegiatan pemrosesan** data pribadi. Menurut ringkasan
PP 33/2026 (SIP Law Firm), ROPA berfungsi sebagai daftar aktivitas **sekaligus peta aliran data**, berisi antara
lain: identitas pengendali, prosesor, dan DPO; sumber data; dasar & tujuan pemrosesan; kategori data; pihak ketiga
yang mengakses; masa retensi; pengamanan; rincian transfer. Pengendali juga harus mampu **menunjukkan kepatuhan**
lewat dokumentasi dan audit.

**Implementasi (WAJIB, dokumen hidup per project):** `docs/ROPA.md`, dibuat di Planning, diperbarui
setiap ada module/integrasi baru yang menyentuh data pribadi (bagian dari *definition of done*).

```markdown
# ROPA — <Nama Project>
Pengendali: <klien> · Prosesor: Sainskerta (dev/hosting?), <hosting>, <email provider>, <AI provider> · DPO: <nama/kontak>
Terakhir diperbarui: <tanggal> oleh <nama>

| # | Aktivitas pemrosesan | Module | Kategori subjek | Kategori data (tandai SPESIFIK) | Sumber | Tujuan | Dasar hukum | Penerima / pihak ketiga | Transfer luar negeri (negara, mekanisme) | Retensi | Langkah keamanan |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Registrasi & login | Auth | Pelanggan | Nama, email, hash password | Subjek langsung | Akses layanan | Perjanjian | Hosting (ID), email provider (SG) | SG — perjanjian + safeguards | Akun aktif + 30 hari | bcrypt, TLS, MFA admin |
| 2 | Rekam medis | MedicalRecords | Pasien | **Kesehatan (SPESIFIK)** | Dokter | Layanan kesehatan | Persetujuan eksplisit + kewajiban hukum | — | — | Sesuai regulasi kesehatan | Enkripsi kolom, ASVS L3, audit log |
```

Perjanjian dengan **prosesor** (hosting, email, AI provider, payment) harus tertulis dan memuat minimal
(PP 33/2026 Pasal 14 menurut Verihubs): cakupan & cara pemrosesan, jenis data, jangka waktu, mekanisme audit,
penyelesaian sengketa, aturan sub-prosesor. AI provider yang menerima data pribadi → cek opsi zero-retention
([AI-PROVIDERS.md](AI-PROVIDERS.md)).

**Transfer lintas negara** (mis. server/AI provider di luar Indonesia): hanya bila negara tujuan punya
tingkat pelindungan setara/lebih tinggi, **atau** ada safeguards yang mengikat, **atau** consent subjek data —
catat mekanismenya di ROPA dan putuskan bersama konsultan hukum.

---

## 4️⃣ DPIA — Data Protection Impact Assessment (Penilaian Dampak Pelindungan Data Pribadi)

**Kapan wajib** — bila pemrosesan berpotensi **risiko tinggi**, termasuk tujuh pemicu dalam UU PDP
(Pasal 34) yang dipertahankan PP 33/2026 (Pasal 120–122 menurut Verihubs):
1. Pengambilan **keputusan otomatis** yang berakibat hukum atau berdampak signifikan bagi subjek data
2. Pemrosesan **data pribadi yang bersifat spesifik**
3. Pemrosesan data pribadi **dalam skala besar**
4. **Evaluasi, penskoran, atau pemantauan sistematis** (profiling)
5. **Pencocokan atau penggabungan** sekelompok data
6. Penggunaan **teknologi baru** (menurut SIP Law Firm: termasuk AI, machine learning, IoT)
7. Pemrosesan yang **membatasi pelaksanaan hak** subjek data

"Skala besar" dinilai **kontekstual**, tanpa ambang angka pasti: volume data, jumlah subjek, durasi,
jenis data, tujuan, cakupan geografis (SIP Law Firm). DPIA dilakukan **sebelum** pemrosesan dimulai,
ditinjau ulang bila profil risiko berubah, dan saran DPO dicatat di dalamnya (Verihubs, SIP Law Firm).
Template teknis resmi akan menyusul lewat peraturan Lembaga PDP — template di bawah adalah struktur minimum
sampai template resmi terbit.

**Skrining DPIA di Planning (WAJIB, 7 pertanyaan ya/tidak):** satu "ya" → **DPIA wajib** sebelum Backend dimulai,
dan ASVS L3 untuk module terkait. Pertanyaan ada di [phases/01-PLANNING.md](../phases/01-PLANNING.md).

**Template `docs/DPIA.md`:**
```markdown
# DPIA — <Nama Project / Module>
Versi: 1.0 · Tanggal: <...> · Penyusun: <...> · Saran DPO: <ringkasan + nama> · Status: Draft/Disetujui

## 1. Deskripsi pemrosesan
Apa, siapa subjeknya, kategori data (tandai spesifik), sumber, alur data (diagram), sistem & prosesor yang terlibat, lokasi penyimpanan, retensi.
## 2. Tujuan & dasar hukum
Tujuan spesifik per aktivitas; dasar hukum (+ LIA bila kepentingan sah).
## 3. Kebutuhan & proporsionalitas
Kenapa data ini perlu? Bisakah dengan data lebih sedikit / anonim / pseudonim? Minimisasi yang diterapkan.
## 4. Penilaian risiko terhadap subjek data
| Risiko | Sumber ancaman | Kemungkinan (1-5) | Dampak (1-5) | Skor | 
|--------|----------------|-------------------|--------------|------|
| Kebocoran data kesehatan | Akses tidak sah / IDOR | 2 | 5 | 10 |
| Keputusan otomatis keliru | Model AI bias | 3 | 4 | 12 |
## 5. Langkah mitigasi
Per risiko: kontrol teknis (enkripsi, ASVS L3, MFA, audit log, human review atas keputusan otomatis) & organisasional; risiko residual.
## 6. Kesimpulan
Lanjut / lanjut dengan syarat / tidak lanjut. Perlu konsultasi ke Lembaga PDP? (bila risiko residual tetap tinggi)
## 7. Jadwal tinjauan ulang
```

---

## 5️⃣ Hak Subjek Data — Mekanisme UI/API Nyata, Bukan Halaman Kebijakan Saja

Hak dalam UU PDP: informasi, **akses & salinan**, **pembaruan/koreksi**, **penghapusan/pemusnahan**,
**penarikan persetujuan**, **keberatan atas keputusan otomatis**, **penundaan/pembatasan pemrosesan**,
**portabilitas** (memperoleh & mengirim data dalam format terstruktur yang umum dipakai), dan ganti rugi.

**Tenggat 3 × 24 jam** (PP 33/2026 menurut Verihubs): perbaikan data (Pasal 71), konfirmasi permintaan salinan
& jangka waktu penyediaannya (Pasal 78, dihitung setelah verifikasi identitas), penghentian pemrosesan setelah
penarikan consent (Pasal 92), penundaan/pembatasan (Pasal 99). Keberatan atas keputusan **sepenuhnya otomatis**
yang berdampak hukum/signifikan → wajib ada mekanisme & penjelasan teknologinya; bila diterima, sediakan
**alternatif dengan campur tangan manusia** (Pasal 93–94). Pengendali wajib **memverifikasi identitas & kewenangan pemohon**.

**Implementasi (WAJIB di Backend + Frontend):**

| Hak | UI (halaman "Privasi & Data Saya") | API (contoh, ter-auth, ter-rate-limit) |
|---|---|---|
| Akses & salinan | Tombol "Unduh data saya" | `POST /api/me/data-export` → job async → link unduh signed, kedaluwarsa 24 jam |
| Portabilitas | Format JSON + CSV terstruktur | sama, `?format=json|csv` |
| Koreksi | Form edit profil + "Ajukan koreksi" untuk field yang tidak bisa diedit sendiri | `PATCH /api/me`, `POST /api/me/privacy-requests {type:"rectification"}` |
| Penghapusan | "Hapus akun saya" + konfirmasi + re-auth | `POST /api/me/privacy-requests {type:"erasure"}` → **hard-delete/anonimisasi** (bukan hanya soft delete) setelah grace period, kecuali data yang wajib disimpan menurut hukum (dijelaskan ke user) |
| Tarik consent | Toggle per tujuan | `DELETE /api/me/consents/{purpose}` |
| Keberatan / pembatasan | Form "Keberatan / batasi pemrosesan" | `POST /api/me/privacy-requests {type:"objection"|"restriction"}` |
| Keberatan keputusan otomatis | Tombol "Minta peninjauan manusia" di hasil keputusan | `POST /api/decisions/{id}/human-review` |

- [ ] **PDP-S1** Semua hak di atas tersedia sebagai UI + API, bukan hanya alamat email di kebijakan privasi
- [ ] **PDP-S2** Tabel `privacy_requests` (`type, status, requested_at, verified_at, due_at, completed_at, handled_by`) + **SLA timer 3 × 24 jam** dengan alert ke admin/DPO bila mendekati `due_at`
- [ ] **PDP-S3** Verifikasi identitas (re-auth / OTP) sebelum eksekusi; aksi di-log sebagai event keamanan (ASVS-F2)
- [ ] **PDP-S4** Panel admin/DPO untuk memproses permintaan yang butuh review manual
- [ ] **PDP-S5** Test otomatis: export berisi semua data user lintas module; erasure tidak meninggalkan data pribadi di tabel turunan (PDP-R3)

---

## 6️⃣ Breach Discovery & Reporting (Kegagalan Pelindungan Data Pribadi)

**Timeline (terverifikasi):** pemberitahuan tertulis **paling lambat 3 × 24 jam (72 jam)** kepada **subjek
data dan Lembaga PDP** — UU PDP **Pasal 46**, diperinci PP 33/2026 **Pasal 114** (Verihubs). Di PP 33/2026,
waktu dihitung **sejak pengendali mengetahui kegagalan secara pasti, patut, dan wajar**.

**Bedanya dengan GDPR** (jangan disamakan): GDPR Art. 33 = 72 jam **ke otoritas saja**, dan notifikasi ke
individu hanya bila risiko tinggi "tanpa penundaan yang tidak semestinya". **UU PDP: 3 × 24 jam ke Lembaga
DAN ke subjek data sekaligus.** Angkanya kebetulan sama (72 jam), cakupannya lebih ketat.

**Isi pemberitahuan minimal:**
- Data pribadi yang terungkap;
- Kapan dan bagaimana data terungkap;
- Upaya penanganan dan pemulihan;
- Kontak petugas pelindungan data (ditambahkan PP 33/2026 Pasal 114 ayat (3)–(4) menurut Verihubs).

Dalam kondisi tertentu (mengganggu pelayanan publik / berdampak serius bagi masyarakat) pengendali **juga wajib
memberitahu masyarakat** (UU PDP Pasal 46 ayat (3); PP 33/2026 Pasal 115).

**Requirement deteksi (WAJIB)** — tidak bisa melapor dalam 72 jam bila tidak tahu terjadi kebocoran:
- [ ] **PDP-B1** Log event keamanan + alert anomali: lonjakan akses/export data, akses lintas tenant ditolak berulang, login admin dari lokasi baru, query massal ke tabel data pribadi ([OWASP-ASVS.md](OWASP-ASVS.md) V16, [SRE-RELIABILITY.md](SRE-RELIABILITY.md) SRE-04)
- [ ] **PDP-B2** Cloudflare Security Events alert aktif (CF-09) & secret scanning (SC-10) — kebocoran credential = potensi kebocoran data
- [ ] **PDP-B3** **Runbook insiden data** `docs/BREACH-RUNBOOK.md`: siapa memutuskan "sudah diketahui secara pasti" (jam 0), kontak DPO & hukum klien, kanal pelaporan ke Lembaga PDP, template surat ke subjek data (3 bahasa), checklist bukti forensik (jangan hapus log), lalu **postmortem blameless** ([SRE-RELIABILITY.md](SRE-RELIABILITY.md) SRE-06)
- [ ] **PDP-B4** Template notifikasi siap pakai memuat 4 elemen isi di atas
- [ ] **PDP-B5** Prosesor (termasuk Sainskerta bila menjadi prosesor/hosting) wajib memberi tahu pengendali **segera** — cantumkan tenggat internal (mis. ≤ 24 jam) di perjanjian agar pengendali masih punya waktu memenuhi 3 × 24 jam

---

## 7️⃣ DPO — Pejabat/Petugas Pelindungan Data Pribadi

**Wajib ditunjuk** (UU PDP Pasal 53; PP 33/2026 Pasal 142 menurut Verihubs, yang menyebutnya PPDP) bila:
1. Pemrosesan untuk kepentingan **pelayanan publik**; **atau**
2. Kegiatan inti pengendali sifatnya memerlukan **pemantauan secara teratur dan sistematis** atas data pribadi
   **dalam skala besar**; **atau**
3. Kegiatan inti pengendali berupa pemrosesan **skala besar** atas **data pribadi yang bersifat spesifik**
   dan/atau data terkait tindak pidana.

DPO boleh dari **dalam atau luar** organisasi (PP 33/2026 Pasal 144), dipilih berdasarkan profesionalitas,
pengetahuan hukum & praktik pelindungan data. Tugas minimal: menginformasikan & memberi saran kepatuhan,
memantau kepatuhan, memberi saran atas DPIA, menjadi narahubung Lembaga PDP.

**Keputusan per project (dicatat di Planning):** DPO adalah kewajiban **pengendali (klien)**, bukan Sainskerta
sebagai vendor — kecuali Sainskerta sendiri adalah pengendali (produk SaaS milik sendiri). Tim memastikan
klien tahu kewajiban ini dan mencatat nama/kontak DPO di ROPA. Walau tidak wajib, menunjuk penanggung jawab
privasi **sangat disarankan**.

---

## ✅ Checklist Kepatuhan Data Pribadi (pass/fail)

**Planning:** [ ] Skrining DPIA 7 pertanyaan dijawab · [ ] Kebutuhan DPO diputuskan · [ ] ROPA awal dibuat · [ ] Tier ASVS per module (L3 bila data spesifik)
**Backend:** [ ] PDP-C1..C5 · [ ] PDP-R1..R6 (job `privacy:purge` + hard-delete/anonimisasi) · [ ] PDP-S1..S5 (endpoint hak subjek data) · [ ] PDP-B1..B5
**Audit:** [ ] DPIA (bila wajib) disetujui · [ ] ROPA sesuai kondisi akhir · [ ] Test erasure & export lulus · [ ] Runbook breach & template notifikasi ada

---

## 🔎 Status Verifikasi Sumber

| Klaim | Status | Sumber |
|---|---|---|
| PP 33/2026 diundangkan 16 Juli 2026, 225 pasal, berlaku 16 Januari 2027 (Pasal 225) | ✅ Konsisten di ≥ 2 sumber sekunder | Verihubs, SIP Law Firm, Hukumonline Pro (judul) |
| Breach notice 3 × 24 jam ke subjek data & Lembaga (UU PDP Pasal 46; PP Pasal 114) + isi notifikasi | ✅ Konsisten | Verihubs; teks UU PDP |
| Tenggat 3 × 24 jam untuk hak subjek data (PP Pasal 71, 78, 92, 99) | ✅ Satu sumber rinci, dikonfirmasi umum oleh SIP Law Firm | Verihubs, SIP Law Firm |
| DPO 3 kondisi (PP Pasal 142, 144) | ✅ Konsisten dengan UU PDP Pasal 53 | Verihubs |
| DPIA 7 pemicu, sebelum pemrosesan, skala besar kontekstual (PP Pasal 120–122) | ✅ | Verihubs, SIP Law Firm |
| ROPA isi minimal; kebijakan retensi (PP Pasal 75); perjanjian prosesor (PP Pasal 14) | ✅ Satu–dua sumber sekunder | SIP Law Firm, Verihubs |
| Denda administratif maks. 2% pendapatan tahunan (PP Pasal 184–185) | ✅ Konsisten | Verihubs, SIP Law Firm |
| Nomor pasal PP 33/2026 terhadap **teks resmi** | ⚠️ **Belum diverifikasi** — teks resmi JDIH/peraturan.go.id tidak diakses | Verifikasi dengan konsultan hukum |
| Ketentuan teknis rinci (format DPIA resmi, kanal pelaporan ke Lembaga) | ⚠️ **Belum ada** — menunggu peraturan Lembaga PDP | — |

**Sumber:**
- [Verihubs — PP 33 Tahun 2026: Isi PP PDP dan Kewajiban Bisnis](https://verihubs.com/blog/pp-33-tahun-2026)
- [SIP Law Firm — PP 33/2026 Mulai Berlaku Januari 2027](https://siplawfirm.id/resources/pp-33-2026-pelindungan-data-pribadi)
- [Hukumonline Pro — Kerangka Implementasi PDP Berlaku Mulai 16 Januari 2027](https://pro.hukumonline.com/a/lt6a97c3fe4527c/pemerintah-akhirnya-terbitkan-kerangka-implementasi-pelindungan-data-pribadi--berlaku-mulai-16-januari-2027)
- [Meridian Hukum — PP No. 33 Tahun 2026](https://meridianhukum.com/peraturan/pp-no-33-tahun-2026)
- [MNL Law — PP 33 Tahun 2026: Mengurai Risiko Hukum](https://mnllaw.co.id/pp-33-tahun-2026-mengurai-risiko-hukum-di-balik-kewajiban-pelindungan-data-pribadi/)
- UU No. 27 Tahun 2022 & PP No. 33 Tahun 2026 — teks resmi: cari di [JDIH BPK](https://peraturan.bpk.go.id/) / [peraturan.go.id](https://peraturan.go.id/)

---

## 🔗 Referensi

- [RULES-OF-THE-GAME.md](../RULES-OF-THE-GAME.md) — Aturan mutlak #19 (dan catatan di aturan #3)
- [standards/OWASP-ASVS.md](OWASP-ASVS.md) — L3 untuk data spesifik, logging, kripto
- [standards/SRE-RELIABILITY.md](SRE-RELIABILITY.md) — Backup, alert, postmortem
- [standards/ISO-27001-27701.md](ISO-27001-27701.md) — ISO 27701 (PIMS) sebagai kerangka organisasi
- [standards/DATABASE-RULES.md](DATABASE-RULES.md) — Soft delete (jaring pengaman operasional)
- [standards/TWELVE-FACTOR.md](TWELVE-FACTOR.md) — Faktor X (staging tanpa data asli), XII (job retensi)
- [phases/01-PLANNING.md](../phases/01-PLANNING.md) · [phases/03-BACKEND.md](../phases/03-BACKEND.md) · [phases/05-AUDIT.md](../phases/05-AUDIT.md)
