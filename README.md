*This project has been created as part of the 42 curriculum by retahri.*

# Inception

## Description

Inception is a Docker infrastructure project from the 42 curriculum.

The goal is to build a small web infrastructure using Docker Compose, with each service running inside its own container.

The mandatory infrastructure contains:

* **NGINX** — HTTPS entry point and web server.
* **WordPress** — website and PHP application.
* **MariaDB** — WordPress database.

This project also contains several bonus services:

* **Redis** — WordPress object cache.
* **FTP** — access to the WordPress files.
* **Adminer** — web interface for MariaDB.
* **Static Portfolio** — a simple terminal-style portfolio.
* **Backup** — periodically creates compressed backups of WordPress files.

The containers communicate through a Docker network, while persistent data is stored in Docker volumes backed by directories on the host.

---

## Project Structure

```text
inception/
├── Makefile
├── README.md
├── secrets/
│   ├── db_password.txt
│   ├── db_root_password.txt
│   ├── ftp_password.txt
│   ├── wp_admin_password.txt
│   └── wp_user_password.txt
│
└── srcs/
    ├── docker-compose.yml
    ├── .env
    │
    └── requirements/
        ├── mariadb/
        ├── wordpress/
        ├── nginx/
        │
        └── bonus/
            ├── redis/
            ├── ftp/
            ├── adminer/
            ├── static/
            └── backup/
```

---

# Docker Architecture

```text
                         Browser
                            │
                         HTTPS :443
                            │
                            ▼
                       ┌─────────┐
                       │  NGINX  │
                       └────┬────┘
                            │
              ┌─────────────┼─────────────┐
              │             │             │
              ▼             ▼             ▼
        ┌──────────┐  ┌──────────┐  ┌──────────┐
        │ WordPress│  │  Adminer │  │  Static  │
        └────┬─────┘  └────┬─────┘  └──────────┘
             │              │
             ▼              ▼
        ┌──────────┐   MariaDB
        │  Redis   │
        └──────────┘

        FTP ───────► WordPress volume

        Backup ────► WordPress volume
```

NGINX is the only service exposed through HTTPS on port `443`.

The other services communicate internally through Docker networking.

---

# Services

## NGINX

NGINX is the public entry point.

It:

* Provides HTTPS.
* Uses TLS 1.2 and TLS 1.3.
* Serves WordPress.
* Sends PHP requests to WordPress/PHP-FPM.
* Provides access to Adminer.
* Proxies `/portfolio/` to the static website.

---

## WordPress

WordPress runs with PHP-FPM.

It:

* Connects to MariaDB.
* Uses Redis for object caching.
* Stores its files in a persistent volume.
* Creates the WordPress installation automatically during the first startup.

PHP-FPM listens on port `9000` inside the Docker network.

---

## MariaDB

MariaDB stores the WordPress database.

It:

* Runs inside its own container.
* Is not exposed to the host.
* Is accessible through the Docker network.
* Stores its database files in a persistent volume.

---

## Redis

Redis is used as the WordPress object cache.

WordPress connects to:

```text
redis:6379
```

Redis stores temporary/cache data in memory instead of replacing MariaDB as the main database.

---

## FTP

The FTP service provides access to the WordPress files.

It uses:

* Port `21` for FTP.
* Ports `21100-21110` for passive FTP connections.

The FTP service shares the WordPress volume.

---

## Adminer

Adminer provides a web interface for managing MariaDB.

It is available through:

```text
https://reda.42.fr/adminer.php
```

Adminer connects to MariaDB through the Docker network.

---

## Static Portfolio

The static service contains a simple terminal-style portfolio.

It is available at:

```text
https://reda.42.fr/portfolio/
```

Available commands include:

```text
help
whoami
portfolio
skills
contact
clear
```

The static container does not expose a port to the host. NGINX proxies requests to it through the Docker network.

---

## Backup

The backup service periodically creates compressed WordPress backups.

The WordPress volume is mounted read-only:

```text
wordpress_data → /var/www/html:ro
```

The service creates files such as:

```text
wordpress-2026-09-25_23-18-45.tar.gz
```

Backups are stored in:

```text
/home/reda/data/backups/
```

This backup service currently backs up **WordPress files**, not the MariaDB database.

