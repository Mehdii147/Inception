FROM debian:bookworm

RUN apt update && apt install -y nginx openssl

RUN mkdir -p /etc/nginx/ssl

RUN openssl req -x509 -nodes -days 365 -newkey rsa:4096 \
    -keyout "/etc/nginx/ssl/server.key" \
    -out "/etc/nginx/ssl/server.crt" \
    -subj "/C=MA/ST=Casablanca/L=Casablanca/O=1337/OU=1337/CN=ehafiane.42.fr"

COPY conf/nginx.conf /etc/nginx/conf.d/nginx.conf

CMD ["nginx", "-g", "daemon off;"]
