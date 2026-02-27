# Odoo 16 Enterprise — Docker Container

Branch `v16` of `taqat-techno/odoo-container`.

This repository contains the **Odoo 16 Enterprise source code** pre-configured for Docker-based development. It is designed to work with a shared Docker image hosted on Docker Hub — no local image build required.

---

## What This Repo Contains

```
odoo-container/ (v16 branch)
├── odoo/                    ← Odoo 16 Enterprise source (standard addons)
├── conf/
│   └── odoo.conf            ← Default Odoo configuration (Docker-ready)
├── project-addons/          ← Clone your custom project modules here
├── .claude/
│   └── commands/
│       └── init-docker-container.md  ← Claude Code command (auto-setup)
├── .vscode/                 ← VSCode workspace settings
├── requirements.txt         ← Python dependencies for this version
├── docker-compose.yml       ← Default compose (no project, generic)
└── .env.example             ← Environment variable template
```

**What is NOT here:** Dockerfile, entrypoint.sh — those live in the `alakosha/odoo-image` Docker Hub repo.

---

## Quick Start

### 1. Clone this repo

```bash
git clone -b v16 https://github.com/taqat-techno/odoo-container.git my-project-odoo16
cd my-project-odoo16
```

### 2. Clone your custom project modules

```bash
gh repo clone taqat-techno/my-project project-addons/my-project
```

### 3. Copy environment file

```bash
cp .env.example .env
```

### 4. Run the setup command (Claude Code)

```
/init-docker-container
```

This command automatically:
- Detects Odoo 16 from `odoo/release.py`
- Scans `project-addons/` for your modules
- Generates `conf/{project}.conf` and `docker-compose.{project}.yml`
- Pulls `alakosha/odoo-image:16.0` from Docker Hub
- Starts the containers

**Access:** http://localhost:8069 · Master password: `123`

---

## Manual Setup (without Claude Code)

```bash
# Pull the Docker image
docker pull alakosha/odoo-image:16.0

# Start with default config (no project)
docker-compose up -d

# Or with a generated project config
docker-compose -f docker-compose.{project}.yml up -d
```

---

## Developer Commands

```bash
# Start
docker-compose -f docker-compose.{project}.yml up -d

# Stop
docker-compose -f docker-compose.{project}.yml down

# View logs
docker-compose -f docker-compose.{project}.yml logs -f odoo

# Open shell inside container
docker-compose -f docker-compose.{project}.yml exec odoo bash

# Update to latest image
docker pull alakosha/odoo-image:16.0
docker-compose -f docker-compose.{project}.yml up -d

# Enable dev mode (auto-reload): set DEV_MODE=1 in .env, then restart
```

---

## Ports

| Port | Service |
|------|---------|
| 8069 | Odoo HTTP |
| 8072 | Gevent / WebSocket |
| 5433 | PostgreSQL (host) → 5432 (container) |
| 5678 | Remote debugger (disabled by default) |

---

## All Versions

| Branch | Odoo | Image Tag | Python | PostgreSQL |
|--------|------|-----------|--------|------------|
| v14 | 14.0 | alakosha/odoo-image:14.0 | 3.8 | 12 |
| v15 | 15.0 | alakosha/odoo-image:15.0 | 3.9 | 12 |
| v16 | 16.0 | alakosha/odoo-image:16.0 | 3.10 | 12 |
| v17 | 17.0 | alakosha/odoo-image:17.0 | 3.10 | 12 |
| v18 | 18.0 | alakosha/odoo-image:18.0 | 3.11 | 15 |
| v19 | 19.0 | alakosha/odoo-image:19.0 | 3.12 | 15 |

---

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `POSTGRES_USER` | `odoo` | Database user |
| `POSTGRES_PASSWORD` | `odoo` | Database password |
| `POSTGRES_DB` | `postgres` | Default database |
| `DEV_MODE` | `0` | Set to `1` for `--dev=all` |
| `ENABLE_DEBUGGER` | `0` | Set to `1` for debugpy on port 5678 |
