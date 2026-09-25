#!/bin/bash

if [ ! -f /var/www/html/wp-load.php ]; then
    echo "Copying WordPress files..."
    cp -a /usr/src/wordpress/. /var/www/html/
fi

DB_PASSWORD=$(cat /run/secrets/db_password)
WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)
WP_USER_PASSWORD=$(cat /run/secrets/wp_user_password)

if [ ! -f /var/www/html/wp-config.php ]; then
    echo "Creating wp-config.php..."

    cat > /var/www/html/wp-config.php << EOF
<?php

define('DB_NAME', '${MYSQL_DATABASE}');
define('DB_USER', '${MYSQL_USER}');
define('DB_PASSWORD', '${DB_PASSWORD}');
define('DB_HOST', 'mariadb:3306');
define('DB_CHARSET', 'utf8');
define('DB_COLLATE', '');

\$table_prefix = 'wp_';

define('WP_DEBUG', false);
define('WP_REDIS_HOST', 'redis');
define('WP_REDIS_PORT', 6379);
if ( ! defined('ABSPATH') ) {
    define('ABSPATH', __DIR__ . '/');
}

require_once ABSPATH . 'wp-settings.php';
EOF

    chown -R www-data:www-data /var/www/html
fi

echo "Waiting for MariaDB..."

until mariadb -h mariadb -u "$MYSQL_USER" -p"$DB_PASSWORD" "$MYSQL_DATABASE" -e "SELECT 1" > /dev/null 2>&1
do
    sleep 2
done

echo "MariaDB is ready."

if ! wp core is-installed --path=/var/www/html --allow-root; then

    echo "Installing WordPress..."

    wp core install \
        --path=/var/www/html \
        --url="https://${DOMAIN_NAME}" \
        --title="Inception WordPress" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$WP_ADMIN_PASSWORD" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --skip-email \
        --allow-root

    echo "Creating second WordPress user..."

    wp user create \
        "$WP_USER" \
        "$WP_USER_EMAIL" \
        --user_pass="$WP_USER_PASSWORD" \
        --role=subscriber \
        --path=/var/www/html \
        --allow-root
fi

echo "Configuring Redis..."

if ! wp plugin is-installed redis-cache --path=/var/www/html --allow-root; then
    wp plugin install redis-cache --path=/var/www/html --allow-root
fi

if ! wp plugin is-active redis-cache --path=/var/www/html --allow-root; then
    wp plugin activate redis-cache --path=/var/www/html --allow-root
fi

if [ ! -f /var/www/html/wp-content/object-cache.php ]; then
    wp redis enable --path=/var/www/html --allow-root
fi

exec php-fpm8.2 -F