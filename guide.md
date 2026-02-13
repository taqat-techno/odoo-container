# Odoo 14 Docker Setup Guide

## Prerequisites

- **Docker Desktop** installed and running
- **Git** (optional, for cloning)
- Ports **8069**, **8072**, and **5433** available on your machine

## Directory Structure

```
odoo-14/
├── Dockerfile              # Python 3.8 + Debian Buster image
├── docker-compose.yml      # Odoo + PostgreSQL services
├── requirements.txt        # Python dependencies
├── conf/
│   └── odoo.conf           # Odoo configuration
├── projects/               # Custom addons go here
├── logs/                   # Odoo log files (auto-created)
└── odoo/                   # Odoo 14 source code (read-only)
    └── addons/             # Standard + Enterprise modules
```

## Quick Start

### 1. Build the Docker Image

```bash
cd odoo-14
docker compose build
```

This builds a custom image with:
- Python 3.8 on Debian Buster
- All Odoo system dependencies
- wkhtmltopdf 0.12.6 for PDF report generation
- All Python packages from `requirements.txt`

First build takes a few minutes. Subsequent builds use cache.

### 2. Start the Containers

```bash
docker compose up -d
```

This starts two containers:

| Container     | Service    | Port          | Description              |
|---------------|------------|---------------|--------------------------|
| `odoo14_web`  | Odoo 14    | `localhost:8069` | Web interface          |
| `odoo14_db`   | PostgreSQL 12 | `localhost:5433` | Database             |

> **Note:** PostgreSQL uses port **5433** (not 5432) to avoid conflicts with any local PostgreSQL installation.

### 3. Create a Database

Open your browser and go to:

```
http://localhost:8069
```

You will see the database manager. Fill in:

| Field           | Value              |
|-----------------|--------------------|
| Master Password | `123`              |
| Database Name   | e.g. `odoo14_test` |
| Email           | `admin`            |
| Password        | `admin`            |
| Language         | English           |

Click **Create Database** and wait for it to finish.

### 4. Log In

After database creation, you are redirected to the Odoo backend. Use:

- **Login:** `admin`
- **Password:** `admin`

## Common Commands

### Stop the containers

```bash
docker compose down
```

### Restart the containers

```bash
docker compose restart
```

### Rebuild after Dockerfile changes

```bash
docker compose down
docker compose build --no-cache
docker compose up -d
```

### View Odoo logs (live)

```bash
docker exec odoo14_web bash -c "tail -f /var/log/odoo/odoo.log"
```

Or check the local `logs/` folder:

```bash
tail -f logs/odoo.log
```

### Open a shell inside the Odoo container

```bash
docker exec -it odoo14_web bash
```

### Install a module

```bash
docker exec -u odoo odoo14_web bash -c "python /opt/odoo/source/setup/odoo -c /etc/odoo/odoo.conf -d DATABASE_NAME -i MODULE_NAME --stop-after-init"
```

### Update a module

```bash
docker exec -u odoo odoo14_web bash -c "python /opt/odoo/source/setup/odoo -c /etc/odoo/odoo.conf -d DATABASE_NAME -u MODULE_NAME --stop-after-init"
```

### Access the Odoo shell

```bash
docker exec -u odoo -it odoo14_web bash -c "python /opt/odoo/source/setup/odoo shell -c /etc/odoo/odoo.conf -d DATABASE_NAME"
```

## Adding Custom Modules

1. Place your module folder inside `projects/`:

```
odoo-14/
└── projects/
    └── my_custom_module/
        ├── __init__.py
        ├── __manifest__.py
        ├── models/
        └── views/
```

2. Restart Odoo:

```bash
docker compose restart odoo
```

3. In the Odoo web interface, go to **Apps** > **Update Apps List**, then search for and install your module.

## Connecting pgAdmin

To manage the database with pgAdmin, create a new server with:

| Setting    | Value       |
|------------|-------------|
| Host       | `localhost` |
| Port       | `5433`      |
| Username   | `odoo`      |
| Password   | `odoo`      |

## Configuration

The Odoo configuration file is at `conf/odoo.conf`. Key settings:

| Setting        | Value                                              | Description                |
|----------------|----------------------------------------------------|----------------------------|
| `db_host`      | `db`                                               | Docker service name        |
| `db_port`      | `5432`                                             | Internal PostgreSQL port   |
| `db_user`      | `odoo`                                             | Database user              |
| `db_password`  | `odoo`                                             | Database password          |
| `admin_passwd` | `123`                                              | Master password            |
| `addons_path`  | `/opt/odoo/source/odoo/addons,/opt/odoo/custom-addons` | Module search paths   |
| `http_port`    | `8069`                                             | Odoo HTTP port             |
| `logfile`      | `/var/log/odoo/odoo.log`                           | Log file location          |

## Volume Mapping

| Host Path          | Container Path            | Mode     | Purpose                |
|--------------------|---------------------------|----------|------------------------|
| `.` (odoo-14/)     | `/opt/odoo/source`        | read-only | Odoo source code      |
| `./projects/`      | `/opt/odoo/custom-addons`  | read-write | Custom modules        |
| `./conf/odoo.conf` | `/etc/odoo/odoo.conf`      | read-only | Configuration         |
| `./logs/`          | `/var/log/odoo`            | read-write | Log files             |
| Docker volume      | `/var/lib/odoo/filestore`  | read-write | Uploaded files        |
| Docker volume      | `/var/lib/postgresql/data` | read-write | Database storage      |

## Troubleshooting

### Port already in use

If port 8069 is already used by a local Odoo instance, stop it first or change the port in `docker-compose.yml`:

```yaml
ports:
  - "8014:8069"    # Use localhost:8014 instead
```

### Container won't start

Check the logs:

```bash
docker logs odoo14_web
docker logs odoo14_db
```

### Database connection refused

Make sure the `db` container is healthy:

```bash
docker ps
```

The `odoo14_db` status should show `(healthy)`.

### Module not found after adding to projects/

1. Restart: `docker compose restart odoo`
2. In Odoo, go to **Apps** > **Update Apps List**
3. Make sure `__manifest__.py` has `'installable': True`

### Reset database password

```bash
docker exec odoo14_db bash -c "psql -U odoo -d postgres -c \"ALTER USER odoo WITH PASSWORD 'odoo';\""
```
