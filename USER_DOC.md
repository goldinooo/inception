# User Documentation

## Services

This project provides the following services:

* **NGINX** — HTTPS web server and entry point.
* **WordPress** — main website.
* **MariaDB** — WordPress database.
* **Redis** — WordPress object cache.
* **FTP** — access to WordPress files.
* **Adminer** — web interface for MariaDB.
* **Static Portfolio** — terminal-style portfolio.
* **Backup** — periodic WordPress file backups.

---

## Start the Project

From the project root:

```bash
make
```

Check that the containers are running:

```bash
docker ps
```

---

## Stop the Project

```bash
make down
```

This stops and removes the containers while keeping persistent data.

To start the project again:

```bash
make up
```

---

## Website

The main website is available at:

```text
https://reda.42.fr/
```

Because the project uses a self-signed certificate, the browser may display a certificate warning during local testing.

---

## WordPress Administration

The WordPress administration panel is available at:

```text
https://reda.42.fr/wp-admin/
```

The administrator username and password are stored in the local `secrets/` directory.

---

## Adminer

Adminer is available at:

```text
https://reda.42.fr/adminer.php
```

Use the MariaDB credentials to connect.

For the server field, use:

```text
mariadb
```

---

## Portfolio

The static portfolio is available at:

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

---

## Credentials

Sensitive credentials are stored locally in:

```text
secrets/
```

The directory contains:

```text
db_password.txt
db_root_password.txt
wp_admin_password.txt
wp_user_password.txt
ftp_password.txt
```

These files should **not be committed to Git**.

Docker makes the secrets available to containers through:

```text
/run/secrets/
```

---

## Check the Services

Check running containers:

```bash
docker ps
```

Check all containers:

```bash
docker ps -a
```

Check Docker logs:

```bash
docker logs <container>
```

For example:

```bash
docker logs srcs-wordpress-1
```

---

## Check HTTPS

```bash
curl -k -I https://reda.42.fr/
```

A successful response should contain:

```text
HTTP/1.1 200 OK
```

---

## Check Persistent Data

Persistent data is stored on the host under:

```text
/home/reda/data/
```

The directories are:

```text
/home/reda/data/mariadb
/home/reda/data/wordpress
/home/reda/data/backups
```

Check their sizes with:

```bash
sudo du -sh /home/reda/data/*
```

---

## Backup

Backups are stored in:

```text
/home/reda/data/backups/
```

List them with:

```bash
ls -lh /home/reda/data/backups/
```

A backup has a name similar to:

```text
wordpress-2026-09-25_23-18-45.tar.gz
```

To inspect a backup:

```bash
tar -tzf /home/reda/data/backups/<backup-file>.tar.gz
```
