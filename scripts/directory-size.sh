#!/usr/bin/env bash

# Directory paths to check
DIRECTORIES=(
    "/mnt/data/library/tv"
    "/mnt/data/library/movies"
)

# Output files for metrics
OUTPUT_FILES=(
    "/home/pi/rpi-media-server/monitoring/config/custom_metrics/directory_size_tv.prom"
    "/home/pi/rpi-media-server/monitoring/config/custom_metrics/directory_size_movies.prom"
)

# Loop through the directories and their corresponding output files
for i in "${!DIRECTORIES[@]}"; do
    DIRECTORY="${DIRECTORIES[$i]}"
    OUTPUT_FILE="${OUTPUT_FILES[$i]}"
    
    echo "# HELP node_directory_size_bytes Disk space used by some directories" > "$OUTPUT_FILE"
    echo "# TYPE node_directory_size_bytes gauge" >> "$OUTPUT_FILE"
    
    while IFS= read -r line; do
        DIR_NAME=$(echo "$line" | awk -F'/' '{ if ($NF != "" && $NF ~ / /) print $NF }')
        DIR_SIZE=$(echo "$line" | awk '{ print $1 }')
        if [ -n "$DIR_NAME" ]; then
            METRIC_NAME="node_directory_size_bytes"
            METRIC_VALUE="${DIR_SIZE}"
            echo "${METRIC_NAME}{directory=\"$DIR_NAME\"} $METRIC_VALUE" >> "$OUTPUT_FILE"
        fi
    done <<< "$(du --block-size=1 --max-depth=1 "$DIRECTORY")"
done

