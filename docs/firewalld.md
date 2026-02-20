# Firewalld

sudo firewall-cmd --permanent --add-service=dhcp
sudo firewall-cmd --permanent --add-port=69/udp

root@box-1:/home/jennifer# sudo firewall-cmd --list-all
FedoraServer (default, active)
  target: default
  ingress-priority: 0
  egress-priority: 0
  icmp-block-inversion: no
  interfaces: br0 eno1
  sources:
  services: cockpit dhcp dhcpv6-client ssh
  ports: 22623/tcp 6443/tcp 80/tcp 443/tcp 69/udp
  protocols: vrrp
  forward: yes
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
