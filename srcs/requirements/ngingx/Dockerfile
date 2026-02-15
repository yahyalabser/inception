FROM alpine:3.22

# Installation NGINX et OpenSSL
RUN apt-get update && apt-get install -y \
    nginx \
    openssl \
    && rm -rf /var/lib/apt/lists/*

# Créer le dossier pour les certificats SSL
RUN  mkdir -p /etc/nginx/ssl

# Générer un certificat SSL auto-signé
RUN openssl genrsa -out server.key 2048 \
    openssl req -new -x509 \
    -key /etc/nginx/ssl/server.key \
    -out /etc/nginx/ssl/server.crt\
    -days 365 \
    -subj "/C=FR/ST=Paris/L=Paris/O=Test/CN=ylabser.42.fr"

# Copier la configuration NGINX
COPY conf/nginx.conf  /etc/nginx/nginx.conf

EXPOSE 443
