provider "google" {
  # access_token = $(gcloud auth print-access-token) for temporary authentication
  access_token = "ya29.a0AeDClZDjdULkxAmXYG6LU_K-CA0L4l2BjdpfS6lk4KdxApa2pNi5nznHN7xxTsvKQmMlwxZ6z9UGOZNcqxyJpRxdXDXVcxwJPEICy2CL1eag6DomIGTBDVvVe0hqmQ0XIDD6UJCM94GyfciYYfOpxRHiRfe0j9t0PagRSvzKDUzrCCIaCgYKAfESARISFQHGX2MimJQwrfawQjcobuzGBxnWwA0182"
  project = "pi-cluster-433101"
  region  = "us-east1"
}