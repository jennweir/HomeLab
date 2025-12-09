#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail
shopt -s failglob

export VIP=192.168.0.201
export INTERFACE=eth0
export KVVERSION=v1.0.2

kube_vip() {
    ctr image pull "ghcr.io/kube-vip/kube-vip:$KVVERSION"
    ctr run --rm --net-host "ghcr.io/kube-vip/kube-vip:$KVVERSION" vip /kube-vip "$@"
}

kube_vip manifest pod \
    --interface "${INTERFACE}" \
    --address "${VIP}" \
    --controlplane \
    --services \
    --arp \
    --leaderElection | tee /etc/kubernetes/manifests/kube-vip.yaml
