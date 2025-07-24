#!/bin/bash

HOST=$(hostname)

case "$HOST" in
  pi0)
    COMPOSE_FILE="docker-compose.pi0.yaml"
    ;;
  pi1)
    COMPOSE_FILE="docker-compose.pi1.yaml"
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

if [ -f docker/.env ] && [ -f docker/.env.private ]; then
  cat docker/.env docker/.env.private > docker/.env.combined
  ENV_FILE=".env.combined"
elif [ -f docker/.env ]; then
  ENV_FILE=".env"
else
  echo "❌ No .env file found in docker/."
  exit 1
fi
printf "${GREEN}%-15s${CYAN}%-30s${RESET}\n" "Env File:" "${ENV_FILE}"
pushd docker
docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" "$@"
popd
