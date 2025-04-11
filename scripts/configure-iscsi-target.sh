#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail
shopt -s failglob

# configure iscsi target
dnf install targetcli
systemctl start target
systemctl enable target
firewall-cmd --permanent --add-port=3260/tcp
firewall-cmd --reload

targetcli << EOF
backstores/block/
create name=block_backend dev=/dev/sdb
create name=block_backend_nvme dev=/dev/nvme0n1
EOF

ISCSI_TARGET_OUTPUT=$(targetcli <<EOF
cd /iscsi
create
EOF
)

IQN=$(echo "$ISCSI_TARGET_OUTPUT" | grep "Created target" | awk '{print $3}' | tr -d '[:space:]')

targetcli << EOF
cd /iscsi/${IQN}/tpg1
luns/ create /backstores/block/block_backend
luns/ create /backstores/block/block_backend_nvme
EOF
