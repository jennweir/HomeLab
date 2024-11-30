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

## Add public OIDC endpoint to kube-apiserver manifests with these flags. ssh into node, then add the following to `/etc/kubernetes/manifests/kube-apiserver.yaml` on master node

```bash
- --service-account-issuer=https://storage.googleapis.com/pi-cluster # name of the storage bucket containing oidc token
- --service-account-jwks-uri=https://storage.googleapis.com/pi-cluster/openid/v1/jwks-cert-manager
```

```bash
kubectl create token -n cert-manager cert-manager | jc --jwt -p

kubectl get --raw /.well-known/openid-configuration | gcloud storage cp --cache-control=no-cache /dev/stdin gs://pi-cluster/.well-known/openid-configuration-cert-manager # gs://pi-cluster is the google storage bucket

kubectl get --raw /openid/v1/jwks | gcloud storage cp --cache-control=no-cache /dev/stdin gs://pi-cluster/openid/v1/jwks-cert-manager
```
