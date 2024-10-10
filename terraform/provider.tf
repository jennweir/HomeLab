provider "google" {
  # include access_token to set up wif
  # gcloud auth login
  # access_token = $(gcloud auth print-access-token) for temporary authentication
  project = "pi-cluster-433101"
  region  = "us-east1"
}