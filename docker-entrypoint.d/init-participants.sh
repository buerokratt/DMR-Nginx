#!/bin/sh
set -e

echo "Initializing participants before nginx starts"
sh ./sh/reload-participants.sh

echo "Starting cron to periodically fetch and reload participants"
# set global env variables for cron
echo "CENTOPS_HOST=$CENTOPS_HOST" >/etc/environment
/etc/init.d/cron start
