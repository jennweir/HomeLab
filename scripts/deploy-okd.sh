#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail
shopt -s failglob

RED="\e[31m"
GREEN="\e[32m"
RESET="\e[0m"

# https://docs.okd.io/4.17/installing/installing_bare_metal/installing-bare-metal.html#installation-dns-user-infra_installing-bare-metal
# https://github.com/okd-project/okd-scos/releases
# https://docs.okd.io/4.18/installing/overview/index.html#ocp-installation-overview

PATH_CURRENT_DIR=$(pwd)
OKD_INSTALL_DIR=~/Projects/HomeLab/okd/install
PHY_SSH_KEY=~/.ssh/id_rsa_homelab_phy_boxes # ~ does not expand when used inside quotes
CORE_SSH_KEY=~/.ssh/okd-cluster-key
WEBSERVER_K8S_KUBECONFIG=~/Projects/HomeLab/.kube/pi-kubeconfig
WEBSERVER_PATH="http://webserver.homelab.jenniferpweir.com"
OKD_DOMAIN="okd.jenniferpweir.com"
PHY_BOX_1="box-1.homelab.jenniferpweir.com"
PHY_BOX_2="box-2.homelab.jenniferpweir.com"
PHY_BOX_3="box-3.homelab.jenniferpweir.com"
OC_CLI="https://mirror.openshift.com/pub/openshift-v4/amd64/clients/ocp/4.17.0/openshift-client-mac-4.17.0.tar.gz"
OCP_INSTALLER="https://mirror.openshift.com/pub/openshift-v4/amd64/clients/ocp/4.17.0/openshift-install-mac-4.17.0.tar.gz"

# This script automates the deployment of an OKD cluster with a bootstrap node and user provisioned infrastructure (UPI) with platform: none

# Prerequisites
echo -e "${GREEN}1. Check the required DNS entries resolve with forward and reverse DNS${RESET}"
okd_required_dns_entries=(
    "api.${OKD_DOMAIN}"
    "api-int.${OKD_DOMAIN}"
    "test.apps.${OKD_DOMAIN}"
    "bootstrap.${OKD_DOMAIN}"
    "cp-1.${OKD_DOMAIN}"
    "cp-2.${OKD_DOMAIN}"
    "cp-3.${OKD_DOMAIN}"
    "worker-1.${OKD_DOMAIN}"
    "worker-2.${OKD_DOMAIN}"
    "worker-3.${OKD_DOMAIN}"
)

for dns_entry in "${okd_required_dns_entries[@]}"; do
    # Perform forward DNS lookup
    ip_address=$(nslookup "$dns_entry" | awk '/^Address: / { print $2 }')
    if [[ -z "$ip_address" ]]; then
        echo -e "${RED}Error: Forward DNS lookup failed for $dns_entry. Check DNS configs.${RESET}"
        exit 1
    else
        echo "Forward DNS lookup for $dns_entry resolved to $ip_address"
    fi

    # Perform reverse DNS lookup
    reverse_dns=$(nslookup "$ip_address")
    echo "Reverse DNS lookup for $ip_address resolved to $reverse_dns"
done

echo -e "${GREEN}2. Check load balancing for the api server, machine config server, and ingress${RESET}"
ports=(22623 6443 80 443)
for port in "${ports[@]}"; do
    echo "Checking load balancer on port $port..."
    if ! nc -zv keepalived.okd.jenniferpweir.com "$port"; then
        echo -e "${RED}Error: Load balancer check failed on port $port. Exiting.${RESET}"
        exit 1
    else
        echo "Load balancer check succeeded on port $port."
    fi
done

echo -e "${GREEN}3. Prepare the environment${RESET}"
# Create directory for okd install
mkdir -p "${OKD_INSTALL_DIR}"
cd "${OKD_INSTALL_DIR}"
# Download the OKD installer and client (4.17.0-okd-scos.0)

curl -L -o openshift-install.tar.gz "${OCP_INSTALLER}"
# Check if the download was successful
if [[ ! -f "openshift-install.tar.gz" ]]; then
    echo -e "${RED}Error: Failed to download the OpenShift installer. Exiting.${RESET}"
    exit 1
fi
# Extract the OpenShift installer
tar -xvf openshift-install.tar.gz

curl -L -o oc.tar.gz "${OC_CLI}"
# Check if the download was successful
if [[ ! -f "oc.tar.gz" ]]; then
    echo -e "${RED}Error: Failed to download the OpenShift CLI (oc). Exiting.${RESET}"
    exit 1
fi
# Extract the OpenShift CLI (oc)
tar -xvf oc.tar.gz
sudo mv oc /usr/local/bin/

# Check if the OpenShift CLI (oc) is installed
if ! command -v oc &> /dev/null; then
    echo -e "${RED}Error: The OpenShift CLI (oc) is not installed or not in the PATH. Exiting.${RESET}"
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
    echo -e "${RED}Error: Either install-config.yaml or pull-secret.txt is missing. Exiting.${RESET}"
    exit 1
