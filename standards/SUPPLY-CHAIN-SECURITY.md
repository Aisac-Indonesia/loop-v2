# SUPPLY-CHAIN-SECURITY.md — Standar Keamanan Dependency & Supply Chain

> **WAJIB untuk setiap project Sainskerta.** Kode kita bisa aman, tapi satu dependency yang dibajak cukup untuk
> mencuri semua secret di laptop developer & CI. Standar ini adalah gate **pass/fail** — dicek di
> [phases/03-BACKEND.md](../phases/03-BACKEND.md) (saat setup) dan [phases/05-AUDIT.md](../phases/05-AUDIT.md) (sebelum deploy).
>
> Aturan mutlak: [RULES-OF-THE-GAME.md #17](../RULES-OF-THE-GAME.md#17-supply-chain--dependency-security--wajib)

---

## ⚠️ Kenapa Ini Wajib — Konteks Insiden

### "Black October 2026"

Label **"Black October 2026"** dipakai media keamanan sekunder untuk rangkaian serangan supply-chain yang
beruntun di Oktober 2026 (mis. [ai-heartland.com — Black October 2026](https://ai-heartland.com/security/black-october-2026/)).
**Catatan:** ini **bukan nama insiden resmi** — tidak ada advisory npm/GitHub/PyPI yang memakai nama itu.
Insiden-insiden di bawahnya sendiri **terverifikasi** dari beberapa sumber independen:

| Tanggal | Insiden | Ekosistem | Pola | Sumber |
|---------|---------|-----------|------|--------|
| 7–8 Okt 2026 | Tensorlake npm SDK `0.5.144` dibajak — payload `preinstall` mencuri kredensial developer/cloud & mencoba menyebar (keluarga Shai-Hulud). **Provenance-nya valid** — provenance saja tidak cukup. | npm | Token/akun dibajak → publish versi baru → jalan saat install | [Sonatype](https://www.sonatype.com/blog/hijacked-tensorlake-npm-turned-install-into-credential-risk) |
| 19 Okt 2026 | OVHcloud CLI — release binary di GitHub diganti (v0.11.0–v0.15.0) via akun developer yang dibajak; ±250 download dalam ±1,5 jam | GitHub Releases (binary) | Akun dibajak → aset release ditukar | [BleepingComputer](https://www.bleepingcomputer.com/news/security/ovhcloud-cli-releases-backdoored-on-github-to-steal-developer-secrets/), [Dark Reading](https://www.darkreading.com/cyberattacks-data-breaches/ovhcloud-github-compromise-glassworm-threat-actors) |
| 21 Okt 2026 | LiteLLM `1.107.0` berbahaya di PyPI + image Docker/GHCR, live ±1 jam 44 menit; root cause: master key bocor (Mei) + token org-owner GitHub dicuri → workflow release dibajak | PyPI, Docker | Token CI over-privileged → release pipeline dibajak | [Help Net Security](https://www.helpnetsecurity.com/2026/10/22/litellm-compromised-supply-chain-attack-pypi-docker/), [BleepingComputer](https://bleepingcomputer.com/news/security/litellm-release-pipeline-hacked-to-distribute-info-stealer-malware) |
| Okt 2026 | "Mini Shai-Hulud" — 300+ paket npm terdampak, pencurian kredensial saat install | npm | Worm self-propagating via token maintainer | [SecurityWeek](https://www.securityweek.com/over-320-npm-packages-hit-by-fresh-mini-shai-hulud-supply-chain-attack/) |

**Pola bersama** (4 langkah): akun/token maintainer dicuri → artefak publik ditukar/di-publish ulang →
kode jalan **saat install** (`preinstall`/`postinstall`, `.pth`, binary) → panen secret (cloud key, `.env`, SSH, token npm/GitHub).

Konteks sebelumnya (2025): kompromi `chalk`/`debug` via phishing maintainer (Sep 2025) dan worm Shai-Hulud /
Shai-Hulud 2.0 (Sep & Nov 2025, ratusan paket, puluhan ribu repo bocor secret) —
[AWS Security Blog](https://aws.amazon.com/blogs/security/defending-against-supply-chain-attacks-like-chalk-debug-and-the-shai-hulud-worm),
[Check Point](https://blog.checkpoint.com/research/shai-hulud-2-0-inside-the-second-coming-the-most-aggressive-npm-supply-chain-attack-of-2025/).

### Respons ekosistem yang relevan (sumber primer)

- **npm v12 GA (Juli 2026):** dependency lifecycle scripts (`preinstall`/`install`/`postinstall`) & build `node-gyp`
  **default OFF** (`allowScripts`), dependency dari git/URL remote **default ditolak** (`--allow-git`, `--allow-remote`).
  Approve script yang dipercaya dengan `npm approve-scripts`, commit allowlist di `package.json`.
  Token granular "bypass 2FA" kehilangan hak publish langsung → pindah ke **trusted publishing (OIDC)** / **staged publishing**.
  — [GitHub Changelog 2026-07-07](https://github.blog/changelog/2026-07-07-npm-install-time-security-and-gat-bypass2fa-deprecation)
- **pnpm 10+:** build script dependency diblok default, allowlist via `onlyBuiltDependencies`; `minimumReleaseAge`
  untuk menunda adopsi versi yang baru rilis. — [pnpm settings](https://pnpm.io/settings)

---

## 📏 Aturan (WAJIB)

| ID | Aturan |
|----|--------|
| **SC-01** | Exact version pinning — tidak ada `^`/`~`/`*`/`latest` di `package.json` production |
| **SC-02** | Lockfile di-commit = source of truth; CI install pakai mode frozen & **gagal** jika lockfile tidak sinkron |
| **SC-03** | Dependency baru / major bump wajib lolos **Dependency Review Gate** sebelum merge |
| **SC-04** | Vulnerability & malware scan di CI — **hard-fail** di severity high/critical |
| **SC-05** | Install scripts pihak ketiga **mati by default**; hanya allowlist yang sudah di-review |
| **SC-06** | Paket yang dipublish tim Sainskerta: 2FA + trusted publishing (OIDC) + provenance |
| **SC-07** | Docker base image di-pin pakai **digest**, rebuild + rescan terjadwal |
| **SC-08** | Renovate/Dependabot: grouped PR, cooldown, **tidak ada auto-merge major**, wajib CI hijau + review manusia |
| **SC-09** | SBOM di-generate di CI/release & disimpan sebagai build artifact |
| **SC-10** | Secret hygiene di CI: token least-privilege & berumur pendek, tidak ada long-lived publish token |

---

### SC-01 — Exact Version Pinning

```bash
# Set sekali per repo — semua `install <pkg>` otomatis exact
npm config set save-exact true --location=project     # → .npmrc: save-exact=true
pnpm config set save-exact true --location=project    # → .npmrc: save-exact=true
```

```jsonc
// ✅ Benar
"dependencies": { "express": "5.1.0" }
// ❌ Salah
"dependencies": { "express": "^5.1.0", "lodash": "~4.17.21", "zod": "latest" }
```

Cek cepat (CI) — gagal jika ada range di `dependencies`/`devDependencies`:

```bash
jq '[(.dependencies, .devDependencies) | objects | to_entries[]
     | select(.value | test("^[\\^~*<>]|latest|\\|\\|")) | .key]
    | if length > 0 then error("unpinned: \(join(", "))") else empty end' package.json
```

> Pinning di `package.json` saja **tidak cukup** — dependency transitif tetap diatur lockfile. Itu sebabnya SC-02 wajib.

### SC-02 — Lockfile sebagai Source of Truth

- `package-lock.json` / `pnpm-lock.yaml` / `yarn.lock` **WAJIB di-commit**. Lockfile menyimpan hash integrity per paket.
- CI **tidak boleh** re-resolve dependency:

| Package manager | Perintah CI |
|-----------------|-------------|
| npm | `npm ci` |
| pnpm | `pnpm install --frozen-lockfile` |
| yarn (berry) | `yarn install --immutable` |
| Composer (PHP) | `composer install --no-dev` + `composer validate --strict` (pakai `composer.lock`) |
| pip | `pip install --require-hashes -r requirements.txt` (hasil `pip-compile --generate-hashes`) |

- Perintah di atas otomatis **gagal** kalau lockfile tidak sinkron dengan manifest → itu yang kita mau.
- PR yang mengubah lockfile tanpa mengubah manifest → reviewer wajib tanya kenapa.

Referensi: [OpenSSF npm best practices](https://github.com/ossf/package-manager-best-practices/blob/main/published/npm.md)

### SC-03 — Dependency Review Gate (sebelum merge)

Setiap **dependency baru** atau **major version bump** wajib dicek & dicatat di PR description:

| Sinyal | Merah 🚩 jika |
|--------|---------------|
| Publisher reputation | Akun baru, tanpa riwayat, nama mirip paket populer (typosquat) |
| Jumlah maintainer | 1 maintainer untuk paket kritikal, atau maintainer **baru ditambahkan** baru-baru ini |
| Download trend | Download kecil/anjlok, atau lonjakan tidak wajar |
| Versi | Major baru muncul tiba-tiba tanpa changelog/tag git yang cocok |
| **Ownership transfer** | Paket/repo baru pindah tangan — **sinyal umum sebelum kompromi** |
| Install scripts | Ada `preinstall`/`install`/`postinstall` |
| Release age | Versi dirilis < 7 hari lalu (lihat cooldown SC-08) |

Tools bantu: `npm view <pkg> maintainers time`, [socket.dev](https://socket.dev) (skor & alert install scripts / network / obfuscation),
[deps.dev](https://deps.dev), [OpenSSF Scorecard](https://scorecard.dev), GitHub
[`actions/dependency-review-action`](https://github.com/actions/dependency-review-action).

**Lebih baik tidak menambah dependency sama sekali** kalau bisa diselesaikan dengan stdlib / fitur native / beberapa baris kode.

### SC-04 — Vulnerability & Malware Scanning di CI

Minimal **satu** scanner advisory + (disarankan) **satu** scanner perilaku/malware, hard-fail di high/critical:

```yaml
# .github/workflows/supply-chain.yml (cuplikan)
- run: npm ci                                   # atau pnpm install --frozen-lockfile
- run: npm audit --audit-level=high             # pnpm audit --audit-level high
- run: npm audit signatures                     # verifikasi signature & provenance registry
- uses: aquasecurity/trivy-action@<commit-sha>  # atau anchore/grype; fs + image scan
  with: { scan-type: fs, severity: HIGH,CRITICAL, exit-code: '1' }
# Opsional: Socket.dev GitHub App / Snyk untuk deteksi malware & install-script mencurigakan
```

- GitHub Actions pihak ketiga juga dependency → **pin by commit SHA**, bukan tag (`@v4`).
- Temuan yang belum ada fix → dokumentasikan exception (ID advisory, alasan, tanggal kedaluwarsa) di `SECURITY-EXCEPTIONS.md`, bukan dimatikan diam-diam.

### SC-05 — Install Scripts Pihak Ketiga

Default: **tidak ada** install script pihak ketiga yang jalan.

```ini
# .npmrc (npm < 12; npm 12+ sudah default off)
ignore-scripts=true
```

```jsonc
// package.json — pnpm 10+: hanya paket ini yang boleh menjalankan build script
"pnpm": { "onlyBuiltDependencies": ["esbuild", "sharp"] }
```

Audit paket yang punya install script:

```bash
npm approve-scripts --allow-scripts-pending   # npm 12+: lihat & approve, commit allowlist
pnpm ignored-builds                           # pnpm 10+: daftar build script yang diblok
# Universal (semua versi npm): cari lifecycle scripts di node_modules
npm query ':attr(scripts, [preinstall]), :attr(scripts, [install]), :attr(scripts, [postinstall])' \
  | jq -r '.[] | "\(.name)@\(.version)"'
```

Paket native yang butuh build (mis. `sharp`, `esbuild`, `bcrypt`) → masuk allowlist **setelah** review SC-03.

### SC-06 — Paket yang Dipublish Tim Sainskerta

- **2FA wajib** di semua akun npm/PyPI/GitHub tim (security key / TOTP, bukan SMS).
- Publish **hanya dari CI** via [npm trusted publishing (OIDC)](https://docs.npmjs.com/trusted-publishers) —
  tidak ada token publish long-lived di laptop / secret CI.
- **Provenance** (Sigstore) aktif: `npm publish --provenance` (otomatis saat trusted publishing dari GitHub Actions).
- Gunakan [staged publishing](https://docs.npmjs.com/staged-publishing) / approval manusia untuk release.
- GitHub: aktifkan **release immutability** & branch protection (pelajaran insiden OVHcloud).

> ⚠️ Provenance membuktikan *dari pipeline mana* paket dibangun, **bukan** bahwa isinya aman — kasus Tensorlake
> tetap punya provenance valid. Provenance melengkapi SC-03/SC-04, tidak menggantikan.

### SC-07 — Docker Base Image Pinned by Digest

```dockerfile
# ❌ Salah — tag bisa ditimpa
FROM node:22-alpine
# ✅ Benar — tag untuk manusia, digest untuk mesin
FROM node:22-alpine@sha256:<digest>
```

- Ambil digest: `docker buildx imagetools inspect node:22-alpine`.
- Renovate/Dependabot meng-update digest (PR terpisah, tetap lewat CI).
- **Rebuild + rescan terjadwal** (mis. mingguan via `schedule:` cron di CI) — image yang tidak berubah tetap bisa kena CVE baru.

### SC-08 — Renovate / Dependabot

```jsonc
// renovate.json
{
  "extends": ["config:recommended", ":pinAllExceptPeerDependencies", "helpers:pinGitHubActionDigests"],
  "minimumReleaseAge": "7 days",          // cooldown: versi baru ditahan 7 hari
  "packageRules": [
    { "matchUpdateTypes": ["minor", "patch"], "groupName": "non-major deps" },
    { "matchUpdateTypes": ["major"], "automerge": false, "dependencyDashboardApproval": true }
  ]
}
```

```yaml
# .github/dependabot.yml (alternatif)
version: 2
updates:
  - package-ecosystem: npm
    directory: /
    schedule: { interval: weekly }
    cooldown: { default-days: 7 }
    groups:
      non-major: { update-types: [minor, patch] }
```

- **Tidak ada auto-merge untuk major.** Minor/patch pun wajib CI hijau + 1 review manusia.
- Samakan cooldown bot dengan `minimumReleaseAge` pnpm (kalau dipakai) supaya bot tidak membuka PR yang tidak bisa di-install.
- Security update boleh bypass cooldown — tetap lewat CI + review.

### SC-09 — SBOM

```bash
npx @cyclonedx/cyclonedx-npm@<versi-exact> --output-file sbom.cdx.json   # dari lockfile npm
syft dir:. -o cyclonedx-json=sbom.cdx.json                               # universal (npm/pnpm/composer/pip)
syft <image>@sha256:<digest> -o spdx-json=sbom-image.spdx.json           # untuk Docker image
```

- Generate di setiap release, upload sebagai **build artifact** (`actions/upload-artifact`) & lampirkan ke GitHub Release.
- Saat ada insiden baru: grep SBOM semua release untuk tahu dalam hitungan menit apakah kita terdampak.

### SC-10 — Secret Hygiene di CI

- `permissions:` di GitHub Actions minimal (`contents: read` default), `id-token: write` hanya di job publish.
- Tidak ada PAT / token org-owner di CI (root cause LiteLLM). Rotasi token yang pernah terekspos — **segera**, bukan nanti.
- Jika dependency yang ter-install ternyata berbahaya: anggap mesin **fully compromised** → rotasi semua secret yang bisa diakses mesin/CI tersebut.

---

## ✅ Checklist Supply Chain (pass/fail)

- [ ] SC-01 Tidak ada `^`/`~`/`*`/`latest` di manifest; `.npmrc` `save-exact=true`
- [ ] SC-02 Lockfile ter-commit; CI pakai `npm ci` / `--frozen-lockfile` / `--immutable`
- [ ] SC-03 Setiap dependency baru / major bump punya catatan Dependency Review di PR
- [ ] SC-04 `npm audit --audit-level=high` (+ Trivy/Grype/Socket/Snyk) hard-fail di CI; Actions di-pin SHA
- [ ] SC-05 Install scripts default off; allowlist ter-commit & ter-review
- [ ] SC-06 (jika publish paket) 2FA + trusted publishing + provenance + release immutability
- [ ] SC-07 Semua `FROM` di-pin digest; rebuild/rescan terjadwal aktif
- [ ] SC-08 Renovate/Dependabot: grouped, cooldown 7 hari, no auto-merge major
- [ ] SC-09 SBOM ter-generate & tersimpan sebagai artifact release
- [ ] SC-10 Token CI least-privilege, tidak ada long-lived publish/org-owner token

---

## 🔗 Referensi

- [RULES-OF-THE-GAME.md](../RULES-OF-THE-GAME.md) — Aturan mutlak #17
- [phases/03-BACKEND.md](../phases/03-BACKEND.md) — Setup dependency & CI
- [phases/05-AUDIT.md](../phases/05-AUDIT.md) — Audit supply chain sebelum deploy
- [phases/06-DEPLOYMENT.md](../phases/06-DEPLOYMENT.md) — Docker image & release
- [standards/SECURITY-CLOUDFLARE.md](SECURITY-CLOUDFLARE.md) — Keamanan edge (lapisan berbeda, saling melengkapi)
- [OpenSSF Package Manager Best Practices](https://github.com/ossf/package-manager-best-practices)
- [GitHub Changelog — npm v12 install-time security](https://github.blog/changelog/2026-07-07-npm-install-time-security-and-gat-bypass2fa-deprecation)
- [standards/OWASP-ASVS.md](OWASP-ASVS.md) — Keamanan lapisan aplikasi (V15 Secure Coding & Architecture mencakup dependency)
- [standards/ISO-27001-27701.md](ISO-27001-27701.md) — Supplier relationships (Annex A 5.19–5.23)
- [standards/TWELVE-FACTOR.md](TWELVE-FACTOR.md) — Faktor II (Dependencies) & V (Build, release, run)
