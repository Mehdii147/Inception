COMPOSE_FILE=srcs/docker-compose.yml
ENV_FILE=srcs/.env
COMPOSE_CMD=docker compose -f $(COMPOSE_FILE) --env-file $(ENV_FILE)

-include $(ENV_FILE)

DATA_DIRS=$(DB_VOLUME_PATH) $(WP_VOLUME_PATH)

.PHONY: all build up down stop clean fclean re logs ps status

all: up

build: $(DATA_DIRS)
	$(COMPOSE_CMD) build

up: $(DATA_DIRS)
	$(COMPOSE_CMD) up --build

$(DATA_DIRS):
	mkdir -p $@

down:
	$(COMPOSE_CMD) down

stop:
	$(COMPOSE_CMD) stop

clean:
	$(COMPOSE_CMD) down --remove-orphans

fclean:
	$(COMPOSE_CMD) down -v --remove-orphans
	rm -rf $(DATA_DIRS)

re: clean all

logs:
	$(COMPOSE_CMD) logs -f

ps status:
	$(COMPOSE_CMD) ps
