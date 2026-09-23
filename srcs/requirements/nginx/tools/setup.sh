#!/bin/bash

mkdir -p /etc/nginx/ssl

openssl req -x509 -nodes -days 365 \
    -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/server.key \
    -out /etc/nginx/ssl/server.crt \
    -subj "/C=MA/ST=Rabat/L=Rabat/O=42/OU=Inception/CN=${DOMAIN_NAME}"

exec nginx -g "daemon off;" #for the main process to stay alive