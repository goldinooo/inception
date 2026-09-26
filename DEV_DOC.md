# Developer Documentation

## Prerequisites

The development environment requires:

* Linux
* Docker
* Docker Compose
* Git
* A working domain entry for `reda.42.fr`

Check Docker:

```bash
docker --version
```

Check Docker Compose:

```bash
docker compose version
```

---

## Project Structure

```text
inception/
├── Makefile
├── README.md
├── USER_DOC.md
├── DEV_DOC.md
├── secrets/
└── srcs/
    ├── docker-compose.yml
    ├── .env
    └── requirements/
        ├── mariadb/
        ├── wordpress/
        ├── nginx/
        └── bonus/
            ├── redis/
            ├── ftp/
            ├── adminer/
            ├── static/
            └── backup/
```

---

## Configuration

The main Compose configuration is:

```text
srcs/docker-compose.yml
```

General configuration is stored in:

```text
srcs/.env
```

Example values:

```text
DOMAIN_NAME=reda.42.fr
MYSQL_DATABASE=wordpress
MYSQL_USER=wpuser
```

Passwords are not stored in `.env`.

They are stored in:

```text
secrets/
```

Required secret files include:

```text
db_password.txt
db_root_password.txt
wp_admin_password.txt
wp_user_password.txt
ftp_password.txt
```

The secret files must contain non-empty passwords.

---

## Host Configuration

For local testing, add the domain to the hosts file.

On Linux:

```bash
sudo nano /etc/hosts
```

Add:

```text
127.0.0.1 reda.42.fr
```

When using a VM, replace the IP address with the VM's IP address.

---

## Build the Project

From the project root:

```bash
make build
```

This builds all Docker images defined in the Compose file.

You can also build directly with:

```bash
docker compose -f srcs/docker-compose.yml build
```

---

## Start the Project

```bash
make up
```

or:

```bash
docker compose -f srcs/docker-compose.yml up -d
```

To build and start in one command:

```bash
make
```

---

## Stop the Project

```bash
make down
```

This removes the containers but keeps persistent data.

---

## Rebuild

```bash
make re
```

This:

1. Stops the containers.
2. Rebuilds the images.
3. Starts the infrastructure again.

---

## Container Management

List running containers:

```bash
docker ps
```

List all containers:

```bash
docker ps -a
```

View logs:

```bash
docker logs <container>
```

Follow logs:

```bash
docker logs -f <container>
```

Open a shell inside a container:

```bash
docker exec -it <container> bash
```

---

## Docker Volumes

List volumes:

```bash
docker volume ls
```

The project uses:

```text
srcs_mariadb_data
srcs_wordpress_data
srcs_backup_data
```

Inspect a volume:

```bash
docker volume inspect srcs_wordpress_data
```

---

## Persistent Storage

The Docker volumes are backed by directories on the host:

```text
/home/reda/data/mariadb
/home/reda/data/wordpress
/home/reda/data/backups
```

MariaDB data is stored in:

```text
/home/reda/data/mariadb
```

WordPress files are stored in:

```text
/home/reda/data/wordpress
```

Backup archives are stored in:

```text
/home/reda/data/backups
```

Because these directories exist outside the containers, removing and recreating containers does not remove the stored data.

Check the data:

```bash
sudo du -sh /home/reda/data/*
```

---

## Test Persistence

Stop the infrastructure:

```bash
make down
```

Confirm that the containers are gone:

```bash
docker ps
```

Start it again:

```bash
make up
```

Then verify the WordPress website and database.

This tests that the important data survives container recreation.

---

## Testing NGINX

Check the configuration:

```bash
docker exec -it srcs-nginx-1 nginx -t
```

Test HTTPS:

```bash
curl -k -I https://reda.42.fr/
```

Expected result:

```text
HTTP/1.1 200 OK
```

---

## Testing Docker Networking

List networks:

```bash
docker network ls
```

Test container name resolution:

```bash
docker exec -it srcs-nginx-1 getent hosts static
```

Docker's internal DNS allows containers to communicate using service names such as:

```text
mariadb
wordpress
redis
static
adminer
```

---

## Testing MariaDB

Open MariaDB:

```bash
docker exec -it srcs-mariadb-1 mariadb -u root -p
```

Check databases:

```sql
SHOW DATABASES;
```

The `wordpress` database should exist.

---

## Testing Redis

Check Redis from WordPress:

```bash
docker exec -it srcs-wordpress-1 \
wp redis status --path=/var/www/html --allow-root
```

Check Redis keys:

```bash
docker exec -it srcs-redis-1 redis-cli DBSIZE
```

---

## Testing Backup

List backups:

```bash
ls -lh /home/reda/data/backups/
```

Inspect an archive:

```bash
tar -tzf /home/reda/data/backups/<backup-file>.tar.gz | head
```

The archive should contain WordPress files such as:

```text
wp-admin/
wp-content/
wp-includes/
wp-settings.php
```

---

## Docker Cleanup

Stop the project:

```bash
make down
```

Remove unused Docker resources:

```bash
docker system prune -f
```

Avoid using:

```bash
docker system prune -a
```

unless a complete Docker image cleanup is specifically required.

The project also provides:

```bash
make fclean
```

which removes Compose containers and Docker volume objects. Use it carefully when persistent data is important.

---

## Development Workflow

A typical development cycle is:

```bash
make
```

Check:

```bash
docker ps
```

View logs if something fails:

```bash
docker logs <container>
```

Modify the relevant Dockerfile, configuration or script.

Then rebuild:

```bash
make re
```

Test the affected service.

Persistent data should be checked before performing destructive cleanup operations.
