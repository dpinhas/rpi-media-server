# Makefile for Docker Compose

# Variables
DOCKER_COMPOSE_DIR=docker
HOSTNAME=$(shell hostname)
DOCKER_COMPOSE_FILE=$(DOCKER_COMPOSE_DIR)/docker-compose.yaml
ENV_FILE=$(DOCKER_COMPOSE_DIR)/.env

# Conditional for hostname
ifeq ($(HOSTNAME), pi1)
	DOCKER_COMPOSE_FILE=$(DOCKER_COMPOSE_DIR)/docker-compose.monitoring.yaml
endif

# Targets
.PHONY: docker_start docker_stop docker_restart build logs help docker_pull docker_ps docker_exec docker_cleanup docker_status

docker_start: ## Start the Docker Compose services
	@echo "Starting Docker Compose services with $(DOCKER_COMPOSE_FILE)..."
	@docker compose -f $(DOCKER_COMPOSE_FILE) --env-file $(ENV_FILE) up -d

docker_stop: ## Stop the Docker Compose services
	@echo "Stopping Docker Compose services with $(DOCKER_COMPOSE_FILE)..."
	@docker compose -f $(DOCKER_COMPOSE_FILE) --env-file $(ENV_FILE) down

docker_restart: ## Restart the Docker Compose services or a specific service
	@echo "Restarting Docker Compose services with $(DOCKER_COMPOSE_FILE)..."
	@if [ -z "$(service)" ]; then \
		echo "No specific service provided, restarting all services..."; \
		docker compose -f $(DOCKER_COMPOSE_FILE) --env-file $(ENV_FILE) down; \
		docker compose -f $(DOCKER_COMPOSE_FILE) --env-file $(ENV_FILE) up -d; \
	else \
		echo "Restarting service: $(service)"; \
		docker compose -f $(DOCKER_COMPOSE_FILE) --env-file $(ENV_FILE) stop $(service); \
		docker compose -f $(DOCKER_COMPOSE_FILE) --env-file $(ENV_FILE) rm -f $(service); \
		docker compose -f $(DOCKER_COMPOSE_FILE) --env-file $(ENV_FILE) up -d $(service); \
	fi

docker_pull: ## Pull the latest images
	@echo "Pulling the latest images..."
	@docker compose -f $(DOCKER_COMPOSE_FILE) --env-file $(ENV_FILE) pull

docker_cleanup: ## Remove stopped containers and unused images
	@echo "Cleaning up stopped containers and unused images..."
	@docker system prune -f
	@docker volume prune -f

help: ## Display this help message
	@echo "Available targets:"
	@awk \
		'BEGIN { \
			FS = ":.*##"; \
			printf "\nUsage: make \033[36m<target>\033[0m\n"; \
		} \
		/^[a-zA-Z_-]+:.*##/ { \
			printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2; \
		}' \
		$(MAKEFILE_LIST)

