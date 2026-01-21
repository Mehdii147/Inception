*This project has been created as part of the 42 curriculum by login.*

## Description
Inception recreates a minimal self-hosted infrastructure using Docker on Debian Bookworm images. The stack provisions MariaDB, WordPress (PHP 8.2 via php-fpm only), and an NGINX TLS gateway connected through a dedicated Docker network with persistent volumes bound to `/home/login/data`. Each service is built from scratch using custom Dockerfiles to reinforce containerization best practices and system administration skills.

### Project Overview
- **MariaDB**: provides the WordPress database with secure bootstrap logic and secrets-driven credentials.
- **WordPress + php-fpm**: installs WordPress via WP-CLI, serves PHP 8.2 over FastCGI, and wires two users (admin + author) without running a web server.
- **NGINX**: acts as the single HTTPS entrypoint, generates self-signed certificates, and proxies requests to php-fpm.
- **Volumes & Network**: bind-mounted directories ensure data persistence, and a user-defined bridge network isolates traffic between containers.

## Instructions
1. Ensure Docker and Docker Compose v2+ are available inside your virtual machine (as required by 42).
2. Populate the `secrets/` files (see below) with secure credentials and update `srcs/.env` with your login/domain.
3. From the repository root, run:
   ```sh
   make
   ```
   This builds all Debian Bookworm-based images (including PHP 8.2) and launches the stack in detached mode.
4. Add a hosts entry that maps your local IP to `login.42.fr` (replace with your actual login).
5. Access `https://login.42.fr` (ignore self-signed warnings) and log in with the admin credentials you defined.
6. To stop the stack, run `make down`. To rebuild from scratch, run `make fclean && make`.

### Secrets layout
Create the following files under `secrets/` and keep them out of Git:
- `db_root_password.txt`
- `db_user_password.txt`
- `wp_admin_password.txt`
- `wp_author_password.txt`
Each file should contain a single strong password.

## Project description
### Main design choices
- **Custom Debian Bookworm images** guarantee control over installed packages and align with the project requirements while standardizing on PHP 8.2.
- **Docker Compose orchestration** centralizes the service graph, health checks, and bind mounts.
- **Docker secrets & env vars** decouple confidential data from images and source control.
- **Tini-based entrypoints** provide correct PID 1 semantics, avoiding hacky `tail -f` workarounds.

### Comparison table
| Topic | Virtual Machines | Docker |
| --- | --- | --- |
| Isolation | Full OS isolation per VM | Process-level isolation using namespaces/cgroups |
| Footprint | Heavy: full kernel + OS per instance | Lightweight: shared host kernel |
| Boot time | Minutes | Seconds |
| Use case | Long-running, diverse workloads | Microservices, reproducible environments |

| Topic | Secrets | Environment Variables |
| --- | --- | --- |
| Storage | Mounted files readable only by the target service | Key-value pairs injected into the container |
| Security | Avoids exposure via `docker inspect` and process lists | Easier to leak via env dumps |
| Rotation | Requires file update & restart | Requires env update & restart |
| Usage | Best for credentials and private keys | Great for non-sensitive config knobs |

| Topic | Docker Network | Host Network |
| --- | --- | --- |
| Connectivity | Isolated virtual bridge, custom DNS | Shares host network stack |
| Security | Containers can’t reach host services unless exposed | All services accessible via host ports |
| Port mapping | Explicit via `ports:` | Direct access, higher collision risk |
| Flexibility | Multiple networks, service discovery | Limited isolation |

| Topic | Docker Volumes | Bind Mounts |
| --- | --- | --- |
| Location | Managed by Docker in `/var/lib/docker/volumes` | Direct bind to host path |
| Portability | Portable across hosts (with backups) | Tied to specific host structure |
| Use case | Service data persistence | Real-time code/config sharing |
| Management | Through Docker CLI | Through host filesystem |

## Resources
- [Docker Docs](https://docs.docker.com/)
- [MariaDB Docs](https://mariadb.com/kb/en/documentation/)
- [WordPress & WP-CLI Docs](https://developer.wordpress.org/cli/commands/)
- [NGINX Docs](https://nginx.org/en/docs/)
- AI assistance: Used to bootstrap configuration files (Dockerfiles, entrypoints) and documentation drafts, with manual review and adjustments for accuracy.

## Additional notes
- Update `DOMAIN_NAME`, `HOST_LOGIN`, and bind paths inside `srcs/.env` before running `make`.
- The stack is pinned to Debian Bookworm and PHP 8.2; rebuilding with `make build` ensures all services stay on that baseline.
- For evaluation, be prepared to justify each service’s Dockerfile, entrypoint, and security choice.
