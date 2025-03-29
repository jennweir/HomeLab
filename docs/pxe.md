# Set up requirements for PXE boot

<https://docs.fedoraproject.org/en-US/fedora/f36/install-guide/advanced/Network_based_Installations/>

## DHCP Server 

See docs/dhcp.md

## TFTP Server

```bash
sudo dnf install tftp-server syslinux
sudo mkdir -p /var/lib/tftpboot/pxelinux.cfg
sudo cp /usr/share/syslinux/{pxelinux.0,menu.c32,vesamenu.c32,ldlinux.c32,libcom32.c32,libutil.c32} /var/lib/tftpboot/
sudo vi /var/lib/tftpboot/pxelinux.cfg/default
systemctl start tftp.socket
systemctl enable tftp.socket
sudo systemctl start tftp.service
sudo systemctl enable tftp.service
sudo systemctl restart tftpd-hpa
```

/var/lib/tftpboot/pxelinux.cfg/default

```conf
# Set the default menu to the first option
default vesamenu.c32
# Set the timeout for the menu
timeout 600
# Enable prompt to select from the menu
prompt 1

# Menu entry to boot from local drive
label local
menu label Boot from ^local drive
menu default
localboot 0xffff

# Menu entry for PXE booting CoreOS Bootstrap
label bootstrap
menu label Boot ^CoreOS Bootstrap
kernel http://webserver.homelab.jenniferpweir.com/kernel.img
append initrd=http://webserver.homelab.jenniferpweir.com/initramfs.img coreos.live.rootfs_url=http://webserver.homelab.jenniferpweir.com/rootfs.img coreos.inst.install_dev=/dev/vda coreos.inst.ignition_url=http://webserver.homelab.jenniferpweir.com/bootstrap.ign

# Menu entry for PXE booting CoreOS Master
label master
menu label Boot ^CoreOS Master
kernel http://webserver.homelab.jenniferpweir.com/kernel.img
append initrd=http://webserver.homelab.jenniferpweir.com/initramfs.img coreos.live.rootfs_url=http://webserver.homelab.jenniferpweir.com/rootfs.img coreos.inst.install_dev=/dev/vda coreos.inst.ignition_url=http://webserver.homelab.jenniferpweir.com/master.ign

# Menu entry for PXE booting CoreOS Worker
label worker
menu label Boot ^CoreOS Worker
kernel http://webserver.homelab.jenniferpweir.com/kernel.img
append initrd=http://webserver.homelab.jenniferpweir.com/initramfs.img coreos.live.rootfs_url=http://webserver.homelab.jenniferpweir.com/rootfs.img coreos.inst.install_dev=/dev/vda coreos.inst.ignition_url=http://webserver.homelab.jenniferpweir.com/worker.ign
```