---

# Instructions

## Requirements

The project requires:

* Docker
* Docker Compose
* Linux environment
* A hosts entry for the project domain

The project uses:

```text
reda.42.fr
```

For local testing, the domain should point to the machine running Docker.

Example:

```text
127.0.0.1 reda.42.fr
```

---

## Build and Start

From the project root:

```bash
make
```

This builds and starts the Docker Compose infrastructure.

You can also use:

```bash
make build
```

to build the images.

Then:

```bash
make up
```

to start the containers.

---

## Stop the Infrastructure

```bash
make down
```

This stops and removes the containers without removing the persistent data.

---

## Rebuild

```bash
make re
```

This stops the containers, rebuilds the images and starts the infrastructure again.

---

## Full Cleanup

```bash
make fclean
```

This removes the Compose containers and Docker volume objects.

The project uses bind-backed volumes, so the actual persistent data is stored outside the Docker volume object.

Use this command carefully.

---

# Accessing the Services

## WordPress

```text
https://reda.42.fr/
```

## WordPress Admin

```text
https://reda.42.fr/wp-admin/
```

## Adminer

```text
https://reda.42.fr/adminer.php
```

## Portfolio

```text
https://reda.42.fr/portfolio/
```

## FTP

```text
ftp://reda.42.fr
```

FTP uses port:

```text
21
```

and passive ports:

```text
21100-21110
```

---

# Testing

The following tests were used during development to verify that the infrastructure works correctly.

## 1. Check Running Containers

```bash
docker ps
```

### Purpose

Checks that the required containers are running.

Expected services include:

```text
nginx
wordpress
mariadb
redis
ftp
adminer
static
backup
```

---

## 2. Check All Containers

```bash
docker ps -a
```

### Purpose

Shows running and stopped containers.

Useful when debugging a container that exits immediately.

---

## 3. Check Docker Volumes

```bash
docker volume ls
```

Expected volumes include:

```text
srcs_mariadb_data
srcs_wordpress_data
srcs_backup_data
```

### Purpose

Confirms that persistent storage exists.

---

# Persistence Tests

## 4. Check Persistent Data on the Host

```bash
sudo du -sh /home/reda/data/*
```

Example:

```text
35M     /home/reda/data/backups
115M    /home/reda/data/mariadb
121M    /home/reda/data/wordpress
```

### Purpose

Confirms that important data is stored outside the containers.

---

## 5. Stop the Containers

```bash
make down
```

Then:

```bash
docker ps
```

### Purpose

Confirms that the containers can be removed without immediately deleting the persistent data.

---

## 6. Start Again

```bash
make up
```

Then:

```bash
docker ps
```

### Purpose

Confirms that the infrastructure can be recreated using the existing persistent data.

WordPress and MariaDB should keep their previous data.

---

## 7. Test WordPress Persistence

Open:

```text
https://reda.42.fr/
```

Then:

```text
https://reda.42.fr/wp-admin/
```

### Purpose

Confirms that the WordPress installation and its database survive container recreation.

---

## 8. Test MariaDB Persistence

Enter the MariaDB container:

```bash
docker exec -it srcs-mariadb-1 mariadb -u root -p
```

Then:

```sql
SHOW DATABASES;
```

### Purpose

Confirms that the WordPress database still exists after restarting the infrastructure.

---

# NGINX Tests

## 9. Test HTTPS

```bash
curl -k -I https://reda.42.fr/
```

Expected:

```text
HTTP/1.1 200 OK
```

### Purpose

Confirms that NGINX is responding through HTTPS.

`-k` is used because the project uses a self-signed certificate.

---

## 10. Check NGINX Configuration

```bash
docker exec -it srcs-nginx-1 nginx -t
```

Expected:

```text
syntax is ok
test is successful
```

### Purpose

Checks that the NGINX configuration is valid.

---

# Docker Network Tests

## 11. Check the Docker Network

```bash
docker network ls
```

### Purpose

Confirms that the Docker network exists.

---

## 12. Test Container Name Resolution

```bash
docker exec -it srcs-nginx-1 getent hosts static
```

Expected output contains an IP address followed by:

```text
static
```

### Purpose

Confirms that containers can find each other using Docker's internal DNS.

---

