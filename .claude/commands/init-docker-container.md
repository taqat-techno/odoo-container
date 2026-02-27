# Init Docker Container - Interactive Docker Setup for Odoo Projects

Set up a project-specific Docker environment with standard ports (8069/8072/5433). The Odoo version is auto-detected by reading `odoo/release.py` from the repo root. Only one container can run at a time.

## Usage
- `/init-docker-container` - Interactive mode, auto-detects version, prompts for project

Arguments (if provided): $ARGUMENTS

## Prerequisites
- Docker Desktop must be running
- This repo must be cloned from `taqat-techno/odoo-container`
- The project folder must already be cloned into the `project-addons/` directory

```bash
# Example: Clone Odoo container repo, then add your project
git clone https://github.com/taqat-techno/odoo-container.git my-odoo
cd my-odoo
gh repo clone taqat-techno/my-project project-addons/my-project
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

Auto-detect the Odoo version by reading `odoo/release.py` from the repo root using the `Read` tool.

Look for a line containing `version_info = (` and extract the first integer in the tuple.
Example: `version_info = (14, 0, 0, 'final', 0, '')` → version `14`

Fallback: if `version_info` line is not found, look for a line containing `version = '` and extract the major version number.
Example: `version = '14.0'` → version `14`

If `odoo/release.py` does not exist, ask the user using `AskUserQuestion`:
"Could not find odoo/release.py. Which Odoo version is this?"
Present options: Odoo 14, Odoo 15, Odoo 16, Odoo 17, Odoo 18, Odoo 19.

Store the detected version number (e.g., `14`).
Set the **base directory** to the current working directory (repo root).

Display: `Detected Odoo {version} from odoo/release.py`

### Step 3: Select Project

List all subdirectories inside `project-addons/` (relative to repo root) using Glob or Bash `ls`.
Only include actual directories, not files.

If no project directories exist, inform the user:
```
No projects found in project-addons/.
Clone your project there first:

  gh repo clone taqat-techno/my-project project-addons/my-project

Expected structure:
  project-addons/{project_name}/
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
- Host path `project-addons/{project}/{subdir}/{module}/__manifest__.py`
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

### Step 9: Pull Image and Start

Ask the user using `AskUserQuestion`: "Pull the Docker image and start the containers now?"

If yes:
1. First stop any existing containers on the same ports:
```bash
docker-compose -f docker-compose.{project_name}.yml down 2>/dev/null
```
2. Pull the pre-built image from Docker Hub:
```bash
docker pull alakosha/odoo-image:{version}.0
```
3. Start the containers:
```bash
docker-compose -f docker-compose.{project_name}.yml up -d
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
  VSCode:  Terminal > Run Task > "{project_name}: Start/Stop/Logs/Shell/Update Image"

Terminal commands:
  Start:        docker-compose -f docker-compose.{project_name}.yml up -d
  Stop:         docker-compose -f docker-compose.{project_name}.yml down
  Logs:         docker-compose -f docker-compose.{project_name}.yml logs -f odoo
  Shell:        docker-compose -f docker-compose.{project_name}.yml exec odoo bash
  Update Image: docker pull alakosha/odoo-image:{version}.0 && docker-compose -f docker-compose.{project_name}.yml up -d

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
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER:-odoo}"]
      interval: 10s
      timeout: 5s
      retries: 5
    restart: unless-stopped

  odoo:
    image: alakosha/odoo-image:{version}.0
    container_name: {project_name}_{version}_web
    depends_on:
      db:
        condition: service_healthy
    volumes:
      - .:/opt/odoo/source:ro
      - ./project-addons:/opt/odoo/custom-addons
      - ./conf/{project_name}.conf:/etc/odoo/odoo.conf:ro
      - ./logs:/var/log/odoo
      - {project_name}_{version}_filestore:/var/lib/odoo/filestore
    ports:
      - "8069:8069"
      - "8072:8072"
      # Uncomment to enable remote debugger (set ENABLE_DEBUGGER=1 in .env):
      # - "5678:5678"
    environment:
      POSTGRES_USER: ${POSTGRES_USER:-odoo}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:-odoo}
      POSTGRES_DB: ${POSTGRES_DB:-postgres}
      DEV_MODE: ${DEV_MODE:-0}
      ENABLE_DEBUGGER: ${ENABLE_DEBUGGER:-0}
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
      "label": "{project_name}: Update Image",
      "type": "shell",
      "command": "docker pull alakosha/odoo-image:{resolved_version}.0 && docker-compose -f docker-compose.{project_name}.yml up -d",
      "group": "build",
      "presentation": { "reveal": "always", "panel": "shared" }
    }
  ]
}
```

Where:
- `{project_name}` = selected project name
- `{resolved_version}` = the actual version number detected in Step 2 (e.g. `14`) — hardcoded at generation time

---

## Error Handling

- **Docker not running**: Check `docker info` first. If fails, abort with clear message.
- **release.py not found**: If `odoo/release.py` doesn't exist, ask user to select version manually using `AskUserQuestion`.
- **No projects found**: Tell user to clone project into `project-addons/` first. Show expected folder structure with `gh repo clone` example.
- **No modules found**: Warn but proceed. Project may have modules added later.
- **Config/compose already exists**: Ask user before overwriting.
- **Image pull fails**: Show docker pull error and suggest checking Docker Hub access or internet connection.
- **Port conflict**: If containers fail to start, suggest stopping other containers first with `docker-compose down`.
- **Special characters in project name**: Replace spaces and special characters with underscores for container names.
