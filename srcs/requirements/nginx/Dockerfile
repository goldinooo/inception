FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    nginx \
    openssl

COPY tools/setup.sh /usr/local/bin/setup.sh
COPY conf/default.conf /etc/nginx/sites-available/default

ENTRYPOINT ["/usr/local/bin/setup.sh"]