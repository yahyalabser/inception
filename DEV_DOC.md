# Developer Documentation — Inception 42

## Project Structure

```
inception/
├── Makefile
├── README.md
├── DEV_DOC.md
├── USER_DOC.md
└── srcs/
    ├── .env                        # Environment variables (credentials)
    ├── docker-compose.yml          # Service orchestration
    └── requirements/
        ├── nginx/
        │   ├── Dockerfile
        │   └── conf/nginx.conf     # HTTPS + FastCGI config
        ├── mariadb/
        │   ├── Dockerfile
        │   ├── conf/server.cnf     # MariaDB bind/port config
        │   └── tools/script.sh     # Init script (creates DB & users)
        └── wordpress/
            ├── Dockerfile
            └── conf/entrypoint.sh  # WP download, config & install
```

## Container Details

### nginx

- Base image: `debian:bullseye`
- Packages: `nginx`, `openssl`
- A self-signed TLS certificate is generated at **build time** using `openssl req -new -x509`.
- Config file `conf/nginx.conf` is copied to `/etc/nginx/conf.d/default.conf`.
- Only ports `443` (HTTPS) is exposed; HTTP is not served.
- Requests for `.php` files are forwarded to the `wordpress` service via FastCGI on port `9000`.

### mariadb

- Base image: `debian:bullseye`
- Package: `mariadb-server`
- `conf/server.cnf` sets `bind-address = 0.0.0.0` so the WordPress container can connect.
- `tools/script.sh` runs at container startup:
  - On first boot it uses `mysqld --bootstrap` to create the database, user, and set the root password.
  - The presence of `/var/lib/mysql/mysql` directory prevents re-initialization on subsequent boots.
  - After initialization it hands off to `exec mysqld`.

### wordpress

- Base image: `debian:bullseye`
- Packages: PHP 7.4 FPM + extensions, `curl`, `mariadb-client`
- WP-CLI is downloaded from the official GitHub releases.
- PHP-FPM is configured to listen on TCP port `9000` instead of a Unix socket.
- `conf/entrypoint.sh` runs at container startup:
  1. Downloads WordPress core if not already present.
  2. Creates `wp-config.php` pointing to the `mariadb` service.
  3. Runs `wp core install` to set up the site (idempotent — skipped if already installed).
  4. Creates a second WordPress user with the `author` role.
  5. Starts `php-fpm7.4 -F` in the foreground.

## Environment Setup

The `srcs/.env` file is not tracked by git. After cloning, create it from scratch:

```bash
cat > srcs/.env << EOF
DOMAIN_NAME=ylabser.42.fr

MYSQL_ROOT_PASSWORD=your_root_password
MYSQL_DATABASE=wordpress
MYSQL_USER=your_db_user
MYSQL_PASSWORD=your_db_password

WP_ADMIN=ylabser
WP_ADMIN_PASS=your_admin_password
WP_ADMIN_EMAIL=admin@example.com

WP_USER=adam
WP_USER_EMAIL=adam@example.com
WP_USER_PASS=your_user_password
EOF
```

Never commit `.env` directly — it contains passwords.

## Building Locally

```bash
# Build all images and start services
make

# Rebuild a single service (example: wordpress)
docker compose -f srcs/docker-compose.yml build wordpress
docker compose -f srcs/docker-compose.yml up -d wordpress
```

## Managing Containers and Volumes

```bash
# List all running containers and their status
docker compose -f srcs/docker-compose.yml ps

# Start / stop / restart a specific service
docker compose -f srcs/docker-compose.yml start mariadb
docker compose -f srcs/docker-compose.yml stop mariadb
docker compose -f srcs/docker-compose.yml restart wordpress

# Open a shell in a running container
docker exec -it wordpress bash
docker exec -it mariadb bash

# Tail logs for a specific service
docker compose -f srcs/docker-compose.yml logs -f mariadb

# List Docker volumes used by the project
docker volume ls | grep inception

# Inspect a volume (shows mount point and driver details)
docker volume inspect inception_wordpress_db
docker volume inspect inception_mariadb_db

# Remove volumes (only after make down — data will be lost)
docker volume rm inception_wordpress_db inception_mariadb_db
```

> ⚠️ Removing volumes does **not** delete the host data directories (`/home/ylabser/data/`). Use `make fclean` to remove everything including host data.

## Debugging

```bash
# Check PHP-FPM configuration
docker exec -it wordpress php-fpm7.4 -t

# Check nginx configuration
docker exec -it nginx nginx -t

# Inspect a container's environment variables
docker inspect wordpress | grep -A 20 '"Env"'
```

## Network

All containers share a single Docker bridge network `docker-network`. No container exposes a port to the host directly except `nginx:443`. Inter-container communication uses service names as hostnames (e.g., `mariadb`, `wordpress`).

## Volumes

| Volume name    | Mount point inside container | Host path                      |
|----------------|------------------------------|--------------------------------|
| `wordpress_db` | `/var/www/html`              | `/home/ylabser/data/wordpress` |
| `mariadb_db`   | `/var/lib/mysql`             | `/home/ylabser/data/mariadb`   |

Both volumes use `driver: local` with `type: none` / `o: bind` to bind-mount a specific host directory into the container.

**How data persists:**
- WordPress files (themes, plugins, uploads) are stored at `/home/ylabser/data/wordpress` on the host.
- MariaDB database files are stored at `/home/ylabser/data/mariadb` on the host.
- These directories are created by `make all` before any container starts.
- Because the data lives on the host filesystem, it survives `docker compose down`, container restarts, and image rebuilds — only `make fclean` will delete it by removing the host directories entirely.

## Known Constraints (42 rules)

- All Dockerfiles must be based on the **penultimate stable** Debian or Alpine release.
- No pre-built images from Docker Hub (except the base OS image).
- Containers must restart automatically on failure (`restart: on-failure`).
- Passwords and secrets must not be stored in Dockerfiles; use environment variables via `.env`.
