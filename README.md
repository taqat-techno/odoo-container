<p align="center">
  <img src="https://www.taqatechno.com/logo.png" alt="TaqaTechno" width="200"/>
</p>

<h1 align="center">Odoo 15 &mdash; Docker Development Environment</h1>

<p align="center">
  <strong>Clone. Build. Develop.</strong><br/>
  Production-grade Odoo Enterprise inside Docker &mdash; ready in under 2 minutes.
</p>

<p align="center">
  <a href="https://github.com/taqat-techno/odoo-container/releases/tag/v15.0.0"><img src="https://img.shields.io/badge/release-v15.0.0-blue" alt="Release"/></a>
  <a href="#all-versions"><img src="https://img.shields.io/badge/versions-14%20%7C%2015%20%7C%2016%20%7C%2017%20%7C%2018%20%7C%2019-green" alt="Versions"/></a>
  <a href="#ide-integration"><img src="https://img.shields.io/badge/IDE-VSCode%20%7C%20PyCharm-purple" alt="IDE Support"/></a>
  <a href="https://www.docker.com/"><img src="https://img.shields.io/badge/Docker-ready-2496ED?logo=docker&logoColor=white" alt="Docker"/></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-Odoo%20Enterprise-red" alt="License"/></a>
</p>

---

## What Is This?

A **complete, containerized Odoo 15 Enterprise development environment**. Everything you need to develop, test, and run Odoo modules locally without installing Python, PostgreSQL, or any system dependencies on your machine.

Each version branch contains:

- **Full Odoo Enterprise source** &mdash; ready to reference, debug, and extend
- **PostgreSQL database** &mdash; isolated per project, auto-configured with health checks
- **Docker Compose orchestration** &mdash; one command to start everything
- **IDE configurations** &mdash; VSCode and PyCharm pre-configured with Odoo source paths
- **Dev mode & debugger** &mdash; toggle via environment variables
- **AI-assisted setup** &mdash; Claude Code `/init-docker-container` command

---

## Quick Start

### 1. Clone

```bash
git clone -b v15 https://github.com/taqat-techno/odoo-container.git odoo15
cd odoo15
```

### 2. Build & Run

```bash
docker-compose up -d --build
```

### 3. Open

Visit **http://localhost:8069** in your browser.

| | |
|---|---|
| **Master Password** | `123` |
| **Database** | Created on first access |

That is it. Odoo 15 is running.

---

## Architecture

```
Docker Compose (odoo15_net)
  +-- odoo15_db  (PostgreSQL 12)
  |   +-- Port: 5433 -> 5432
  |   +-- Health: pg_isready
  |
  +-- odoo15_web (Odoo 15 Enterprise)
      +-- Port: 8069 -> 8069 (HTTP)
      +-- Port: 8072 -> 8072 (Gevent/WebSocket)
      +-- Port: 5678 -> 5678 (Debugger, when enabled)
      +-- Health: /web/health
      +-- Python 3.9 | Debian Bullseye
```

### Ports

| Service | Host Port | Container Port | Purpose |
|---------|-----------|----------------|---------|
| Odoo HTTP | `8069` | `8069` | Web interface & API |
| Odoo Gevent | `8072` | `8072` | WebSocket / Longpolling |
| PostgreSQL | `5433` | `5432` | Database access |
| Debugger | `5678` | `5678` | debugpy (when enabled) |

---

## Environment Variables

Configure via `.env` file (copy from `.env.example`):

```bash
cp .env.example .env
```

| Variable | Default | Description |
|----------|---------|-------------|
| `POSTGRES_USER` | `odoo` | PostgreSQL username |
| `POSTGRES_PASSWORD` | `odoo` | PostgreSQL password |
| `POSTGRES_DB` | `postgres` | PostgreSQL database |
| `DEV_MODE` | `0` | Set to `1` for `--dev=all` (auto-reload, debug assets) |
| `ENABLE_DEBUGGER` | `0` | Set to `1` for debugpy on port 5678 |

---

## Dev Mode

Enable auto-reload and debug assets for active development:

1. Copy `.env.example` to `.env`
2. Set `DEV_MODE=1`
3. Restart: `docker-compose up -d`

Odoo will auto-reload on Python file changes and serve unminified assets. This is equivalent to running Odoo with `--dev=all`.

---

## Debugging (VSCode / PyCharm)

Attach your IDE debugger to the running Odoo container:

1. Set `ENABLE_DEBUGGER=1` in `.env`
2. Restart: `docker-compose up -d`
3. Odoo will wait for debugger to attach on port `5678`

### VSCode

Add to `.vscode/launch.json`:

```json
{
  "name": "Attach to Odoo Docker",
  "type": "debugpy",
  "request": "attach",
  "connect": { "host": "localhost", "port": 5678 },
  "pathMappings": [
    { "localRoot": "${workspaceFolder}", "remoteRoot": "/opt/odoo/source" },
    { "localRoot": "${workspaceFolder}/projects", "remoteRoot": "/opt/odoo/custom-addons" }
  ]
}
```

### PyCharm

Create a **Python Remote Debug** configuration pointing to `localhost:5678`.

---

## Project Setup

### Option A: Claude Code (Recommended)

