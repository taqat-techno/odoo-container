# Init Docker Container - Interactive Docker Setup for Odoo Projects

Set up a project-specific Docker environment with standard ports (8069/8072/5433). The Odoo version is auto-detected from the current git branch. Only one container can run at a time.

## Usage
- `/init-docker-container` - Interactive mode, auto-detects version, prompts for project

Arguments (if provided): $ARGUMENTS

## Prerequisites
- Docker Desktop must be running
- This repo must be cloned from `taqat-techno/odoo-container` (any version branch)
- The project folder must already be cloned into the `projects/` directory

```bash
# Example: Clone Odoo 17 environment, then add your project
git clone -b v17 https://github.com/taqat-techno/odoo-container.git my-odoo17
cd my-odoo17
gh repo clone my-org/my-project projects/my-project
/init-docker-container
```

---

## Instructions

Follow these steps exactly when this command is invoked.

### Step 1: Check Docker

Run `docker info` via Bash to verify Docker Desktop is running. If it fails, tell the user:
"Docker Desktop is not running. Please start it first."
and stop.

### Step 2: Detect Odoo Version

Auto-detect the Odoo version from the current git branch name.

Run `git branch --show-current` in the current working directory.

Parse the version number from the branch name:
- `v14` -> version `14`
- `v15` -> version `15`
- `v16` -> version `16`
- `v17` -> version `17`
- `v18` -> version `18`
- `v19` -> version `19`

If the branch name does not match any known version pattern, ask the user using `AskUserQuestion`:
"Could not detect Odoo version from branch '{branch_name}'. Which version is this?"
Present options: Odoo 14, Odoo 15, Odoo 16, Odoo 17, Odoo 18, Odoo 19.

Store the detected version number (e.g., `17`).
Set the **base directory** to the current working directory (repo root).

Display: `Detected Odoo {version} from branch '{branch_name}'`

### Step 3: Select Project

List all subdirectories inside `projects/` (relative to repo root) using Glob or Bash `ls`.
Only include actual directories, not files.

If no project directories exist, inform the user:
```
No projects found in projects/.
Clone your project there first:

  gh repo clone my-org/my-project projects/my-project

Expected structure:
  projects/{project_name}/
    module_a/__manifest__.py
    module_b/__manifest__.py
    ...
```
and stop.

Use `AskUserQuestion` to let the user pick a project from the found directories.

### Step 4: Scan for Custom Odoo Modules

Search the selected project directory for files named `__manifest__.py` or `__openerp__.py` (max depth 3 levels).

For each manifest file found:
1. The **module directory** = parent folder of the manifest file
2. The **addons path** = parent of the module directory

Collect all unique addons paths and convert them to container paths:
- Host path `projects/{project}/{subdir}/{module}/__manifest__.py`
- Container addons path: `/opt/odoo/custom-addons/{project}/{subdir}`

Most common case: modules at project root -> single addons path `/opt/odoo/custom-addons/{project_name}`

Display the results:
```
Found {count} Odoo modules in {project_name}:
  - module_a
  - module_b
  - ...

Addons paths:
  - /opt/odoo/custom-addons/{project_name}
```

If no modules are found, warn the user but continue (modules may be added later).

### Step 5: Check for Existing Config

Check if `conf/{project_name}.conf` or `docker-compose.{project_name}.yml` already exist in the repo root.

If either exists, ask the user if they want to overwrite using `AskUserQuestion`.
If no, stop.

### Step 6: Generate Odoo Config File

Create `conf/{project_name}.conf` (relative to repo root) using the **Odoo Config Template** below.

Use the **Version Settings Table** to determine the correct gevent/longpolling config key.

### Step 7: Generate Docker Compose File

Create `docker-compose.{project_name}.yml` (relative to repo root) using the **Docker Compose Template** below.

Use the **Version Settings Table** for the correct PostgreSQL image.

### Step 8: Generate IDE Configurations

**PyCharm**: Create `.idea/runConfigurations/{project_name}_docker.xml` using the **PyCharm Run Config Template** below. Create the `.idea/runConfigurations/` directory if it does not exist.

**VSCode**: Create or update `.vscode/tasks.json` using the **VSCode Tasks Template** below.
- If `.vscode/tasks.json` does NOT exist, create it with the project tasks.
- If `.vscode/tasks.json` ALREADY exists, read it, parse the JSON, and append the new project tasks to the existing `tasks` array (avoid duplicates by checking task labels). Write back the merged result.

