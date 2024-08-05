# Raspberry Pi Ansible Playbook Guide

## Install k8s on raspberry pi with the deploy-install playbook

### deploy-install-k8s.yaml copies 2 temp files for the install-k8s playbooks and cleanup-install-files.yaml deletes these temporary files once installation is complete. Run this command on machine where HomeLab repo exists (not a pi)

```ansible-playbook -i inventory playbooks/raspberry-pis/deploy-install-k8s.yaml```

### ssh into pi

```ssh pi-#@raspberry-pi-#.local```

```ansible-playbook /tmp/install-k8s-pt1.yaml```

### Restart pi required to load k8s and re-ssh into pi

```ssh pi-#@raspberry-pi-#.local```

```ansible-playbook /tmp/install-k8s-pt2.yaml```

### On machine where HomeLab repo exists

```ansible-playbook -i inventory playbooks/raspberry-pis/cleanup-install-files.yaml```

### Restart pi to load changes

## All above steps should be completed on every raspberry pi in the cluster. The steps below should then be completed on a single pi that will act as the main

```sudo kubeadm init --pod-network-cidr=10.244.0.0/16```

```mkdir -p $HOME/.kube```

```sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config```

```sudo chown $(id -u):$(id -g) $HOME/.kube/config```

### Add flannel to the cluster

```kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml```

### Add MetalLB to the cluster

```kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.12.1/manifests/namespace.yaml```

```kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.12.1/manifests/metallb.yaml```

### Configure MetalLB

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: metallb-system
  name: config
data:
  config: |
    address-pools:
    - name: default
      protocol: layer2
      addresses:
      - 10.0.0.200-10.0.0.250
---
EOF
```

### Join each worker to main (fill in credentials appropriately)

```bash
sudo kubeadm join local-main-IP:6443 --token token-here \ 
--discovery-token-ca-cert-hash sha256:sha256-value-here
```

### View cluster

```kubectl get nodes -o wide```

## Useful Links

[https://docs.ansible.com/ansible/latest/network/getting_started/first_playbook.html](https://docs.ansible.com/ansible/latest/network/getting_started/first_playbook.html)

[https://docs.ansible.com/ansible/latest/collections/ansible/builtin/copy_module.html](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/copy_module.html)
