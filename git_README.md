# Docker Fundamentals

A simple reference for understanding Docker

---

## 1. The Big Picture

Docker packages an application and its environment so it can run consistently on different machines.

The basic workflow is:

```text
Dockerfile
    ↓
docker build
    ↓
Image
    ↓
docker run
    ↓
Container
```

### Image

An **image** is a reusable template/blueprint.

It contains things such as:

* Operating system files
* Installed packages
* Application files
* Configuration
* Default commands

Example:

```text
Debian + NGINX + configuration
        ↓
      Image
```

### Container

A **container** is an actual instance created from an image.

```text
Image
  ↓
Container 1
Container 2
Container 3
```

One image can create many containers.

---

# 2. Dockerfile

A `Dockerfile` describes how to build an image.

Example:

```dockerfile
FROM debian:bookworm

RUN apt-get update

WORKDIR /app

COPY hello.txt .

ENV NAME=Reda

EXPOSE 80

CMD ["echo", "hello"]
```

---

## 3. `FROM`

Defines the base image.

```dockerfile
FROM debian:bookworm
```

Meaning:

> Start building my image from Debian Bookworm.

Think:

```text
Debian
   ↓
my custom image
```

For Inception, images must be based on the allowed stable **Alpine or Debian** base images.

---

# 4. `RUN`

Executes a command **during image building**.

```dockerfile
RUN apt-get update
```

Important:

```text
docker build
     ↓
RUN executes
```

NOT:

```text
docker run
```

Example:

```dockerfile
RUN apt-get update
RUN apt-get install -y nginx
```

NGINX is installed while the image is being built.

### `RUN` vs `CMD`

```dockerfile
RUN echo "A"
CMD ["echo", "B"]
```

During:

```bash
docker build -t my-image .
```

you get:

```text
A
```

When running:

```bash
docker run my-image
```

you get:

```text
B
```

So:

```text
RUN → build time
CMD → container startup
```

---

# 5. `COPY`

Copies files from your **build context** into the image.

Example:

```text
project/
├── Dockerfile
└── hello.txt
```

Dockerfile:

```dockerfile
COPY hello.txt /hello.txt
```

After building:

```text
container
└── /hello.txt
```

The original file exists on your computer:

```text
project/hello.txt
```

The copied file exists inside the image/container:

```text
/hello.txt
```

### Important

`COPY` happens during:

```bash
docker build
```

If you delete the original `hello.txt` from your computer afterward, the already-built image still has its copied version.

---

# 6. `WORKDIR`

Sets the current working directory **inside the image/container**.

```dockerfile
WORKDIR /app
```

If `/app` doesn't exist, Docker creates it.

Example:

```dockerfile
WORKDIR /app
COPY hello.txt .
```

Because `.` means the current directory:

```text
/app/hello.txt
```

The same as:

```dockerfile
COPY hello.txt /app/hello.txt
```

You can check the current directory inside a container with:

```bash
pwd
```

---

# 7. `ENV`

Defines an environment variable.

```dockerfile
ENV PORT=8080
```

Inside the container:

```bash
echo $PORT
```

outputs:

```text
8080
```

Think of it similarly to:

```bash
export PORT=8080
```

in a shell.

### Important distinction

A `.env` file is not the same thing as Dockerfile `ENV`.

`.env`:

```text
PORT=8080
DOMAIN=example.com
```

is a file containing values.

`ENV`:

```dockerfile
ENV PORT=8080
```

puts the variable into the image/container environment.

For Inception, `.env` will be used by Docker Compose for configuration.

### Security

Do **not** put passwords directly into Dockerfiles.

For Inception, credentials should be handled using the required environment/secrets mechanism.

---

# 8. `EXPOSE`

Documents which port the application inside the container is expected to use.

```dockerfile
EXPOSE 80
```

It means:

> This container expects an application to listen on port 80.

It does **not** publish the port to your computer.

### `EXPOSE` vs `-p`

```dockerfile
EXPOSE 80
```

is different from:

```bash
docker run -p 8080:80 my-image
```

`EXPOSE`:

```text
"I use port 80."
```

`-p`:

```text
"Connect my computer's port 8080 to the container's port 80."
```

---

# 9. Publishing Ports with `-p`

Syntax:

```bash
-p HOST_PORT:CONTAINER_PORT
```

Example:

```bash
docker run -p 8080:80 my-image
```

