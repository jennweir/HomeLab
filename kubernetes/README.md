# Notes

## Verify that your cluster’s DNS resolver (core-dns) is functioning properly by testing DNS resolution within the cluster using busybox

```bash
kubectl run -i --tty --rm dns-test --image=busybox --restart=Never -- nslookup google.com

Server:         10.96.0.10
Address:        10.96.0.10:53

Non-authoritative answer:
Name:   google.com
Address: 2607:f8b0:4009:818::200e

Non-authoritative answer:
Name:   google.com
Address: 142.250.190.14

pod "dns-test" deleted
```
