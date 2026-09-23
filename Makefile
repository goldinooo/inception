NAME = inception

COMPOSE = docker compose -f srcs/docker-compose.yml

all:
	$(COMPOSE) up -d

build:
	$(COMPOSE) build

up:
	$(COMPOSE) up -d

down:
	$(COMPOSE) down

clean:
	$(COMPOSE) down

fclean:
	$(COMPOSE) down -v

re:
	$(COMPOSE) down
	$(COMPOSE) build
	$(COMPOSE) up -d