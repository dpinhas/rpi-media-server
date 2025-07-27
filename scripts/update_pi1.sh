#!/bin/bash

# Script to update pi1 node after git commit to branch
# This script pulls the latest changes and restarts Docker services

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PI1_HOST="pi1"
PI1_USER="pi"
REPO_PATH="/home/pi/rpi-media-server"
BRANCH="${1:-main}"  # Default to main branch if no argument provided

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if we can connect to pi1
check_connection() {
    print_status "Checking connection to $PI1_HOST..."
    if ! ssh -o ConnectTimeout=10 -o BatchMode=yes "$PI1_USER@$PI1_HOST" "echo 'Connection successful'" >/dev/null 2>&1; then
        print_error "Cannot connect to $PI1_HOST. Please check:"
        print_error "1. SSH key is set up for passwordless access"
        print_error "2. $PI1_HOST is reachable on the network"
        print_error "3. SSH service is running on $PI1_HOST"
        exit 1
    fi
    print_success "Connection to $PI1_HOST established"
}

# Function to update pi1
update_pi1() {
    print_status "Starting update process for $PI1_HOST..."
    
    # SSH into pi1 and perform the update
    ssh "$PI1_USER@$PI1_HOST" << EOF
        set -e
        
        echo "=== Updating pi1 node ==="
        
        # Navigate to the repository
        cd $REPO_PATH
        
        # Check if we're on the correct branch
        current_branch=\$(git branch --show-current)
        echo "Current branch: \$current_branch"
        echo "Target branch: $BRANCH"
        
        # Fetch latest changes
        echo "Fetching latest changes..."
        git fetch origin
        
        # Check if we need to switch branches
        if [ "\$current_branch" != "$BRANCH" ]; then
            echo "Switching from \$current_branch to $BRANCH..."
            git checkout $BRANCH
        fi
        
        # Pull latest changes
        echo "Pulling latest changes from $BRANCH..."
        git pull origin $BRANCH
        
        # Show the latest commit
        echo "Latest commit:"
        git log --oneline -1
        
        # Check if Docker is running
        if ! docker info >/dev/null 2>&1; then
            echo "Docker is not running. Starting Docker..."
            sudo systemctl start docker
            sleep 5
        fi
        
        # Navigate to docker directory and restart services
        cd docker
        
        # Pull latest images
        echo "Pulling latest Docker images..."
        docker compose -f docker-compose.pi1.yaml pull
        
        # Restart services
        echo "Restarting Docker services..."
        docker compose -f docker-compose.pi1.yaml down
        docker compose -f docker-compose.pi1.yaml up -d
        
        # Check service status
        echo "Checking service status..."
        docker compose -f docker-compose.pi1.yaml ps
        
        echo "=== Update completed successfully ==="
EOF
}

# Function to verify update
verify_update() {
    print_status "Verifying update on $PI1_HOST..."
    
    ssh "$PI1_USER@$PI1_HOST" << EOF
        cd $REPO_PATH
        
        # Check git status
        echo "=== Git Status ==="
        git status --porcelain
        
        # Check Docker services
        echo "=== Docker Services Status ==="
        cd docker
        docker compose -f docker-compose.pi1.yaml ps
        
        # Check if services are healthy
        echo "=== Service Health Check ==="
        for service in prometheus grafana alertmanager blackbox homebridge node-exporter cadvisor; do
            if docker compose -f docker-compose.pi1.yaml ps \$service | grep -q "Up"; then
                echo "✓ \$service is running"
            else
                echo "✗ \$service is not running"
            fi
        done
EOF
}

# Main execution
main() {
    echo "=========================================="
    echo "    Pi1 Node Update Script"
    echo "=========================================="
    echo "Target Host: $PI1_HOST"
    echo "Target Branch: $BRANCH"
    echo "Repository Path: $REPO_PATH"
    echo "=========================================="
    echo
    
    # Check if branch argument is provided
    if [ -z "$1" ]; then
        print_warning "No branch specified, using 'main' as default"
        print_warning "Usage: $0 <branch_name>"
        echo
    fi
    
    # Perform the update
    check_connection
    update_pi1
    verify_update
    
    print_success "Pi1 node update completed successfully!"
    echo
    print_status "You can monitor the services at:"
    print_status "- Prometheus: http://$PI1_HOST:9090"
    print_status "- Grafana: http://$PI1_HOST:3000"
    print_status "- Alertmanager: http://$PI1_HOST:9093"
}

# Run main function
main "$@" 