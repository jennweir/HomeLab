# external secrets operator

<https://external-secrets.io/main/>
<https://github.com/external-secrets/external-secrets>
<https://raw.githubusercontent.com/external-secrets/external-secrets/v0.18.2/deploy/crds/bundle.yaml>

```bash
gcloud iam service-accounts keys create credentials.json \
  --iam-account=gsm_accessor@okd-homelab.iam.gserviceaccount.com

kubectl create secret generic gcpsm-secret \
  --from-file=credentials.json=/Users/jenn/Projects/HomeLab/manifests/platform/external-secrets-operator/overlays/okd/credentials.json \
  --namespace=external-secrets-operator

helm repo add external-secrets https://charts.external-secrets.io
helm repo update

helm template helm-chart-0.19.1 external-secrets/external-secrets \
  --version 0.19.1 \
  --namespace external-secrets-operator
```
