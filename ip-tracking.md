# HomeLab IP tracking

Subnet
192.168.0.0/24

DHCP server in router IP space
192.168.0.2 - 192.168.0.103

pi-host-1   192.168.0.102
pi-host-2   192.168.0.103
pi-host-3   192.168.0.101

OKD cluster api vip
192.168.0.220

OKD cluster ingress vip
192.168.0.221

k8s cluster kube-vip VIP
192.168.0.201

Metallb okd cluster
192.168.0.225-192.168.0.234

Metallb k8s pi cluster IP space
192.168.0.235-192.168.0.255
    ingress-nginx ingress controller 192.168.0.235
    pihole DNS server 192.168.0.236
