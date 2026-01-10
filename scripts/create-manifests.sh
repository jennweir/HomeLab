#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail
shopt -s failglob

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <manifest-url>"
  exit 1
fi

MANIFESTURL="$1"

mkdir -p base
pushd base > /dev/null || exit 1

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
