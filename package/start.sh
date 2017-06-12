#!/bin/bash

if [ "${RANCHER_DEBUG}" == "true" ]; then
    set -x
fi

SLEEP_INTERVAL=600

if [ "${PING_INTERVAL}" != "" ]; then
    SLEEP_INTERVAL=${PING_INTERVAL}
fi

echo "PING_INTERVAL=${SLEEP_INTERVAL}"

while true
do
    echo "Starting Pinger"
    pinger.sh
    echo "Sleeping for ${SLEEP_INTERVAL} seconds"
    sleep ${SLEEP_INTERVAL}
done
