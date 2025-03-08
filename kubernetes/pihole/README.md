# pihole

Mounting secret was not working. Temporary solution is to remove password requirement

```bash
kubectl exec -it pihole-0 -n pihole -- /bin/bash
sudo pihole setpassword
```

Todos:

- Why does pihole GUI randomly become unavailable and require ingress-nginx-controller pod to be restarted
  - seemingly related to clicking around and accessing routes other than /admin
- Fix readiness and liveness probe 403 error (or how to add them when password is removed)
- Fix ability to set password with secret object

## Ref

<https://maxanderson.tech/posts/pi-hole-ha-on-k8s/>
<https://hetzbiz.cloud/2022/03/04/wildcard-dns-in-pihole/>
<https://learn.littlebirdelectronics.com.au/raspberry-pi/pi-hole-for-raspberry-pi-4>

### Notes

Prior to v6.05, could not use GUI to create wildcard DNS entries

```bash
cd /etc/dnsmasq.d
touch 02-my-wildcard-dns.conf # edit this file with below config 
pi@pi-host-1:/etc/dnsmasq.d $ cat 02-my-wildcard-dns.conf
address=/apps.homelab.jenniferpweir.com/<ip-for-application-ingress-lb>
sudo systemctl restart pihole-FTL
```

>Set DNS Server on computer to be pi.hole server IP on local network
On Mac, System Settings > Network > Details for Wifi > DNS > <pi.hole ip address>
