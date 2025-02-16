# Highly available HAProxy with keepalived

## References

<https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/7/html/load_balancer_administration/index#Load_Balancer_Administration>
<https://www.redhat.com/en/blog/ha-cluster-linux>
<https://www.redhat.com/en/blog/keepalived-basics>

```bash
sudo dnf install haproxy -y
systemctl enable haproxy
# haproxy permissions denied when not running as root
systemctl start haproxy # once config created
sudo dnf install keepalived -y
systemctl enable keepalived
systemctl start keepalived # once config created
```

Enable ports for HAProxy load balancer and keepalived

```bash
sudo firewall-cmd --add-port=22623/tcp --permanent
sudo firewall-cmd --add-port=6443/tcp --permanent
sudo firewall-cmd --add-port=80/tcp --permanent
sudo firewall-cmd --add-port=443/tcp --permanent
sudo firewall-cmd --add-protocol=vrrp --permanent # 112 for vrrp
sudo firewall-cmd --reload
```

And check the ports are listening

```bash
sudo netstat -tulnp | grep 22623
sudo netstat -tulnp | grep 6443
sudo netstat -tulnp | grep 80
sudo netstat -tulnp | grep 443
```

And check connections succeed

```bash
nc -zv keepalived.homelab.jenniferpweir.com 22623
nc -zv keepalived.homelab.jenniferpweir.com 6443
nc -zv keepalived.homelab.jenniferpweir.com 80
nc -zv keepalived.homelab.jenniferpweir.com 443
```

> Running `ip -brief address show` on each machine participating in the keepalived service will show which machine is actively managing the VIP for vrrp from the keepalived service and stopping the keepalived service on the master machine creates successful failover to the backup machine(s) running HAProxy