# Redis Tests

## 13. Check Redis from WordPress

```bash
docker exec -it srcs-wordpress-1 wp redis status --path=/var/www/html --allow-root
```

The output should show that Redis is connected.

### Purpose

Confirms that WordPress can communicate with Redis.

---

## 14. Check Redis Keys

```bash
docker exec -it srcs-redis-1 redis-cli DBSIZE
```

### Purpose

Confirms that Redis is actually storing cache data.

---

# FTP Tests

## 15. Test FTP Connection

Connect using an FTP client with:

```text
Host: reda.42.fr
Port: 21
```

### Purpose

Confirms that the FTP service is reachable.

---

## 16. Test FTP File Access

Upload or create a test file through FTP.

Then check the WordPress files.

### Purpose

Confirms that FTP and WordPress are using the same shared volume.

---

# Adminer Test

## 17. Open Adminer

Visit:

```text
https://reda.42.fr/adminer.php
```

Use:

```text
System: MySQL
Server: mariadb
Database: wordpress
Username: wpuser
Password: database password
```

### Purpose

Confirms that Adminer can communicate with MariaDB through the Docker network.

---

# Static Portfolio Test

## 18. Open the Portfolio

Visit:

```text
https://reda.42.fr/portfolio/
```

Then type:

```text
help
```

### Purpose

Confirms that NGINX can proxy requests to the static container.

---

## 19. Test Portfolio Commands

Try:

```text
whoami
portfolio
skills
contact
clear
```

### Purpose

Confirms that the HTML, CSS and JavaScript of the static service are working.

---

# Backup Tests

## 20. Check Backup Files

```bash
ls -lh /home/reda/data/backups/
```

Expected:

```text
wordpress-YYYY-MM-DD_HH-MM-SS.tar.gz
```

### Purpose

Confirms that the backup service is creating persistent backup files.

---

## 21. Inspect a Backup

```bash
tar -tzf /home/reda/data/backups/wordpress-YYYY-MM-DD_HH-MM-SS.tar.gz | head
```

Expected files include:

```text
./wp-settings.php
./wp-blog-header.php
./wp-cron.php
./wp-content/
./wp-admin/
```

### Purpose

Confirms that the archive actually contains WordPress files.

---

# Docker Design Choices

## Virtual Machines vs Docker

### Virtual Machine

A VM virtualizes an entire operating system.

```text
Physical machine
      │
      ▼
Virtual Machine
      │
      └── Complete OS
```

A VM usually requires more memory and storage because each VM has its own operating system.

### Docker

Docker uses containers that share the host kernel.

```text
Physical machine
      │
      ▼
Docker
 ├── NGINX
 ├── WordPress
 ├── MariaDB
 └── Redis
```

Containers are generally lighter and faster to create than full virtual machines.

For this project, Docker makes it possible to separate each service into its own isolated container.

---

# Secrets vs Environment Variables

## Environment Variables

Environment variables are useful for configuration such as:

```text
DOMAIN_NAME=reda.42.fr
MYSQL_DATABASE=wordpress
MYSQL_USER=wpuser
```

They are appropriate for configuration that is not sensitive.

## Docker Secrets

Passwords should not be placed directly inside the Compose file.

This project uses Docker secrets for:

```text
db_password
db_root_password
wp_admin_password
wp_user_password
ftp_password
```

The containers read them from:

```text
/run/secrets/
```

This separates sensitive information from normal configuration.

---

# Docker Network vs Host Network

## Docker Network

Containers communicate through a private Docker network.

For example:

```text
wordpress → mariadb:3306
wordpress → redis:6379
nginx → wordpress:9000
```

The containers can use service names instead of manually configured IP addresses.

## Host Network

With host networking, a container uses the host's network directly.

This provides less network isolation and is unnecessary for this project.

The project therefore uses a Docker network.

---

# Docker Volumes vs Bind Mounts

## Docker Volume

A Docker volume is managed by Docker.

Example:

```text
wordpress_data
```

The container can use it for persistent storage.

## Bind Mount

A bind mount connects a Docker volume to a specific directory on the host.

This project uses bind-backed volumes such as:

```text
/home/reda/data/mariadb
/home/reda/data/wordpress
/home/reda/data/backups
```

