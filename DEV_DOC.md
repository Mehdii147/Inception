# Developer Documentation

## Prerequisites
- Virtual machine running Linux with Docker Engine and Docker Compose v2 installed.
- Your login-specific directories available at `/home/<login>/data` for bind mounts.
- Hostname mapping for `<login>.42.fr` pointing to the VM IP.
- Awareness that every container image is built FROM `debian:bookworm`, and WordPress ships with PHP 8.2 (php-fpm) out of the box.

## Initial setup
1. Clone the repository inside your VM.
2. Copy the subject-provided `.env` template from `srcs/.env` and adjust:
   - `HOST_LOGIN`, `DOMAIN_NAME`, and bind paths.
   - WordPress usernames, emails, and titles.
3. Create the secrets directory:
   ```sh
   mkdir -p secrets
   ```
4. Populate secret files (one password per file):
   - `secrets/db_root_password.txt`
   - `secrets/db_user_password.txt`
   - `secrets/wp_admin_password.txt`
   - `secrets/wp_author_password.txt`
   These files are mounted as Docker secrets.

## Building and running
Use the Makefile to orchestrate Docker Compose:
```sh
make         # builds (if needed) and starts the stack
make build   # only build images
make down    # stop containers and keep volumes
make fclean  # stop containers and delete volumes + bind dirs
make logs    # follow container logs
make status  # show container status
```
Behind the scenes, `make` invokes `docker compose -f srcs/docker-compose.yml --env-file srcs/.env ...`.

## Managing containers and volumes
- Containers share the custom network `${NETWORK_NAME}` (defaults to `inception`). Use `docker network inspect inception` to inspect.
- WordPress files persist in `${WP_VOLUME_PATH}` and MariaDB data in `${DB_VOLUME_PATH}` on the host. Deleting these directories wipes the site database/files.
- To manually inspect volumes from the host, browse `/home/<login>/data/wordpress` and `/home/<login>/data/mariadb`.

## Development tips
- Modify Dockerfiles under `srcs/requirements/*/Dockerfile`. Re-run `make build` to rebuild images (they currently pin to `debian:bookworm`).
- Entry scripts live under `srcs/requirements/*/tools/entrypoint.sh`. Ensure they remain executable.
- Update `srcs/docker-compose.yml` when adding services or environment variables.
- PHP-FPM listens on port 9000 via PHP 8.2, so adjust `/etc/php/8.2/fpm/pool.d/www.conf` if you need alternate FastCGI tuning.
- Keep secrets out of Git; rely on `.gitignore` and the provided `secrets/.gitignore` guard.
