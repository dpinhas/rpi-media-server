#!/bin/bash

HOST=$(hostname)

case "$HOST" in
  pi0)
    COMPOSE_FILE="docker/docker-compose.pi0.yaml"
    ENV_FILE="docker/.env.pi0"
    ;;
  pi1)
    COMPOSE_FILE="docker/docker-compose.pi1.yaml"
    ENV_FILE="docker/.env.pi1"
    ;;
  *)
    echo "❌ Unknown host: $HOST"
    exit 1
    ;;
esac

GREEN='\033[1;32m'
CYAN='\033[1;36m'
RESET='\033[0m'

printf "${GREEN}%-15s${CYAN}%-30s${RESET}\n" "Hostname:" "$(hostname)"
printf "${GREEN}%-15s${CYAN}%-30s${RESET}\n" "Compose File:" "${COMPOSE_FILE}"
printf "${GREEN}%-15s${CYAN}%-30s${RESET}\n" "Env File:" "${ENV_FILE}"

docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" "$@"
