#!/bin/bash
# Script to install Operator Lifecycle Manager (OLM) and operators
set -o errexit # exit on any failure

brew install operator-sdk 
operator-sdk olm install
kubectl create -f https://operatorhub.io/install/argocd-operator.yaml
kubectl get csv -n operators # likely need to rerun to check installation finished successfully