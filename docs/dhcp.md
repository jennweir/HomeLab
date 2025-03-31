# DHCP Server

<https://docs.fedoraproject.org/en-US/fedora/f36/install-guide/advanced/Network_based_Installations/>

```bash
dnf install dhcp-server

```/etc/dhcp/dhcpd.conf
subnet 192.168.0.0 netmask 255.255.255.0 {
interface br0;
authoritative;
default-lease-time 600;
max-lease-time 7200;
ddns-update-style none;

option domain-name-servers 192.168.0.236;
option routers 192.168.0.1;

# PXE Boot options
option bootfile-name "pxelinux.0";
next-server 192.168.0.11;

range 192.168.0.104 192.168.0.114;
}
```

```bash
systemctl start dhcpd
systemctl status dhcpd
journalctl --unit dhcpd --since -2m --follow
```

## Extra info

DHCP Server Configuration file
see /usr/share/doc/dhcp-server/dhcpd.conf.example
see dhcpd.conf(5) man page
