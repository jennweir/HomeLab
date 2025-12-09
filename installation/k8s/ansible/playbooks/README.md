# Raspberry Pi Ansible Playbook Guide

## Install k8s on raspberry pi with the install-k8s playbook

```ansible-playbook -i inventory playbooks/raspberry-pis/install-k8s.yaml```

## Get kubeconfig

`/etc/kubernetes/admin.conf`

## Remove taint on control plane nodes

`kubectl taint nodes --all node-role.kubernetes.io/control-plane-`

## Apply overlays

argocd, metallb, ingress-nginx, kubernetes-dashboard, longhorn, cert-manager, etc.

## Useful Links

[https://docs.ansible.com/ansible/latest/network/getting_started/first_playbook.html](https://docs.ansible.com/ansible/latest/network/getting_started/first_playbook.html)

[https://docs.ansible.com/ansible/latest/collections/ansible/builtin/copy_module.html](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/copy_module.html)