fi

# Generate cluster ssh key
ssh-keygen -t ecdsa -N '' -f "${CORE_SSH_KEY}"
# Add the public key to the install-config.yaml
if [[ -f "install-config.yaml" && -f ~/.ssh/okd-cluster-key.pub ]]; then
    echo "Adding public SSH key to install-config.yaml..."
    public_key=$(cat "${CORE_SSH_KEY}.pub" | tr -d '\n')
    escaped_public_key=$(echo "$public_key" | sed 's/"/\\"/g')
    yq -i ".sshKey = \"$escaped_public_key\"" install-config.yaml
    echo "Public SSH key added successfully."
else
    echo -e "${RED}Error: Either install-config.yaml or the SSH public key is missing. Exiting.${RESET}"
    exit 1
fi

echo -e "${GREEN}4. Create Kubernetes manifests${RESET}"
mkdir -p "${OKD_INSTALL_DIR}"
./openshift-install create manifests --dir "${OKD_INSTALL_DIR}"

# Set mastersSchedulable parameter in manifests/cluster-scheduler-02-config.yml to false to prevent pods from being scheduled on the control plane machines
yq -i '.spec.mastersSchedulable = false' "${OKD_INSTALL_DIR}/manifests/cluster-scheduler-02-config.yml"

echo -e "${GREEN}5. Create Ignition config files${RESET}"
./openshift-install create ignition-configs --dir "${OKD_INSTALL_DIR}"

echo -e "${GREEN}6. Install FCOS using iso image${RESET}"

# copy ignition files to web server running in k8s cluster
KUBECONFIG="${WEBSERVER_K8S_KUBECONFIG}"
export KUBECONFIG

WEBSERVER_POD=$(kubectl get pod -n webserver -l app=webserver -o jsonpath="{.items[0].metadata.name}")
WEBSERVER_FILE_PATH="/usr/local/apache2/htdocs"

if [[ -z "${WEBSERVER_POD}" ]]; then
    echo -e "${RED}Error: Web server pod not found. Exiting.${RESET}"
    exit 1
fi

chmod 0644 bootstrap.ign
chmod 0644 master.ign
chmod 0644 worker.ign
kubectl cp bootstrap.ign ${WEBSERVER_POD}:${WEBSERVER_FILE_PATH} -n webserver --request-timeout=20s
kubectl cp master.ign ${WEBSERVER_POD}:${WEBSERVER_FILE_PATH} -n webserver --request-timeout=20s
kubectl cp worker.ign ${WEBSERVER_POD}:${WEBSERVER_FILE_PATH} -n webserver --request-timeout=20s

./openshift-install coreos print-stream-json | grep '\.iso[^.]'
COREOS_LOCATION=$(./openshift-install coreos print-stream-json | grep '\.iso[^.]' | grep x86_64 | awk '{print $2}' | sed 's/\"//g')
COREOS_LOCATION=$(echo "${COREOS_LOCATION}" | sed 's/,$//')

ssh -i "${PHY_SSH_KEY}" "root@${PHY_BOX_1}" "
    cd /var/lib/libvirt/images && \
    curl -o coreos.iso '${COREOS_LOCATION}' && \
    curl -o bootstrap.ign '${WEBSERVER_PATH}/bootstrap.ign' && \
    curl -o master.ign '${WEBSERVER_PATH}/master.ign' && \
    curl -o worker.ign '${WEBSERVER_PATH}/worker.ign'"

ssh -i "${PHY_SSH_KEY}" "root@${PHY_BOX_2}" "
    cd /var/lib/libvirt/images && \
    curl -o coreos.iso '${COREOS_LOCATION}' && \
    curl -o master.ign '${WEBSERVER_PATH}/master.ign' && \
    curl -o worker.ign '${WEBSERVER_PATH}/worker.ign'"

ssh -i "${PHY_SSH_KEY}" "root@${PHY_BOX_3}" "
    cd /var/lib/libvirt/images && \
    curl -o coreos.iso '${COREOS_LOCATION}'&& \
    curl -o master.ign '${WEBSERVER_PATH}/master.ign' && \
    curl -o worker.ign '${WEBSERVER_PATH}/worker.ign'"

cd vms

scp -i "${PHY_SSH_KEY}" create-bootstrap.sh "root@${PHY_BOX_1}":create-bootstrap.sh
scp -i "${PHY_SSH_KEY}" create-control-plane.sh "root@${PHY_BOX_1}":create-control-plane.sh
scp -i "${PHY_SSH_KEY}" create-worker.sh "root@${PHY_BOX_1}":create-worker.sh

scp -i "${PHY_SSH_KEY}" create-control-plane.sh "root@${PHY_BOX_2}":create-control-plane.sh
scp -i "${PHY_SSH_KEY}" create-worker.sh "root@${PHY_BOX_2}":create-worker.sh

