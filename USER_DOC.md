# User Documentation

## Stack overview
The Inception stack exposes a single HTTPS endpoint (`https://login.42.fr`) served by NGINX. Internally, NGINX proxies PHP requests to a WordPress container running PHP 8.2 via php-fpm on top of Debian Bookworm, which in turn persists data inside a MariaDB database. Two bind-mounted directories (`/home/login/data/mariadb` and `/home/login/data/wordpress`) ensure data stays on the host.

## Starting and stopping the services
1. Ensure Docker and Docker Compose v2+ are installed in your VM.
2. Populate the secret files under `secrets/` with secure passwords.
3. From the repository root, run `make` (or `make up`) to build and start all containers.
4. To stop services without removing data, run `make down`.
5. To destroy everything (including volumes), run `make fclean`.

## Accessing the website and administration panel
1. Update your hosts file so `login.42.fr` resolves to the VM’s IP address.
2. Open `https://login.42.fr` in a browser. Accept the self-signed certificate warning.
3. Use the administrator credentials (stored in `secrets/wp_admin_password.txt`) with the admin username from `srcs/.env` to log into `https://login.42.fr/wp-admin`.

## Credentials management
- Passwords for MariaDB root/user and WordPress admin/author users live in `secrets/*.txt`. Each file contains a single password.
- Usernames, domain name, and emails are defined in `srcs/.env`.
- Update these values before running `make` and keep secrets outside version control.

## Verifying services
- `make status` shows container states through Docker Compose.
- `docker compose -f srcs/docker-compose.yml --env-file srcs/.env logs -f` streams logs.
- Inside the VM, `docker ps` confirms the three containers (nginx, wordpress, mariadb) are running.
- Visit the site and admin panel to ensure WordPress loads correctly.
