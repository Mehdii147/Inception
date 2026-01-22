#!/bin/bash

DB_PASSWORD=${MARIADB_USER_PASSWORD:?}
ADMIN_PASSWORD=${WP_ADMIN_PASSWORD:?}
AUTHOR_PASSWORD=${WP_AUTHOR_PASSWORD:?}

mkdir -p /var/www/html
cd /var/www/html

sleep 10

if [ ! -f /usr/local/bin/wp ]; then
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
    mv wp-cli.phar /usr/local/bin/wp
fi

if [ ! -f wp-config.php ]; then
    wp core download --allow-root
    wp config create --dbname=$MARIADB_DATABASE --dbuser=$MARIADB_USER --dbpass=$DB_PASSWORD --dbhost=$MARIADB_HOST --allow-root
    wp core install --url=https://$DOMAIN_NAME --title=$WP_SITE_TITLE --admin_user=$WP_ADMIN_USER --admin_email=$WP_ADMIN_EMAIL --admin_password=$ADMIN_PASSWORD --skip-email --allow-root
    wp user create $WP_AUTHOR_USER $WP_AUTHOR_EMAIL --role=author --user_pass=$AUTHOR_PASSWORD --allow-root
fi

exec "$@"
