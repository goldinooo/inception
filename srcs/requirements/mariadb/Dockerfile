FROM debian:bookworm

RUN apt-get update && apt-get install -y mariadb-server mariadb-client

COPY tools/setup.sh /usr/local/bin/setup.sh

COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

ENTRYPOINT ["/usr/local/bin/setup.sh"]