provider "google" {
  # access_token = $(gcloud auth print-access-token) for temporary authentication
  project = "pi-cluster-433101"
  region  = "us-east1"
}