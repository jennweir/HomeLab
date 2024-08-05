# Raspberry Pi Ansible Playbook Guide

## Install k8s on raspberry pi with the install-k8s playbook

```ansible-playbook -i inventory playbooks/raspberry-pis/install-k8s.yaml```

## Main

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
