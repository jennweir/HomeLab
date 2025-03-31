# HomeLab IP tracking

Subnet
192.168.0.0/24

DHCP server in router IP space
192.168.0.2 - 192.168.0.100

pi-host-1   192.168.0.102
pi-host-2   192.168.0.103
pi-host-3   192.168.0.101

Separate DHCP server IP space
192.168.0.

*.apps.okd.jenniferpweir.com
192.168.0.200

k8s cluster kube-vip VIP
192.168.0.201

Metallb k8s pi cluster IP space
192.168.0.235-192.168.0.255
    ingress-nginx ingress controller 192.168.0.235
    pihole DNS server 192.168.0.236
