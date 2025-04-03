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

COREOS="/var/lib/libvirt/images/coreos-master.iso"
VM_NAME="cp-${INDEX}"
VCPUS="4"
RAM_MB="18432"
STREAM="stable"
DISK="/dev/fedora/cp-${INDEX}-disk"

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
    --os-variant="fedora-coreos-${STREAM}"

sleep 30 # wait for vm to start before marking it to autostart when host boots

virsh autostart "${VM_NAME}"
