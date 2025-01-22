# libvirt

## tmux installation to not lose ssh connection when updating to bridged networking configuration

`sudo dnf install tmux`

## Install libvirt

<https://wiki.libvirt.org/Networking.html>

```bash
sudo dnf install @virtualization
sudo systemctl enable --now libvirtd
sudo systemctl status libvirtd
```

> Installing libvirt creates the interface virbr0 since it is defaultly configured to use NAT forwarding

### Use bridged networking

> Virtual machines get IP addresses directly from the same subnet as host

<https://wiki.libvirt.org/Networking.html#bridged-networking-aka-shared-physical-device>

<https://lukas.zapletalovi.com/posts/2015/fedora-22-libvirt-with-bridge/>

First start tmux session with `tmux`

```bash
dnf install bridge-utils
dnf groupinstall "Virtualization Tools"
export MAIN_CONN=eno1
bash -x <<EOS
systemctl stop libvirtd
nmcli c delete "$MAIN_CONN"
nmcli c delete "Wired connection 1"
nmcli c add type bridge ifname br0 autoconnect yes con-name br0 stp off
nmcli c add type bridge-slave autoconnect yes con-name "$MAIN_CONN" ifname "$MAIN_CONN" master br0
systemctl restart NetworkManager
systemctl start libvirtd
systemctl enable libvirtd
echo "net.ipv4.ip_forward = 1" | sudo tee /etc/sysctl.d/99-ipforward.conf
sysctl -p /etc/sysctl.d/99-ipforward.conf
EOS
```

Check bridge was created successfully with `brctl show`

Additionally, enable stp

```bash
nmcli connection modify br0 bridge.stp yes
nmcli connection down br0 # will lose ssh connection to host
nmcli connection up br0
nmcli connection up eno1
```

## Create logical volume for each vm from available disk space

```bash
vgdisplay
lvcreate -L 100G -n <disk-name> <volume-group-name>
lvdisplay /dev/<volume-group-name>/<disk-name>
mkfs.ext4 /dev/<volume-group-name>/<disk-name> # format each logical volume before using it
lvs # to view summarized view of logical volumes
vgs # status of your volume groups and their allocated space
```

## Create a vm

```bash
virt-install \
  --name=cp-# \
  --vcpus=4 \
  --memory=16384 \
  --location=/var/lib/libvirt/images/fedora-coreos-39.iso \
  --disk path=/dev/<volume-group-name>/<disk-name> \
  --os-variant=fedora-coreos-stable \
  --network bridge=br0,model=virtio \
  --graphics none \
  --console pty,target_type=serial
```

```bash
virt-install \
  --name=bootstrap \
  --vcpus=4 \
  --memory=16384 \
  --cdrom=/var/lib/libvirt/images/fedora-coreos-39.iso \
  --disk path=/dev/fedora/bootstrap-disk \
  --os-variant=fedora-coreos-stable \
  --network bridge=br0,model=virtio \
  --graphics none \
  --console pty,target_type=serial
```

```bash
virt-install \
  --name=worker-# \
  --vcpus=2 \
  --memory=8192 \
  --cdrom=/var/lib/libvirt/images/fedora-coreos-39.iso \
  --disk path=/dev/<volume-group-name>/<disk-name> \
  --os-variant=fedora-coreos-stable \
  --network bridge=br0,model=virtio \
  --graphics none \
  --console pty,target_type=serial
```

```bash
journalctl -f # to see status
virsh list --all
virsh --connect qemu:///system console <vm>
virsh console <vm>
virsh domifaddr <vm>
```