Means:

```text
Your PC                    Container

localhost:8080  ─────────► :80
```

Another example:

```bash
docker run -p 5000:3000 my-image
```

means:

```text
localhost:5000 ─────────► container:3000
```

Same port:

```bash
docker run -p 443:443 my-image
```

means:

```text
localhost:443 ──────────► container:443
```

### Mental model

You are simply **routing one port to another port**.

```text
-p PC_PORT:CONTAINER_PORT
```

---

# 10. `CMD`

Defines the default command executed when the container starts.

```dockerfile
CMD ["echo", "hello"]
```

Running:

```bash
docker run my-image
```

runs:

```text
echo hello
```

### Important

`CMD` happens when the container starts, not when the image is built.

Also:

> Only the last `CMD` in a Dockerfile stage is used.

This is wrong:

```dockerfile
CMD ["echo", "father"]
CMD ["echo", "hello"]
```

Only the second one is effective.

---

# 11. Why Containers Stop

A container normally lives as long as its **main process** is running.

Example:

```dockerfile
CMD ["echo", "hello"]
```

The process:

```text
echo hello
```

runs:

```text
print hello
    ↓
process finishes
    ↓
container stops
```

This is normal.

A stopped container still exists:

```bash
docker ps
```

shows running containers.

```bash
docker ps -a
```

shows **all containers**, including stopped ones.

---

# 12. `docker run -it`

`-it` does not mean "keep the container alive forever."

It combines:

```text
-i → interactive input
-t → pseudo-terminal
```

For example:

```bash
docker run -it my-image bash
```

starts Bash inside the container.

Now you can:

```bash
pwd
ls
cat /hello.txt
```

and explore the container.

When you type:

```bash
exit
```

Bash ends, so the container stops.

### Important

The command after the image overrides the default `CMD`.

For example:

```dockerfile
CMD ["echo", "hello"]
```

Normally:

```bash
docker run my-image
```

runs:

```text
echo hello
```

But:

```bash
docker run -it my-image bash
```

runs:

```text
bash
```

instead.

---

# 13. `ENTRYPOINT`

Defines the main program the container is designed to run.

Example:

```dockerfile
ENTRYPOINT ["echo"]
```

Then:

```bash
docker run my-image hello
```

effectively runs:

```bash
echo hello
```

A useful mental model:

```text
ENTRYPOINT = main program
CMD        = default arguments
```

Example:

```dockerfile
ENTRYPOINT ["python3"]
CMD ["app.py"]
```

Running:

```bash
docker run my-image
```

means:

```text
python3 app.py
```

Running:

```bash
docker run my-image test.py
```

means:

```text
python3 test.py
```

### ENTRYPOINT does NOT:

* expose ports
* connect the container to the internet
* select the Python version

The installed software/version comes from the image.

For example:

```dockerfile
FROM debian:bookworm

RUN apt-get update && apt-get install -y python3
```

The Python version is determined by what was installed in the image.

---

# 14. Useful Docker Commands

### Build an image

```bash
docker build -t my-image .
```

`-t` means **tag/name the image**.

`.` means:

> Use the current directory as the build context.

---

### Create and start a new container

```bash
docker run my-image
```

Every `docker run` normally creates a **new container**.

---

### Start an existing stopped container

```bash
docker start my-container
```

Interactive:

```bash
docker start -i my-container
```

---

### List running containers

```bash
docker ps
```

### List all containers

```bash
docker ps -a
```

---

### Remove a container

```bash
docker rm my-container
```

Force removal:

```bash
docker rm -f my-container
```

---

### Remove an image

```bash
docker rmi my-image
```

---

# 15. Container Names

Container names must be unique.

If:

```bash
docker run --name anothertest my-image
```

creates a container named:

```text
anothertest
```

and you stop it, the name is still taken.

Trying:

```bash
docker run --name anothertest my-image
```

again gives a name conflict.

You can remove the old container:

```bash
docker rm anothertest
```

or use another name.

---

# 16. Docker Networks

Containers normally have their own network environments.

Docker networks allow containers to communicate with each other.

Create one manually:

```bash
docker network create my-network
```

Then:

```bash
docker run --network my-network ...
docker run --network my-network ...
```

Now the containers can communicate through that network.

Think:

```text
              Docker network
        ┌────────────────────────┐
        │                        │
        │ Container A ↔ Container B
        │                        │
        └────────────────────────┘
```

