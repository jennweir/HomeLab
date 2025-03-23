#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail
shopt -s failglob

# This script automates the deployment of an OKD cluster with a bootstrap node and user provisioned infrastructure (UPI) with platform: none

# Prerequisites
# 1. Check the required DNS entries resolve with forward and reverse DNS
okd_required_dns_entries=(
    "api.okd.jenniferpweir.com"
    "api-int.okd.jenniferpweir.com"
    "test.apps.okd.jenniferpweir.com" # to check *.apps.okd.jenniferpweir.com
    "bootstrap.okd.jenniferpweir.com"
    "cp-1.okd.jenniferpweir.com"
    "cp-2.okd.jenniferpweir.com"
    "cp-3.okd.jenniferpweir.com"
    "worker-1.okd.jenniferpweir.com"
    "worker-2.okd.jenniferpweir.com"
    "worker-3.okd.jenniferpweir.com"
)

for dns_entry in "${okd_required_dns_entries[@]}"; do
    # Perform forward DNS lookup
    ip_address=$(nslookup "$dns_entry" | awk '/^Address: / { print $2 }')
    if [[ -z "$ip_address" ]]; then
        echo "Error: Forward DNS lookup failed for $dns_entry. Check DNS configs."
        exit 1
    else
        echo "Forward DNS lookup for $dns_entry resolved to $ip_address"
    fi

    # Perform reverse DNS lookup
    reverse_dns=$(nslookup "$ip_address")
    echo "Reverse DNS lookup for $ip_address resolved to $reverse_dns"
done

# 2. Check load balancing for the api server, machine config server, and ingress
ports=(22623 6443 80 443)
for port in "${ports[@]}"; do
    echo "Checking load balancer on port $port..."
    if ! nc -zv keepalived.okd.jenniferpweir.com "$port"; then
        echo "Error: Load balancer check failed on port $port. Exiting."
        exit 1
    else
        echo "Load balancer check succeeded on port $port."
    fi
done

# Prepare the environment
# Create directory for okd install
mkdir -p ~/Projects/HomeLab/okd/install
cd ~/Projects/HomeLab/okd/install
# Download the OKD installer and client

