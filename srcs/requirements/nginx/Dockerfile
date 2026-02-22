FROM debian:bullseye

RUN apt-get update && apt-get install -y \
    nginx \
    openssl \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/nginx/ssl \
    && openssl genrsa -out /etc/nginx/ssl/server.key 2048 \
    && openssl req -new -x509 \
        -key /etc/nginx/ssl/server.key \
        -out /etc/nginx/ssl/server.crt \
        -days 365 \
        -subj "/C=MO/L=KH/O=1337/CN=ylabser.42.fr"

COPY conf/nginx.conf /etc/nginx/nginx.conf

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]