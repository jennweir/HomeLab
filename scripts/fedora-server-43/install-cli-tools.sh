#!/usr/bin/env bash

curl -LO https://github.com/okd-project/okd/releases/download/4.20.0-okd-scos.6/openshift-client-linux-4.20.0-okd-scos.6.tar.gz
tar -xvf openshift-client-linux-4.20.0-okd-scos.6.tar.gz -C /usr/local/bin
chmod +x /usr/local/bin/oc /usr/local/bin/kubectl
curl -LO https://github.com/okd-project/okd/releases/download/4.20.0-okd-scos.6/ccoctl-linux-4.20.0-okd-scos.6.tar.gz
tar -xvzf ccoctl-linux-4.20.0-okd-scos.6.tar.gz -C /usr/local/bin
hash -r

tee /etc/yum.repos.d/google-cloud-sdk.repo <<'EOF'
[google-cloud-cli]
name=Google Cloud CLI
baseurl=https://packages.cloud.google.com/yum/repos/cloud-sdk-el9-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=0
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
       https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

dnf install -y google-cloud-cli

dnf install snapd
systemctl enable --now snapd.service
ln -s /var/lib/snapd/snap /snap
snap install yq
echo 'export PATH=$PATH:/snap/bin' >> ~/.bashrc

