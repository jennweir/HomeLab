#!/usr/bin/env bash
# CREDIT: https://github.com/dronenb/HomeLab/blob/main/kubernetes/workloads/cert-manager/create_manifests.sh
set -o errexit
set -o nounset
set -o pipefail
shopt -s failglob

mkdir -p base
pushd base > /dev/null || exit 1

MANIFESTURL="<CHANGE-ME>"

# Download manifests and separate into separate files
curl -sL "${MANIFESTURL}" | \
    yq --no-colors --prettyPrint '... comments=""' | \
    kubectl-slice -o . --template "{{ .kind | lower }}.yaml"

# Split the deployment up
kubectl-slice -o . --template "{{ .kind | lower }}-{{ .metadata.name | lower }}.yaml" < deployment.yaml
rm deployment.yaml

kustomize create --autodetect

# Format YAML
prettier . --write
popd > /dev/null || exit 1