#!/bin/bash
set -eu

echo "Fetching participants"
participants=$(curl -X GET --location "$CENTOPS_HOST/participants")

file="/etc/nginx/conf.d/upstream.conf"
if [ -f "$file" ]; then
  rm "$file"
fi

echo "Updating participants configuration"
echo "$participants" | jq -c '.[]' |
  while read -r participant; do
    participant_name=$(echo "$participant" | jq -r '.name')
    participant_host=$(echo "$participant" | jq -r '.host')
    printf 'upstream %s {\n  server %s;\n}\n' "$participant_name" "$participant_host" | cat >>"$file"
    echo "Added participant '$participant_name' with host '$participant_host'"
  done

# Do not reload nginx when it's not running (participant sync on startup)
if [ -e /var/run/nginx.pid ]; then
  echo "Reloading nginx configuration"
  /usr/sbin/nginx -s reload
else
  echo "Nginx is not running, no need to reload configuration"
fi
