# Fase 06: Deployment

> **Fase deployment — project siap masuk ke production. Domain, SSL, environment variables, backup, semuanya harus siap.**

---

## 🎯 Tujuan

1. Build production
2. Deploy ke target (Vercel / VPS / shared hosting / cloud)
3. Setup domain & SSL
4. Setup environment variables
5. Backup database
6. Health check endpoint
7. Monitoring setup
8. Cloudflare edge security & anti-abuse (WAJIB sebelum go-live)

> **🧷 Fleksibilitas Deployment & Database (WAJIB):** Platform yang dibangun Loop harus bisa
> deploy di **Vercel** ATAU **di luar Vercel** (Hostinger, Domainesia, VPS, shared hosting)
> tanpa ubah kode. Koneksi database via `.env` — bisa Postgres (Neon/Supabase/hosting) atau
> MySQL (cPanel/phpMyAdmin). Di Vercel → sesuaikan env vars di dashboard Vercel. Di shared
> hosting → sesuaikan `.env` + phpMyAdmin. Jangan paksa satu provider.
> Lihat [standards/DATABASE-RULES.md](../standards/DATABASE-RULES.md).

---

## 📋 Prasyarat

Sebelum deploy, pastikan:
- [x] Fase audit sudah selesai dan lulus ([05-AUDIT.md](05-AUDIT.md))
- [x] User sudah approve untuk deploy
- [x] Target deployment sudah siap (server aktif, SSH accessible)
- [x] Domain sudah pointing ke server
- [x] Database production sudah siap
- [x] User sudah siapkan environment variables production
- [x] Domain sudah dikelola di Cloudflare (nameserver Cloudflare) — prasyarat Langkah 8

---

## 📋 Langkah-Langkah

### Langkah 1: Build Production

```bash
# Backend build
cd backend

# Laravel
composer install --optimize-autoloader --no-dev
php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan optimize

# Frontend build
cd frontend
npm ci
npm run build
```

### Langkah 2: Deploy ke Target

**VPS (Manual via SSH):**

```bash
# Push ke repository
git push production main

# SSH ke server dan pull
ssh user@server-ip
cd /var/www/project
git pull origin main

# Setup symlink untuk public/storage
php artisan storage:link

# Setup permissions
chmod -R 775 storage bootstrap/cache
chown -R www-data:www-data .

# Restart queue worker (jika ada)
php artisan queue:restart
```

**VPS (Docker):**

```bash
# Build & run
docker-compose -f docker-compose.prod.yml build
docker-compose -f docker-compose.prod.yml up -d

# Check logs
docker-compose logs -f
```

**Shared Hosting:**
```bash
# Upload via FTP/SFTP ke public_html
# Arahkan domain ke folder public (Laravel) atau /dist (Next.js)
# Setup .env
# Setup database via phpMyAdmin
```

### Langkah 3: Setup Domain & SSL

```bash
# Nginx config example
sudo nano /etc/nginx/sites-available/project.com

# Isi konfigurasi
server {
    listen 80;
    server_name project.com www.project.com;
    root /var/www/project/public;
    
    index index.php index.html;
    
    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }
    
    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }
    
    location ~ /\.ht {
        deny all;
    }
}

# Enable site
sudo ln -s /etc/nginx/sites-available/project.com /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx

# Setup SSL dengan Let's Encrypt
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d project.com -d www.project.com
```

### Langkah 4: Setup Environment Variables

```bash
# Production .env
APP_ENV=production
APP_DEBUG=false
APP_URL=https://project.com

DB_HOST=localhost
DB_PORT=3306
DB_DATABASE=project_production
DB_USERNAME=project_user
DB_PASSWORD=secure_password_123

# Mail
MAIL_HOST=smtp.sendgrid.net
MAIL_PORT=587
MAIL_USERNAME=apikey
MAIL_PASSWORD=sendgrid_api_key

# Queue (jika ada)
QUEUE_CONNECTION=database

# Session
SESSION_DRIVER=database
SESSION_LIFETIME=120

# API Keys (jika ada)
OPENAI_API_KEY=sk-xxx
```

### Langkah 5: Backup Database

```bash
# Buat script backup
#!/bin/bash
# backup.sh
BACKUP_DIR="/backups/project"
DATE=$(date +%Y-%m-%d-%H%M)
DB_NAME="project_production"
DB_USER="project_user"
DB_PASS="secure_password_123"

mkdir -p $BACKUP_DIR
mysqldump -u $DB_USER -p$DB_PASS $DB_NAME | gzip > $BACKUP_DIR/$DATE.sql.gz

# Hapus backup lebih dari 30 hari
find $BACKUP_DIR -name "*.sql.gz" -mtime +30 -delete

# Cron job (setiap hari jam 03:00)
# 0 3 * * * /bin/bash /home/user/backup.sh
```

