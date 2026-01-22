#!/bin/bash
set -euo pipefail

ROOT_PASSWORD=${MARIADB_ROOT_PASSWORD:?}
USER_PASSWORD=${MARIADB_USER_PASSWORD:?}
DATABASE_NAME=${MARIADB_DATABASE:-wordpress}
DATABASE_USER=${MARIADB_USER:-wp_user}

if [ ! -d "/var/lib/mysql/${DATABASE_NAME}" ]; then
    service mariadb start
    sleep 5

    mysql -e "CREATE DATABASE IF NOT EXISTS \`${DATABASE_NAME}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
    mysql -e "CREATE USER IF NOT EXISTS \`${DATABASE_USER}\`@'%' IDENTIFIED BY '${USER_PASSWORD}';"
    mysql -e "GRANT ALL PRIVILEGES ON \`${DATABASE_NAME}\`.* TO \`${DATABASE_USER}\`@'%';"
    mysql -e "FLUSH PRIVILEGES;"
    mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${ROOT_PASSWORD}';"

    mysqladmin -u root -p"${ROOT_PASSWORD}" shutdown
fi

exec "$@"
