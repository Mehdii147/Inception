# Developer Documentation

## Prerequisites

### System Requirements
- Docker Engine (version 20.10+)
- Docker Compose v2+
- macOS, Linux, or WSL2 on Windows
- At least 2GB free disk space

### Installation Check
```bash
docker --version
docker compose version
```

## Setting Up the Environment from Scratch

### 1. Clone the Repository
```bash
git clone <repository-url>
cd inception_m
```

### 2. Configure Environment Variables
Edit `srcs/.env` to customize your setup:

```bash
# Domain Configuration
DOMAIN_NAME=ehafiane.42.fr    # Change to your login
NETWORK_NAME=inception

# Data Storage Paths (adjust as needed)
DB_VOLUME_PATH=/Users/mehdi/data/mariadb
WP_VOLUME_PATH=/Users/mehdi/data/wordpress

# Database Configuration
MARIADB_DATABASE=wordpress
MARIADB_USER=wp_user
MARIADB_HOST=mariadb

# WordPress Configuration
WP_SITE_TITLE=Inception
WP_ADMIN_USER=site_keeper
WP_ADMIN_EMAIL=admin@ehafiane.42.fr
WP_AUTHOR_USER=content_editor
WP_AUTHOR_EMAIL=writer@ehafiane.42.fr

# Passwords (change these!)
MARIADB_ROOT_PASSWORD=your_secure_root_password
MARIADB_USER_PASSWORD=your_secure_user_password
WP_ADMIN_PASSWORD=your_secure_admin_password
WP_AUTHOR_PASSWORD=your_secure_author_password
```

**Important:** Change all passwords before deploying!

### 3. Configure Hosts File
Add the domain to your system's hosts file:
```bash
echo "127.0.0.1 ehafiane.42.fr" | sudo tee -a /etc/hosts
```

## Building and Launching the Project

### Using the Makefile

All project management is done through the Makefile:

```bash
# Build and start everything
make              # or: make up

# Build images only (without starting)
make build

# Stop containers (keep data)
make down         # or: make stop

# View container status
make status       # or: make ps

# Follow logs in real-time
make logs

# Complete cleanup (removes all data)
make fclean

# Rebuild from scratch
make re           # Equivalent to: make clean && make all
```

### Behind the Scenes
The Makefile executes Docker Compose commands:
```bash
docker compose -f srcs/docker-compose.yml --env-file srcs/.env <command>
```

## Managing Containers and Volumes

### Container Management

**List running containers:**
```bash
docker ps
```

**View all containers (including stopped):**
```bash
docker ps -a
```

**Inspect a specific container:**
```bash
docker inspect mariadb
docker inspect wordpress
docker inspect nginx
```

**Execute commands inside containers:**
```bash
docker exec -it wordpress bash
docker exec -it mariadb bash
docker exec wordpress wp --info --allow-root
```

**View container logs:**
```bash
docker logs mariadb
docker logs wordpress -f    # Follow logs
docker logs nginx --tail 50 # Last 50 lines
```

### Volume Management

**List volumes:**
```bash
docker volume ls
```

**Inspect volumes:**
```bash
docker volume inspect srcs_db_data
docker volume inspect srcs_wordpress_data
```

**Access volume data on host:**
```bash
ls -la /Users/mehdi/data/mariadb      # MariaDB data
ls -la /Users/mehdi/data/wordpress    # WordPress files
```

### Network Management

**Inspect the network:**
```bash
docker network inspect inception
```

**View network connections:**
```bash
docker network ls
```

## Project Data Storage and Persistence

### Data Locations

**On Host (Bind Mounts):**
- MariaDB data: `${DB_VOLUME_PATH}` (default: `/Users/mehdi/data/mariadb`)
- WordPress files: `${WP_VOLUME_PATH}` (default: `/Users/mehdi/data/wordpress`)

**Inside Containers:**
- MariaDB: `/var/lib/mysql`
- WordPress: `/var/www/html`

### Persistence Mechanism

The project uses Docker bind mounts to persist data on the host filesystem:

```yaml
volumes:
  db_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: ${DB_VOLUME_PATH}
```

This ensures:
- Data survives container restarts
- Data survives `docker compose down`
- Data can be backed up from the host
- Data is only removed with `make fclean`

### Backup and Restore

**Backup:**
```bash
# Stop containers
make down

# Backup data directories
tar -czf backup.tar.gz /Users/mehdi/data/

# Restart
make
```

**Restore:**
```bash
make fclean
tar -xzf backup.tar.gz -C /
make
```

## Architecture Overview

### Container Communication

```
Internet → NGINX:443
              ↓
         WordPress:9000 (PHP-FPM)
              ↓
         MariaDB:3306
```

- All containers share the `inception` network
- Only NGINX exposes ports to the host (443)
- Containers communicate via service names (DNS)

### Service Details

**NGINX:**
- Base: `debian:bookworm`
- Serves HTTPS on port 443
- Self-signed SSL certificate
- Proxies PHP to WordPress via FastCGI

**WordPress:**
- Base: `debian:bookworm`
- PHP 8.2 with php-fpm
- Listens on port 9000
- Uses WP-CLI for installation
- Connects to MariaDB

**MariaDB:**
- Base: `debian:bullseye`
- MariaDB server
- Data persisted to host
- Initialized on first run

## Development Workflow

### Making Changes

**1. Modify Dockerfile:**
```bash
vim srcs/requirements/wordpress/Dockerfile
make build    # Rebuild image
make up       # Restart container
```

**2. Modify entrypoint script:**
```bash
vim srcs/requirements/mariadb/tools/entrypoint.sh
make fclean   # Clean everything
make          # Rebuild and restart
```

**3. Modify configuration:**
```bash
vim srcs/requirements/nginx/conf/nginx.conf
make down     # Stop containers
make up       # Restart with new config
```

### Debugging

**Check container health:**
```bash
docker inspect mariadb | grep -A 10 Health
```

**Test database connection:**
```bash
docker exec mariadb mariadb-admin ping -h localhost
```

**Test WordPress installation:**
```bash
docker exec wordpress wp core is-installed --allow-root
```

**View PHP-FPM status:**
```bash
docker exec wordpress php-fpm8.2 -t
```

## Common Issues

**Issue: Containers won't start**
```bash
docker compose -f srcs/docker-compose.yml logs
```

**Issue: Port already in use**
```bash
sudo lsof -i :443
# Kill the process or change nginx port
```

**Issue: Permission denied on volumes**
```bash
sudo chown -R $(whoami) /Users/mehdi/data
```

**Issue: WordPress redirects to wrong URL**
```bash
docker exec wordpress wp option update home 'https://ehafiane.42.fr' --allow-root
docker exec wordpress wp option update siteurl 'https://ehafiane.42.fr' --allow-root
```