If you use [Claude Code](https://claude.ai/code), the built-in command handles everything:

```
/init-docker-container
```

This will:
1. Auto-detect the Odoo version from the git branch
2. Let you pick your project from `projects/`
3. Scan for Odoo modules and map addons paths
4. Generate project-specific config and docker-compose files
5. Create PyCharm run configuration + VSCode tasks
6. Optionally build and start the containers

### Option B: Manual Setup

```bash
# 1. Clone your modules into projects/
gh repo clone your-org/your-modules projects/my_project

# 2. Edit conf/odoo.conf - add your custom addons path
#    addons_path = /opt/odoo/source/odoo/addons,/opt/odoo/custom-addons/my_project

# 3. Start
docker-compose up -d --build

# 4. Install your module
docker-compose exec odoo python /opt/odoo/source/setup/odoo \
  -d my_db -i my_module --stop-after-init
```

---

## IDE Integration

### VSCode

Open this directory in VSCode &mdash; it is pre-configured:

- **Pylance** source paths point to `odoo/` for autocomplete and go-to-definition
- **Docker extension** &mdash; right-click `docker-compose.yml` > Compose Up
- **Tasks** &mdash; `Terminal > Run Task` for Start, Stop, Logs, Shell, Rebuild
- **Debugging** &mdash; attach to container via debugpy (see Debugging section)

### PyCharm

Open this directory as a PyCharm project:

- **Run configurations** &mdash; pre-built Docker Compose configs per project
- **Python SDK** &mdash; point to Python 3.9 interpreter in the container
- **Source roots** &mdash; `odoo/` and `projects/` marked for code intelligence
- **Database tools** &mdash; connect to `localhost:5433` with `odoo`/`odoo` credentials

### Claude Code

AI-powered development directly in your terminal:

- **`.claude/` settings** &mdash; pre-configured with safe permissions (core Odoo is read-only)
- **`/init-docker-container`** &mdash; interactive project setup command
- **Odoo-aware** &mdash; understands module structure, inheritance, views, and security

---

## Tech Stack

| Component | Version | Purpose |
|-----------|---------|---------|
| **Odoo** | 15.0 Enterprise | ERP framework |
| **Python** | 3.9 | Runtime |
| **PostgreSQL** | 12 | Database |
| **Debian** | Bullseye (slim) | Base OS |
| **Node.js** | 20 | Asset pipeline (rtlcss) |
| **wkhtmltopdf** | 0.12.6 | PDF report generation |
| **Docker Compose** | v2 | Container orchestration |

---

## Directory Structure

```
.
|-- Dockerfile                    # Container image definition
|-- docker-compose.yml            # Default orchestration
|-- entrypoint.sh                 # Container startup (dev mode, debugger)
|-- quick-start.bat               # Windows one-click launcher
|-- requirements.txt              # Python dependencies
|-- .env.example                  # Environment variable template
|
|-- conf/                         # Odoo configuration files
|   |-- odoo.conf                 # Default config
|   +-- {project}.conf          # Per-project (generated)
|
|-- odoo/                         # Odoo 15 Enterprise source (READ-ONLY)
|   |-- addons/                   # 1200+ standard & enterprise modules
|   |-- odoo/                     # Core framework (ORM, API, HTTP)
|   +-- setup/                    # Entry point
|
|-- projects/                     # Your custom modules (clone here)
|   +-- {project}/
|       |-- module_a/
|       +-- module_b/
|
|-- logs/                         # Runtime log files
|-- .vscode/                      # VSCode workspace settings
|-- .idea/                        # PyCharm project settings
+-- .claude/                      # Claude Code settings & commands
```

---

## Common Commands

```bash
# Start containers
docker-compose up -d

# Stop containers
docker-compose down

# View Odoo logs (live)
docker-compose logs -f odoo

# Open shell inside container
docker-compose exec odoo bash

# Rebuild after Dockerfile changes
docker-compose up -d --build

# Install or update a module
docker-compose exec odoo python /opt/odoo/source/setup/odoo \
  -c /etc/odoo/odoo.conf -d mydb -u my_module --stop-after-init

# Access PostgreSQL directly
docker-compose exec db psql -U odoo

# Check container health
docker inspect --format="{{.State.Health.Status}}" odoo15_web
```

---

## All Versions

Every Odoo version (14 through 19) is available as a separate branch. Each branch is a **complete, independent environment** with version-appropriate dependencies.

| Version | Branch | Python | PostgreSQL | Debian | Clone |
|---------|--------|--------|------------|--------|-------|
| **Odoo 19** | [`v19`](https://github.com/taqat-techno/odoo-container/tree/v19) (default) | 3.12 | 15 | Bookworm | `git clone -b v19 ...` |
| Odoo 18 | [`v18`](https://github.com/taqat-techno/odoo-container/tree/v18) | 3.11 | 15 | Bookworm | `git clone -b v18 ...` |
| Odoo 17 | [`v17`](https://github.com/taqat-techno/odoo-container/tree/v17) | 3.10 | 12 | Bookworm | `git clone -b v17 ...` |
| Odoo 16 | [`v16`](https://github.com/taqat-techno/odoo-container/tree/v16) | 3.10 | 12 | Bullseye | `git clone -b v16 ...` |
| Odoo 15 | [`v15`](https://github.com/taqat-techno/odoo-container/tree/v15) | 3.9 | 12 | Bullseye | `git clone -b v15 ...` |
| Odoo 14 | [`v14`](https://github.com/taqat-techno/odoo-container/tree/v14) | 3.8 | 12 | Buster | `git clone -b v14 ...` |

Clone URL: `https://github.com/taqat-techno/odoo-container.git`

Or download from the [Releases](https://github.com/taqat-techno/odoo-container/releases) page.

---

## License

Odoo Enterprise Edition is subject to the [Odoo Enterprise License v1.0](https://www.odoo.com/documentation/15.0/legal/licenses.html#odoo-enterprise-license).

---

<p align="center">
  Maintained by <a href="https://www.taqatechno.com/">TaqaTechno</a><br/>
  <sub>Empowering businesses with smart ERP solutions</sub>
</p>
