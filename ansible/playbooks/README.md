# Raspberry Pi Ansible Playbook Guide

## Install k8s on raspberry pi with the install-k8s playbook

```ansible-playbook -i inventory playbooks/raspberry-pis/install-k8s.yaml```

## Choose main node and initialize with kubeadm. Save the resulting kubeadm join credentials in a secret place

```sudo kubeadm init --pod-network-cidr=10.244.0.0/16```

## Get kubeconfig

```bash
  # mkdir -p $HOME/.kube
  # sudo cp /etc/kubernetes/admin.conf /root/.kube/config

  # - name: Create the .kube directory
  #   ansible.builtin.file:
  #     path: "{{ ansible_env.HOME }}/.kube"
  #     state: directory
  #     mode: '0755'

  # - name: Copy admin.conf to .kube/config
  #   ansible.builtin.command:
  #     cmd: cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  #   become: yes

  # - name: Change ownership of the config file
  #   ansible.builtin.command:
  #     cmd: chown $(id -u):$(id -g) $HOME/.kube/config
  #   become: yes

# sudo systemctl start kubelet
```

## Apply overlays

flannel, argocd, metallb, ingress-nginx, kubernetes-dashboard, longhorn, cert-manager, etc.

## Join each worker to main (fill in credentials appropriately)

```bash
sudo <kubeadm token create --print-join-command>
```

## Useful Links

[https://docs.ansible.com/ansible/latest/network/getting_started/first_playbook.html](https://docs.ansible.com/ansible/latest/network/getting_started/first_playbook.html)

[https://docs.ansible.com/ansible/latest/collections/ansible/builtin/copy_module.html](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/copy_module.html)
