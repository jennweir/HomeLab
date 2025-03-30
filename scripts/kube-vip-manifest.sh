#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail
shopt -s failglob

# Usage: run on a to-be control plane node after kubeadm init

export VIP=192.168.0.201
export INTERFACE=eth0
# KVVERSION=$(curl -sL https://api.github.com/repos/kube-vip/kube-vip/releases | jq -r ".[0].name")
export KVVERSION=v0.8.9 

# for containerd runtime
alias kube-vip="ctr image pull ghcr.io/kube-vip/kube-vip:$KVVERSION; ctr run --rm --net-host ghcr.io/kube-vip/kube-vip:$KVVERSION vip /kube-vip"

kube-vip manifest pod \
    --interface "${INTERFACE}" \
    --address "${VIP}" \
    --controlplane \
    --services \
    --arp \
    --leaderElection | tee /etc/kubernetes/manifests/kube-vip.yaml