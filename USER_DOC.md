# User Documentation

## What Services Are Provided

The Inception stack provides a complete WordPress website infrastructure with:
- **NGINX** - Web server handling HTTPS connections on port 443
- **WordPress** - Content management system with PHP-FPM
- **MariaDB** - Database server storing all WordPress data

The stack exposes a single HTTPS endpoint at `https://ehafiane.42.fr`, served securely with TLS 1.2/1.3.

## Starting and Stopping the Project

### Starting the Stack
From the project root directory:
```bash
make
```
This will create data directories, build all Docker images, and start the containers.

### Stopping the Stack
```bash
make down      # Stop containers, keep data
make stop      # Same as down
```

### Complete Cleanup
```bash
make fclean    # Stop containers and delete all data
```

## Accessing the Website and Administration Panel

### Prerequisites
Add the domain to your hosts file:
```bash
echo "127.0.0.1 ehafiane.42.fr" | sudo tee -a /etc/hosts
```

### Access Points
- **Main Website**: `https://ehafiane.42.fr`
- **Admin Panel**: `https://ehafiane.42.fr/wp-admin`

Your browser will show a security warning due to the self-signed SSL certificate. This is normal for development - accept it to proceed.

## Locating and Managing Credentials

All credentials are stored in `srcs/.env`:

```bash
# Database passwords
MARIADB_ROOT_PASSWORD=rootpass123      # MariaDB root password
MARIADB_USER_PASSWORD=userpass123      # MariaDB user password

# WordPress passwords
WP_ADMIN_PASSWORD=adminpass123         # Admin login password
WP_AUTHOR_PASSWORD=authorpass123       # Author user password
```

**Usernames:**
- WordPress Admin: `site_keeper` (defined by `WP_ADMIN_USER`)
- WordPress Author: `content_editor` (defined by `WP_AUTHOR_USER`)
- Database User: `wp_user` (defined by `MARIADB_USER`)

**To change credentials:**
1. Edit `srcs/.env`
2. Run `make fclean && make` to recreate everything with new credentials

## Checking That Services Are Running Correctly

### View Container Status
```bash
make status    # or: make ps
```

### View Live Logs
```bash
make logs
```

### Manual Checks
```bash
docker ps      # All 3 containers should show "Up"
```

Expected containers:
- `nginx` - Running on port 443
- `wordpress` - Running internally
- `mariadb` - Running internally

### Verify Website Access
1. Open `https://ehafiane.42.fr` in your browser
2. You should see the WordPress homepage
3. Access `https://ehafiane.42.fr/wp-admin` and log in with admin credentials

### Health Checks
The stack includes automatic health checks:
- MariaDB: Ping test every 10 seconds
- WordPress: Waits for MariaDB to be healthy before starting
