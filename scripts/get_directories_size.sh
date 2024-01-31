#!/usr/bin/env bash
# Default debug mode is off
DEBUG=false

# Static array of directories to check
DIRECTORIES=(
    "/mnt/data/library/tv"
    "/mnt/data/library/movies"
)

# Function to display usage information
usage() {
  echo "Usage: $0 [--debug]"
  exit 1
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --debug)
      DEBUG=true
      shift
      ;;
    -*)
      echo "Unknown option: $1"
      usage
      ;;
    *)
      usage
      ;;
  esac
done

# Loop through the specified directories
for DIRECTORY in "${DIRECTORIES[@]}"; do
  if [ ! -d "$DIRECTORY" ]; then
    echo "Directory not found: $DIRECTORY"
    continue
  fi

  # Determine the output file based on the directory
  OUTPUT_FILE="/home/pi/rpi-media-server/monitoring/config/custom_metrics/directory_size_$(basename "$DIRECTORY").prom"

  echo "# HELP node_directory_size_bytes Disk space used by some directories" > "$OUTPUT_FILE"
  echo "# TYPE node_directory_size_bytes gauge" >> "$OUTPUT_FILE"

  # Use while read loop to handle lines from 'du'
  while IFS= read -r line; do
    if [[ $line =~ ^([0-9]+)[[:space:]]+(.*)$ ]]; then
      DIR_SIZE="${BASH_REMATCH[1]}"
      DIR_NAME="${BASH_REMATCH[2]}"
      METRIC_NAME="node_directory_size_bytes"
      METRIC_VALUE="${DIR_SIZE}"

      if [ "$DIR_NAME" != "$DIRECTORY" ]; then
        if [ "$DEBUG" = true ]; then
          echo "${METRIC_NAME}{directory=\"$DIR_NAME\"} $METRIC_VALUE"
        else
          echo "${METRIC_NAME}{directory=\"$DIR_NAME\"} $METRIC_VALUE" >> "$OUTPUT_FILE"
        fi
      fi
    fi
  done < <(du --block-size=1 --max-depth=1 "$DIRECTORY" | \
            sed -e 's/\/mnt\/data\/library\/tv\//\[T\] /' \
              -e 's/\/mnt\/data\/library\/movies\//\[M\] /' \
              -e 's/\/\//\//' | cut -c 1-40)
done

