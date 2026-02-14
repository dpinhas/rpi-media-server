#!/usr/bin/env bash

set -e

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
REPO_DIR="$(realpath "$SCRIPT_DIR/..")"

# Use the same logic as run_docker.sh
HOST=$(hostname)
case "$HOST" in
  pi0) COMPOSE_FILE="docker-compose.pi0.yaml" ;;
  pi1) COMPOSE_FILE="docker-compose.pi1.yaml" ;;
  *)   echo "❌ Unknown host: $HOST"; exit 1 ;;
esac

cd "$REPO_DIR/docker"

# Build combined env file
if [ -f .env ] && [ -f .env.private ]; then
  cat .env .env.private > .env.combined
  ENV_FILE=".env.combined"
elif [ -f .env ]; then
  ENV_FILE=".env"
else
  echo "❌ No .env file found"; exit 1
fi

echo "Pulling the latest Docker Compose images..."
docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" pull

echo "Starting updated containers..."
docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" up -d

echo "Docker stack updated successfully."