Create the `.vscode/` directory if it does not exist.

### Step 9: Build and Start

Ask the user using `AskUserQuestion`: "Build and start the Docker containers now?"

If yes:
1. First stop any existing containers on the same ports:
```bash
docker-compose -f docker-compose.{project_name}.yml down 2>/dev/null
```
2. Then build and start:
```bash
docker-compose -f docker-compose.{project_name}.yml up -d --build
```

Wait for containers to be healthy, then display the summary.

If no, just display the files created and the manual commands.

### Step 10: Display Summary

```
Docker environment ready!

Odoo Version: {version}
Odoo Web:     http://localhost:8069
Master Pwd:   123
Database:     {project_name}

Containers:
  - {project_name}_{version}_web (Odoo)
  - {project_name}_{version}_db  (PostgreSQL)

Ports:
  - HTTP:     8069
  - Gevent:   8072
  - Postgres: 5433

Files created:
  - conf/{project_name}.conf
  - docker-compose.{project_name}.yml
  - .idea/runConfigurations/{project_name}_docker.xml  (PyCharm)
  - .vscode/tasks.json                                 (VSCode - merged)

IDE integration:
  PyCharm: Run configuration "{project_name} Docker" (auto-created)
  VSCode:  Terminal > Run Task > "{project_name}: Start/Stop/Logs/Shell/Rebuild"
           Or right-click docker-compose.{project_name}.yml > Compose Up

Terminal commands:
  Start:   docker-compose -f docker-compose.{project_name}.yml up -d
  Stop:    docker-compose -f docker-compose.{project_name}.yml down
  Logs:    docker-compose -f docker-compose.{project_name}.yml logs -f odoo
  Shell:   docker-compose -f docker-compose.{project_name}.yml exec odoo bash
  Rebuild: docker-compose -f docker-compose.{project_name}.yml up -d --build

Note: Only one project container can run at a time on these ports.
Stop the current one before starting another.
```

---

## Version Settings Table

| Version | Postgres Image | Gevent Config Key  |
|---------|----------------|--------------------|
| 14      | postgres:12    | longpolling_port   |
| 15      | postgres:12    | longpolling_port   |
| 16      | postgres:12    | longpolling_port   |
| 17      | postgres:12    | gevent_port        |
| 18      | postgres:15    | gevent_port        |
| 19      | postgres:15    | gevent_port        |

All versions use the same standard ports:
- HTTP: 8069
- Gevent/Longpolling: 8072
- PostgreSQL: 5433 (host) -> 5432 (container)

---

## Odoo Config Template

Generate `conf/{project_name}.conf` with these contents (replace all `{placeholders}`):

```ini
[options]
db_host = db
db_port = 5432
db_user = odoo
db_password = odoo
db_name = {project_name}
admin_passwd = 123
addons_path = /opt/odoo/source/odoo/addons,{comma_separated_custom_addons_paths}
data_dir = /var/lib/odoo
http_port = 8069
http_interface = 0.0.0.0
{gevent_config_key} = 8072
dbfilter = {project_name}*
logfile = /var/log/odoo/odoo.log
log_level = info
proxy_mode = False
list_db = True
workers = 0
limit_time_real = 600
limit_time_cpu = 600
```

Where:
- `{project_name}` = selected project name
- `{comma_separated_custom_addons_paths}` = discovered addons paths joined by commas (e.g., `/opt/odoo/custom-addons/myproject`)
- `{gevent_config_key}` = `longpolling_port` for v14-16, `gevent_port` for v17-19

---

## Docker Compose Template

Generate `docker-compose.{project_name}.yml` with these contents (replace all `{placeholders}`):

