# Inception 42

A Docker-based infrastructure project from 42 school that sets up a small web stack using docker-compose.

## Architecture

The project runs three services, each in its own Docker container based on **Debian Bullseye**:

| Container   | Role                                      | Port |
|-------------|-------------------------------------------|------|
| **nginx**   | HTTPS reverse proxy (TLS 1.2/1.3 only)   | 443  |
| **wordpress** | PHP-FPM application server              | 9000 |
| **mariadb** | MySQL-compatible database                 | 3306 |

```
Browser ──HTTPS(443)──► nginx ──FastCGI(9000)──► wordpress ──MySQL(3306)──► mariadb
```

## Prerequisites

- Docker and Docker Compose
- `sudo` privileges (for creating host data directories)
- Add `127.0.0.1 ylabser.42.fr` to `/etc/hosts`

## Quick Start

```bash
# Clone the repository
git clone <repo-url> inception
cd inception

# Build and start all services
make

# Stop services
make down

# Full cleanup (removes containers, volumes, and data directories)
make fclean
```

## Makefile Targets

| Target    | Description                                              |
|-----------|----------------------------------------------------------|
| `all`     | Create data directories and start all containers         |
| `down`    | Stop and remove containers                               |
| `clean`   | Stop containers and prune unused Docker objects          |
| `fclean`  | Full cleanup including host data directories             |
| `re`      | Full rebuild from scratch                                |

## Environment Variables

All configuration lives in `srcs/.env`:

| Variable             | Description                     |
|----------------------|---------------------------------|
| `DOMAIN_NAME`        | Domain served by nginx          |
| `MYSQL_ROOT_PASSWORD`| MariaDB root password           |
| `MYSQL_DATABASE`     | WordPress database name         |
| `MYSQL_USER`         | WordPress database user         |
| `MYSQL_PASSWORD`     | WordPress database password     |
| `WP_ADMIN`           | WordPress admin username        |
| `WP_ADMIN_PASS`      | WordPress admin password        |
| `WP_ADMIN_EMAIL`     | WordPress admin email           |
| `WP_USER`            | Additional WordPress user       |
| `WP_USER_EMAIL`      | Additional WordPress user email |
| `WP_USER_PASS`       | Additional WordPress user pass  |

## Volumes

Data is persisted on the host machine at `/home/yahyalb/data/`:

- `/home/yahyalb/data/wordpress` — WordPress files
- `/home/yahyalb/data/mariadb` — MariaDB database files

## Security

- nginx only accepts TLSv1.2 and TLSv1.3 connections
- A self-signed SSL certificate is generated at build time
- No service is reachable directly from the host except nginx on port 443
