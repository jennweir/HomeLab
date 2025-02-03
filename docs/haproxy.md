# HAProxy

Enable ports on HAProxy load balancer

```bash
sudo firewall-cmd --add-port=22623/tcp --permanent
sudo firewall-cmd --add-port=6443/tcp --permanent
sudo firewall-cmd --add-port=80/tcp --permanent
sudo firewall-cmd --add-port=443/tcp --permanent
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
nc -zv helper.homelab.jenniferpweir.com 22623
nc -zv helper.homelab.jenniferpweir.com 6443
nc -zv helper.homelab.jenniferpweir.com 80
nc -zv helper.homelab.jenniferpweir.com 443
```
