# external secrets operator

<https://external-secrets.io/main/>
<https://github.com/external-secrets/external-secrets>
<https://raw.githubusercontent.com/external-secrets/external-secrets/v0.18.2/deploy/crds/bundle.yaml>

## okd cluster

```bash
gcloud iam service-accounts keys create credentials.json \
  --iam-account=gsm_accessor@okd-homelab.iam.gserviceaccount.com

kubectl create secret generic gcpsm-secret \
  --from-file=credentials.json=/Users/jenn/Projects/HomeLab/manifests/platform/external-secrets-operator/overlays/okd/credentials.json \
  --namespace=external-secrets-operator
```

## k8s pi cluster

```bash
gcloud iam service-accounts keys create credentials.json \
  --iam-account=gsm-accessor@pi-cluster-433101.iam.gserviceaccount.com

~/Projects/HomeLab/manifests/platform/external-secrets-operator/overlays/pi-cluster % k apply -k . --server-side
# server side since eso crds are too long

kubectl create secret generic gcpsm-secret \
  --from-file=credentials.json=/Users/jenn/Projects/HomeLab/manifests/platform/external-secrets-operator/overlays/pi-cluster/credentials.json \
  --namespace=external-secrets-operator
```

## general helm

```bash
helm repo add external-secrets https://charts.external-secrets.io
helm repo update

helm template helm-chart-0.20.4 external-secrets/external-secrets \
  --version 0.20.4 \
  --namespace external-secrets-operator
```
