FROM debian:bookworm

RUN apt-get update && apt-get install -y nginx

COPY index.html /var/www/html/
COPY style.css /var/www/html/
COPY script.js /var/www/html/

CMD ["nginx", "-g", "daemon off;"]