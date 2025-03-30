# Raspberry Pi Ansible Playbook Guide

## Install k8s on raspberry pi with the install-k8s playbook

```ansible-playbook -i inventory playbooks/raspberry-pis/install-k8s.yaml```

## Initialize with kubeadm

<https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/high-availability/>
<https://kube-vip.io/docs/installation/static/#generating-a-manifest>

`sudo kubeadm init --control-plane-endpoint 192.168.0.201:6443 --pod-network-cidr=10.244.0.0/16 --upload-certs`
where 192.168.0.201 is kube-vip VIP

## Get kubeconfig

`/etc/kubernetes/admin.conf`

## Apply pod network (CNI) and overlays

flannel - pod network (CNI) <https://kubernetes.io/docs/concepts/cluster-administration/addons/>
argocd, metallb, ingress-nginx, kubernetes-dashboard, longhorn, cert-manager, etc.

## Useful Links

[https://docs.ansible.com/ansible/latest/network/getting_started/first_playbook.html](https://docs.ansible.com/ansible/latest/network/getting_started/first_playbook.html)

[https://docs.ansible.com/ansible/latest/collections/ansible/builtin/copy_module.html](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/copy_module.html)
