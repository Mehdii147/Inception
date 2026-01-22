FROM debian:bookworm

RUN apt-get update -y && \
    apt-get install -y \
        php \
        php-fpm \
        php-mysql \
        mariadb-client \
        curl

COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf
COPY tools/entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh && \
    mkdir -p /run/php

ENTRYPOINT ["/entrypoint.sh"]
CMD ["php-fpm8.2", "-F"]
