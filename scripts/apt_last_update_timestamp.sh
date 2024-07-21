#!/bin/bash

# Define paths to the necessary files and directories
UPDATE_SUCCESS_STAMP="/var/lib/apt/periodic/update-success-stamp"
OUTPUT_FILE="/home/pi/rpi-media-server/config/custom_metrics/update_success_timestamp_$(hostname).prom"

# Check if the update-success-stamp file exists
if [ -f "$UPDATE_SUCCESS_STAMP" ]; then
    # Get the last modification timestamp of the update-success-stamp file
    timestamp=$(stat -c %Y "$UPDATE_SUCCESS_STAMP")

    # Create or overwrite the Prometheus metric file with the timestamp
    echo "# HELP update_success_timestamp_seconds The last time apt-get update was successful, in Unix time." > "$OUTPUT_FILE"
    echo "# TYPE update_success_timestamp_seconds gauge" >> "$OUTPUT_FILE"
    echo "update_success_timestamp_seconds $timestamp" >> "$OUTPUT_FILE"
else
    # If the update-success-stamp file does not exist, output a metric indicating an error state
    echo "# HELP update_success_timestamp_seconds The last time apt-get update was successful, in Unix time." > "$OUTPUT_FILE"
    echo "# TYPE update_success_timestamp_seconds gauge" >> "$OUTPUT_FILE"
    echo "update_success_timestamp_seconds -1" >> "$OUTPUT_FILE"
    echo "The update-success-stamp file does not exist." >&2
fi

# Set correct permissions for the output file
chown pi:pi "$OUTPUT_FILE"
