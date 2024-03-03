#!/bin/bash

# Function to check if a directory contains .mkv or .mp4 files
function contains_video_files {
    local dir="$1"
    find "$dir" -type f \( -name "*.mkv" -o -name "*.mp4" \) -print -quit | grep -q .
}

# Function to remove directories without .mkv or .mp4 files
function remove_empty_directories {
    local parent_dir="$1"
    local dry_run="$2"

    while IFS= read -r -d '' dir; do
        if ! contains_video_files "$dir"; then
            if [ "$dry_run" == "true" ]; then
                echo "Would remove directory: $dir"
            else
                echo "Removing directory: $dir"
                rm -r "$dir"
            fi
        fi
    done < <(find "$parent_dir" -type d -print0)
}

# Main script
while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run)
            dry_run="true"
            shift
            ;;
        --path)
            shift
            parent_directory="$1"
            shift
            ;;
        *)
            echo "Usage: $0 --path <parent_directory> --dry-run"
            exit 1
            ;;
    esac
done

if [ -z "$parent_directory" ]; then
    echo "Error: Please specify the parent directory using the --path option."
    exit 1
fi

if [ ! -d "$parent_directory" ]; then
    echo "Error: The specified parent directory '$parent_directory' is not a valid directory."
    exit 1
fi

remove_empty_directories "$parent_directory" "$dry_run"

if [ "$dry_run" == "true" ]; then
    echo "Dry run complete. No directories were deleted."
fi
