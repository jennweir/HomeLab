#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail
shopt -s failglob

# Follows steps outlined here: https://docs.okd.io/4.17/installing/installing_bare_metal/installing-bare-metal.html#installation-dns-user-infra_installing-bare-metal


OKD_INSTALL_DIR=~/Projects/HomeLab/okd/install # ~ does not expand when used inside quotes
OC_CLI="https://mirror.openshift.com/pub/openshift-v4/arm64/clients/ocp/4.17.0/openshift-client-mac-arm64-4.17.0.tar.gz"
OCP_INSTALLER="https://mirror.openshift.com/pub/openshift-v4/arm64/clients/ocp/4.17.0/openshift-install-mac-arm64-4.17.0.tar.gz"
WEBSERVER_K8S_KUBECONFIG=~/Projects/HomeLab/.kube/pi-kubeconfig

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
mkdir -p "${OKD_INSTALL_DIR}"
cd "${OKD_INSTALL_DIR}"
# Download the OKD installer and client (4.17.0-okd-scos.0)

curl -L -o openshift-install.tar.gz "${OCP_INSTALLER}"
# Check if the download was successful
if [[ ! -f "openshift-install.tar.gz" ]]; then
    echo "Error: Failed to download the OpenShift installer. Exiting."
    exit 1
fi
# Extract the OpenShift installer
tar -xvf openshift-install.tar.gz

curl -L -o oc.tar.gz "${OC_CLI}"
# Check if the download was successful
if [[ ! -f "oc.tar.gz" ]]; then
    echo "Error: Failed to download the OpenShift CLI (oc). Exiting."
    exit 1
fi
# Extract the OpenShift CLI (oc)
tar -xvf oc.tar.gz
sudo mv oc /usr/local/bin/

# Check if the OpenShift CLI (oc) is installed
if ! command -v oc &> /dev/null; then
    echo "Error: The OpenShift CLI (oc) is not installed or not in the PATH. Exiting."
    exit 1
else
    echo "The OpenShift CLI (oc) is installed."
    # Optionally, verify the version
    oc version --client
fi

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

# 4. Create Kubernetes manifest
mkdir -p "${OKD_INSTALL_DIR}"
./openshift-install create manifests --dir "${OKD_INSTALL_DIR}"

# Set mastersSchedulable parameter in manifests/cluster-scheduler-02-config.yml to false to prevent pods from being scheduled on the control plane machines
yq -i '.spec.mastersSchedulable = false' "${OKD_INSTALL_DIR}/manifests/cluster-scheduler-02-config.yml"

# 5. Create Ignition config files
./openshift-install create ignition-configs --dir "${OKD_INSTALL_DIR}"

# 6. Install FCOS using iso image
# save sha sum for each iso image
mkdir -p ign-sha
sha512sum bootstrap.ign > ign-sha/bootstrap-sha.txt
sha512sum master.ign > ign-sha/master-sha.txt
sha512sum worker.ign > ign-sha/worker-sha.txt

# copy ignition files to the web server running in k8s pi cluster
KUBECONFIG="${WEBSERVER_K8S_KUBECONFIG}"
export KUBECONFIG

kubectl cp bootstrap.ign $(kubectl get pod -n webserver -l app=webserver -o jsonpath="{.items[0].metadata.name}"):/usr/local/apache2/htdocs -n webserver
kubectl cp master.ign $(kubectl get pod -n webserver -l app=webserver -o jsonpath="{.items[0].metadata.name}"):/usr/local/apache2/htdocs -n webserver
kubectl cp worker.ign $(kubectl get pod -n webserver -l app=webserver -o jsonpath="{.items[0].metadata.name}"):/usr/local/apache2/htdocs -n webserver
# to retrieve files, use:
# curl webserver.homelab.jenniferpweir.com/bootstrap.ign
# curl webserver.homelab.jenniferpweir.com/master.ign
# curl webserver.homelab.jenniferpweir.com/worker.ign

./openshift-install coreos print-stream-json | grep '\.iso[^.]'
COREOS_LOCATION=$(./openshift-install coreos print-stream-json | grep '\.iso[^.]' | grep x86_64 | awk '{print $2}' | sed 's/\"//g')
COREOS_LOCATION=${COREOS_LOCATION%,} # remove trailing comma


