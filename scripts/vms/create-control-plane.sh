#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail
shopt -s failglob

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <INDEX>"
    exit 1
fi

INDEX=$1

COREOS="coreos.iso"
IGNITION_CONFIG="master.ign"
VM_NAME="cp-${INDEX}"
VCPUS="4"
RAM_MB="18483"
STREAM="stable"
DISK="/dev/fedora/cp-${INDEX}-disk"

# Setup the correct SELinux label to allow access to the config
chcon --verbose --type svirt_home_t "${IGNITION_CONFIG}"

virt-install \
    --connect="qemu:///system" \
    --name="${VM_NAME}" \
    --vcpus="${VCPUS}" \
    --memory="${RAM_MB}" \
    --cdrom "${COREOS}" \
    --disk="${DISK}" \
    --noautoconsole \
    --network bridge=br0 \
    --graphics vnc,listen=0.0.0.0 \
    --os-variant="fedora-coreos-${STREAM}" \
    --qemu-commandline="-fw_cfg name=opt/com.coreos/config,file=${IGNITION_CONFIG}"
