#!/bin/bash
set -o errexit # exit on any failure
set -o nounset # exit if undeclared variable is used
set -x print each command before executing it

CUSTOMER_GCP_SERVICE_ACCOUNT=gcp-wif-service-account
CUSTOMER_GCP_PROJECT_ID=pi-cluster-433101
K8S_NAMESPACE=argocd
K8S_SERVICE_ACCOUNT=k8s-wif-service-account
K8S_GCP_PROJECT_NUMBER=494599251997
K8S_WORKLOAD_IDENTITY_POOL=k8s-wif-pool

cat <<EOF > configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: google-creds
  namespace: ${K8S_NAMESPACE}
data:
  credentials_config.json: |
    {
      "credential_source": {
        "file": "/var/run/secrets/kubernetes.io/serviceaccount/token",
        "format": {
          "type": "text"
        }
      },
      "audience": "//iamcredentials.googleapis.com/projects/${K8S_GCP_PROJECT_NUMBER}/locations/global/workloadIdentityPools/${K8S_WORKLOAD_IDENTITY_POOL}/providers/${K8S_SERVICE_ACCOUNT}",
      "service_account_impersonation_url": "https://iamcredentials.googleapis.com/v1/projects/-/serviceAccounts/${K8S_SERVICE_ACCOUNT}:generateAccessToken",
      "type": "external_account",
      "subject_token_type": "urn:ietf:params:oauth:token-type:jwt",
      "token_url": "https://sts.googleapis.com/v1/token"
    }
EOF

kubectl apply -f configmap.yaml