#!/usr/bin/env bash
version=$(curl -u $username:$token -X GET "https://api.github.com/repos/cloudflare/cloudflared/tags" | jq -r ".[0] .name")
printf "%s" "${version}"
