#!/usr/bin/env bash

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"

cd "$SCRIPT_DIR/../docker"
echo "Current working directory: $(pwd)"

echo "Pulling the latest Docker Compose images..."
docker-compose pull

echo "Starting updated containers..."
docker-compose up -d

echo "Docker Compose images updated and cache cleared successfully!"

