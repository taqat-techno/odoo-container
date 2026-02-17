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
- **PostgreSQL database** &mdash; isolated per project, auto-configured
- **Docker Compose orchestration** &mdash; one command to start everything
- **IDE configurations** &mdash; VSCode and PyCharm pre-configured with Odoo source paths
- **AI-assisted setup** &mdash; Claude Code `/init-docker-container` command for instant project scaffolding

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
                         +-------------------------------------------+
                         |           Docker Compose                  |
                         |                                           |
  localhost:8069  ------>|   +-----------------------------------+   |
  (HTTP)                 |   |          odoo15_web             |   |
                         |   |                                   |   |
  localhost:8072  ------>|   |   Odoo 15 Enterprise              |   |
  (Gevent/WebSocket)     |   |   Python 3.9 | Debian Bullseye   |   |
                         |   |                                   |   |
                         |   |   /opt/odoo/source      (ro)      |---- Odoo source
                         |   |   /opt/odoo/custom-addons         |---- Your modules
                         |   |   /etc/odoo/odoo.conf   (ro)      |---- Config
                         |   |   /var/log/odoo                   |---- Logs
                         |   +----------------+------------------+   |
                         |                    |                      |
                         |                    v                      |
                         |   +-----------------------------------+   |
  localhost:5433  ------>|   |          odoo15_db              |   |
  (PostgreSQL)           |   |                                   |   |
                         |   |   PostgreSQL 12                   |   |
                         |   |   Data persisted in Docker volume |   |
                         |   +-----------------------------------+   |
                         +-------------------------------------------+
```

### Ports

| Service | Host Port | Container Port | Purpose |
|---------|-----------|----------------|---------|
| Odoo HTTP | `8069` | `8069` | Web interface & API |
| Odoo Gevent | `8072` | `8072` | WebSocket / Longpolling |
| PostgreSQL | `5433` | `5432` | Database access |

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
4. Generate `conf/{project}.conf` with correct settings
5. Generate `docker-compose.{project}.yml` with isolated containers
6. Create PyCharm run configuration + VSCode tasks
7. Optionally build and start the containers

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
- **Python debugging** &mdash; set breakpoints, attach to running container

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
|-- docker-compose.{project}.yml  # Per-project (generated)
|-- entrypoint.sh                 # Container startup script
|-- quick-start.bat               # Windows one-click launcher
|-- requirements.txt              # Python dependencies
|
|-- conf/                         # Odoo configuration files
|   |-- odoo.conf                 # Default config
|   +-- {project}.conf            # Per-project (generated)
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

# Per-project commands (when using /init-docker-container)
docker-compose -f docker-compose.my_project.yml up -d
docker-compose -f docker-compose.my_project.yml logs -f odoo
docker-compose -f docker-compose.my_project.yml down
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

## Workflow Example

```bash
# 1. Clone the environment for your Odoo version
git clone -b v15 https://github.com/taqat-techno/odoo-container.git client-project
cd client-project

# 2. Add your custom modules
gh repo clone my-org/client-modules projects/client-modules

# 3. Set up with Claude Code (or manually edit conf/odoo.conf)
/init-docker-container

# 4. Develop - edit modules in projects/, restart to see changes
code .     # Open in VSCode
pycharm .  # Or open in PyCharm

# 5. Test your module
docker-compose -f docker-compose.client-modules.yml exec odoo \
  python /opt/odoo/source/setup/odoo -c /etc/odoo/odoo.conf \
  -d client_db --test-enable -i my_module --stop-after-init
```

---

## License

Odoo Enterprise Edition is subject to the [Odoo Enterprise License v1.0](https://www.odoo.com/documentation/15.0/legal/licenses.html#odoo-enterprise-license).

---

<p align="center">
  Maintained by <a href="https://www.taqatechno.com/">TaqaTechno</a><br/>
  <sub>Empowering businesses with smart ERP solutions</sub>
</p>
