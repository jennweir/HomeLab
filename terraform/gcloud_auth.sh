#!/usr/bin/env bash
set -e
echo "Running gcloud_auth.sh script" >&2
auth=$(gcloud auth application-default print-access-token 2>/dev/null)
if [ -z "$auth" ]; then
  echo "{\"error\":\"Authentication failed or no token available\"}"
  exit 1
fi
echo "${auth}"
