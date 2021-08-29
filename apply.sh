#!/usr/bin/env bash

set -e  

terraform apply "$@"

echo ""
echo "Environment variables for jonoh/cloudflared:"
terraform output -json | \
jq -r '.tunnels.value | 
    to_entries[] | 
    "# \(.key)\nACCOUNT_ID=\(.value.account_id)\nTUNNEL_NAME=\(.value.tunnel_name)\nTUNNEL_ID=\(.value.tunnel_id)\nTUNNEL_SECRET=\(.value.tunnel_secret)"'
