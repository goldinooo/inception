FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    tar \
    gzip

COPY tools/backup.sh /usr/local/bin/backup.sh

RUN chmod +x /usr/local/bin/backup.sh

CMD ["/usr/local/bin/backup.sh"]