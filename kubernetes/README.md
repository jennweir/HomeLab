# Notes

## Inspiration

[Raspberry Pi 4 B 4GB](https://www.microcenter.com/product/637834/raspberry-pi-4-model-b-4gb-ddr4)
[Raspberry Pi 15W Power Supply](https://www.microcenter.com/product/608169/raspberry-pi-4-official-15w-power-supply-us-white)
[MicroSD Card with Adapter 32GB](https://www.meijer.com/shopping/product/sandisk-ultra-plus-microsdhc-uhs-i-card-with-adapter-32gb/61965917455.html)

[https://www.pidramble.com/](https://www.pidramble.com/)
[https://medium.com/karlmax-berlin/how-to-install-kubernetes-on-raspberry-pi-53b4ce300b58](https://medium.com/karlmax-berlin/how-to-install-kubernetes-on-raspberry-pi-53b4ce300b58)
[https://alexsniffin.medium.com/a-guide-to-building-a-kubernetes-cluster-with-raspberry-pis-23fa4938d420](https://alexsniffin.medium.com/a-guide-to-building-a-kubernetes-cluster-with-raspberry-pis-23fa4938d420)
[https://opensource.com/article/20/8/kubernetes-raspberry-pi](https://opensource.com/article/20/8/kubernetes-raspberry-pi)


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

## Debug pod

`kubectl run debug-pod -n cert-manager --image=alpine --restart=Never -- sleep 1d`

`kubectl exec -it debug-pod -n cert-manager -- ls <path>`
