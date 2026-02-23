# User Documentation — Inception 42

## What Is This?

**Inception 42** is a self-hosted WordPress website running entirely inside Docker containers. It uses HTTPS and is accessible at `https://ylabser.42.fr`.

## Requirements

- A Linux machine with Docker and Docker Compose installed.
- `sudo` access.
- Port `443` must be free.

## First-Time Setup

### 1. Configure your hosts file

Add the following line to `/etc/hosts` so your browser can resolve the local domain:

```
127.0.0.1   ylabser.42.fr
```

### 2. Start the stack

```bash
make
```

This will:
- Create the data directories at `/home/yahyalb/data/`.
- Build the three Docker images (nginx, wordpress, mariadb).
- Start all containers.

### 3. Open the website

Navigate to `https://ylabser.42.fr` in your browser.

> ⚠️ Your browser will warn about an untrusted certificate because the site uses a self-signed TLS certificate. You can safely accept the warning for local use.

## Logging In to WordPress

| Role          | Username   | URL                                   |
|---------------|------------|---------------------------------------|
| Administrator | `ylabser`  | `https://ylabser.42.fr/wp-admin`      |
| Author        | `adam`     | `https://ylabser.42.fr/wp-login.php`  |

> Passwords are defined in `srcs/.env`.

## Stopping the Stack

```bash
make down
```

## Full Cleanup

To stop everything, remove all Docker data, **and** delete the WordPress and database files from disk:

```bash
make fclean
```

> ⚠️ This is irreversible. All WordPress posts, settings, and database entries will be lost.

## Restarting From Scratch

```bash
make re
```

This runs `fclean` followed by `all` — a complete rebuild and fresh installation.

## Checking That Services Are Running

```bash
# List all running containers and their status
docker compose -f srcs/docker-compose.yml ps

# Tail live logs for each service
docker compose -f srcs/docker-compose.yml logs -f

# Tail logs for a specific service (nginx, wordpress, or mariadb)
docker compose -f srcs/docker-compose.yml logs -f nginx

# Verify HTTPS is working (replace the domain if needed)
curl -k -I https://ylabser.42.fr

# Check that MariaDB is accepting connections
docker exec -it mariadb mariadb -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" -e "SHOW DATABASES;"

# Check PHP-FPM is listening on port 9000
docker exec -it wordpress ss -tlnp | grep 9000
```

If a container has exited unexpectedly, inspect its last logs:

```bash
docker compose -f srcs/docker-compose.yml logs --tail=50 <service>
```