# Raspberry Pi Ansible Playbook Guide

## Install k8s on raspberry pi with the deploy-install playbook

### deploy-install-k8s.yaml copies 2 temp files for the install-k8s playbooks and cleanup-install-files.yaml deletes these temporary files once installation is complete. Run this command on machine where HomeLab repo exists (not a pi)

```ansible-playbook -i inventory playbooks/raspberry-pis/deploy-install-k8s.yaml```

### ssh into pi: ssh pi-#@raspberry-pi-#.local

```ansible-playbook /tmp/install-k8s-pt1.yaml```

### Restart pi required to load k8s and re-ssh into pi: ssh pi-#@raspberry-pi-#.local

```ansible-playbook /tmp/install-k8s-pt2.yaml```

### On machine where HomeLab repo exists

```ansible-playbook -i inventory playbooks/raspberry-pis/cleanup-install-files.yaml```

### Restart pi to load changes

## Useful Links

[https://docs.ansible.com/ansible/latest/network/getting_started/first_playbook.html](https://docs.ansible.com/ansible/latest/network/getting_started/first_playbook.html)

[https://docs.ansible.com/ansible/latest/collections/ansible/builtin/copy_module.html](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/copy_module.html)
