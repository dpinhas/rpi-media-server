#!/bin/bash
# Auto-update script for rpi-media-server on pi0 and pi1 nodes.
# This script is run via cron to pull the latest changes from GitHub and update Docker services.

set -e

# Automatically resolve the repository root directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
LOG_FILE="/var/log/rpi-media-server-updater.log"

# Ensure log file exists and is writable
touch "$LOG_FILE" 2>/dev/null || true

# Redirect all output to log file
exec >> "$LOG_FILE" 2>&1

echo "[$(date '+%Y-%m-%d %H:%M:%S')] --- Checking for updates ---"

cd "$REPO_DIR"

# Ensure we are on the main branch
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "main" ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Current branch is '$CURRENT_BRANCH', not 'main'. Skipping auto-update."
    exit 0
fi

# Fetch the latest changes from origin
git fetch origin main

LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse origin/main)

if [ "$LOCAL" != "$REMOTE" ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] New changes detected! Updating repository..."
    
    # Pull changes
    git pull origin main
    
    # Determine the Docker Compose file to use based on hostname
    HOSTNAME=$(hostname)
    if [ "$HOSTNAME" = "pi1" ]; then
        DOCKER_COMPOSE_FILE="docker-compose.pi1.yaml"
    else
        DOCKER_COMPOSE_FILE="docker-compose.pi0.yaml"
    fi
    
    cd docker
    
    # Re-build the combined environment file
    if [ -f .env.private ]; then
        cat .env .env.private > .env.combined
    else
        cp .env .env.combined
    fi
    chmod 600 .env.combined
    
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Hostname: $HOSTNAME, using $DOCKER_COMPOSE_FILE"
    
    # Pull latest Docker images
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Pulling latest Docker images..."
    docker compose -f "$DOCKER_COMPOSE_FILE" --env-file .env.combined pull
    
    # Restart services
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Restarting Docker services..."
    docker compose -f "$DOCKER_COMPOSE_FILE" --env-file .env.combined down
    docker compose -f "$DOCKER_COMPOSE_FILE" --env-file .env.combined up -d
    
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Update completed successfully!"
else
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Already up-to-date."
fi
