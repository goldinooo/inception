#!/bin/bash

FTP_PASSWORD=$(cat /run/secrets/ftp_password)

if ! id ftpuser >/dev/null 2>&1; then
    useradd -d /var/www/html -s /bin/bash ftpuser
    echo "ftpuser:${FTP_PASSWORD}" | chpasswd
fi

chown -R ftpuser:ftpuser /var/www/html
mkdir -p /var/run/vsftpd/empty

exec vsftpd /etc/vsftpd.conf