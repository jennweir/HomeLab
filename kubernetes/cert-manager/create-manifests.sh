#!/usr/bin/env bash
# CREDIT: https://github.com/dronenb/HomeLab/blob/main/kubernetes/workloads/cert-manager/create_manifests.sh
# Definitely just copied this script for the curl request and splitting the deployments from dronenb/HomeLab
set -o errexit
set -o nounset
set -o pipefail
shopt -s failglob

mkdir -p base
pushd base > /dev/null || exit 1

CERT_MANAGER_VERSION=1.16.1

# Download manifests and separate into separate files
curl -sL "https://github.com/cert-manager/cert-manager/releases/download/v${CERT_MANAGER_VERSION}/cert-manager.yaml" | \
    yq --no-colors --prettyPrint '... comments=""' | \
    kubectl-slice -o . --template "{{ .kind | lower }}.yaml"

# Split the deployment up
kubectl-slice -o . --template "{{ .kind | lower }}-{{ .metadata.name | lower }}.yaml" < deployment.yaml
rm deployment.yaml

kustomize create --autodetect

# Format YAML
prettier . --write
popd > /dev/null || exit 1