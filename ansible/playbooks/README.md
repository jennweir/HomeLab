# Raspberry Pi Ansible Playbook Guide

## Install k8s on raspberry pi with the install-k8s playbook

```ansible-playbook -i inventory playbooks/raspberry-pis/install-k8s.yaml```

## Choose main node and initialize with kubeadm. Save the resulting kubeadm join credentials in a secret place

```sudo kubeadm init --pod-network-cidr=10.244.0.0/16```

## Install main node with the install-main playbook

```ansible-playbook -i inventory playbooks/raspberry-pis/install-main.yaml```

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
