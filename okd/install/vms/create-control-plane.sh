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

VM_NAME="cp-${INDEX}"
VCPUS="4"
RAM_MB="18432"
STREAM="stable"
DISK="/dev/fedora/cp-${INDEX}-disk"

# system for when VMs are acting as servers
virt-install \
    --connect "qemu:///system" \
    --name "${VM_NAME}" \
    --vcpus "${VCPUS}" \
    --memory "${RAM_MB}" \
    --disk "${DISK}",format=raw \
    --noautoconsole \
    --pxe \
    --network bridge=br0 \
    --graphics vnc \
    --os-variant="fedora-coreos-${STREAM}" \
    --boot network

sleep 30 # wait for vm to start before marking it to autostart when host boots

virsh autostart "${VM_NAME}"
