# Odoo 19 - Docker Development Environment

Ready-to-use Docker setup for Odoo 19 Enterprise development with full IDE integration.

## Quick Start

```bash
# Clone this repo
git clone https://github.com/taqat-techno/odoo-container.git
cd odoo-container

# Start Docker containers
docker-compose up -d --build

# Or use the Windows quick-start script
quick-start.bat
```

Open http://localhost:8069 in your browser.

- **Master Password**: `123`
- **Database**: Created on first access

## Other Versions

| Version | Branch | Clone Command |
|---------|--------|---------------|
| **Odoo 19** | `v19` (default) | `git clone https://github.com/taqat-techno/odoo-container.git` |
| Odoo 18 | `v18` | `git clone -b v18 https://github.com/taqat-techno/odoo-container.git` |
| Odoo 17 | `v17` | `git clone -b v17 https://github.com/taqat-techno/odoo-container.git` |
| Odoo 16 | `v16` | `git clone -b v16 https://github.com/taqat-techno/odoo-container.git` |
| Odoo 15 | `v15` | `git clone -b v15 https://github.com/taqat-techno/odoo-container.git` |
| Odoo 14 | `v14` | `git clone -b v14 https://github.com/taqat-techno/odoo-container.git` |

Or download from the [Releases](https://github.com/taqat-techno/odoo-container/releases) page.

## Specs

| Component | Version |
|-----------|---------|
| Python | 3.12 |
| Debian | Bookworm |
| PostgreSQL | 15 |
| Node.js | 20 |
| wkhtmltopdf | 0.12.6 |

## Architecture

```
Docker Compose
  ├── odoo19_db  (PostgreSQL 15)
  │   └── Port: 5433 -> 5432
  └── odoo19_web (Odoo 19)
      ├── Port: 8069 -> 8069 (HTTP)
      └── Port: 8072 -> 8072 (Longpolling)
```

## Project Setup

Clone your custom modules into the `projects/` directory:

```bash
cd projects
git clone https://github.com/your-org/your-modules.git my_project
```

Then update `conf/odoo.conf` to include the custom addons path, or use the Claude Code command `/init-docker-container`.

## IDE Integration

### PyCharm
- Open this directory as a PyCharm project
- Use the pre-configured run configuration: **Odoo 19 Docker**
- Python SDK: Python 3.12

### VSCode
- Open this directory in VSCode
- Install recommended extensions (prompted automatically)
- Pylance configured with Odoo source paths
- Docker extension for container management

### Claude Code
- `.claude/` settings pre-configured
- Use `/init-docker-container` to set up project-specific Docker environments

## Useful Commands

```bash
# Start containers
docker-compose up -d

# Stop containers
docker-compose down

# View logs
docker-compose logs -f odoo

# Access Odoo shell
docker-compose exec odoo bash

# Rebuild after Dockerfile changes
docker-compose up -d --build
```

## Directory Structure

```
.
├── Dockerfile              # Odoo 19 container image
├── docker-compose.yml      # PostgreSQL + Odoo orchestration
├── entrypoint.sh           # Container startup (editable install)
├── quick-start.bat         # Windows one-click setup
├── requirements.txt        # Python dependencies
├── conf/
│   └── odoo.conf           # Odoo server configuration
├── odoo/                   # Odoo 19 Enterprise source
├── projects/               # Custom modules (clone here)
├── logs/                   # Runtime logs
├── .vscode/                # VSCode settings
├── .idea/                  # PyCharm settings
└── .claude/                # Claude Code settings
```

## License

Odoo Enterprise is subject to the [Odoo Enterprise License](LICENSE).

---

Maintained by [TaqaTechno](https://www.taqatechno.com/)