```yaml
services:
  db:
    image: {postgres_image}
    container_name: {project_name}_{version}_db
    environment:
      POSTGRES_USER: ${POSTGRES_USER:-odoo}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:-odoo}
      POSTGRES_DB: ${POSTGRES_DB:-postgres}
    ports:
      - "5433:5432"
    volumes:
      - {project_name}_{version}_db_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER:-odoo} -d ${POSTGRES_DB:-postgres}"]
      interval: 10s
      timeout: 5s
      retries: 5
    restart: unless-stopped

  odoo:
    build:
      context: .
    container_name: {project_name}_{version}_web
    depends_on:
      db:
        condition: service_healthy
    volumes:
      - .:/opt/odoo/source:ro
      - ./projects:/opt/odoo/custom-addons
      - ./conf/{project_name}.conf:/etc/odoo/odoo.conf:ro
      - ./logs:/var/log/odoo
      - {project_name}_{version}_filestore:/var/lib/odoo
    ports:
      - "8069:8069"
      - "8072:8072"
    environment:
      POSTGRES_USER: ${POSTGRES_USER:-odoo}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:-odoo}
      POSTGRES_DB: ${POSTGRES_DB:-postgres}
      DEV_MODE: ${DEV_MODE:-0}
      ENABLE_DEBUGGER: ${ENABLE_DEBUGGER:-0}
      SOURCE_CACHE: ${SOURCE_CACHE:-auto}
      WAIT_FOR_DB: "1"
    healthcheck:
      test: ["CMD-SHELL", "curl -sf http://localhost:8069/web/health || curl -sf http://localhost:8069/web/login || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 120s
    restart: unless-stopped

volumes:
  {project_name}_{version}_db_data:
  {project_name}_{version}_filestore:
```

Where:
- `{postgres_image}` = from Version Settings Table
- `{project_name}` = selected project name
- `{version}` = detected version number (14, 15, 16, 17, 18, 19)

---

## PyCharm Run Config Template

Generate `.idea/runConfigurations/{project_name}_docker.xml` with these contents (replace all `{placeholders}`):

```xml
<component name="ProjectRunConfigurationManager">
  <configuration default="false" name="{project_name} Docker" type="docker-deploy" factoryName="docker-compose.yml" server-name="Docker">
    <deployment type="docker-compose.yml">
      <settings>
        <option name="compose-file" value="docker-compose.{project_name}.yml" />
      </settings>
    </deployment>
    <method v="2" />
  </configuration>
</component>
```

Where:
- `{project_name}` = selected project name

This creates a PyCharm run configuration that uses the project-specific docker-compose file.

---

## VSCode Tasks Template

Generate or merge into `.vscode/tasks.json`. Each project adds 5 tasks. If the file already exists, read it, parse the JSON, and append these tasks to the `tasks` array. Skip any task whose `label` already exists.

For a **new** `tasks.json`, generate:

```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "{project_name}: Start",
      "type": "shell",
      "command": "docker-compose -f docker-compose.{project_name}.yml up -d",
      "group": "none",
      "presentation": { "reveal": "always", "panel": "shared" }
    },
    {
      "label": "{project_name}: Stop",
      "type": "shell",
      "command": "docker-compose -f docker-compose.{project_name}.yml down",
      "group": "none",
      "presentation": { "reveal": "always", "panel": "shared" }
    },
    {
      "label": "{project_name}: Logs",
      "type": "shell",
      "command": "docker-compose -f docker-compose.{project_name}.yml logs -f odoo",
      "group": "none",
      "presentation": { "reveal": "always", "panel": "dedicated" },
      "isBackground": true
    },
    {
      "label": "{project_name}: Shell",
      "type": "shell",
      "command": "docker-compose -f docker-compose.{project_name}.yml exec odoo bash",
      "group": "none",
      "presentation": { "reveal": "always", "panel": "dedicated" }
    },
    {
      "label": "{project_name}: Rebuild",
      "type": "shell",
      "command": "docker-compose -f docker-compose.{project_name}.yml up -d --build",
      "group": "build",
      "presentation": { "reveal": "always", "panel": "shared" }
    }
  ]
}
```

For an **existing** `tasks.json`, append the 5 task objects above to the existing `tasks` array. This allows multiple projects to coexist in the same tasks file.

Where:
- `{project_name}` = selected project name

---

## Error Handling

- **Docker not running**: Check `docker info` first. If fails, abort with clear message.
- **Branch not recognized**: Fall back to asking user which Odoo version.
- **No projects found**: Tell user to clone project first. Show expected folder structure with `gh repo clone` example.
- **No modules found**: Warn but proceed. Project may have modules added later.
- **Config/compose already exists**: Ask user before overwriting.
- **Build fails**: Show docker build logs and suggest checking Dockerfile.
- **Port conflict**: If containers fail to start, suggest stopping other containers first with `docker-compose down`.
- **Special characters in project name**: Replace spaces and special characters with underscores for container names.
