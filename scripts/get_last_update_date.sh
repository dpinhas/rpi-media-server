#!/bin/bash

# Find the last upgrade entry in /var/log/dpkg.log
last_upgrade=$(grep "upgrade " /var/log/dpkg.log | tail -n 1)

if [ -n "$last_upgrade" ]; then
    # Extract the timestamp
    last_upgrade_timestamp=$(echo "$last_upgrade" | awk '{print $1, $2}')

    # Convert the timestamp into seconds since the Unix epoch
    last_upgrade_seconds=$(date -d "$last_upgrade_timestamp" +%s)

    # Get the current time in seconds since the Unix epoch
    current_time=$(date +%s)

    # Calculate the number of days since the last upgrade
    days_ago=$(( (current_time - last_upgrade_seconds) / 86400 ))

    echo "node_apt_last_upgrade $days_ago" > /home/pi/rpi-media-server/monitoring/config/custom_metrics/last_update_$(hostname).prom
    chown pi:pi /home/pi/rpi-media-server/monitoring/config/custom_metrics/last_update_$(hostname).prom
else
    echo "No upgrade history found."
fi

