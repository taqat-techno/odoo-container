# Odoo 18 - Docker Development Environment

Ready-to-use Docker setup for Odoo 18 Enterprise development with full IDE integration.

## Quick Start

```bash
# Clone this version
git clone -b v18 https://github.com/taqat-techno/odoo-container.git
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
| Odoo 19 | `v19` (default) | `git clone https://github.com/taqat-techno/odoo-container.git` |
| Odoo 18 | `v18` | `git clone -b v18 https://github.com/taqat-techno/odoo-container.git` |
| Odoo 17 | `v17` | `git clone -b v17 https://github.com/taqat-techno/odoo-container.git` |
| Odoo 16 | `v16` | `git clone -b v16 https://github.com/taqat-techno/odoo-container.git` |
| Odoo 15 | `v15` | `git clone -b v15 https://github.com/taqat-techno/odoo-container.git` |
| Odoo 14 | `v14` | `git clone -b v14 https://github.com/taqat-techno/odoo-container.git` |

Or download from the [Releases](https://github.com/taqat-techno/odoo-container/releases) page.

## Specs

| Component | Version |
|-----------|---------|
| Python | 3.11 |
| Debian | Bookworm |
| PostgreSQL | 15 |
| Node.js | 20 |
| wkhtmltopdf | 0.12.6 |

## Architecture

```
Docker Compose
  ├── odoo18_db  (PostgreSQL 15)
  │   └── Port: 5433 -> 5432
  └── odoo18_web (Odoo 18)
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

## License

Odoo Enterprise is subject to the [Odoo Enterprise License](LICENSE).

---

Maintained by [TaqaTechno](https://www.taqatechno.com/)
