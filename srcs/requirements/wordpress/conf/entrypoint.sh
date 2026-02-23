#!/bin/bash

cd /var/www/html

if [ ! -f "/var/www/html/wp-login.php" ]; then
    wp core download --allow-root

    wp config create \
        --dbname=$MYSQL_DATABASE \
        --dbuser=$MYSQL_USER \
        --dbpass=$MYSQL_PASSWORD \
        --dbhost=mariadb \
        --allow-root
fi

if ! wp core is-installed --allow-root 2>/dev/null; then
    wp core install \
        --url=$DOMAIN_NAME \
        --title="Inception 42" \
        --admin_user=$WP_ADMIN \
        --admin_password=$WP_ADMIN_PASS \
        --admin_email=$WP_ADMIN_EMAIL \
        --allow-root

    wp user create $WP_USER $WP_USER_EMAIL \
        --user_pass=$WP_USER_PASS \
        --role=author \
        --allow-root
fi

php-fpm7.4 -F