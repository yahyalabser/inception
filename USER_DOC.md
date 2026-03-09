# User Documentation — Inception 42

## What Is This?

**Inception 42** is a self-hosted WordPress website running entirely inside Docker containers. It uses HTTPS and is accessible at `https://ylabser.42.fr`.

The stack provides three services:

| Service       | Role                                          |
|---------------|-----------------------------------------------|
| **nginx**     | HTTPS reverse proxy — the entry point for all web traffic |
| **wordpress** | The WordPress application and admin panel     |
| **mariadb**   | The database storing all WordPress content    |

## Requirements

- A Linux machine with Docker and Docker Compose installed.
- `sudo` access.
- Port `443` must be free.

## First-Time Setup

### 0. Create the environment file

The `.env` file is not included in the repository. Create it before running `make`:

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

Then replace each `your_*` value with your actual passwords before continuing.  
Without this file, `make` will fail.

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
- Create the data directories at `/home/ylabser/data/`.
- Build the three Docker images (nginx, wordpress, mariadb).
- Start all containers.

### 3. Open the website

Navigate to `https://ylabser.42.fr` in your browser.

> ⚠️ Your browser will warn about an untrusted certificate because the site uses a self-signed TLS certificate. You can safely accept the warning for local use.

## Accessing the Website and Admin Panel

| Role          | Username   | URL                                   |
|---------------|------------|---------------------------------------|
| Administrator | `ylabser`  | `https://ylabser.42.fr/wp-admin`      |
| Author        | `adam`     | `https://ylabser.42.fr/wp-login.php`  |

## Credentials — Where to Find and How to Change Them

All credentials are stored in a single file: `srcs/.env`.

To view the current credentials:

```bash
cat srcs/.env
```

To change a password (example: WordPress admin password):

1. Edit `srcs/.env` and update the relevant variable (e.g. `WP_ADMIN_PASS`).
2. Run a full rebuild so the new values take effect:

```bash
make re
```

> ⚠️ `make re` will delete all data and reinstall WordPress from scratch. Back up any content you want to keep before running it.

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
