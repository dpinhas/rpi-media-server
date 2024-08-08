# Makefile for Docker Compose

# Variables
DOCKER_COMPOSE_DIR=docker
HOSTNAME=$(shell hostname)
DOCKER_COMPOSE_FILE=docker-compose.yaml
ENV_FILE=.env

# Conditional for hostname
ifeq ($(HOSTNAME), pi1)
	DOCKER_COMPOSE_FILE=docker-compose.monitoring.yaml
endif

# Define functions
define run_docker_compose
	@cd $(DOCKER_COMPOSE_DIR) && \
	docker compose -f $(DOCKER_COMPOSE_FILE) --env-file $(ENV_FILE) $(1)
endef

define check_service_cmd
	@if [ -z "$(service)" ] || [ -z "$(cmd)" ]; then \
		echo "Usage: make docker_exec service=<service_name> cmd=<command>"; \
		exit 1; \
	fi
endef

# Targets
.PHONY: docker_start docker_stop docker_restart build logs help docker_pull docker_ps docker_exec docker_cleanup docker_status

docker_start: ## Start the Docker Compose services
	@echo "Starting Docker Compose services with $(DOCKER_COMPOSE_FILE)..."
	$(call run_docker_compose, up -d)

docker_stop: ## Stop the Docker Compose services
	@echo "Stopping Docker Compose services with $(DOCKER_COMPOSE_FILE)..."
	$(call run_docker_compose, down)

docker_restart: ## Restart the Docker Compose services or a specific service
	@echo "Restarting Docker Compose services with $(DOCKER_COMPOSE_FILE)..."
	@if [ -z "$(service)" ]; then \
		echo "No specific service provided, restarting all services..."; \
		$(call run_docker_compose, down); \
		$(call run_docker_compose, up -d); \
	else \
		echo "Restarting service: $(service)"; \
		$(call run_docker_compose, stop $(service)); \
		$(call run_docker_compose, rm -f $(service)); \
		$(call run_docker_compose, up -d $(service)); \
	fi

docker_pull: ## Pull the latest images
	@echo "Pulling the latest images..."
	$(call run_docker_compose, pull)

docker_cleanup: ## Remove stopped containers and unused images
	@echo "Cleaning up stopped containers and unused images..."
	@docker system prune -af && \
	docker volume prune -af

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

