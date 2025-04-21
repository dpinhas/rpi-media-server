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

echo "✅ Running on $HOST"
echo "📦 Using $COMPOSE_FILE"
echo "🧪 Using $ENV_FILE"

docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" "$@"
