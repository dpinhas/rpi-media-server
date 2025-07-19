#!/bin/bash

logit() { while read ; do echo "$(date) $REPLY" >> ${LOG_FILE} ; done }
LOG_FILE="$(dirname $(readlink -f $0))/ddns.log"
exec 3>&1 1>> >(logit) 2>&1

set -x 
internal_ip=192.168.68.10
external_ip=$(curl -s  ifconfig.me)
DUCKDNS_TOKEN="54646b5f-f855-419f-87c2-ee6326a39183"
curl -s "http://nouser:${DUCKDNS_TOKEN}@www.duckdns.org/v3/update?hostname=dpinhas-public&myip=${external_ip}"
curl -s "http://nouser:${DUCKDNS_TOKEN}@www.duckdns.org/v3/update?hostname=dpinhas&myip=${internal_ip}"
echo
