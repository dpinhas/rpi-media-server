#!/bin/bash


for i in $(ls /var/log/apt/history*) ; do
    if [[ $i == *.log ]] ; then
        if grep -q upgrade /var/log/apt/history.log ; then
            echo yes
            continue
        fi
    else
        last_upgrade=$(zcat $i  | grep upgrade -B1 | tail -2 |grep Start-Date | awk -F ' ' '{print $2}' | sed 's/-//g')
        break
    fi
done
now=$(date '+%Y%m%d')
result=$(( ($(date --date="$now" +%s) - $(date --date="$last_upgrade" +%s) )/(60*60*24) ))

echo node_apt_last_upgrade  $result > /home/pi/rpi-media-server/monitoring/config/custom_metrics/last_update_$(hostname).prom
chown pi:pi /home/pi/rpi-media-server/monitoring/config/custom_metrics/last_update_$(hostname).prom
