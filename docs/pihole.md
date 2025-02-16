# pihole

<https://hetzbiz.cloud/2022/03/04/wildcard-dns-in-pihole/>

```bash
cd /etc/dnsmasq.d
touch 02-my-wildcard-dns.conf # edit this file with below config 
pi@pi-host-1:/etc/dnsmasq.d $ cat 02-my-wildcard-dns.conf
address=/apps.homelab.jenniferpweir.com/<ip-for-application-ingress-lb>
sudo systemctl restart pihole-FTL
```

>Set DNS Server on computer to be pi.hole server IP on local network
On Mac, System Settings > Network > Details for Wifi > DNS > <pi.hole ip address>
