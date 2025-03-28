#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail
shopt -s failglob

COREOS="/var/lib/libvirt/images/coreos.iso"
IGNITION_CONFIG="/var/lib/libvirt/images/bootstrap.ign"
VM_NAME="bootstrap"
VCPUS="4"
RAM_MB="18432"
STREAM="stable"
DISK="/dev/fedora/bootstrap-disk"

# Setup the correct SELinux label to allow access to the config
chcon --verbose --type svirt_home_t ${IGNITION_CONFIG}

# system for when VMs are acting as servers; autostart only works with system and provides root permissions
virt-install \
    --connect "qemu:///system" \
    --name "${VM_NAME}" \
    --vcpus "${VCPUS}" \
    --memory "${RAM_MB}" \
    --cdrom "${COREOS}" \
    --disk "${DISK}",format=raw \
    --noautoconsole \
    --network bridge=br0 \
    --graphics vnc,listen=0.0.0.0 \
    --os-variant="fedora-coreos-${STREAM}" \
    --qemu-commandline="-fw_cfg name=opt/com.coreos/config,file=${IGNITION_CONFIG}"
