FROM debian:bookworm

RUN apt-get update && apt-get install -y \ 
    #runs php code 
    php-fpm \
    #let php talk to mariadb
    php-mysql \
    #http requests
    php-curl \
    #image processing
    php-gd \
    #handle multibyte strings
    php-mbstring \
    #xml parser
    php-xml \
    #zip support
    php-zip \
    wget \  
    mariadb-client

#download wp cli for commands line
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    -O /usr/local/bin/wp \
    && chmod +x /usr/local/bin/wp

#change to wordpress:9000 so that nginx can talk to it instead of php-fpm:9000
COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf 

RUN wget https://wordpress.org/latest.tar.gz

RUN tar -xzf latest.tar.gz

RUN mv wordpress /usr/src/wordpress

RUN rm latest.tar.gz

COPY tools/setup.sh /usr/local/bin/setup.sh

ENTRYPOINT ["/usr/local/bin/setup.sh"]
