#!/bin/bash

echo "🚀 Démarrage de MariaDB..."

if [ ! -f "/var/lib/mysql/.initialized" ]; then
    echo "📦 Première initialisation..."
    
    mysqld --user=mysql --bootstrap << EOF
USE mysql;
FLUSH PRIVILEGES;
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF

    touch /var/lib/mysql/.initialized
    echo "✅ Initialisé"
fi

echo "🔄 Lancement de mysqld..."
exec mysqld --user=mysql --console 2>&1