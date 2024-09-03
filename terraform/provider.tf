provider "google" {
  # bootstrapping problem: include access_token to set up wif for first time
  # gcloud auth application-default login
  # access_token = $(gcloud auth print-access-token) for temporary authentication
  project = "pi-cluster-433101"
  region  = "us-east1"
}