#!/usr/bin/env bash

set -e  

terraform apply "$@"

echo ""
echo "Environment variables for cloudflared:"
terraform output -json | \
jq -r '.tunnels.value | to_entries[] | "# \(.key)\nTUNNEL_ID=\(.value.tunnel_id)\nTUNNEL_SECRET=\(.value.tunnel_secret)"'
