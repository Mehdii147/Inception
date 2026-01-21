FROM debian:bookworm

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        php8.2-fpm \
        php8.2-mysql \
        php8.2-cli \
        php8.2-curl \
        php8.2-xml \
        php8.2-zip \
        php8.2-mbstring \
        php8.2-gd \
        php8.2-intl \
        mariadb-client \
        curl \
        wget \
        ca-certificates \
        tar \
        tini \
    && rm -rf /var/lib/apt/lists/*

COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf
COPY tools/entrypoint.sh /usr/local/bin/wordpress-entrypoint.sh

RUN curl -fsSL https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -o /usr/local/bin/wp \
    && chmod +x /usr/local/bin/wp \
    && chmod +x /usr/local/bin/wordpress-entrypoint.sh \
    && mkdir -p /var/www/html \
    && chown -R www-data:www-data /var/www/html

WORKDIR /var/www/html
VOLUME ["/var/www/html"]
EXPOSE 9000

ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/wordpress-entrypoint.sh"]
CMD ["php-fpm8.2", "-F"]
