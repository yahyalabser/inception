#!/bin/bash
set -e

echo "Starting MariaDB..."

# S'assurer que les répertoires existent (utile avec bind-mount)
mkdir -p /var/run/mysqld
chown -R mysql:mysql /var/run/mysqld /var/lib/mysql

# Init uniquement si le dossier système n'existe pas encore
if [ ! -d "/var/lib/mysql/mysql" ]; then
  echo "First initialization..."

  mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql >/dev/null

  # Bootstrap de la configuration (root password, db, user)
  mysqld --user=mysql --bootstrap <<-EOF
    FLUSH PRIVILEGES;
    ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
    CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
    CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
    GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
    FLUSH PRIVILEGES;
EOF

  echo "MariaDB initialized."
fi

echo "Launching mysqld..."
exec mysqld --user=mysql --console