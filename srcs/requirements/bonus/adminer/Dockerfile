FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    php-fpm \
    php-mysql \
    wget

RUN mkdir -p /var/www/html

RUN wget https://github.com/vrana/adminer/releases/download/v5.4.1/adminer-5.4.1.php \
    -O /var/www/html/adminer.php

COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf
COPY tools/setup.sh /usr/local/bin/setup.sh

RUN chmod +x /usr/local/bin/setup.sh

ENTRYPOINT ["/usr/local/bin/setup.sh"]