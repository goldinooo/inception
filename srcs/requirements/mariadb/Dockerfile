FROM debian:bookworm

RUN apt-get update && apt-get install -y mariadb-server mariadb-client

COPY tools/setup.sh /usr/local/bin/setup.sh

ENTRYPOINT ["/usr/local/bin/setup.sh"]