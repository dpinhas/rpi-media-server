# Pi1 Node Update Scripts

This directory contains scripts to automatically update the pi1 node (monitoring server) after git commits to specific branches.

## Overview

The pi1 node runs monitoring services including:
- Prometheus (metrics collection)
- Grafana (dashboards)
- Alertmanager (alerting)
- Blackbox Exporter (endpoint monitoring)
- Homebridge (HomeKit integration)
- Node Exporter (system metrics)
- cAdvisor (container metrics)

## Scripts

### 1. `update_pi1.sh` - Main Update Script

The primary script that performs the actual update of the pi1 node.

**Usage:**
```bash
# Update pi1 with the main branch
./scripts/update_pi1.sh main

# Update pi1 with a specific branch
./scripts/update_pi1.sh develop

# Update pi1 with current branch (defaults to main)
./scripts/update_pi1.sh
```

**What it does:**
1. Connects to pi1 via SSH
2. Fetches latest changes from the specified branch
3. Pulls latest Docker images
4. Restarts all Docker services
5. Verifies service health

**Prerequisites:**
- SSH key-based authentication to pi1
- pi1 must be reachable on the network
- pi1 must have the repository cloned at `/home/pi/rpi-media-server`

### 2. `git-hook-update-pi1.sh` - Git Hook Script

A script designed to be used as a git hook for automatic updates.

**Usage:**
```bash
# Check if current branch should trigger auto-update
./scripts/git-hook-update-pi1.sh

# Force update for any branch
./scripts/git-hook-update-pi1.sh --force

# Check specific branch
./scripts/git-hook-update-pi1.sh --branch develop

# Show help
./scripts/git-hook-update-pi1.sh --help
```

**Auto-update branches:** `main`, `master`, `develop`

### 3. `setup-git-hooks.sh` - Git Hooks Setup

Helper script to configure git hooks for automatic updates.

**Usage:**
```bash
# Setup all recommended hooks
./scripts/setup-git-hooks.sh --all

# Setup specific hook
./scripts/setup-git-hooks.sh --post-commit

# Check current hook status
./scripts/setup-git-hooks.sh --status

# Show help
./scripts/setup-git-hooks.sh --help
```

## Setup Instructions

### 1. Initial Setup

1. **Ensure SSH access to pi1:**
   ```bash
   # Test SSH connection
   ssh pi@pi1 "echo 'Connection successful'"
   ```

2. **Clone repository on pi1:**
   ```bash
   ssh pi@pi1
   cd /home/pi
   git clone <your-repo-url> rpi-media-server
   ```

3. **Setup git hooks (optional):**
   ```bash
   ./scripts/setup-git-hooks.sh --all
   ```

### 2. Manual Updates

For manual updates, simply run:
```bash
./scripts/update_pi1.sh <branch-name>
```

### 3. Automatic Updates

After setting up git hooks, updates will happen automatically when you:
- Commit to branches: `main`, `master`, `develop`
- Push to these branches

## Configuration

### Environment Variables

The scripts use the following configuration (can be modified in the scripts):

- `PI1_HOST`: Hostname of pi1 (default: "pi1")
- `PI1_USER`: SSH user (default: "pi")
- `REPO_PATH`: Repository path on pi1 (default: "/home/pi/rpi-media-server")
- `AUTO_UPDATE_BRANCHES`: Branches that trigger auto-update

### Customizing Auto-update Branches

Edit `git-hook-update-pi1.sh` and modify the `AUTO_UPDATE_BRANCHES` array:

```bash
AUTO_UPDATE_BRANCHES=("main" "master" "develop" "staging")
```

## Troubleshooting

### Common Issues

1. **SSH Connection Failed**
   - Ensure SSH keys are set up
   - Check if pi1 is reachable: `ping pi1`
   - Verify SSH service is running on pi1

2. **Docker Services Not Starting**
   - Check Docker is running on pi1: `docker info`
   - Verify environment variables are set
   - Check logs: `docker compose -f docker/docker-compose.pi1.yaml logs`

3. **Git Hooks Not Triggering**
   - Verify hooks are executable: `ls -la .git/hooks/`
   - Check hook content: `cat .git/hooks/post-commit`
   - Test manually: `./scripts/git-hook-update-pi1.sh`

### Debug Mode

Add `set -x` at the beginning of any script to enable debug output:

```bash
#!/bin/bash
set -x  # Enable debug mode
# ... rest of script
```

### Logs

Check the following for troubleshooting:
- Script output (colored console output)
- Docker logs: `docker compose -f docker/docker-compose.pi1.yaml logs <service>`
- System logs: `journalctl -u docker`

## Security Considerations

1. **SSH Keys**: Use SSH key-based authentication, not passwords
2. **Network Access**: Ensure pi1 is only accessible from trusted networks
3. **Repository Access**: Use private repositories or ensure sensitive data is not committed
4. **Docker Images**: Regularly update Docker images for security patches

## Monitoring

After updates, you can monitor the services at:
- **Prometheus**: http://pi1:9090
- **Grafana**: http://pi1:3000
- **Alertmanager**: http://pi1:9093

## Examples

### Example 1: Manual Update
```bash
# Update pi1 with latest changes from main branch
./scripts/update_pi1.sh main
```

### Example 2: Setup Automatic Updates
```bash
# Setup git hooks for automatic updates
./scripts/setup-git-hooks.sh --all

# Make a commit and push (will trigger auto-update)
git add .
git commit -m "Update monitoring configuration"
git push origin main
```

### Example 3: Force Update
```bash
# Force update even if branch is not in auto-update list
./scripts/git-hook-update-pi1.sh --force
```

## Contributing

When modifying these scripts:
1. Test on a non-production environment first
2. Update this documentation
3. Ensure backward compatibility
4. Add appropriate error handling 