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

# 3. Prepare the environment
# Create directory for okd install
mkdir -p ~/Projects/HomeLab/okd/install
cd ~/Projects/HomeLab/okd/install
# Download the OKD installer and client (4.17.0-okd-scos.0)

curl -L -o openshift-install-linux.tar.gz "https://github.com/okd-project/okd/releases/download/4.17.0-okd-scos.0/openshift-client-mac-arm64-4.17.0-okd-scos.0.tar.gz"
tar -xvf openshift-install-linux.tar.gz

# Replace the pull secret in install-config.yaml
if [[ -f "install-config-template.yaml" && -f "pull-secret.txt" ]]; then
    echo "Creating install-config.yaml from template..."
    cp install-config-template.yaml install-config.yaml
    echo "Replacing pull secret in install-config.yaml with contents from pull-secret.txt..."
    pull_secret=$(cat pull-secret.txt | tr -d '\n' | jq -c .)
    escaped_pull_secret=$(echo "$pull_secret" | sed 's/"/\\"/g')
    yq -i ".pullSecret = \"$escaped_pull_secret\"" install-config.yaml
    echo "Pull secret replaced successfully."
else
    echo "Error: Either install-config.yaml or pull-secret.txt is missing. Exiting."
    exit 1
fi

# Generate cluster ssh key
ssh-keygen -t ecdsa -N '' -f ~/.ssh/okd-cluster-key
# Add the public key to the install-config.yaml
if [[ -f "install-config.yaml" && -f ~/.ssh/okd-cluster-key.pub ]]; then
    echo "Adding public SSH key to install-config.yaml..."
    public_key=$(cat ~/.ssh/okd-cluster-key.pub | tr -d '\n')
    escaped_public_key=$(echo "$public_key" | sed 's/"/\\"/g')
    yq -i ".sshKey = \"$escaped_public_key\"" install-config.yaml
    echo "Public SSH key added successfully."
else
    echo "Error: Either install-config.yaml or the SSH public key is missing. Exiting."
    exit 1
fi