scp -i "${PHY_SSH_KEY}" create-control-plane.sh "root@${PHY_BOX_3}":create-control-plane.sh
scp -i "${PHY_SSH_KEY}" create-worker.sh "root@${PHY_BOX_3}":create-worker.sh

echo -e "${GREEN}7. Create VMs${RESET}"
ssh -i "${PHY_SSH_KEY}" "root@${PHY_BOX_1}" "./create-bootstrap.sh"
ssh -i "${PHY_SSH_KEY}" "root@${PHY_BOX_1}" "./create-control-plane.sh 1"
ssh -i "${PHY_SSH_KEY}" "root@${PHY_BOX_2}" "./create-control-plane.sh 2"
ssh -i "${PHY_SSH_KEY}" "root@${PHY_BOX_3}" "./create-control-plane.sh 3"

ssh -i "${PHY_SSH_KEY}" "root@${PHY_BOX_1}" "./create-worker.sh 1"
ssh -i "${PHY_SSH_KEY}" "root@${PHY_BOX_2}" "./create-worker.sh 2"
ssh -i "${PHY_SSH_KEY}" "root@${PHY_BOX_3}" "./create-worker.sh 3"

BOOTSTRAP_MAC=$(ssh -i "${PHY_SSH_KEY}" "root@${PHY_BOX_1}" "virsh domiflist bootstrap | awk '{ print \$5 }' | tail -2 | head -1")
CP_1_MAC=$(ssh -i "${PHY_SSH_KEY}" "root@${PHY_BOX_1}" "virsh domiflist cp-1 | awk '{ print \$5 }' | tail -2 | head -1")
CP_2_MAC=$(ssh -i "${PHY_SSH_KEY}" "root@${PHY_BOX_2}" "virsh domiflist cp-2 | awk '{ print \$5 }' | tail -2 | head -1")
CP_3_MAC=$(ssh -i "${PHY_SSH_KEY}" "root@${PHY_BOX_3}" "virsh domiflist cp-3 | awk '{ print \$5 }' | tail -2 | head -1")
WORKER_1_MAC=$(ssh -i "${PHY_SSH_KEY}" "root@${PHY_BOX_1}" "virsh domiflist worker-1 | awk '{ print \$5 }' | tail -2 | head -1")
WORKER_2_MAC=$(ssh -i "${PHY_SSH_KEY}" "root@${PHY_BOX_2}" "virsh domiflist worker-2 | awk '{ print \$5 }' | tail -2 | head -1")
WORKER_3_MAC=$(ssh -i "${PHY_SSH_KEY}" "root@${PHY_BOX_3}" "virsh domiflist worker-3 | awk '{ print \$5 }' | tail -2 | head -1")

echo -e "${GREEN}8. Print node MAC addresses${RESET}"
echo -e "${GREEN}bootstrap with MAC ${BOOTSTRAP_MAC} ${RESET}"
echo -e "${GREEN}cp-1 has MAC ${CP_1_MAC} ${RESET}"
echo -e "${GREEN}cp-2 has MAC ${CP_2_MAC} ${RESET}"
echo -e "${GREEN}cp-3 has MAC ${CP_3_MAC} ${RESET}"
echo -e "${GREEN}worker-1 has MAC ${WORKER_1_MAC} ${RESET}"
echo -e "${GREEN}worker-2 has MAC ${WORKER_2_MAC} ${RESET}"
echo -e "${GREEN}worker-3 has MAC ${WORKER_3_MAC} ${RESET}"

sleep 20

echo -e "${GREEN}9. Reboot vms to apply ignition${RESET}"

ssh -i "${PHY_SSH_KEY}" "root@${PHY_BOX_1}" "virsh shutdown bootstrap; virsh shutdown cp-1; virsh shutdown worker-1; sleep 10; virsh start bootstrap; virsh start cp-1; virsh start worker-1"
ssh -i "${PHY_SSH_KEY}" "root@${PHY_BOX_2}" "virsh shutdown cp-2; virsh shutdown worker-2; sleep 10; virsh start cp-2; virsh start worker-2"
ssh -i "${PHY_SSH_KEY}" "root@${PHY_BOX_3}" "virsh shutdown cp-3; virsh shutdown worker-3; sleep 10; virsh start cp-3; virsh start worker-3"

echo -e "${GREEN}10. Wait for bootstrap to complete${RESET}"
cd "${OKD_INSTALL_DIR}"
./openshift-install --dir "${OKD_INSTALL_DIR}" wait-for bootstrap-complete --log-level=info

# remove bootstrap machine from load balancer

# approve csrs
# oc get csr -o go-template='{{range .items}}{{if not .status}}{{.metadata.name}}{{"\n"}}{{end}}{{end}}' | xargs oc adm certificate approve

# ./openshift-install --dir "${OKD_INSTALL_DIR}" wait-for install-complete 