#!/bin/bash

mkdir -p /backup

while true
do
    tar -czf "/backup/wordpress-$(date +%Y-%m-%d_%H-%M-%S).tar.gz" -C /var/www/html .
    sleep 86400
done