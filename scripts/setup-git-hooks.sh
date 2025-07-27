#!/bin/bash

# Setup script to configure git hooks for automatic pi1 updates

set -e

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

# Function to check if we're in a git repository
check_git_repo() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        print_error "Not in a git repository"
        exit 1
    fi
}

# Function to setup post-push hook
setup_post_push_hook() {
    local hook_dir=".git/hooks"
    local hook_file="$hook_dir/post-push"
    local script_path="$(pwd)/scripts/git-hook-update-pi1.sh"
    
    print_status "Setting up post-push hook..."
    
    # Create hook file
    cat > "$hook_file" << EOF
#!/bin/bash
# Post-push hook to automatically update pi1 node
# This hook is triggered after git push

# Execute the git hook update script
"$script_path" "\$1"
EOF
    
    # Make hook executable
    chmod +x "$hook_file"
    
    print_success "Post-push hook created at $hook_file"
}

# Function to setup post-commit hook (alternative)
setup_post_commit_hook() {
    local hook_dir=".git/hooks"
    local hook_file="$hook_dir/post-commit"
    local script_path="$(pwd)/scripts/git-hook-update-pi1.sh"
    
    print_status "Setting up post-commit hook..."
    
    # Create hook file
    cat > "$hook_file" << EOF
#!/bin/bash
# Post-commit hook to automatically update pi1 node
# This hook is triggered after git commit

# Get current branch
BRANCH=\$(git branch --show-current)

# Execute the git hook update script
"$script_path" "\$BRANCH"
EOF
    
    # Make hook executable
    chmod +x "$hook_file"
    
    print_success "Post-commit hook created at $hook_file"
}

# Function to setup pre-push hook (recommended)
setup_pre_push_hook() {
    local hook_dir=".git/hooks"
    local hook_file="$hook_dir/pre-push"
    local script_path="$(pwd)/scripts/git-hook-update-pi1.sh"
    
    print_status "Setting up pre-push hook..."
    
    # Create hook file
    cat > "$hook_file" << EOF
#!/bin/bash
# Pre-push hook to automatically update pi1 node
# This hook is triggered before git push

# Get the branch being pushed
while read local_ref local_sha remote_ref remote_sha
do
    if [ "\$remote_ref" = "refs/heads/main" ] || [ "\$remote_ref" = "refs/heads/master" ] || [ "\$remote_ref" = "refs/heads/develop" ]; then
        BRANCH=\$(echo "\$remote_ref" | sed 's|refs/heads/||')
        echo "Pre-push hook: Will update pi1 after push to \$BRANCH"
        # Note: We can't execute the update script here as the push hasn't happened yet
        # This is just for notification
    fi
done
EOF
    
    # Make hook executable
    chmod +x "$hook_file"
    
    print_success "Pre-push hook created at $hook_file"
}

# Function to setup post-receive hook (for bare repositories)
setup_post_receive_hook() {
    local hook_dir=".git/hooks"
    local hook_file="$hook_dir/post-receive"
    local script_path="$(pwd)/scripts/git-hook-update-pi1.sh"
    
    print_status "Setting up post-receive hook..."
    
    # Create hook file
    cat > "$hook_file" << EOF
#!/bin/bash
# Post-receive hook to automatically update pi1 node
# This hook is triggered after receiving a push

while read oldrev newrev refname
do
    BRANCH=\$(echo "\$refname" | sed 's|refs/heads/||')
    echo "Post-receive hook: Updating pi1 for branch \$BRANCH"
    
    # Execute the git hook update script
    "$script_path" "\$BRANCH"
done
EOF
    
    # Make hook executable
    chmod +x "$hook_file"
    
    print_success "Post-receive hook created at $hook_file"
}

# Function to show current hook status
show_hook_status() {
    local hook_dir=".git/hooks"
    
    print_status "Current git hooks status:"
    echo
    
    for hook in post-push post-commit pre-push post-receive; do
        if [[ -f "$hook_dir/$hook" ]]; then
            print_success "✓ $hook hook is installed"
        else
            print_warning "✗ $hook hook is not installed"
        fi
    done
    echo
}

# Function to show help
show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Options:"
    echo "  -h, --help           Show this help message"
    echo "  -s, --status         Show current hook status"
    echo "  -a, --all            Setup all recommended hooks"
    echo "  --post-push          Setup post-push hook"
    echo "  --post-commit        Setup post-commit hook"
    echo "  --pre-push           Setup pre-push hook"
    echo "  --post-receive       Setup post-receive hook (for bare repos)"
    echo
    echo "This script helps configure git hooks for automatic pi1 node updates."
    echo "Recommended: Use --all to setup the most useful hooks."
}

# Main execution
main() {
    echo "=========================================="
    echo "    Git Hooks Setup for Pi1 Updates"
    echo "=========================================="
    echo
    
    # Check if we're in a git repository
    check_git_repo
    
    # Parse command line arguments
    if [[ $# -eq 0 ]]; then
        show_help
        exit 0
    fi
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -s|--status)
                show_hook_status
                exit 0
                ;;
            -a|--all)
                setup_pre_push_hook
                setup_post_commit_hook
                print_success "All recommended hooks have been set up!"
                echo
                print_status "Note: Post-commit hook will trigger on every commit."
                print_status "      Pre-push hook will notify before push."
                print_status "      Consider using only one based on your workflow."
                ;;
            --post-push)
                setup_post_push_hook
                ;;
            --post-commit)
                setup_post_commit_hook
                ;;
            --pre-push)
                setup_pre_push_hook
                ;;
            --post-receive)
                setup_post_receive_hook
                ;;
            *)
                print_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
        shift
    done
    
    echo
    print_success "Git hooks setup completed!"
    echo
    print_status "Next steps:"
    print_status "1. Test the hooks by making a commit and pushing"
    print_status "2. Check that pi1 is reachable from this machine"
    print_status "3. Ensure SSH keys are set up for passwordless access to pi1"
}

# Run main function
main "$@" 