### Internal communication does NOT require `-p`

If WordPress and MariaDB are on the same Docker network, WordPress does not need:

```bash
-p 3306:3306
```

to communicate with MariaDB.

`-p` is for publishing a container port to the host/outside world.

---

# 17. `localhost` Inside a Container

This is extremely important.

Inside the WordPress container:

```text
localhost
127.0.0.1
```

means:

> **the WordPress container itself**

It does NOT mean the MariaDB container.

So:

```text
WordPress → localhost:3306
```

looks for MariaDB inside the WordPress container.

Instead, Docker networking lets you use the other service/container's name:

```text
WordPress → mariadb:3306
```

Mental model:

```text
localhost → myself
mariadb   → MariaDB container
```

---

# 18. Docker Compose

Docker Compose lets you describe an entire multi-container application in one YAML file.

Instead of manually creating:

```text
NGINX container
WordPress container
MariaDB container
Network
Volumes
Ports
Environment variables
```

you define them in:

```text
docker-compose.yml
```

For Inception:

```text
docker-compose.yml
        │
        ├── nginx
        ├── wordpress
        └── mariadb
```

---

# 19. Compose `services`

A service describes a container that Compose should create.

Example:

```yaml
services:
  nginx:
    ...

  wordpress:
    ...

  mariadb:
    ...
```

Three services normally result in three dedicated containers:

```text
services              containers

nginx       ───────►  nginx
wordpress   ───────►  wordpress
mariadb     ───────►  mariadb
```

---

# 20. Compose `build`

Example:

```yaml
services:
  mariadb:
    build: ./requirements/mariadb
```

This tells Compose:

> Build the image using the Dockerfile located in this directory.

Project:

```text
srcs/
├── docker-compose.yml
└── requirements/
    └── mariadb/
        └── Dockerfile
```

Compose looks in:

```text
./requirements/mariadb
```

for the Dockerfile.

---

# 21. Compose `ports`

Example:

```yaml
services:
  nginx:
    build: ./requirements/nginx
    ports:
      - "443:443"
```

This is similar to:

```bash
docker run -p 443:443 ...
```

It means:

```text
Host :443 ─────────► NGINX container :443
```

In Inception, NGINX is the public entry point and uses HTTPS.

---

# 22. Compose `volumes`

Containers are disposable.

If a container stores important data directly inside itself:

```text
MariaDB container
└── database
```

deleting the container can delete that data.

A Docker volume stores the data separately:

```text
MariaDB container
       │
       ▼
Docker volume
       │
       └── database data
```

Delete the container:

```text
Container ❌
Volume    ✅
Data      ✅
```

---

## Named volumes

Example:

```yaml
services:
  mariadb:
    volumes:
      - database:/var/lib/mysql

volumes:
  database:
```

Meaning:

```text
Docker volume: database
        │
        ▼
MariaDB:
/var/lib/mysql
```

The volume survives container deletion.

A new container can mount the same volume and access the existing data.

---

# 23. Named Volume vs Bind Mount

### Named Docker volume

```yaml
volumes:
  - database:/var/lib/mysql
```

Docker manages the volume.

### Bind mount

```yaml
volumes:
  - ./database:/var/lib/mysql
```

This directly maps a directory from your host.

Conceptually:

```text
Named volume:

Docker
└── managed volume
        ↓
    container


Bind mount:

Your PC
└── ./database
        ↓
    container
```

For Inception, the subject requires **Docker named volumes**, not simple bind mounts.

The required data must ultimately be stored under:

```text
/home/<login>/data
```

on the host.

---

# 24. Compose `networks`

Compose can create and manage Docker networks.

Example:

```yaml
services:
  nginx:
    networks:
      - inception

  wordpress:
    networks:
      - inception

  mariadb:
    networks:
      - inception

networks:
  inception:
```

Now:

```text
             inception network
        ┌──────────────────────────┐
        │                          │
        │ NGINX ↔ WordPress ↔ MariaDB
        │                          │
        └──────────────────────────┘
```

Containers can communicate using service names.

For example:

```text
mariadb:3306
```

---

# 25. `ports` vs `networks`

These are different concepts.

### `ports`

Used for communication between:

```text
Host ↔ Container
```

Example:

```yaml
ports:
  - "443:443"
```

### `networks`

