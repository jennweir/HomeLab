# libvirt

## tmux installation to not lose ssh connection when updating to bridged networking configuration

`sudo dnf install tmux`

## Install libvirt and related plugins

<https://docs.fedoraproject.org/en-US/fedora-server/virtualization/installation/#_finishing_cockpit_machines_configuration>

<https://wiki.libvirt.org/Networking.html>

<https://www.reddit.com/r/qemu_kvm/comments/13uc290/vm_on_the_local_network/>

<https://linuxconfig.org/how-to-use-bridged-networking-with-libvirt-and-kvm>

```bash
sudo dnf install qemu-kvm-core libvirt virt-install cockpit-machines guestfs-tools
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
lvcreate -L <#>G -n <disk-name> <volume-group-name>
lvdisplay /dev/<volume-group-name>/<disk-name>
mkfs.ext4 /dev/<volume-group-name>/<disk-name> # format each logical volume before using it
lvs # to view summarized view of logical volumes
vgs # status of your volume groups and their allocated space
```

## Create a vm

```bash
# control plane and bootstrap
IGNITION_CONFIG="<ign-config>"
IMAGE="/var/lib/libvirt/images/<image>"
VM_NAME="<vm>"
VCPUS="<#>"
RAM_MB="<#>"
STREAM="stable"
DISK_NAME="path=/dev/fedora/<lv>"
# For x86 / aarch64,
IGNITION_DEVICE_ARG=(--qemu-commandline="-fw_cfg name=opt/com.coreos/config,file=${IGNITION_CONFIG}")

# Setup the correct SELinux label to allow access to the config
chcon --verbose --type svirt_home_t ${IGNITION_CONFIG}

virt-install --connect="qemu:///system" --name="${VM_NAME}" --vcpus="${VCPUS}" --memory="${RAM_MB}" \
        --os-variant="fedora-coreos-$STREAM" --import --graphics=none \
        --disk="${DISK_NAME}" \
        --network network=br0 "${IGNITION_DEVICE_ARG[@]}"
```

### Create bridged network

```bash
vi br0.xml
cat br0.xml
<network>
  <name>br0</name>
  <bridge name="br0" />
  <forward mode="bridge"/>
</network>
virsh net-define br0.xml
virsh net-start br0
virsh net-autostart br0
virsh net-list
# deactivate default libvirt NAT network using device virbr0
virsh net-undefine virbr0

# configure virtual nic to use this network
sudo brctl addif br0 vnet0
sudo ip link set vnet0 up
virsh domiflist <vm>
```

`journalctl -xe | grep -i libvirt`

## Cockpit Configuration

<https://docs.fedoraproject.org/en-US/fedora-server/virtualization/vm-management-cockpit/>
