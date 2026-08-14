# ARISE — Complete Operations, Execution & Self-Hosting Guide

This guide provides step-by-step instructions for running **ARISE** locally, authenticating, managing manual data inputs, configuring and administering the databases, and self-hosting the entire stack (NestJS backend + PostgreSQL + Redis + Nginx + SSL) on a **Debian Linux** server.

---

## Table of Contents

1. [Architecture & Component Overview](#1-architecture--component-overview)
2. [Local Development: Running the Project](#2-local-development-running-the-project)
   - [2.1 Prerequisites](#21-prerequisites)
   - [2.2 Step 1: Start PostgreSQL & Redis](#22-step-1-start-postgresql--redis)
   - [2.3 Step 2: Configure & Run the Backend](#23-step-2-configure--run-the-backend)
   - [2.4 Step 3: Run the Flutter Client](#24-step-3-run-the-flutter-client)
3. [Authentication & First-Time Account Setup](#3-authentication--first-time-account-setup)
   - [3.1 Registering via UI or API](#31-registering-via-ui-or-api)
   - [3.2 Login & Token Storage Lifecycle](#32-login--token-storage-lifecycle)
4. [Configuration Files & Manual Data Inputs](#4-configuration-files--manual-data-inputs)
   - [4.1 Where Data is Stored](#41-where-data-is-stored)
   - [4.2 What Needs to Be Configured Manually](#42-what-needs-to-be-configured-manually)
   - [4.3 How to Change Configurations](#43-how-to-change-configurations)
5. [Database Management & Administration](#5-database-management--administration)
   - [5.1 Applying Migrations](#51-applying-migrations)
   - [5.2 Visual Database GUI (Prisma Studio)](#52-visual-database-gui-prisma-studio)
   - [5.3 Resetting the Database](#53-resetting-the-database)
6. [Self-Hosting on a Debian Linux Server](#6-self-hosting-on-a-debian-linux-server)
   - [6.1 Server Prerequisites](#61-server-prerequisites)
   - [6.2 Step 1: System Packages & Firewall Setup](#62-step-1-system-packages--firewall-setup)
   - [6.3 Step 2: Clone & Directory Structure](#63-step-2-clone--directory-structure)
   - [6.4 Step 3: Launch PostgreSQL & Redis with Docker](#64-step-3-launch-postgresql--redis-with-docker)
   - [6.5 Step 4: Build & Run Backend with PM2](#65-step-4-build--run-backend-with-pm2)
   - [6.6 Step 5: Nginx Reverse Proxy & SSL (Let's Encrypt)](#66-step-5-nginx-reverse-proxy--ssl-lets-encrypt)
   - [6.7 Step 6: Connect Flutter Client to Production](#67-step-6-connect-flutter-client-to-production)
   - [6.8 Step 7: Automated Database Backups](#68-step-7-automated-database-backups)

---

## 1. Architecture & Component Overview

ARISE is designed around two main decoupled components:

1. **Backend (`/backend`)**:
   - Framework: **NestJS** (Modular Monolith architecture with TypeScript)
   - Primary Database: **PostgreSQL 16** via **Prisma ORM**
   - Cache / Queue: **Redis 7** (used for rate-limiting, job workers, and AI mutexes)
   - AI Engine: Provider abstraction layer supporting **Google Gemini**, **OpenAI**, **Anthropic Claude**, or a local **Mock** adapter.

2. **Frontend (`/flutter frontend`)**:
   - Framework: **Flutter 3.22+** (Dart 3.4+)
   - Local Database: **Drift SQLite** (`arise.db` stored locally on device)
   - State Management: **Riverpod 2.5+**
   - Offline Synchronization: **Persistent Command Queue** + **SyncEngine** (processes actions optimistically and syncs with backend when online).

---

## 2. Local Development: Running the Project

### 2.1 Prerequisites
Ensure the following tools are installed on your machine:
- **Node.js** (v20.x or v22.x LTS): [nodejs.org](https://nodejs.org)
- **Flutter SDK** (v3.22.x or later): [flutter.dev](https://flutter.dev)
- **Docker Desktop** (or native PostgreSQL 16 + Redis 7): [docker.com](https://www.docker.com)

---

### 2.2 Step 1: Start PostgreSQL & Redis

From the root repository directory, run Docker Compose:

```bash
# In project root (E:\Project_Files\Arise or ~/Arise):
docker compose up -d
```

This starts:
- PostgreSQL on `localhost:5432` (Username: `postgres`, Password: `postgres`, Database: `arise`)
- Redis on `localhost:6379`

To verify they are running:
```bash
docker compose ps
```

---

### 2.3 Step 2: Configure & Run the Backend

```bash
# 1. Navigate to the backend folder
cd backend

# 2. Install dependencies
npm install

# 3. Create environment file from template
cp ../.env.example .env
```

Review your `backend/.env` file. The defaults work out of the box with Docker Compose:
```ini
PORT=3000
NODE_ENV=development
DATABASE_URL="postgresql://postgres:postgres@localhost:5432/arise?schema=public"
REDIS_URL="redis://localhost:6379"
JWT_SECRET="arise-dev-jwt-super-secret-key-replace-in-production-min-32-chars"
AI_PROVIDER=mock
```

Apply database migrations:
```bash
# 4. Generate Prisma client & apply database schema (from backend directory)
npm run prisma:generate
npm run prisma:migrate

# 5. Start the backend development server (with hot reload)
npm run start:dev
```

*(Alternatively, from the project root `E:\Project_Files\Arise`, you can simply run `npm run prisma:generate`, `npm run prisma:migrate`, and `npm run start:dev`)*

The backend server will output:
```
[Nest] LOG [NestApplication] Nest application successfully started +50ms
API running at: http://localhost:3000/api/v1
Health check:   http://localhost:3000/health
```

---

### 2.4 Step 3: Run the Flutter Client

Open a new terminal window:

```bash
# 1. Navigate to the Flutter frontend folder
cd "flutter frontend"

# 2. Install Flutter packages
flutter pub get

# 3. (Optional) Rebuild Drift database code if you modified tables:
dart run build_runner build --delete-conflicting-outputs
```

Run on your preferred platform:

- **For Google Chrome (Web Browser)**:
  ```bash
  flutter run -d chrome
  ```

- **For Android Emulator** (auto-routes `10.0.2.2` to host `localhost:3000`):
  ```bash
  flutter run -d emulator-5554
  ```

- **For Custom API URL (e.g. Physical Device or Production Server)**:
  ```bash
  flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:3000/api/v1
  ```

---

## 3. Authentication & First-Time Account Setup

### 3.1 Registering via UI or API

#### Option A: Via the Flutter App UI
1. Launch the app in Chrome or on your device.
2. The initial screen displays the **[ AUTHENTICATION GATE ]**.
3. Toggle to the **SIGN UP** tab.
4. Input your credentials:
   - **Email**: `hunter@arise.dev` (or your email)
   - **Password**: `Password123!` (minimum 8 characters with letters, numbers, and symbols)
   - **Difficulty Mode**: Select `CASUAL` (relaxed penalties) or `HARDCORE` (real-time XP loss on missed quests).
   - **Chronotype**: Select `EARLY BIRD` (morning peak) or `NIGHT OWL` (evening peak).
5. Click **AWAKEN HUNTER**. The app automatically saves authentication tokens and proceeds into Onboarding.

#### Option B: Via cURL / HTTP Request
```bash
curl -X POST http://localhost:3000/api/v1/auth/signup \
  -H "Content-Type: application/json" \
  -d '{
    "email": "solo_hunter@arise.dev",
    "password": "Password123!",
    "difficultyMode": "casual",
    "chronotype": "early_bird"
  }'
```

Response:
```json
{
  "data": {
    "user": {
      "id": "b177980c-dc1c-402a-90af-e363ba9ad028",
      "email": "solo_hunter@arise.dev",
      "difficultyMode": "casual"
    },
    "tokens": {
      "accessToken": "eyJhbGciOi...",
      "refreshToken": "eyJhbGciOi..."
    }
  }
}
```

---

### 3.2 Login & Token Storage Lifecycle

When logging in:
```bash
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "solo_hunter@arise.dev",
    "password": "Password123!"
  }'
```

- **Storage Location**: The Flutter app securely saves the token pair into platform-encrypted hardware storage (`flutter_secure_storage` / `SecureTokenStorage`).
- **Silent Refresh**: Access tokens expire in 15 minutes; the app's `AuthInterceptor` automatically calls `POST /api/v1/auth/refresh` using the 30-day refresh token in the background with a thread-safe mutex lock.

---

## 4. Configuration Files & Manual Data Inputs

### 4.1 Where Data is Stored

| Component | Storage Type | File / Location | Purpose |
|---|---|---|---|
| **Backend Config** | Environment Variables | `backend/.env` | Database URLs, JWT secrets, AI API keys, ports, CORS origins. |
| **Server Database** | PostgreSQL 16 Tables | Docker volume `postgres_data` or Postgres host | Users, Characters, Quests, Bosses, Dungeons, Ledger, History. |
| **Client Database** | SQLite (Drift) | Local device file: `arise.db` | Client-side offline cache, local quests, offline command queue. |
| **RPG Balancing** | JSON Configuration | `backend/src/config/*.json` | XP curves, level thresholds, screen time mana modifiers. |
| **Client API URL** | Dart Defines | `flutter frontend/lib/core/network/api_config.dart` | Configures backend endpoint per platform. |

---

### 4.2 What Needs to Be Configured Manually

1. **AI API Keys (Optional)**:
   If you want to use real AI for quest planning and coaching rather than the built-in Mock provider, obtain an API key and update `backend/.env`:
   - **Google Gemini**: Set `AI_PROVIDER=gemini` and `GEMINI_API_KEY=AIzaSy...`
   - **OpenAI**: Set `AI_PROVIDER=openai` and `OPENAI_API_KEY=sk-...`
   - **Anthropic Claude**: Set `AI_PROVIDER=claude` and `ANTHROPIC_API_KEY=sk-ant-...`

2. **JWT Secret (Required for Production)**:
   In `backend/.env`, replace `JWT_SECRET` with a randomly generated 64-character string:
   ```bash
   # Generate a secure random 64-character secret
   node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
   ```

3. **CORS Origins**:
   If hosting Flutter Web on a custom domain (e.g. `https://app.yourdomain.com`), add it to `CORS_ORIGIN` in `backend/.env`:
   ```ini
   CORS_ORIGIN="http://localhost:3000,http://localhost:8443,https://app.yourdomain.com"
   ```

---

## 5. Database Management & Administration

### 5.1 Applying Migrations

Whenever models in `backend/src/db/prisma/schema.prisma` are modified:

```bash
cd backend
# Create and apply migration
npx prisma migrate dev --name <migration_name>
```

For production deployments (applies pending migrations without prompting):
```bash
npx prisma migrate deploy
```

---

### 5.2 Visual Database GUI (Prisma Studio)

To inspect, edit, or delete database rows (users, characters, quests, boss HP) via a clean visual interface:

```bash
cd backend
npx prisma studio
```
Open your browser at: **`http://localhost:5555`**

---

### 5.3 Resetting the Database

To wipe and reinitialize the local database with a fresh schema:

```bash
cd backend
npx prisma migrate reset --force
```

---

## 6. Self-Hosting on a Debian Linux Server

This section walks through deploying the complete ARISE backend and database on a fresh **Debian 12 (Bookworm)** or **Debian 11 (Bullseye)** VPS (e.g., Hetzner, DigitalOcean, Linode, AWS EC2).

---

### 6.1 Server Prerequisites
- A Debian 12 VPS with at least **2 GB RAM** and **1 vCPU**.
- A registered domain name (e.g. `api.yourdomain.com`) with a DNS **A Record** pointing to your server's public IP address.
- Root or `sudo` shell access.

---

### 6.2 Step 1: System Packages & Firewall Setup

SSH into your server:
```bash
ssh root@your_server_ip
```

Update system and install required tools:
```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl git ufw nginx certbot python3-certbot-nginx build-essential
```

Install **Node.js 20 LTS** & **PM2** process manager:
```bash
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs
sudo npm install -g pm2
```

Install **Docker** & **Docker Compose**:
```bash
# Add Docker repository
sudo apt install -y ca-certificates gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

Configure Firewall (UFW):
```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 80/tcp    # HTTP
sudo ufw allow 443/tcp   # HTTPS
sudo ufw enable
```

---

### 6.3 Step 2: Clone & Directory Structure

```bash
# Create application directory
sudo mkdir -p /opt/arise
sudo chown -R $USER:$USER /opt/arise

# Clone repository
cd /opt/arise
git clone https://github.com/wantedfelconer/Arise.git .
```

---

### 6.4 Step 3: Launch PostgreSQL & Redis with Docker

Create the production Docker Compose file in `/opt/arise/docker-compose.prod.yml`:

```yaml
services:
  postgres:
    image: postgres:16-alpine
    container_name: arise-postgres
    restart: always
    environment:
      POSTGRES_USER: arise_admin
      POSTGRES_PASSWORD: StrongProductionPasswordGoesHere123!
      POSTGRES_DB: arise_production
    ports:
      - "127.0.0.1:5432:5432" # Bind only to localhost for security
    volumes:
      - /var/lib/arise/postgres_data:/var/lib/postgresql/data
    networks:
      - arise-prod-network

  redis:
    image: redis:7-alpine
    container_name: arise-redis
    restart: always
    command: redis-server --requirepass StrongRedisPasswordGoesHere123!
    ports:
      - "127.0.0.1:6379:6379" # Bind only to localhost
    volumes:
      - /var/lib/arise/redis_data:/data
    networks:
      - arise-prod-network

volumes:
  postgres_data:
  redis_data:

networks:
  arise-prod-network:
    driver: bridge
```

Start the databases:
```bash
docker compose -f docker-compose.prod.yml up -d
```

Verify containers are running:
```bash
docker compose -f docker-compose.prod.yml ps
```

---

### 6.5 Step 4: Build & Run Backend with PM2

```bash
cd /opt/arise/backend

# 1. Install production dependencies
npm install

# 2. Create production environment file
cat << 'EOF' > .env
PORT=3000
NODE_ENV=production
LOG_LEVEL=info
CORS_ORIGIN="https://yourdomain.com,https://app.yourdomain.com"

# Database
DATABASE_URL="postgresql://arise_admin:StrongProductionPasswordGoesHere123!@127.0.0.1:5432/arise_production?schema=public"

# Redis
REDIS_URL="redis://:StrongRedisPasswordGoesHere123!@127.0.0.1:6379"

# Cryptography (Replace with a generated secret)
JWT_SECRET="generate-a-64-character-random-hex-string-for-production-signing"
JWT_ACCESS_EXPIRES_IN="15m"
JWT_REFRESH_EXPIRES_IN="30d"

# Rate Limiting
RATE_LIMIT_TTL=60
RATE_LIMIT_LIMIT=120

# AI Provider (Gemini / OpenAI / Claude / Mock)
AI_PROVIDER=gemini
AI_DAILY_QUOTA=50
GEMINI_API_KEY="your-gemini-api-key-here"
EOF

# 3. Apply database migrations
npx prisma generate
npx prisma migrate deploy

# 4. Build TypeScript NestJS code
npm run build

# 5. Start Backend with PM2 process manager
pm2 start dist/src/main.js --name arise-backend

# 6. Save PM2 state and configure systemd startup on reboot
pm2 save
pm2 startup
```

Check backend status and logs:
```bash
pm2 status
pm2 logs arise-backend
```

Test localhost response:
```bash
curl http://localhost:3000/health
# Should return: {"status":"ok","timestamp":"..."}
```

---

### 6.6 Step 5: Nginx Reverse Proxy & SSL (Let's Encrypt)

Create an Nginx configuration file for your ARISE API subdomain:

```bash
sudo nano /etc/nginx/sites-available/arise-api
```

Paste the following configuration (replace `api.yourdomain.com` with your actual domain):

```nginx
server {
    server_name api.yourdomain.com;

    # Client body limit for file/avatar uploads
    client_max_body_size 25M;

    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;

        # WebSocket & connection upgrade support
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;

        # Real IP headers for rate limiting and proxy logging
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # Timeouts for AI stream generation
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
}
```

Enable site and test Nginx config:
```bash
sudo ln -s /etc/nginx/sites-available/arise-api /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

Obtain a free SSL certificate via Let's Encrypt:
```bash
sudo certbot --nginx -d api.yourdomain.com
```

Select automatic HTTP to HTTPS redirection when prompted.

Test your public API endpoint:
```bash
curl https://api.yourdomain.com/health
# Returns: {"status":"ok"}
```

---

### 6.7 Step 6: Connect Flutter Client to Production

Now build or run your Flutter application configured with your production server URL:

- **Build Production Android APK**:
  ```bash
  cd "flutter frontend"
  flutter build apk --release --dart-define=API_BASE_URL=https://api.yourdomain.com/api/v1
  ```

- **Build Production Web Bundle**:
  ```bash
  cd "flutter frontend"
  flutter build web --release --dart-define=API_BASE_URL=https://api.yourdomain.com/api/v1
  ```

- **Run in Development pointing to Production Server**:
  ```bash
  flutter run -d chrome --dart-define=API_BASE_URL=https://api.yourdomain.com/api/v1
  ```

---

### 6.8 Step 7: Automated Database Backups

Setup a daily PostgreSQL backup cron job:

```bash
# Create backup directory
sudo mkdir -p /var/backups/arise
sudo chown -R $USER:$USER /var/backups/arise

# Open crontab editor
crontab -e
```

Add the following line to execute daily at 03:00 AM UTC:
```cron
0 3 * * * docker exec arise-postgres pg_dump -U arise_admin arise_production | gzip > /var/backups/arise/arise_backup_$(date +\%Y\%m\%d_\%H\%M\%S).sql.gz
```

To restore a backup if ever needed:
```bash
gunzip < /var/backups/arise/arise_backup_YYYYMMDD_HHMMSS.sql.gz | docker exec -i arise-postgres psql -U arise_admin -d arise_production
```

---

## 7. Operational Summary & Quick Reference

| Action | Command |
|---|---|
| **View Backend Status** | `pm2 status arise-backend` |
| **View Backend Logs** | `pm2 logs arise-backend` |
| **Restart Backend** | `pm2 restart arise-backend` |
| **View Database Containers** | `docker compose -f /opt/arise/docker-compose.prod.yml ps` |
| **Restart Databases** | `docker compose -f /opt/arise/docker-compose.prod.yml restart` |
| **Run Migrations** | `cd /opt/arise/backend && npx prisma migrate deploy` |
| **Check Nginx Status** | `sudo systemctl status nginx` |
| **Test Health Endpoint** | `curl https://api.yourdomain.com/health` |
