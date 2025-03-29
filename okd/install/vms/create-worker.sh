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

COREOS="/var/lib/libvirt/images/coreos.iso"
IGNITION_CONFIG="/var/lib/libvirt/images/worker.ign"
VM_NAME="worker-${INDEX}"
VCPUS="2"
RAM_MB="12288"
STREAM="stable"
DISK="/dev/fedora/worker-${INDEX}-disk"

# Setup the correct SELinux label to allow access to the config
chcon --verbose --type svirt_home_t ${IGNITION_CONFIG}

virt-install \
    --connect "qemu:///system" \
    --name "${VM_NAME}" \
    --vcpus "${VCPUS}" \
    --memory "${RAM_MB}" \
    --cdrom "${COREOS}" \
    --disk "${DISK}",format=raw \
    --noautoconsole \
    --network bridge=br0 \
    --graphics vnc \
    --os-variant="fedora-coreos-${STREAM}" \
    --qemu-commandline="-fw_cfg name=opt/com.coreos/config,file=${IGNITION_CONFIG}"

sleep 30 # wait for vm to start before marking it to autostart when host boots

virsh autostart "${VM_NAME}"
