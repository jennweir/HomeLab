#!/bin/bash
# Script to create a GCP Workload Identity Pool and a Workload Identity
set -o errexit # exit on any failure
set -o nounset # exit on undeclared variables
set -o pipefail # return value of all commands in a pipe
set -o xtrace # command tracing

# Set variables
if [ $# -ne 3 ]; then
    echo "Usage: $0 PROJECT_ID PROJECT_NUMBER NAMESPACE"
    exit 1
fi

PROJECT_ID="$1"
PROJECT_NUMBER="$2"
NAMESPACE="$3"

# gcloud iam workload-identity-pools create "k8s-wif-pool" \
#     --location="global" \
#     --display-name="Kubernetes WIF Pool"

gcloud iam workload-identity-pools providers create-oidc "k8s-provider" \
    --location="global" \
    --workload-identity-pool="k8s-wif-pool" \
    --display-name="Kubernetes Provider" \
    --attribute-mapping="attribute.k8s-cluster=oidc.issuer" \
    --issuer-uri="https://kubernetes.default.svc.id.goog"

gcloud iam service-accounts create "cert-manager-sa" \
    --display-name="Service Account for cert-manager"

gcloud projects add-iam-policy-binding "pi-cluster" \
    --member="serviceAccount:cert-manager-sa@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/dns.admin"

gcloud iam service-accounts add-iam-policy-binding "cert-manager-sa@$PROJECT_ID.iam.gserviceaccount.com" \
    --member="principalSet://iam.googleapis.com/projects/YOUR_$PROJECT_NUMBER/locations/global/workloadIdentityPools/k8s-wif-pool/attribute.actor/kubernetes-service-account/$NAMESPACE/cert-manager" \
    --role="roles/iam.workloadIdentityUser"

kubectl annotate serviceaccount \
    cert-manager \
    --namespace $NAMESPACE \
    iam.gke.io/gcp-service-account=cert-manager-sa@$PROJECT_ID.iam.gserviceaccount.com
