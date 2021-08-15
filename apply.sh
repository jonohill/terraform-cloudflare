#!/usr/bin/env bash

set -e  

terraform apply "$@"
echo ""

mkdir -p out

IFS=$'\n'
for conf in $(terraform output -json | jq --compact-output '.tunnels.value[]'); do
    id="$(echo "$conf" | jq -r '.TunnelID')"
    echo "$conf" >"out/${id}.json"
done
unset IFS

echo "cloudflared configs have been written to the out/ directory"