Used mainly for:

```text
Container ↔ Container
```

Example:

```text
WordPress → mariadb:3306
```

You normally don't publish MariaDB's port to the host just so WordPress can access it.

---

# 26. Inception Architecture

The required architecture is approximately:

```text
                     Internet / Browser
                            │
                         HTTPS
                          :443
                            │
                            ▼
                    ┌───────────────┐
                    │     NGINX     │
                    │    :443       │
                    └───────┬───────┘
                            │
                            ▼
                    ┌───────────────┐
                    │   WordPress   │
                    │   PHP-FPM     │
                    └───────┬───────┘
                            │
                            ▼
                    ┌───────────────┐
                    │    MariaDB    │
                    │    :3306      │
                    └───────────────┘
```

All three communicate through a Docker network.

Persistent data uses two named volumes:

```text
MariaDB
   │
   ▼
Database volume

WordPress
   │
   ▼
Website files volume
```

---

# 27. Inception Service Responsibilities

### NGINX

Responsible for:

* Public entry point
* HTTPS
* TLS 1.2 / TLS 1.3
* Receiving browser requests
* Passing PHP requests toward WordPress/PHP-FPM

Only NGINX should be exposed publicly on port `443`.

---

### WordPress + PHP-FPM

Responsible for:

* WordPress application
* Executing PHP through PHP-FPM
* Website files

It should **not** contain NGINX.

---

### MariaDB

Responsible for:

* WordPress database
* Database users
* Database persistence

It should **not** contain NGINX.

---

# 28. Why Separate Containers?

Not simply because of networking.

The main reason is **separation of responsibilities**:

```text
NGINX
→ web server / HTTPS

WordPress
→ application / PHP

MariaDB
→ database
```

Each service has its own dedicated container.

The Docker network allows those separate containers to communicate.

---

# 29. Important Inception Rules

The project requires:

* Docker Compose
* One dedicated container per service
* One Dockerfile per service
* Dockerfiles based on Alpine or Debian
* No ready-made WordPress/MariaDB/NGINX DockerHub images
* NGINX with TLS 1.2 or TLS 1.3
* WordPress with PHP-FPM
* MariaDB
* Two named volumes
* Docker network
* Containers restart on crashes
* No `network: host`
* No `--link`
* No fake infinite loops such as `tail -f` or `sleep infinity`
* NGINX is the only public entry point
* Port `443`
* Environment variables
* `.env`
* Secrets for sensitive credentials
* No passwords hardcoded in Dockerfiles
* No `latest` tag
* WordPress must have an administrator and another user
* Administrator username must not contain `admin` or `administrator`
* Domain must point to the local machine's IP

---

# 30. The Most Important Mental Models

### Build vs Run

```text
docker build
    ↓
creates image

docker run
    ↓
creates container from image
```

---

### RUN vs CMD

```text
RUN → build time

CMD → container startup
```

---

### Image vs Container

```text
Image     = blueprint
Container = instance
```

---

### `EXPOSE` vs `-p`

```text
EXPOSE
→ documents the container port

-p
→ actually maps host port → container port
```

---

### `localhost`

```text
localhost
127.0.0.1
    ↓
this container
```

To reach another Compose service:

```text
service-name:port
```

Example:

```text
mariadb:3306
```

---

### Volume

```text
Container
    ↓
Volume
    ↓
persistent data
```

Container can disappear while the data remains.

---

### Network

```text
Container ↔ Container
```

Allows services to communicate privately.

---

### ENTRYPOINT vs CMD

```text
ENTRYPOINT → main program
CMD        → default arguments
```

---

# 31. Final Inception Mental Model

Think of the entire project like this:

```text
                    BROWSER
                       │
                       │ HTTPS :443
                       ▼
                  ┌──────────┐
                  │  NGINX   │
                  └────┬─────┘
                       │
                  Docker network
                       │
                       ▼
                ┌─────────────┐
                │  WordPress  │
                │  PHP-FPM    │
                └──────┬──────┘
                       │
                  Docker network
                       │
                       ▼
                ┌─────────────┐
                │   MariaDB   │
                └──────┬──────┘
                       │
                       ▼
                Database volume


          WordPress
              │
              ▼
       Website volume
```

The core idea:

> **Images contain the environment. Containers run the services. Networks connect the containers. Volumes preserve important data. Compose describes and manages the whole system.**
>
