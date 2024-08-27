#!/bin/bash
# Script to install terraform on mac machine using brew
set -o errexit # exit on any failure

brew tap hashicorp/tap
brew install hashicorp/tap/terraform
brew update
brew upgrade hashicorp/tap/terraform

terraform -help

# CLI driven workflow
# terraform login # login to create an API key