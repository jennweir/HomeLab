# OIDC public endpoint

Add public OIDC endpoint to kube-apiserver manifests with these flags. ssh into node, then add the following to `/etc/kubernetes/manifests/kube-apiserver.yaml` on master node

```bash
- --service-account-issuer=https://storage.googleapis.com/pi-cluster # name of the storage bucket containing oidc token
- --service-account-jwks-uri=https://storage.googleapis.com/pi-cluster/openid/v1/jwks
```

```bash
kubectl create token -n cert-manager cert-manager | jc --jwt -p

kubectl get --raw /.well-known/openid-configuration | gcloud storage cp --cache-control=no-cache /dev/stdin gs://pi-cluster/.well-known/openid-configuration # gs://pi-cluster is the google storage bucket

kubectl get --raw /openid/v1/jwks | gcloud storage cp --cache-control=no-cache /dev/stdin gs://pi-cluster/openid/v1/jwks
```
