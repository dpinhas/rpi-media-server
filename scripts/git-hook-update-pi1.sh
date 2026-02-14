#!/bin/bash

# Git hook script to automatically update pi1 node after push to specific branches
# This script can be used as a post-receive hook or post-push hook

set -e

# Configuration
PI1_HOST="pi1"
PI1_USER="pi"
REPO_PATH="/home/pi/rpi-media-server"
AUTO_UPDATE_BRANCHES=("main" "master" "develop")  # Branches that trigger auto-update
UPDATE_SCRIPT_PATH="$(dirname "$0")/update_pi1.sh"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# Function to check if branch should trigger auto-update
should_update_branch() {
    local branch="$1"
    for auto_branch in "${AUTO_UPDATE_BRANCHES[@]}"; do
        if [[ "$branch" == "$auto_branch" ]]; then
            return 0  # Should update
        fi
    done
    return 1  # Should not update
}

# Function to get the current branch name
get_current_branch() {
    git branch --show-current 2>/dev/null || git rev-parse --abbrev-ref HEAD
}

# Function to check if we're in a git repository
check_git_repo() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        print_error "Not in a git repository"
        exit 1
    fi
}

# Function to check if update script exists
check_update_script() {
    if [[ ! -f "$UPDATE_SCRIPT_PATH" ]]; then
        print_error "Update script not found at: $UPDATE_SCRIPT_PATH"
        exit 1
    fi
}

# Function to trigger update
trigger_update() {
    local branch="$1"
    print_status "Auto-update triggered for branch: $branch"
    
    if [[ -f "$UPDATE_SCRIPT_PATH" ]]; then
        print_status "Executing update script..."
        "$UPDATE_SCRIPT_PATH" "$branch"
    else
        print_error "Update script not found. Please run manually:"
        print_error "  $UPDATE_SCRIPT_PATH $branch"
    fi
}

# Function to check if pi1 is reachable
check_pi1_availability() {
    print_status "Checking if $PI1_HOST is reachable..."
    if ping -c 1 -W 5 "$PI1_HOST" >/dev/null 2>&1; then
        print_success "$PI1_HOST is reachable"
        return 0
    else
        print_warning "$PI1_HOST is not reachable"
        return 1
    fi
}

# Main execution
main() {
    echo "=========================================="
    echo "    Git Hook - Pi1 Auto-Update"
    echo "=========================================="
    
    # Check if we're in a git repository
    check_git_repo
    
    # Get current branch
    local current_branch=$(get_current_branch)
    print_status "Current branch: $current_branch"
    
    # Check if this branch should trigger auto-update
    if should_update_branch "$current_branch"; then
        print_status "Branch '$current_branch' is configured for auto-update"
        
        # Check if pi1 is available
        if check_pi1_availability; then
            # Check if update script exists
            check_update_script
            
            # Trigger the update
            trigger_update "$current_branch"
        else
            print_warning "Skipping auto-update - $PI1_HOST is not reachable"
            print_warning "You can manually update later with: $UPDATE_SCRIPT_PATH $current_branch"
        fi
    else
        print_status "Branch '$current_branch' is not configured for auto-update"
        print_status "Auto-update branches: ${AUTO_UPDATE_BRANCHES[*]}"
        print_status "To update manually, run: $UPDATE_SCRIPT_PATH $current_branch"
    fi
}

# Function to show help
show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  -b, --branch   Specify branch to check (default: current branch)"
    echo "  -f, --force    Force update even if branch is not in auto-update list"
    echo
    echo "This script checks if the current (or specified) branch should trigger"
    echo "an automatic update of the pi1 node and executes the update if needed."
    echo
    echo "Auto-update branches: ${AUTO_UPDATE_BRANCHES[*]}"
}

# Parse command line arguments
FORCE_UPDATE=false
SPECIFIED_BRANCH=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -b|--branch)
            SPECIFIED_BRANCH="$2"
            shift 2
            ;;
        -f|--force)
            FORCE_UPDATE=true
            shift
            ;;
        *)
            # Ignore unrecognized arguments (e.g. when called as a git hook)
            shift
            ;;
    esac
done

# Override branch check if force update is requested
if [[ "$FORCE_UPDATE" == "true" ]]; then
    AUTO_UPDATE_BRANCHES=("all")
fi

# Use specified branch if provided
if [[ -n "$SPECIFIED_BRANCH" ]]; then
    # Temporarily override the branch check
    should_update_branch() {
        return 0  # Always return true when branch is specified
    }
    get_current_branch() {
        echo "$SPECIFIED_BRANCH"
    }
fi

# Run main function
main "$@" 