This makes the persistent data easy to inspect and preserve outside the project directory.

---

# Technical Choices

### Why separate containers?

Each major service has its own container:

```text
NGINX
WordPress
MariaDB
Redis
FTP
Adminer
Static
Backup
```

This keeps the services separated and makes them easier to build, restart and debug.

### Why NGINX as the public entry point?

Only NGINX needs to receive HTTP/HTTPS traffic from outside.

The other services remain inside the Docker infrastructure.

### Why PHP-FPM?

WordPress requires PHP to execute its PHP files.

PHP-FPM allows NGINX to send PHP requests to the WordPress container.

### Why Redis?

Redis provides object caching for WordPress and reduces repeated database work.

### Why persistent volumes?

Containers can be removed and recreated. Persistent volumes keep important data such as:

* MariaDB databases
* WordPress files
* Backup archives

---

# Resources

## Docker

* Docker documentation:
  [https://docs.docker.com/](https://docs.docker.com/)
* Docker Compose documentation:
  [https://docs.docker.com/compose/](https://docs.docker.com/compose/)
* Docker volumes:
  [https://docs.docker.com/engine/storage/volumes/](https://docs.docker.com/engine/storage/volumes/)
* Docker networking:
  [https://docs.docker.com/engine/network/](https://docs.docker.com/engine/network/)
* Docker secrets:
  [https://docs.docker.com/engine/swarm/secrets/](https://docs.docker.com/engine/swarm/secrets/)
* Understanding Docker
  [https://youtu.be/DQdB7wFEygo?si=cm4WkB31RRZ9G9i_](https://youtu.be/DQdB7wFEygo?si=cm4WkB31RRZ9G9i_)

## NGINX

* NGINX documentation:
  [https://nginx.org/en/docs/](https://nginx.org/en/docs/)
* Understanding NGINX:
  [https://www.youtube.com/watch?v=iInUBOVeBCc](https://www.youtube.com/watch?v=iInUBOVeBCc)

## WordPress

* WordPress documentation:
  [https://wordpress.org/documentation/](https://wordpress.org/documentation/)
* WP-CLI documentation:
  [https://developer.wordpress.org/cli/commands/](https://developer.wordpress.org/cli/commands/)

## MariaDB

* MariaDB documentation:
  [https://mariadb.com/docs/](https://mariadb.com/docs/)
* MariaDB explanation:
  [https://www.youtube.com/watch?v=ty8mi76UOks](https://www.youtube.com/watch?v=ty8mi76UOks)

## Redis

* Redis documentation:
  [https://redis.io/docs/](https://redis.io/docs/)
* Redis in 100 sec:
  [https://www.youtube.com/watch?v=G1rOthIU-uo](https://www.youtube.com/watch?v=G1rOthIU-uo)
* Redis explanation:
  [https://www.youtube.com/watch?v=8A_iNFRP0F4](https://www.youtube.com/watch?v=8A_iNFRP0F4)

## Adminer

* Adminer:
  [https://www.adminer.org/](https://www.adminer.org/)

## FTP

* vsftpd documentation:
  [https://security.appspot.com/vsftpd.html](https://security.appspot.com/vsftpd.html)
* man ftp 😄

---

# AI Usage

AI was used as a learning and development assistant during this project.

It was mainly used for:

* Understanding Docker and Docker Compose concepts.
* Understanding the difference between images and containers.
* Understanding Docker volumes and bind mounts.
* Understanding Docker networks.
* Debugging Docker Compose configuration.
* Debugging NGINX configuration.
* Understanding PHP-FPM and the connection between NGINX and WordPress.
* Debugging MariaDB initialization and user permissions.
* Understanding WordPress and WP-CLI setup.
* Explaining FTP configuration.
* Creating the static portfolio structure.
* Suggesting testing commands and explaining what each test verifies.

AI was not used as a replacement for understanding the project. The configurations and commands were tested manually, and errors were investigated during development.

---

# Final Notes

The project is designed to be reproducible with Docker Compose.

Persistent data is stored separately from the project:

```text
/home/reda/data/mariadb
/home/reda/data/wordpress
/home/reda/data/backups
```

Sensitive files are stored locally in:

```text
secrets/
```

and should not be committed to the Git repository.