### Langkah 6: Health Check Endpoint

Buat endpoint untuk monitoring:

```php
// routes/api.php
Route::get('/health', function () {
    try {
        DB::connection()->getPdo();
        return response()->json([
            'status' => 'healthy',
            'database' => 'connected',
            'timestamp' => now()
        ]);
    } catch (\Exception $e) {
        return response()->json([
            'status' => 'unhealthy',
            'database' => 'disconnected',
            'error' => $e->getMessage()
        ], 500);
    }
});
```

### Langkah 7: Monitoring Setup

**Minimal monitoring:**
- [ ] Error logging (file log atau Sentry)
- [ ] Uptime monitor (UptimeRobot atau BetterUptime)
- [ ] Database backup ter-schedule
- [ ] Log rotation

**Recommended:**
- [ ] Sentry — error tracking realtime
- [ ] Grafana + Prometheus — performance metrics
- [ ] Alerting — email/Slack untuk error kritis

### Langkah 8: Cloudflare Edge Security & Anti-Abuse (WAJIB)

> **Tidak boleh go-live sebelum semua item WAJIB di bawah ✅.** Detail konfigurasi:
> [standards/SECURITY-CLOUDFLARE.md](../standards/SECURITY-CLOUDFLARE.md)

App publik pasti jadi target: registrasi massal ribuan email palsu, pentest/scan tanpa izin,
brute force login, DDoS. Lapisan ini memblok di edge sebelum request sampai ke server.

- [ ] **CF-01** DNS di-proxy Cloudflare (orange-cloud), SSL/TLS **Full (strict)**; origin VPS hanya terima IP Cloudflare
- [ ] **CF-02** Turnstile di form signup, login, reset password — token **diverifikasi di backend** (`siteverify`), key di `.env`
- [ ] **CF-03** Rate Limiting Rules: register, login, forgot-password, OTP/verify, write API publik
- [ ] **CF-04** WAF: Cloudflare Managed Ruleset + OWASP Core Ruleset aktif; custom rule blok `/.env`, `/.git`, backup file, dll
- [ ] **CF-05** Bot Fight Mode / Super Bot Fight Mode aktif (path webhook pihak ketiga di-skip)
- [ ] **CF-06** DDoS managed ruleset terkonfirmasi aktif
- [ ] **CF-07** *(Anjuran)* API Shield Schema Validation untuk API publik / agent-key
- [ ] **CF-08** Runbook blok IP / negara / ASN tertulis di dokumentasi project
- [ ] **CF-09** Notifications (Security Events Alert, HTTP DDoS Attack Alert) → email/Slack tim

**Verifikasi cepat setelah setup:**
```bash
# Header dari Cloudflare harus muncul (cf-ray) → artinya traffic lewat proxy
curl -sI https://project.com | grep -i "cf-ray"

# Akses path sensitif harus diblok WAF (403)
curl -s -o /dev/null -w "%{http_code}\n" https://project.com/.env

# Signup tanpa token Turnstile harus ditolak backend (400/403)
curl -s -o /dev/null -w "%{http_code}\n" -X POST https://project.com/api/auth/register \
  -H "Content-Type: application/json" -d '{"email":"test@example.com","password":"x"}'
```

---

## ✅ Output Fase 06

Setelah fase ini selesai:
- [x] Production build sukses
- [x] Project ter-deploy ke target
- [x] Domain sudah aktif dengan SSL
- [x] Environment variables production sudah ter-setup
- [x] Database backup berjalan (manual atau cron)
- [x] Health check endpoint berfungsi
- [x] Monitoring sudah aktif
- [x] Cloudflare edge security lulus (CF-01..CF-09, semua item WAJIB ✅)
- [x] User sudah bisa akses project di production

---

## ▶️ Lanjut ke Fase 07

Setelah deploy sukses, update progress dan lanjut ke fase maintenance [07-IMPROVEMENT.md](07-IMPROVEMENT.md).

---

## 🔗 Referensi

- [phases/05-AUDIT.md](05-AUDIT.md) — Laporan audit pra-deploy
- [phases/07-IMPROVEMENT.md](07-IMPROVEMENT.md) — Fase maintenance
- [standards/DATABASE-RULES.md](../standards/DATABASE-RULES.md) — Backup strategy
- [standards/SECURITY-CLOUDFLARE.md](../standards/SECURITY-CLOUDFLARE.md) — Cloudflare edge security & anti-abuse
