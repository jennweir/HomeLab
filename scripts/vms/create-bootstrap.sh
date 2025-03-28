#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail
shopt -s failglob

COREOS="coreos.iso"
IGNITION_CONFIG="bootstrap.ign"
VM_NAME="bootstrap"
VCPUS="4"
RAM_MB="18483"
STREAM="stable"
DISK="/dev/fedora/bootstrap-disk"

# For x86 / aarch64,
IGNITION_DEVICE_ARG=(--qemu-commandline="-fw_cfg name=opt/com.coreos/config,file=${IGNITION_CONFIG}")

# Setup the correct SELinux label to allow access to the config
chcon --verbose --type svirt_home_t ${IGNITION_CONFIG}

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
