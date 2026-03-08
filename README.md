*This project has been created as part of the 42 curriculum by ylabser.*

# Inception 42

## Description

**Inception 42** is a system administration project from the 42 school curriculum. It provisions a small, self-contained web infrastructure entirely inside Docker containers using `docker-compose`. The goal is to understand how to design, build, and operate multi-container applications while respecting security and isolation principles.

The stack consists of three services:

| Container     | Role                                       | Port  |
|---------------|--------------------------------------------|-------|
| **nginx**     | HTTPS reverse proxy (TLS 1.2/1.3 only)    | 443   |
| **wordpress** | PHP-FPM application server                 | 9000  |
| **mariadb**   | MySQL-compatible database                  | 3306  |

```
Browser ──HTTPS(443)──► nginx ──FastCGI(9000)──► wordpress ──MySQL(3306)──► mariadb
```

Each container is built from a custom `Dockerfile` based on `debian:bullseye`. No pre-built application images are used.

## Instructions

### Prerequisites

- Docker and Docker Compose installed
- `sudo` privileges (to create host data directories)
- Add the following line to `/etc/hosts`:
  ```
  127.0.0.1   ylabser.42.fr
  ```

### Installation and Execution

```bash
# Clone the repository
git clone <repo-url> inception
cd inception

# Copy and fill in credentials
cp srcs/.env.example srcs/.env

# Build and start all services
make

# Visit the site
# https://ylabser.42.fr
```

### Makefile Targets

| Target    | Description                                               |
|-----------|-----------------------------------------------------------|
| `all`     | Create data directories and start all containers          |
| `down`    | Stop and remove containers                                |
| `clean`   | Stop containers and prune unused Docker objects           |
| `fclean`  | Full cleanup including host data directories              |
| `re`      | Full rebuild from scratch                                 |

### Environment Variables

All configuration lives in `srcs/.env` (not committed — see `.gitignore`):

| Variable              | Description                      |
|-----------------------|----------------------------------|
| `DOMAIN_NAME`         | Domain served by nginx           |
| `MYSQL_ROOT_PASSWORD` | MariaDB root password            |
| `MYSQL_DATABASE`      | WordPress database name          |
| `MYSQL_USER`          | WordPress database user          |
| `MYSQL_PASSWORD`      | WordPress database password      |
| `WP_ADMIN`            | WordPress admin username         |
| `WP_ADMIN_PASS`       | WordPress admin password         |
| `WP_ADMIN_EMAIL`      | WordPress admin email            |
| `WP_USER`             | Additional WordPress user        |
| `WP_USER_EMAIL`       | Additional WordPress user email  |
| `WP_USER_PASS`        | Additional WordPress user pass   |

## Project Description

### Virtual Machines vs Docker

| Aspect          | Virtual Machine                                | Docker Container                              |
|-----------------|------------------------------------------------|-----------------------------------------------|
| Isolation       | Full OS-level isolation via hypervisor         | Process-level isolation via kernel namespaces |
| Startup time    | Minutes (full OS boot)                         | Seconds (process start)                       |
| Resource usage  | Heavy (dedicated CPU/RAM per VM)               | Lightweight (shared kernel)                   |
| Portability     | Portable but large image size                  | Very portable; small images                   |
| Use case        | Strong isolation, different OS versions        | Microservices, CI/CD, reproducible builds     |

In this project Docker is preferred because the three services (nginx, WordPress, MariaDB) are lightweight and benefit from fast startup, easy orchestration with `docker-compose`, and minimal resource overhead.

### Secrets vs Environment Variables

| Aspect         | Environment Variables                          | Docker Secrets                                 |
|----------------|------------------------------------------------|------------------------------------------------|
| Storage        | In memory of the process / `.env` file on disk | Encrypted in Docker Swarm; file under `/run/secrets/` |
| Visibility     | Visible via `docker inspect` and `env`         | Mounted as a file; not exposed to `docker inspect` |
| Git safety     | Must be gitignored manually                    | Stored outside the image/compose build context |
| Best for       | Non-sensitive config (domain name, ports)      | Passwords, API keys, TLS private keys          |

In this project sensitive values (database passwords, WordPress credentials) are kept in `srcs/.env` which is gitignored. Using Docker secrets (Swarm mode) would add an extra layer of protection in production.

### Docker Network vs Host Network

| Aspect              | `bridge` (docker-network)                      | `host` network                                |
|---------------------|------------------------------------------------|-----------------------------------------------|
| Isolation           | Containers have their own IP range             | Container shares the host's network stack     |
| Port mapping        | Explicit (`ports:`) required to reach host     | No mapping needed; ports bind directly        |
| Security            | Better — containers are isolated by default    | Lower — container can access all host ports   |
| Inter-container DNS | Service names resolve automatically            | Must use `localhost` or host IP               |

This project uses a dedicated `bridge` network (`docker-network`) so containers communicate by name (e.g., `mariadb`, `wordpress`) and only nginx is reachable from outside on port 443.

### Docker Volumes vs Bind Mounts

| Aspect          | Docker Named Volumes                           | Bind Mounts                                    |
|-----------------|------------------------------------------------|------------------------------------------------|
| Management      | Managed by Docker (`docker volume ls/rm`)      | Managed by the host filesystem directly        |
| Portability     | Portable across Docker hosts                   | Path must exist on the host                   |
| Performance     | Optimised by Docker storage driver             | Raw filesystem performance                    |
| Subject rules   | **Required** by the 42 subject                 | **Forbidden** for the two persistent volumes  |

This project uses two named volumes (`wordpress_db`, `mariadb_db`) that are pinned to `/home/<login>/data/` on the host (where `<login>` is your system username, configured in the `Makefile`) via `driver: local` so data survives container removal.

## Resources

- [Docker documentation](https://docs.docker.com/)
- [Docker Compose reference](https://docs.docker.com/compose/compose-file/)
- [NGINX documentation](https://nginx.org/en/docs/)
- [MariaDB documentation](https://mariadb.com/kb/en/)
- [WP-CLI documentation](https://wp-cli.org/)
- [PHP-FPM configuration](https://www.php.net/manual/en/install.fpm.configuration.php)
- [OpenSSL self-signed certificate guide](https://www.openssl.org/docs/man1.1.1/man1/req.html)
- [PID 1 and signal handling in Docker](https://cloud.google.com/architecture/best-practices-for-building-containers)

### AI Usage

AI tools (ChatGPT / GitHub Copilot) were used during this project for the following tasks:

- **Understanding concepts**: explaining the difference between bind mounts and named volumes, TLS handshake flow, and PHP-FPM FastCGI protocol.
- **Debugging**: helping interpret Docker error messages and MariaDB bootstrap SQL syntax.
- **Documentation drafting**: generating initial drafts of README sections which were then reviewed, corrected, and rewritten to match the actual project.

All AI-generated content was reviewed, tested, and validated before inclusion. No code was copied without understanding it first.